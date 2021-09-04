// Copyright (c) 2021 dreae
// 
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

#if defined _gflbans_chat_include
    #endinput
#endif
#define _gflbans_chat_include

void GFLBansChat_NotifyAdmin(int client, const char[] format, any ...);
void GFLBansChat_Announce(int client, const char[] format, any ...);
