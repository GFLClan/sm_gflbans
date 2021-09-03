// Copyright (c) 2021 dreae
// 
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

#include <sourcemod>
#include <basecomm>
#include "includes/infractions"
#include "includes/utils"
#include "includes/api"

enum struct PlayerInfractions {
    Handle infraction_timer[Block_None];
    int infraction_expires[Block_None];
}

PlayerInfractions player_infractions[MAXPLAYERS];

void GFLBans_ApplyPunishments(int client, const InfractionBlock[] blocks, int total_blocks, int duration) {
    if (!GFLBans_ValidClient(client)) {
        return;
    }

    // TODO: Proper logging

    for (int c = 0; c < total_blocks; c++) {
        char infraction_str[32];
        GFLBans_PunishmentToString(blocks[c], infraction_str, sizeof(infraction_str));
        PrintToServer("Applying infraction %s to %N", infraction_str, client);

        if (duration > 0) {
            SetupExpirationTimer(client, blocks[c], duration);
        }
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
    if (!GFLBans_ValidClient(client)) {
        return;
    }

    for (int c = 0; c < total_blocks; c++) {
        // TODO: Proper logging
        char infraction_str[32];
        GFLBans_PunishmentToString(blocks[c], infraction_str, sizeof(infraction_str));
        PrintToServer("Removing infraction %s to %N", infraction_str, client);
        
        KillExpirationTimer(client, blocks[c]);
        if (blocks[c] == Block_Chat) {
            BaseComm_SetClientGag(client, false);
            continue;
        } else if (blocks[c] == Block_Voice) {
            BaseComm_SetClientMute(client, false);
            continue;
        }
    }
}

void GFLBans_ClearOtherPunishments(int client, const InfractionBlock[] blocks, int total_blocks) {
    InfractionBlock blocks_to_clear[Block_None];
    int total_blocks_to_clear;
    int max_blocks = view_as<int>(Block_None);
    for (int c = 0; c < max_blocks; c++) {
        bool found = false;
        InfractionBlock b = view_as<InfractionBlock>(c);
        for (int i = 0; i < total_blocks; i++) {
            if (blocks[i] == b) {
                found = true;
                continue;
            } 
        }

        if (!found) {
                blocks_to_clear[total_blocks_to_clear] = b;
                total_blocks_to_clear++;
        }
    }

    GFLBans_RemovePunishments(client, blocks_to_clear, total_blocks_to_clear);
}

void GFLBans_ClearPunishments(client) {
    InfractionBlock blocks_to_clear[Block_None];
    int max_blocks = view_as<int>(Block_None);
    for (int c = 0; c < max_blocks; c++) {
        blocks_to_clear[c] = view_as<InfractionBlock>(c);
    }

    GFLBans_RemovePunishments(client, blocks_to_clear, max_blocks);
}

bool GFLBans_PunishmentExpiresBefore(int client, InfractionBlock block, int expires) {
    if (!GFLBans_ValidClient(client)) {
        return false;
    }

    return !(player_infractions[client].infraction_expires[block] > expires);
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
    return true;
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

void SetupExpirationTimer(int client, InfractionBlock block, int duration) {
    int expires = GetTime() + duration;
    if (player_infractions[client].infraction_expires[block] > expires) {
        return;
    }

    if (player_infractions[client].infraction_timer[block] != INVALID_HANDLE) {
        KillTimer(player_infractions[client].infraction_timer[block], true);
    }
    DataPack data = new DataPack();
    data.WriteCell(client);
    data.WriteCell(block);
    data.Reset();
    player_infractions[client].infraction_timer[block] = CreateTimer(float(duration * 60), Timer_ExpireInfraction, data);
}

void KillExpirationTimer(int client, InfractionBlock block) {
    if (player_infractions[client].infraction_timer[block] != INVALID_HANDLE) {
        KillTimer(player_infractions[client].infraction_timer[block], true);
    }
}

Action Timer_ExpireInfraction(Handle timer, any data) {
    DataPack dp = view_as<DataPack>(data);
    int client = dp.ReadCell();
    InfractionBlock infraction = view_as<InfractionBlock>(dp.ReadCell());

    InfractionBlock infractions[1];
    infractions[0] = infraction;

    GFLBans_RemovePunishments(client, infractions, 1);
    player_infractions[client].infraction_timer[infraction] = INVALID_HANDLE;
}
