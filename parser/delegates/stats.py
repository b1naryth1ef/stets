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
        return sum(map(lambda i: i.frags, self.rounds))

    @property
    def deaths(self):
        return sum(map(lambda i: i.deaths, self.rounds))

    @property
    def assists(self):
        return sum(map(lambda i: i.assists, self.rounds))

    @property
    def score(self):
        return sum(map(lambda i: i.score, self.rounds))

    @property
    def mvps(self):
        return sum(map(lambda i: i.mvps, self.rounds))

class PlayerRound(object):
    def __init__(self, player):
        self.player = player
        self.team = None

        # KDA
        self.frags = 0
        self.deaths = 0
        self.assists = 0

        # Damage
        self.damage_given = 0
        self.damage_taken = 0

        # ETC
        self.headshots = 0
        self.wallbangs = 0
        self.score = 0
        self.mvps = 0

        # Shots fired
        self.shots_fired = 0
        self.shots_hit = 0
        self.shots_hit_with = 0

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
                event.data.steamid,
                event.data.bot)

        self.game.players[event.data.userid] = self.game.users[steamid]

    def event_player_disconnect(self, event):
        del self.game.players[event.data.userid]

    def event_round_start(self, event):
        for player in self.game.players.values():
            player.current = PlayerRound(player)
            player.rounds.append(player.current)

    def event_weapon_fire(self, event):
        p1 = self.game.players[event.data.userid]
        p1.current.shots_fired += 1

    def event_player_team(self, event):
        player = self.game.players[event.data.userid]
        player.team = event.data.new_team

    def event_player_death(self, event):
        p1 = self.game.players[event.data.userid]
        p1.current.deaths += 1

        p2 = self.game.players[event.data.attacker]

        if p2.team != p1.team:
            p2.current.frags += 1
        else:
            p2.current.frags -= 1
        p2.current.headshots += int(event.data.headshot)
        p2.current.wallbangs += int(event.data.penetrated != 0)

        if event.data.assister:
            p3 = self.game.players[event.data.assister]

            if p3.team != p1.team:
                p3.current.assists += 1

    def event_player_hurt(self, event):
        p1 = self.game.players[event.data.userid]
        p1.current.damage_taken += event.data.dmg_health
        p1.current.shots_hit_with += 1

        if event.data.attacker:
            p2 = self.game.players[event.data.attacker]
            p2.current.damage_given += event.data.dmg_health
            p2.current.shots_hit += 1

    def event_round_end(self, event):
        self.game.current = Round()
        self.game.rounds.append(self.game.current)

        for player in self.game.players:
            self.game.current.players[player] = self.game.players[player]

    def event_round_mvp(self, event):
        player = self.game.players[event.data.userid]
        player.current.mvps += 1

    def event_round_end_stats(self, event):
        if event.data.userid not in self.game.players:
            return

        player = self.game.players[event.data.userid]
        player.current.score = event.data.score
        player.current.team = event.data.team

    def complete(self):
        for player in self.game.users.values():
            print player.userid, player.name

    def render(self):
        with open("delegates/content/stats.html", 'r') as f:
            template = Template(f.read())

        return template.render(rounds=self.game.rounds, users=self.game.users.values())
