class GameState(object):
    def __init__(self):
        self.players = {}
        self.disconnected = []

class Player(object):
    def __init__(self, name, userid, steamid, is_bot):
        self.name = name
        self.userid = userid
        self.steamid = steamid
        self.is_bot = is_bot

        self.rounds = []
        self.current = PlayerRound(self)

class PlayerRound(object):
    def __init__(self, player):
        self.player = player

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
        self.game.players[event.data.userid] = Player(
            event.data.name, event.data.userid, event.data.steamid, event.data.bot)

    def event_player_disconnect(self, event):
        self.game.disconnected.append(self.game.players[event.data.userid])
        del self.game.players[event.data.userid]

    def event_round_start(self, event):
        for player in self.game.players.values():
            if player.current:
                player.rounds.append(player.current)
            player.current = PlayerRound(player)

    def event_weapon_fire(self, event):
        p1 = self.game.players[event.data.userid]
        p1.current.shots_fired += 1

    def event_player_death(self, event):
        p1 = self.game.players[event.data.userid]
        p1.current.deaths += 1

        p2 = self.game.players[event.data.attacker]
        p2.current.frags += 1
        p2.current.headshots += int(event.data.headshot)
        p2.current.wallbangs += int(event.data.penetrated != 0)

        if event.data.assister:
            p3 = self.game.players[event.data.assister]
            p3.current.assists += 1

    def event_player_hurt(self, event):
        p1 = self.game.players[event.data.userid]
        p1.current.damage_taken += event.data.dmg_health
        p1.current.shots_hit_with += 1

        if event.data.attacker:
            p2 = self.game.players[event.data.attacker]
            p2.current.damage_given += event.data.dmg_health
            p2.current.shots_hit += 1

    def event_round_end_stats(self, event):
        if event.data.userid not in self.game.players:
            return

        player = self.game.players[event.data.userid]
        player.current.score = event.data.score
        player.current.mvps = event.data.mvps

    def complete(self):
        for player in self.game.disconnected:
            if player.is_bot: continue
            print "%s" % player.name

