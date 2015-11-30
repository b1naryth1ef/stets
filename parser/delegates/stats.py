from jinja2 import Template

class GameState(object):
    def __init__(self):
        # Persistant steamid -> Player mapping
        self.users = {}

        # Transient state of the currently active players
        self.players = {}
        self.disconnected = []
        self.current = Round()
        self.rounds = [self.current]

class Round(object):
    def __init__(self):
        self.players = {}

class Player(object):
    def __init__(self, name, userid, steamid, is_bot):
        self.name = name
        self.userid = userid
        self.steamid = steamid
        self.is_bot = is_bot
        self.team = None

        self.current = PlayerRound(self)
        self.rounds = [self.current]

    @property
    def frags(self):
        return self.rounds[-1].scoreboard.frags

    @property
    def deaths(self):
        return self.rounds[-1].scoreboard.deaths

    @property
    def assists(self):
        return self.rounds[-1].scoreboard.assists

    @property
    def score(self):
        return self.rounds[-1].scoreboard.score

    @property
    def mvps(self):
        return self.rounds[-1].scoreboard.mvps

class PlayerScoreboard(object):
    def __init__(self, player_round):
        self.player_round = player_round

        self.frags = 0
        self.deaths = 0
        self.assists = 0
        self.score = 0
        self.mvps = 0

    def from_round_end_event(self, event):
        self.frags = event.data.frags
        self.deaths = event.data.deaths
        self.assists = event.data.assists
        self.score = event.data.score
        self.mvps = event.data.mvps

class PlayerRound(object):
    def __init__(self, player):
        self.player = player
        self.team = None
        self.mvp = False

        self.scoreboard = PlayerScoreboard(self)

        # General events
        self.frags = []
        self.deaths = []
        self.assists = []
        self.damage_given = []
        self.damage_taken = []
        self.shots_fired = []

        # Specific events
        self.headshots = []
        self.wallbangs = []

class StatsDelegation(object):
    def __init__(self):
        self.game = GameState()

    def event_player_connect(self, event):
        steamid = event.data.steamid
        if steamid == 'BOT':
            steamid = 'BOT-%s' % event.data.userid

        if steamid not in self.game.users:
            self.game.users[steamid] = Player(
                event.data.name,
                event.data.userid,
                steamid,
                event.data.bot)

        self.game.players[event.data.userid] = self.game.users[steamid]

    def event_player_disconnect(self, event):
        del self.game.players[event.data.userid]

    def event_round_start(self, event):
        pass

    def event_weapon_fire(self, event):
        p1 = self.game.players[event.data.userid]
        p1.current.shots_fired.append(event)

    def event_player_team(self, event):
        if event.data.userid not in self.game.players:
            return
        player = self.game.players[event.data.userid]
        player.team = event.data.new_team

    def event_player_death(self, event):
        p1 = self.game.players[event.data.userid]
        p1.current.deaths.append(event)

        p2 = self.game.players[event.data.attacker]
        p2.current.frags.append(event)

        if event.data.headshot:
            p2.current.headshots.append(event)

        if event.data.penetrated:
            p2.current.wallbangs.append(event)

        if event.data.assister:
            p3 = self.game.players[event.data.assister]
            p3.current.assists.append(event)

    def event_player_hurt(self, event):
        p1 = self.game.players[event.data.userid]
        p1.current.damage_taken.append(event)

        if event.data.attacker:
            p2 = self.game.players[event.data.attacker]
            p2.current.damage_given.append(event)

    def event_round_end(self, event):
        self.game.current = Round()
        self.game.rounds.append(self.game.current)

        for player in self.game.players.values():
            player.current = PlayerRound(player)
            player.rounds.append(player.current)
            self.game.current.players[player.userid] = player.current


    def event_round_mvp(self, event):
        player = self.game.players[event.data.userid]
        player.current.mvp = True

    def event_round_end_stats(self, event):
        if event.data.userid not in self.game.players:
            return

        player = self.game.players[event.data.userid]
        player.current.scoreboard.from_round_end_event(event)
        #= event.data.score
        #player.current.team = event.data.team

    def complete(self):
        for player in self.game.users.values():
            print player.userid, player.name

    def render(self):
        with open("delegates/content/stats.html", 'r') as f:
            template = Template(f.read())

        return template.render(rounds=self.game.rounds, users=self.game.users.values())
