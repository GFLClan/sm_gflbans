// Copyright (c) 2021 Dreae
// 
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

#pragma semicolon 1

#include <sourcemod>
#include <clientprefs>
#include "includes/commands"
#include "includes/globals"
#include "includes/api"
#include "includes/log"

public Plugin myinfo = {
    name = "GFLBans",
    author = "Dreae",
    description = "SourceMod integration with GFL Bans",
    version = "0.0.1", 
    url = "https://gitlab.gflclan.com/Dreae/sm_gflbans"
}

public void OnPluginStart() {
    GFLBans_RegisterCommands();
    GFLBans_InitLogging();
    g_cvar_gflbans_website = CreateConVar("gflbans_website", "", "Base URL for GFL Bans instance");
    g_cvar_gflbans_global_bans = CreateConVar("gflbans_global_bans", "1", "Should this server accept global bans");
    g_cvar_gflbans_server_id = CreateConVar("gflbans_server_id", "", "ID for this server in GFL Bans", FCVAR_PROTECTED);
    g_cvar_gflbans_server_key = CreateConVar("gflbans_server_key", "", "Key for this server in GFL Bans", FCVAR_PROTECTED);

    ConVar cvar_hostname = FindConVar("hostname");
    ConVar cvar_password = FindConVar("sv_password");
    cvar_hostname.AddChangeHook(Cvar_HostnameChanged);
    cvar_password.AddChangeHook(Cvar_PasswordChanged);

    CheckServerMod();
    CheckServerOS();
    GFLBansAPI_StartHeartbeatTimer();

    LoadTranslations("common.phrases");
    LoadTranslations("gflbans.phrases");

    for (int c = 1; c <= MaxClients; c++) {
        if (IsClientAuthorized(c)) {
            OnClientAuthorized(c, "");
        }
        if (AreClientCookiesCached(c)) {
            OnClientCookiesCached(c);
        }
    }
}

public void OnMapStart() {
    GetCurrentMap(g_s_current_map, sizeof(g_s_current_map));
}

public void OnConfigsExecuted() {
    ConVar cvar_hostname = FindConVar("hostname");
    ConVar cvar_password = FindConVar("sv_password");
    
    cvar_hostname.GetString(g_s_server_hostname, sizeof(g_s_server_hostname));

    char buffer[32];
    cvar_password.GetString(buffer, sizeof(buffer));
    if (strlen(buffer) == 0) {
        g_b_server_locked = false;
    } else {
        g_b_server_locked = true;
    }

    GFLBansLogs_OnConfigsLoaded();
    GFLBansAPI_DoHeartbeat();
}

public void OnClientAuthorized(int client, const char[] auth) {
    if (!IsFakeClient(client)) {
        GFLBansAPI_CheckClient(client);
    }
}

public void OnClientPostAdminCheck(int client) {
    if (AreClientCookiesCached(client)) {
        OnClientCookiesCached(client);
    }
}

public void OnClientDisconnect(int client) {
    if (!IsFakeClient(client)) {
        GFLBansLogs_OnClientDisconnected(client);
    }
    GFLBans_KillPunishmentTimers(client);
}

public void OnClientCookiesCached(int client) {
    GFLBansLogs_OnClientCookiesCached(client);
}

public void Cvar_HostnameChanged(ConVar cvar, const char[] old_value, const char[] new_value) {
    Format(g_s_server_hostname, sizeof(g_s_server_hostname), new_value);
}

public void Cvar_PasswordChanged(ConVar cvar, const char[] old_value, const char[] new_value) {
    if (strlen(new_value) == 0) {
        g_b_server_locked = false;
    } else {
        g_b_server_locked = true;
    }
}

void CheckServerMod() {
    if (GetEngineVersion() == Engine_CSGO) {
        Format(g_s_server_mod, sizeof(g_s_server_mod), "csgo");
    } else if (GetEngineVersion() == Engine_CSS) { 
        Format(g_s_server_mod, sizeof(g_s_server_mod), "css"); // The best game
    } else if (GetEngineVersion() == Engine_TF2) { 
        Format(g_s_server_mod, sizeof(g_s_server_mod), "tf");
    } else {
        SetFailState("Incompatible mod");
    }
}

void CheckServerOS() {
    Handle game_data = LoadGameConfigFile("gflbans.games");
    if (game_data == INVALID_HANDLE) {
        // TODO: Log error
        Format(g_s_server_os, sizeof(g_s_server_os), "unknown");
    } else {
        if (GameConfGetOffset(game_data, "CheckOS") == 1) {
            Format(g_s_server_os, sizeof(g_s_server_os), "windows");
        } else {
            Format(g_s_server_os, sizeof(g_s_server_os), "linux");
        }
        delete game_data;
    }
}
