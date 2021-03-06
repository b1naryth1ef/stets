#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>

#define PLUGIN_VERSION "0.0.1"
#define FORMAT_VERSION "0.0.2"

File LOG_FILE;

ConVar mp_restartgame;

public Plugin myinfo = {
  name = "stets",
  author = "b1nZy",
  description = "Logs stats to a file that can be parsed later"
};

void NewMatchLog() {
  // If we have a log file open, close it
  if (LOG_FILE) {
    LOG_FILE.Close();
  }

  // Format the timestamp for this logfile
  char timeStamp[32];
  FormatTime(timeStamp, sizeof(timeStamp), "%S_%M_%H_%d_%m_%y");

  // Format the file name for this logfile
  char fileName[128];
  Format(fileName, sizeof(fileName), "logs/stets-match-%s.log", timeStamp);

  // Open the file
  LOG_FILE = OpenFile(fileName, "w");

  // Log the init message, aka the header
  WriteLine("init %i '%s' '%s' '%s'", GetTime(), PLUGIN_VERSION, FORMAT_VERSION, fileName);
}

public void OnPluginStart() {
  // Spawn flush timer
  CreateTimer(2.0, Timer_FlushLogFile, _, TIMER_REPEAT);

  // Create inital file
  NewMatchLog();

  // Hook CVars
  mp_restartgame = FindConVar("mp_restartgame");
  if (mp_restartgame != null) {
    mp_restartgame.AddChangeHook(OnRestartGameChange);
  }

  // Commands
  AddCommandListener(OnPlayerChat, "say");
  AddCommandListener(OnPlayerChatTeam, "say_team");

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
  HookEvent("round_mvp", Event_RoundMvp);
  HookEvent("player_blind", Event_PlayerBlind);
  HookEvent("player_falldamage", Event_PlayerFallDamage);
  HookEvent("inspect_weapon", Event_InspectWeapon);

  // Generic Events
  HookEvent("player_score", Event_PlayerScore);
  HookEvent("player_changename", Event_PlayerChangeName);
  HookEvent("player_connect", Event_PlayerConnect);
  HookEvent("player_disconnect", Event_PlayerDisconnect);
  HookEvent("player_team", Event_PlayerTeam);
  HookEvent("team_info", Event_TeamInfo);
  HookEvent("team_score", Event_TeamScore);
}

public void OnPluginEnd() {
  LOG_FILE.Close();
}

public OnClientPostAdminCheck(client) {
  SDKHook(client, SDKHook_WeaponDrop, Hook_WeaponDrop);
}

public Action Timer_FlushLogFile(Handle timer) {
  if (LOG_FILE != null) {
    FlushFile(LOG_FILE);
  }

  return Plugin_Continue;
}

public void OnRestartGameChange(ConVar convar, char[] oldValue, char[] newValue) {
  WriteLine("event_mp_restartgame '%s' '%s'", oldValue, newValue);
}

void WriteLine(const char[] format, any ...) {
  char buffer[2048];
  VFormat(buffer, sizeof(buffer), format, 2);

  char final[2048];
  Format(final, sizeof(final), "[%i] %s", GetGameTime(), buffer);

  LOG_FILE.WriteLine(final);
}


public Action OnPlayerChat(client, const char[] command, args) {
  char message[256];
  GetCmdArg(1, message, sizeof(message));
  WriteLine("event_player_chat %i '%s'", client, message);
  return Plugin_Continue;
}

public Action OnPlayerChatTeam(client, const char[] command, args) {
  char message[256];
  GetCmdArg(1, message, sizeof(message));
  WriteLine("event_player_chat_team %i '%s'", client, message);
  return Plugin_Continue;
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

  WriteLine("event_item_purchase %i %i '%s'",
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
  WriteLine("event_cs_intermission %i", GetTime());
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
  GetClientWeapon(GetClientOfUserId(event.GetInt("userid")), weapon, sizeof(weapon));

  WriteLine("event_weapon_out_of_ammo %i '%s'", event.GetInt("userid"), weapon);
}

public Action Event_WeaponReload(Event event, const char[] name, bool dontBroadcast) {
  // Valve sucks at programming, bots will spam reload sometimes and this ruins our logs
  if (IsFakeClient(GetClientOfUserId(event.GetInt("userid")))) {
    return;
  }

  char weapon[32];
  GetClientWeapon(GetClientOfUserId(event.GetInt("userid")), weapon, sizeof(weapon));

  WriteLine("event_weapon_reload %i '%s'", event.GetInt("userid"), weapon);
}

public Action Event_WeaponZoom(Event event, const char[] name, bool dontBroadcast) {
  char weapon[32];
  GetClientWeapon(GetClientOfUserId(event.GetInt("userid")), weapon, sizeof(weapon));

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
  WriteLine("event_match_end %i", GetTime());
}

public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast) {
  WriteLine("event_round_start %i", GetTime());
}

public Action Event_RoundEnd(Event event, const char[] name, bool dontBroadcast) {
  WriteLine("event_round_end %i", GetTime());

  char buff[256];

  for (new i = 1; i < MAXPLAYERS; i++) {
    if (IsClientInGame(i)) {
      GetClientName(i, buff, sizeof(buff));
      WriteLine("event_round_end_stats %i %i %i %i %i %i %i '%s'",
        GetClientUserId(i),
        GetClientFrags(i),
        CS_GetClientAssists(i),
        GetClientDeaths(i),
        CS_GetClientContributionScore(i),
        CS_GetMVPCount(i),
        GetClientTeam(i),
        buff
      );

    }
  }
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

public Action Event_RoundMvp(Event event, const char[] name, bool dontBroadcast) {
  WriteLine("event_round_mvp %i %i",
    event.GetInt("userid"),
    event.GetInt("reason"));
}

public Action Event_PlayerFallDamage(Event event, const char[] name, bool dontBroadcast) {
  WriteLine("event_player_fall_damage %i %i",
    event.GetInt("userid"),
    event.GetInt("damage"));
}

public Action Event_PlayerBlind(Event event, const char[] name, bool dontBroadcast) {
  WriteLine("event_player_blind %i", event.GetInt("userid"));
}

public Action Event_InspectWeapon(Event event, const char[] name, bool dontBroadcast) {
  WriteLine("event_inspect_weapon %i", event.GetInt("userid"));
}

public Action Event_TeamInfo(Event event, const char[] name, bool dontBroadcast) {
  char teamName[256];
  event.GetString("teamname", teamName, sizeof(teamName));

  WriteLine("event_team_info %i '%s'",
    event.GetInt("teamid"),
    teamName);
}

public Action Event_TeamScore(Event event, const char[] name, bool dontBroadcast) {
  WriteLine("event_team_score %i %i",
    event.GetInt("teamid"),
    event.GetInt("score"));
}

public Action Event_PlayerTeam(Event event, const char[] name, bool dontBroadcast) {
  WriteLine("event_player_team %i %i %i",
    event.GetInt("userid"),
    event.GetInt("team"),
    event.GetInt("oldteam"));
}

public Action Hook_WeaponDrop(client, weapon) {
  if (weapon == -1) {
    return;
  }

  char weaponName[32];
  GetEntityClassname(weapon, weaponName, sizeof(weaponName));
  WriteLine("event_weapon_drop %i '%s'", client, weaponName);
}
