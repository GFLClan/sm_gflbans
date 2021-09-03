// Copyright (c) 2021 dreae
// 
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

#include <sourcemod>
#include <basecomm>
#include "includes/infractions"
#include "includes/utils"
#include "includes/api"

void GFLBans_ApplyPunishments(int client, const InfractionBlock[] blocks, int total_blocks) {
    if (!GFLBans_ValidClient(client)) {
        return;
    }

    // TODO: Proper logging
    PrintToServer("Applying infractions to %N", client);

    for (int c = 0; c < total_blocks; c++) {
        if (blocks[c] == Block_Join) {
            char website[64];
            g_cvar_gflbans_website.GetString(website, sizeof(website));
            KickClient(client, "%t", "You're Banned", website);
            break;
        } else if (blocks[c] == Block_Chat) {
            BaseComm_SetClientGag(client, true);
        } else if (blocks[c] == Block_Voice) {
            BaseComm_SetClientMute(client, true);
        }
    }
}

void GFLBans_RemovePunishments(int client, const InfractionBlock[] blocks, int total_blocks) {
    for (int c = 0; c < total_blocks; c++) {
        if (blocks[c] == Block_Chat) {
            BaseComm_SetClientGag(client, false);
            continue;
        } else if (blocks[c] == Block_Voice) {
            BaseComm_SetClientMute(client, false);
            continue;
        }
    }
}

void GFLBans_ClearPunishments(int client) {
    if (BaseComm_IsClientGagged(client)) {
        BaseComm_SetClientGag(client, false);
    }

    if (BaseComm_IsClientMuted(client)) {
        BaseComm_SetClientMute(client, false);
    }
}

bool GFLBans_PunishmentToString(InfractionBlock punishment, char[] buffer, int max_size) {
    if (punishment == Block_Chat) {
        Format(buffer, max_size, "chat_block");
    } else if (punishment == Block_Voice) {
        Format(buffer, max_size, "voice_block");
    } else if (punishment == Block_Join) {
        Format(buffer, max_size, "ban");
    } else if (punishment == Block_CallAdmin) {
        Format(buffer, max_size, "call_admin_block");
    } else if (punishment == Block_AdminChat) {
        Format(buffer, max_size, "admin_chat_block");
    }
}

bool GFLBans_StringToPunishment(const char[] string, InfractionBlock &punishment) {
    if (StrEqual(string, "voice_block")) {
        punishment = Block_Voice;
    } else if (StrEqual(string, "chat_block")) {
        punishment = Block_Chat;
    } else if (StrEqual(string, "ban")) {
        punishment = Block_Join;
    } else if (StrEqual(string, "admin_chat_block")) {
        punishment = Block_AdminChat;
    } else if (StrEqual(string, "call_admin_block")) {
        punishment = Block_CallAdmin;
    } else {
        return false;
    }

    return true;
}
