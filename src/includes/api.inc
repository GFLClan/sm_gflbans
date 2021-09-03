// Copyright (c) 2021 dreae
// 
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

#if defined _gflbans_api_include
    #endinput
#endif
#define _gflbans_api_include

#include "infractions"

void GFLBansAPI_SaveInfraction(int client, int target, const InfractionBlock[] blocks, int total_blocks, int duration, const char[] reason);
void GFLBansAPI_RemoveInfraction(int client, int target, const InfractionBlock[] blocks, int total_blocks, const char[] remove_reason);
void GFLBansAPI_StartHeartbeatTimer();
void GFLBansAPI_DoHeartbeat();
void GFLBansAPI_CheckClient(int client);
void GFLBansAPI_CallAdmin(int client, const char[] reason);
