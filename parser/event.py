import re

from collections import OrderedDict

EVENTS = {}

class EventData(object):
    pass

class Event(object):
    DATA_RE = re.compile("([0-9]+|\'.+?\')")

    def __init__(self, data):
        self.time_major = int(data[0])
        self.time_minor = int(data[1])
        self.name = data[2].strip()
        self.data = EventData()

        attrs = []
        for item in self.DATA_RE.findall(data[3]):
            if item[0] == "'" and item[-1] == "'":
                attrs.append(item[1:-1])
            else:
                attrs.append(item)

        if self.name not in EVENTS:
            raise Exception("Could not find event `%s`" % self.name)

        for dex, i in enumerate(EVENTS[self.name].items()):
            try:
                setattr(self.data, i[0], i[1](attrs[dex]))
            except IndexError:
                setattr(self.data, i[0], i[1]())

    def timestamp(self):
        return "%s.%s" % (self.time_major, self.time_minor)

def userid(i=None):
    if not i:
        return -1
    elif i not in ('BOT', 'GOTV'):
        return int(i)
    return i

def to_bool(i=None):
    if not i:
        return False
    return bool(int(i))

def add_event(n, *args):
    EVENTS[n] = OrderedDict(args)

add_event("init", ('version', str))

add_event("event_player_death",
        ('userid', userid),
        ('attacker', userid),
        ('assister', userid),
        ('weapon', str),
        ('headshot', to_bool),
        ('penetrated', int))
add_event("event_player_hurt",
        ('userid', userid),
        ('attacker', userid),
        ('health', int),
        ('armor', int),
        ('weapon', str),
        ('dmg_health', int),
        ('dmg_armor', int),
        ('hitgroup', int))
add_event("event_item_purchase",
        ('userid', userid),
        ('team', int),
        ('weapon', str))
add_event("event_bomb_begin_plant",
        ('userid', userid),
        ('site', int))
add_event("event_bomb_abort_plant",
        ('userid', userid),
        ('site', int))
add_event("event_bomb_planted",
        ('userid', userid),
        ('site', int))
add_event("event_bomb_defused",
        ('userid', userid),
        ('site', int))
add_event("event_bomb_exploded",
        ('userid', userid),
        ('site', int))
add_event("event_bomb_dropped",
        ('userid', userid),
        ('site', int))
add_event("event_bomb_pickup",
        ('userid', userid),
        ('site', int))
add_event("event_defuser_drop",
        ('entity', int))
add_event("event_defuser_pickup",
        ('userid', userid),
        ('entity', int))
add_event("event_bomb_begin_defuse",
        ('userid', userid),
        ('haskit', to_bool))
add_event("event_bomb_abort_defuse",
        ('userid', userid))
add_event("event_player_radio",
        ('userid', userid),
        ('slot', int))
add_event("event_weapon_fire",
        ('userid', userid),
        ('weapon', str),
        ('silenced', to_bool))
add_event("event_weapon_fire_empty",
        ('userid', userid),
        ('weapon', str))
add_event("event_weapon_out_of_ammo",
        ('userid', userid),
        ('weapon', str))
add_event("event_weapon_reload",
        ('userid', userid),
        ('weapon', str))
add_event("event_weapon_zoom",
        ('userid', userid),
        ('weapon', str))
add_event("event_item_pickup",
        ('userid', userid),
        ('item', str),
        ('silent', to_bool))
add_event("event_he_detonate",
        ('userid', userid),
        ('entity', int),
        ('x', float),
        ('y', float),
        ('z', float))
add_event("event_flash_detonate",
        ('userid', userid),
        ('entity', int),
        ('x', float),
        ('y', float),
        ('z', float))
add_event("event_smoke_detonate",
        ('userid', userid),
        ('entity', int),
        ('x', float),
        ('y', float),
        ('z', float))
add_event("event_molotov_detonate",
        ('userid', userid),
        ('x', float),
        ('y', float),
        ('z', float))
add_event("event_decoy_detonate",
        ('userid', userid),
        ('entity', int),
        ('x', float),
        ('y', float),
        ('z', float))
add_event("event_player_chat",
        ('teamonly', to_bool),
        ('userid', userid),
        ('msg', str))
add_event("event_player_score",
        ('userid', userid),
        ('kills', int),
        ('deaths', int),
        ('score', int))
add_event("event_player_change_name",
        ('userid', userid),
        ('old_name', str),
        ('new_name', str))
add_event("event_player_connect",
        ('name', str),
        ('index', userid),
        ('userid', userid),
        ('steamid', str),
        ('bot', to_bool))
add_event("event_player_disconnect",
        ('userid', userid),
        ('reason', str),
        ('name', str),
        ('steamid', str),
        ('bot', to_bool))
add_event("event_round_end_stats",
        ('userid', userid),
        ('frags', int),
        ('assists', int),
        ('score', int),
        ('mvps', int))

add_event("event_cs_intermission")
add_event("event_match_end")
add_event("event_round_start")
add_event("event_round_end")

