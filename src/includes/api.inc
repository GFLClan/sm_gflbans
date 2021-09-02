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
void GFLBansAPI_RevokeInfraction(int client, int target, const InfractionBlock[] blocks, int total_blocks);
