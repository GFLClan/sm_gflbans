// Copyright (c) 2021 dreae
// 
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

#if defined _gflbans_infractions_include
    #endinput
#endif
#define _gflbans_infractions_include

enum InfractionBlock {
    Block_Join,
    Block_Chat,
    Block_Voice,
    Block_CallAdmin,
    Block_AdminChat,
    Block_None
}
void GFLBans_ApplyPunishment(int client, InfractionBlock block, int duration);
void GFLBans_RemovePunishment(int client, InfractionBlock block);
void GFLBans_ApplyPunishments(int client, const InfractionBlock[] blocks, int total_blocks, int duration);
void GFLBans_RemovePunishments(int client, const InfractionBlock[] blocks, int total_blocks);
void GFLBans_ClearOtherPunishments(int client, const InfractionBlock[] blocks, int total_blocks);
void GFLBans_ClearPunishments(client);
bool GFLBans_StringToPunishment(const char[] string, InfractionBlock &punishment);
bool GFLBans_PunishmentToString(InfractionBlock punishment, char[] buffer, int max_size);
bool GFLBans_PunishmentExpiresBefore(int client, InfractionBlock block, int expires);
bool GFLBans_CallAdminBanned(int client);
void GFLBans_KillPunishmentTimers(int client);
