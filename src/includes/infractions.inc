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
    Block_AdminChat
}

void GFLBans_ApplyPunishments(int client, const InfractionBlock[] blocks, int total_blocks);
void GFLBans_RemovePunishments(int client, const InfractionBlock[] blocks, int total_blocks);
void GFLBans_ClearPunishments(int client);
bool GFLBans_StringToPunishment(const char[] string, InfractionBlock &punishment);
