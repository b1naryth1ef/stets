#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <pugsetup.inc>

#define PLUGIN_VERSION "0.0.1"

File LOG_FILE;

public Plugin myinfo = {
  name = "stets",
  author = "b1nZy",
  description = "Logs stats to a file that can be parsed later"
};

public void OnPluginStart() {
  LOG_FILE = OpenFile("logs/match.log", "w");
  WriteLine("init '%s'", PLUGIN_VERSION);

  // CS Events
  HookEvent("player_death", Event_PlayerDeath);
  HookEvent("player_hurt", Event_PlayerHurt);
  HookEvent("item_purchase", Event_ItemPurchase);
  HookEvent("bomb_beginplant", Event_BombBeginPlant);
  HookEvent("bomb_abortplant", Event_BombAbortPlant);
  HookEvent("bomb_planted", Event_BombPlanted);
  HookEvent("bomb_defused", Event_BombDefused);
  HookEvent("bomb_exploded", Event_BombExploded);
  HookEvent("bomb_dropped", Event_BombDropped);
  HookEvent("bomb_pickup", Event_BombPickup);
  HookEvent("defuser_dropped", Event_DefuserDropped);
  HookEvent("defuser_pickup", Event_DefuserPickup);
  HookEvent("bomb_begindefuse", Event_BombBeginDefuse);
  HookEvent("bomb_abortdefuse", Event_BombAbortDefuse);
  HookEvent("player_radio", Event_PlayerRadio);
  HookEvent("weapon_fire", Event_WeaponFire);
  HookEvent("weapon_fire_on_empty", Event_WeaponFireEmpty);
  HookEvent("weapon_outofammo", Event_WeaponOutOfAmmo);
  HookEvent("weapon_reload", Event_WeaponReload);
  HookEvent("weapon_zoom", Event_WeaponZoom);
  HookEvent("item_pickup", Event_ItemPickup);
  HookEvent("hegrenade_detonate", Event_HEDetonate);
  HookEvent("flashbang_detonate", Event_FlashDetonate);
  HookEvent("smokegrenade_detonate", Event_SmokeDetonate);
  HookEvent("molotov_detonate", Event_MolotovDetonate);
  HookEvent("decoy_detonate", Event_DecoyDetonate);
  HookEvent("cs_win_panel_match", Event_WinPanelMatch);
  HookEvent("round_start", Event_RoundStart);
  HookEvent("round_end", Event_RoundEnd);

  // Generic Events
  HookEvent("player_chat", Event_PlayerChat);
  HookEvent("player_score", Event_PlayerScore);
  HookEvent("player_changename", Event_PlayerChangeName);
  HookEvent("player_connect", Event_PlayerConnect);
  HookEvent("player_disconnect", Event_PlayerDisconnect);
}

public void OnPluginEnd() {
  LOG_FILE.Close();
}

void WriteLine(const char[] format, any ...) {
//  if (!IsMatchLive()) {
//    return;
//  }

  char buffer[2048];
  VFormat(buffer, sizeof(buffer), format, 2);

  char final[2048];
  Format(final, sizeof(final), "[%i-%i] %s", GetTime(), GetSysTickCount(), buffer);

  LOG_FILE.WriteLine(final);

  // For debugging
  FlushFile(LOG_FILE);
}

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) {
  char weapon[32];
  event.GetString("weapon", weapon, sizeof(weapon));

  WriteLine("event_player_death %i %i %i '%s' %b %i",
    event.GetInt("userid"),
    event.GetInt("attacker"),
    event.GetInt("assister"),
    weapon,
    event.GetBool("headshot"),
    event.GetInt("penetrated"));
}


public Action Event_PlayerHurt(Event event, const char[] name, bool dontBroadcast) {
  char weapon[32];
  event.GetString("weapon", weapon, sizeof(weapon));

  WriteLine("event_player_hurt %i %i %i %i '%s' %i %i %i",
    event.GetInt("userid"),
    event.GetInt("attacker"),
    event.GetInt("health"),
    event.GetInt("armor"),
    weapon,
    event.GetInt("dmg_health"),
    event.GetInt("dmg_armor"),
    event.GetInt("hitgroup"));
}

public Action Event_ItemPurchase(Event event, const char[] name, bool dontBroadcast) {
  char weapon[32];
  event.GetString("weapon", weapon, sizeof(weapon));

  WriteLine("event_item_purchase %i %i %s",
    event.GetInt("userid"),
    event.GetInt("team"),
    weapon);
}

public Action Event_BombBeginPlant(Event event, const char[] name, bool dontBroadcast) {
  WriteLine("event_bomb_begin_plant %i %i",
    event.GetInt("userid"),
    event.GetInt("site"));
}

public Action Event_BombAbortPlant(Event event, const char[] name, bool dontBroadcast) {
  WriteLine("event_bomb_abort_plant %i %i",
    event.GetInt("userid"),
    event.GetInt("site"));
}

public Action Event_BombPlanted(Event event, const char[] name, bool dontBroadcast) {
  WriteLine("event_bomb_planted %i %i",
    event.GetInt("userid"),
    event.GetInt("site"));
}

public Action Event_BombDefused(Event event, const char[] name, bool dontBroadcast) {
  WriteLine("event_bomb_defused %i %i",
    event.GetInt("userid"),
    event.GetInt("site"));
}

public Action Event_BombExploded(Event event, const char[] name, bool dontBroadcast) {
  WriteLine("event_bomb_exploded %i %i",
    event.GetInt("userid"),
    event.GetInt("site"));
}

public Action Event_BombDropped(Event event, const char[] name, bool dontBroadcast) {
  WriteLine("event_bomb_dropped %i %i",
    event.GetInt("userid"),
    event.GetInt("entindex"));
}

public Action Event_BombPickup(Event event, const char[] name, bool dontBroadcast) {
  WriteLine("event_bomb_pickup %i",
    event.GetInt("userid"));
}

public Action Event_DefuserDropped(Event event, const char[] name, bool dontBroadcast) {
  WriteLine("event_defuser_drop %i", event.GetInt("entityid"));
}

public Action Event_DefuserPickup(Event event, const char[] name, bool dontBroadcast) {
  WriteLine("event_defuser_pickup %i %i",
    event.GetInt("userid"),
    event.GetInt("entityid"));
}


public Action Event_CSIntermission(Event event, const char[] name, bool dontBroadcast) {
  WriteLine("event_cs_intermission");
}


public Action Event_BombBeginDefuse(Event event, const char[] name, bool dontBroadcast) {
  WriteLine("event_bomb_begin_defuse %i %b",
    event.GetInt("userid"),
    event.GetBool("haskit"));
}

public Action Event_BombAbortDefuse(Event event, const char[] name, bool dontBroadcast) {
  WriteLine("event_bomb_abort_defuse %i", event.GetInt("userid"));
}

public Action Event_PlayerRadio(Event event, const char[] name, bool dontBroadcast) {
  WriteLine("event_player_radio %i %i",
    event.GetInt("userid"),
    event.GetInt("slot"));
}

public Action Event_WeaponFire(Event event, const char[] name, bool dontBroadcast) {
  char weapon[32];
  event.GetString("weapon", weapon, sizeof(weapon));

  WriteLine("event_weapon_fire %i '%s' %b",
    event.GetInt("userid"),
    weapon,
    event.GetBool("silenced"));
}


public Action Event_WeaponFireEmpty(Event event, const char[] name, bool dontBroadcast) {
  char weapon[32];
  event.GetString("weapon", weapon, sizeof(weapon));
  WriteLine("event_weapon_fire_empty %i '%s'", event.GetInt("userid"), weapon);
}

public Action Event_WeaponOutOfAmmo(Event event, const char[] name, bool dontBroadcast) {
  char weapon[32];
  GetClientWeapon(event.GetInt("userid"), weapon, sizeof(weapon));
  
  WriteLine("event_weapon_out_of_ammo %i '%s'", event.GetInt("userid"), weapon);
}

public Action Event_WeaponReload(Event event, const char[] name, bool dontBroadcast) {
  char weapon[32];
  GetClientWeapon(event.GetInt("userid"), weapon, sizeof(weapon));

  WriteLine("event_weapon_reload %i '%s'", event.GetInt("userid"), weapon);
}

public Action Event_WeaponZoom(Event event, const char[] name, bool dontBroadcast) {
  char weapon[32];
  GetClientWeapon(event.GetInt("userid"), weapon, sizeof(weapon));
  
  WriteLine("event_weapon_zoom %i '%s'", event.GetInt("userid"), weapon);
}

public Action Event_ItemPickup(Event event, const char[] name, bool dontBroadcast) {
  char item[32];
  event.GetString("item", item, sizeof(item));

  WriteLine("event_item_pickup %i '%s' %b",
    event.GetInt("userid"),
    item,
    event.GetBool("silent"));
}

public Action Event_HEDetonate(Event event, const char[] name, bool dontBroadcast) {
  WriteLine("event_he_detonate %i %i %f %f %f",
    event.GetInt("userid"),
    event.GetInt("entityid"),
    event.GetFloat("x"),
    event.GetFloat("y"),
    event.GetFloat("z"));
}

public Action Event_FlashDetonate(Event event, const char[] name, bool dontBroadcast) {
  WriteLine("event_flash_detonate %i %i %f %f %f",
    event.GetInt("userid"),
    event.GetInt("entityid"),
    event.GetFloat("x"),
    event.GetFloat("y"),
    event.GetFloat("z"));
}

public Action Event_SmokeDetonate(Event event, const char[] name, bool dontBroadcast) {
  WriteLine("event_smoke_detonate %i %i %f %f %f",
    event.GetInt("userid"),
    event.GetInt("entityid"),
    event.GetFloat("x"),
    event.GetFloat("y"),
    event.GetFloat("z"));
}

public Action Event_MolotovDetonate(Event event, const char[] name, bool dontBroadcast) {
  WriteLine("event_molotov_detonate %i %f %f %f",
    event.GetInt("userid"),
    event.GetFloat("x"),
    event.GetFloat("y"),
    event.GetFloat("z"));
}

public Action Event_DecoyDetonate(Event event, const char[] name, bool dontBroadcast) {
  WriteLine("event_decoy_detonate %i %i %f %f %f",
    event.GetInt("userid"),
    event.GetInt("entityid"),
    event.GetFloat("x"),
    event.GetFloat("y"),
    event.GetFloat("z"));
}

public Action Event_WinPanelMatch(Event event, const char[] name, bool dontBroadcast) {
  WriteLine("event_match_end");
}

public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast) {
  WriteLine("event_round_start");
}

public Action Event_RoundEnd(Event event, const char[] name, bool dontBroadcast) {
  WriteLine("event_round_end");
}

public Action Event_PlayerChat(Event event, const char[] name, bool dontBroadcast) {
  char msg[1024];
  event.GetString("text", msg, sizeof(msg));

  WriteLine("event_player_chat %b %i '%s'",
    event.GetBool("teamonly"),
    event.GetInt("userid"),
    msg);
}

public Action Event_PlayerScore(Event event, const char[] name, bool dontBroadcast) {
  WriteLine("event_player_score %i %i %i %i",
    event.GetInt("userid"),
    event.GetInt("kills"),
    event.GetInt("deaths"),
    event.GetInt("score"));
}

public Action Event_PlayerChangeName(Event event, const char[] name, bool dontBroadcast) {
  char oldn[64];
  char newn[64];

  event.GetString("oldname", oldn, sizeof(oldn));
  event.GetString("newname", newn, sizeof(newn));

  WriteLine("event_player_change_name %i '%s' '%s'",
    event.GetInt("userid"),
    oldn,
    newn);
}

public Action Event_PlayerConnect(Event event, const char[] name, bool dontBroadcast) {
  char uname[64];
  char steamid[64];

  event.GetString("name", uname, sizeof(uname));
  event.GetString("networkid", steamid, sizeof(steamid));

  WriteLine("event_player_connect '%s' %i %i '%s' %b",
    uname,
    event.GetInt("index"),
    event.GetInt("userid"),
    steamid,
    event.GetBool("bot"));
}

public Action Event_PlayerDisconnect(Event event, const char[] name, bool dontBroadcast) {
  char reason[64];
  char uname[64];
  char steamid[64];

  event.GetString("reason", reason, sizeof(reason));
  event.GetString("name", uname, sizeof(uname));
  event.GetString("networkid", steamid, sizeof(steamid));

  WriteLine("event_player_disconnect %i '%s' '%s' '%s' %b",
    event.GetInt("userid"),
    reason,
    uname,
    steamid,
    event.GetBool("bot"));
}

