// Copyright (c) 2021 dreae
// 
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

#if defined _gflbans_chat_include
    #endinput
#endif
#define _gflbans_chat_include

#include "infractions"

void GFLBansChat_AnnounceAction(int client, int target, const InfractionBlock[] blocks, int total_blocks, int duration);
void GFLBansChat_NotifyAdmins(const char[] format, any ...);
void GFLBansChat_NotifyAdmin(int client, const char[] format, any ...);
void GFLBansChat_Announce(int client, const char[] format, any ...);
