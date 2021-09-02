// Copyright (c) 2021 dreae
// 
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

#include <sourcemod>
#include <basecomm>
#include "includes/infractions"
#include "includes/utils"
#include "includes/api"

void GFLBans_ApplyInfraction(int client, int target, const InfractionBlock[] blocks, int total_blocks, int duration, const char[] reason) {
    if (!GFLBans_ValidClient(target)) {
        return;
    }

    bool kick = false;
    for (int c = 0; c < total_blocks; c++) {
        if (blocks[c] == Block_Chat) {
            BaseComm_SetClientGag(target, true);
            continue;
        } else if (blocks[c] == Block_Voice) {
            BaseComm_SetClientMute(target, true);
            continue;
        } else if (blocks[c] == Block_Join) {
            kick = true;
        }
    }

    GFLBansAPI_SaveInfraction(client, target, blocks, total_blocks, duration, reason);
    if (kick) {
        char website[64];
        g_cvar_gflbans_web.GetString(website, sizeof(website));
        KickClient(target, "%t", "You're Banned", website);
    }
}

void GFLBans_RevertInfraction(int client, int target, const InfractionBlock[] blocks, int total_blocks) {
    if (!GFLBans_ValidClient(target)) {
        return;
    }

    for (int c = 0; c < total_blocks; c++) {

    }
}
