// Copyright (c) 2021 dreae
// 
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

#include <sourcemod>
#include <ripext>

Handle heartbeat_timer;

void GFLBansAPI_StartHeartbeatTimer() {
    heartbeat_timer = CreateTimer(30.0, Timer_Heartbeat, _, TIMER_REPEAT);
}

HTTPRequest Start_HTTPRequest(const char[] api_path) {
    
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
    for (int c = 0; c < total_blocks; c++) {
        if (blocks[c] == Block_Chat) {
            array.PushString("chat_block");
        } else if (blocks[c] == Block_Voice) {
            array.PushString("voice_block");
        } else if (blocks[c] == Block_Join) {
            array.PushString("ban");
        } else if (blocks[c] == Block_CallAdmin) {
            array.PushString("call_admin_block");
        } else if (blocks[c] == Block_AdminChat) {
            array.PushString("admin_chat_block");
        }
    }

    return array;
}

void GFLBansAPI_SaveInfraction(int client, int target, const InfractionBlock[] blocks, int total_blocks, int duration, const char[] reason) {
    HTTPRequest req = Start_HTTPRequest("/api/v1/infractions/");
    JSONObject body = new JSONObject();
    JSONObject player = GetPlayerObj(target);
    JSONObject admin = GetPlayerObj(client, false);
    body.SetString("reason", reason);
    body.Set("punishments", InfractionsToAPIPunishments(blocks, total_blocks));
    body.SetInt("duration", duration);
    body.SetString("scope", "server"); // TODO: Read from cvar
}

void GFLBansAPI_RevokeInfraction(int client, int target, const InfractionBlock[] blocks) {

}

public Action Timer_Heartbeat(Handle timer) {
    
}
