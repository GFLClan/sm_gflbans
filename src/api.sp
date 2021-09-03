// Copyright (c) 2021 dreae
// 
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

#include <sourcemod>
#include <ripext>
#include "includes/globals"
#include "includes/utils"
#include "includes/infractions"

void GFLBansAPI_StartHeartbeatTimer() {
    CreateTimer(30.0, Timer_Heartbeat, _, TIMER_REPEAT);
}

HTTPRequest Start_HTTPRequest(const char[] api_path) {
    char base_addr[128], server_id[32], server_key[256];
    g_cvar_gflbans_website.GetString(base_addr, sizeof(base_addr));
    g_cvar_gflbans_server_id.GetString(server_id, sizeof(server_id));
    g_cvar_gflbans_server_key.GetString(server_key, sizeof(server_key));
    int len = strlen(base_addr);
    if (len == 0) {
        ThrowError("gflbans_website is not set");
    } else if (base_addr[len - 1] == '/') {
        base_addr[len - 1] = '\0';
    }

    char api_url[256];
    Format(api_url, sizeof(api_url), "%s%s", base_addr, api_path);
    
    HTTPRequest req = new HTTPRequest(api_url);
    req.SetHeader("Authorization", "SERVER %s %s", server_id, server_key);

    return req;
}

JSONObject GetPlayerObj(int client, bool ip = true) {
    char player_id[24];
    GetClientAuthId(client, AuthId_SteamID64, player_id, sizeof(player_id), true);
    JSONObject player_obj = new JSONObject();
    player_obj.SetString("gs_service", "steam");
    player_obj.SetString("gs_id", player_id);
    if (ip) {
        char player_ip[24];
        GetClientIP(client, player_ip, sizeof(player_id), true);
        player_obj.SetString("ip", player_ip);
    }

    return player_obj;
}

JSONArray InfractionsToAPIPunishments(const InfractionBlock[] blocks, int total_blocks) {
    JSONArray array = new JSONArray();
    char name_buff[32];
    for (int c = 0; c < total_blocks; c++) {
        if (GFLBans_PunishmentToString(blocks[c], name_buff, sizeof(name_buff))) {
            array.PushString(name_buff);
        }
    }

    return array;
}

JSONArray GetPlayerList() {
    JSONArray players = new JSONArray();
    for (int c = 1; c < MaxClients; c++) {
        if (IsClientConnected(c) && !IsFakeClient(c)) {
            JSONObject player_obj = GetPlayerObj(c);
            players.Push(player_obj);
            delete player_obj;
        }
    }

    return players;
}

void GFLBansAPI_SaveInfraction(int client, int target, const InfractionBlock[] blocks, int total_blocks, int duration, const char[] reason) {
    HTTPRequest req = Start_HTTPRequest("/api/v1/infractions/");
    JSONObject body = new JSONObject();
    JSONObject player = GetPlayerObj(target);
    JSONArray punishments = InfractionsToAPIPunishments(blocks, total_blocks);
    
    body.Set("player", player);
    if (GFLBans_ValidClient(client)) {
        JSONObject admin_player = GetPlayerObj(client, false);
        JSONObject admin = new JSONObject();
        admin.Set("gs_admin", admin_player);
        body.Set("admin", admin);
        delete admin;
        delete admin_player;
    }

    if (strlen(reason) == 0) {
        body.SetString("reason", "No reason provided");
    } else {
        body.SetString("reason", reason);
    }
    body.Set("punishments", punishments);

    if (duration > 0) {
        body.SetInt("duration", duration * 60);
    }
    
    if (g_cvar_gflbans_global_bans.BoolValue) {
        body.SetString("scope", "global");
    } else {
        body.SetString("scope", "server");
    }

    char buffer[512];
    body.ToString(buffer, sizeof(buffer));
    PrintToServer(buffer);

    req.Post(body, HTTPCallback_SaveInfraction, client);
    
    delete body;
    delete player;
    delete punishments;
}

void GFLBansAPI_RemoveInfraction(int client, int target, const InfractionBlock[] blocks, int total_blocks, const char[] remove_reason) {
    HTTPRequest req = Start_HTTPRequest("/api/v1/infractions/remove");
    JSONObject body = new JSONObject();
    JSONObject player = GetPlayerObj(target);
    JSONArray punishments = InfractionsToAPIPunishments(blocks, total_blocks);
    
    body.Set("player", player);
    if (GFLBans_ValidClient(client)) {
        JSONObject admin_player = GetPlayerObj(client, false);
        JSONObject admin = new JSONObject();
        admin.Set("gs_admin", admin_player);
        body.Set("admin", admin);
        delete admin;
        delete admin_player;
    }

    if (strlen(remove_reason) == 0) {
        body.SetString("remove_reason", "No reason provided");
    } else {
        body.SetString("remove_reason", remove_reason);
    }
    body.Set("restrict_types", punishments);
    body.SetBool("include_other_servers", g_cvar_gflbans_global_bans.BoolValue);
    
    char buffer[512];
    body.ToString(buffer, sizeof(buffer));
    PrintToServer(buffer);

    req.Post(body, HTTPCallback_RemoveInfraction, client);
    
    delete body;
    delete player;
    delete punishments;
}

void GFLBansAPI_CheckClient(int client) {
    HTTPRequest req = Start_HTTPRequest("/api/v1/infractions/check");
    char player_id[24], player_ip[24];
    GetClientAuthId(client, AuthId_SteamID64, player_id, sizeof(player_id), true);
    GetClientIP(client, player_ip, sizeof(player_id), true);
    req.AppendQueryParam("gs_service", "steam");
    req.AppendQueryParam("gs_id", player_id);
    req.AppendQueryParam("ip", player_ip);
    if (g_cvar_gflbans_global_bans.BoolValue) {
        req.AppendQueryParam("include_other_servers", "true");
    } else {
        req.AppendQueryParam("include_other_servers", "false");
    }
    req.Get(HTTPCallback_CheckPlayer, client);
}

void GFLBansAPI_CallAdmin(int client, const char[] reason) {
    HTTPRequest req = Start_HTTPRequest("/api/v1/gs/calladmin");
    JSONObject body = new JSONObject();
    JSONObject player_obj = GetPlayerObj(client, false);
    char name[64];
    GetClientName(client, name, sizeof(name));
    body.Set("caller", player_obj);
    body.SetString("caller_name", name);
    body.SetBool("include_other_servers", g_cvar_gflbans_global_bans.BoolValue);
    body.SetString("message", reason);
    req.Post(body, HTTPCallback_CallAdmin, client);

    delete player_obj;
    delete body;
}

public Action Timer_Heartbeat(Handle timer) {
    GFLBansAPI_DoHeartbeat();
}

void GFLBansAPI_DoHeartbeat() {
    HTTPRequest req = Start_HTTPRequest("/api/v1/gs/heartbeat");
    JSONObject body = new JSONObject();
    JSONArray player_list = GetPlayerList();
    body.SetString("hostname", g_s_server_hostname);
    body.SetInt("max_slots", GetMaxHumanPlayers());
    body.Set("players", player_list);
    body.SetString("operating_system", g_s_server_os);
    body.SetString("mod", g_s_server_mod);
    body.SetString("map", g_s_current_map);
    body.SetBool("locked", g_b_server_locked);
    body.SetBool("include_other_servers", g_cvar_gflbans_global_bans.BoolValue);

    req.Post(body, HTTPCallback_Heartbeat);
    delete body;
    delete player_list;
}

public void HTTPCallback_CallAdmin(HTTPResponse response, any data) {
    int client = view_as<int>(data);
    int status = view_as<int>(response.Status);
    if (status == 200 && GFLBans_ValidClient(client)) {
        // TODO: This
        PrintToServer("Admin called");
    } else if (status != 200) {
        PrintToServer("CallAdmin error %d", status);
        // TODO: Proper logging
    }
}

public void HTTPCallback_CheckPlayer(HTTPResponse response, any data) {
    int client = view_as<int>(data);
    int status = view_as<int>(response.Status);
    if (status == 200 && GFLBans_ValidClient(client)) {
        JSONObject check = view_as<JSONObject>(response.Data);
        HandleCheckObj(client, check);
        delete check;
    } else if (status != 200) {
        PrintToServer("Check error %d", status);
        // TODO: Proper logging
    }
}

public void HTTPCallback_Heartbeat(HTTPResponse response, any _data) {
    int status = view_as<int>(response.Status);
    if (status == 200) {
        JSONArray data = view_as<JSONArray>(response.Data);
        char buffer[512];
        data.ToString(buffer, sizeof(buffer));
        PrintToServer(buffer);
        for (int c = 0; c < data.Length; c++) {
            JSONObject heartbeat_obj = view_as<JSONObject>(data.Get(c));
            JSONObject player = view_as<JSONObject>(heartbeat_obj.Get("player"));
            char service[12];
            player.GetString("gs_service", service, sizeof(service));
            if (StrEqual(service, "steam", false)) {
                char steamid[32];
                player.GetString("gs_id", steamid, sizeof(steamid));
                int client = GFLBans_GetClientBySteamID(steamid);
                if (client) {
                    JSONObject check = view_as<JSONObject>(heartbeat_obj.Get("check"));
                    
                    bool has_punishments = HandleCheckObj(client, check);
                    if (!has_punishments) {
                        GFLBans_ClearPunishments(client);
                    }

                    delete check;
                } else {
                    // TODO: Log error
                }
            }

            delete player;
            delete heartbeat_obj;
        }

        delete data;
    } else {
        PrintToServer("Heartbeat error %d", status);
        // TODO: Log error
    }
}

bool HandleCheckObj(int client, JSONObject check) {
    JSONObjectKeys keys = check.Keys();
                    
    char key_buff[32];
    while (keys.ReadKey(key_buff, sizeof(key_buff))) {
        JSONObject check_item = view_as<JSONObject>(check.Get(key_buff));
        int expires;
        if (check_item.HasKey("expiration")) {
            expires = check_item.GetInt("expiration");
        } else {
            expires = 0;
        }
        delete check_item;

        InfractionBlock block;
        InfractionBlock blocks[Block_None];
        int total_blocks = 0;
        if (GFLBans_StringToPunishment(key_buff, block) && GFLBans_PunishmentExpiresBefore(client, block, expires)) {
            blocks[total_blocks] = block;
            total_blocks++;
            
            InfractionBlock current_block[1];
            current_block[0] = block;

            GFLBans_ApplyPunishments(client, current_block, sizeof(current_block), expires - GetTime());
        }
        GFLBans_ClearOtherPunishments(client, blocks, total_blocks);
    }
    delete keys;
}

public void HTTPCallback_SaveInfraction(HTTPResponse response, any data) {
    int status = view_as<int>(response.Status);
    if (status == 200) {
        // TODO: Handle response
        PrintToServer("Infraction saved");
    } else {
        PrintToServer("Infraction error %d", status);
        // TODO: Log error
    }
}

public void HTTPCallback_RemoveInfraction(HTTPResponse response, any data) {
    int status = view_as<int>(response.Status);
    if (status == 200) {
        // TODO: Handle response
        PrintToServer("Infraction saved");
    } else {
        PrintToServer("Infraction error %d", status);
        // TODO: Log error
    }
}
