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

void GFLBans_ApplyInfraction(int client, int target, const InfractionBlock[] blocks, int total_blocks, int duration, const char[] reason);
void GFLBans_RevertInfraction(int client, int target, const InfractionBlock[] blocks, int total_blocks);
