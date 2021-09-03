// Copyright (c) 2021 dreae
// 
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

#if defined _gflbans_utils_include
    #endinput
#endif
#define _gflbans_utils_include

bool GFLBans_ValidClient(int client);
void GFLBans_FormatDuration(int client, int duration, char[] buffer, int max_size);
int GFLBans_GetClientBySteamID(const char[] steamid);
