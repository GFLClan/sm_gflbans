// SM GFLBans
// Copyright (C) 2021 Dreae

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

#pragma semicolon 1
#pragma newdecls required

#include <basecomm>

enum struct PlayerInfractions {
    Handle infraction_timer[Block_None];
    int infraction_expires[Block_None];
    bool call_admin_banned;
}

PlayerInfractions player_infractions[MAXPLAYERS+1];

bool GFLBans_CallAdminBanned(int client) {
    if (!GFLBans_ValidClient(client)) {
        return false;
    } else {
        return player_infractions[client].call_admin_banned;
    }
}

void GFLBans_ApplyPunishment(int client, InfractionBlock block, int duration) {
    GFLBans_LogDebug("Applying infraction %d to %N", block, client);
    
    if (duration > 0) {
        SetupExpirationTimer(client, block, duration);
    }
    if (block == Block_Join) {
        char website[64];
        g_cvar_gflbans_website.GetString(website, sizeof(website));
        KickClient(client, "%t", "You're Banned", website);
    } else if (block == Block_Chat) {
        if (!BaseComm_IsClientGagged(client)) {
            GFLBansChat_Announce(client, "%t", "You've been gagged");
        }
        BaseComm_SetClientGag(client, true);
    } else if (block == Block_Voice) {
        if (!BaseComm_IsClientMuted(client)) {
            GFLBansChat_Announce(client, "%t", "You've been muted");
        }
        BaseComm_SetClientMute(client, true);
    } else if (block == Block_CallAdmin) {
        if (!player_infractions[client].call_admin_banned) {
            GFLBansChat_Announce(client, "%t", "You've been CallAdmin banned");
        }
        player_infractions[client].call_admin_banned = true;
    }
}

void GFLBans_RemovePunishment(int client, InfractionBlock block) {    
    KillExpirationTimer(client, block);
    if (block == Block_Chat) {
        if (BaseComm_IsClientGagged(client)) {
            GFLBansChat_Announce(client, "%t", "You've been ungagged");
        }
        BaseComm_SetClientGag(client, false);
    } else if (block == Block_Voice) {
        if (BaseComm_IsClientMuted(client)) {
            GFLBansChat_Announce(client, "%t", "You've been unmuted");
        }
        BaseComm_SetClientMute(client, false);
    } else if (block == Block_CallAdmin) {
        if (player_infractions[client].call_admin_banned) {
            GFLBansChat_Announce(client, "%t", "You've been CallAdmin unbanned");
        }
        player_infractions[client].call_admin_banned = false;
    }
}

void GFLBans_ApplyPunishments(int client, const InfractionBlock[] blocks, int total_blocks, int duration) {
    if (!GFLBans_ValidClient(client)) {
        return;
    }

    for (int c = 0; c < total_blocks; c++) {
        GFLBans_ApplyPunishment(client, blocks[c], duration);
    }
}

void GFLBans_RemovePunishments(int client, const InfractionBlock[] blocks, int total_blocks) {
    if (!GFLBans_ValidClient(client)) {
        return;
    }

    for (int c = 0; c < total_blocks; c++) {
        GFLBans_RemovePunishment(client, blocks[c]);
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

void GFLBans_ClearPunishments(int client) {
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

void GFLBans_KillPunishmentTimers(int client) {
    int max_blocks = view_as<int>(Block_None);
    for (int c = 0; c < max_blocks; c++) {
        if (player_infractions[client].infraction_timer[c] != INVALID_HANDLE) {
            KillTimer(player_infractions[client].infraction_timer[c], true);
            player_infractions[client].infraction_timer[c] = INVALID_HANDLE;
        }
    }
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
    player_infractions[client].infraction_timer[block] = CreateTimer(float(duration * 60), Timer_ExpireInfraction, data, TIMER_DATA_HNDL_CLOSE);
}

void KillExpirationTimer(int client, InfractionBlock block) {
    if (player_infractions[client].infraction_timer[block] != INVALID_HANDLE) {
        KillTimer(player_infractions[client].infraction_timer[block], true);
        player_infractions[client].infraction_timer[block] = INVALID_HANDLE;
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

    return Plugin_Continue;
}
