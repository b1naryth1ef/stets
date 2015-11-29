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

        # Stats
        self.kills = 0
        self.deaths = 0
        self.assists = 0
        self.damage_given = 0
        self.damage_taken = 0
        self.headshots = 0
        self.wallbangs = 0

class StatsDelegation(object):
    def __init__(self):
        self.game = GameState()

    def event_player_connect(self, event):
        self.game.players[event.data.userid] = Player(
            event.data.name, event.data.userid, event.data.steamid, event.data.bot)

    def event_player_disconnect(self, event):
        self.game.disconnected.append(self.game.players[event.data.userid])
        del self.game.players[event.data.userid]

    def event_player_death(self, event):
        p1 = self.game.players[event.data.userid]
        p2 = self.game.players[event.data.attacker]

        if event.data.assister:
            p3 = self.game.players[event.data.assister]
            p3.assists += 1

        p1.deaths += 1
        p2.kills += 1
        p2.headshots += int(event.data.headshot)
        p2.wallbangs += int(event.data.penetrated != 0)

    def event_player_hurt(self, event):
        p1 = self.game.players[event.data.userid]
        p2 = self.game.players[event.data.attacker]

        p1.damage_taken += event.data.dmg_health
        p2.damage_given += event.data.dmg_health


    def complete(self):
        for player in self.game.disconnected:
            if player.is_bot: continue
            print "%s" % player.name
            print " kills:     %s" % player.kills
            print " deaths:    %s" % player.deaths
            print " assists:   %s" % player.assists
            print " headshots: %s" % player.headshots
            print " wallbangs: %s" % player.wallbangs
            print " damage:    %s" % player.damage_given

        print self.game.players, self.game.disconnected

