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

#if defined SPCOMP
    #endinput
#endif
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
void GFLBansAPI_VPNCheckClient(int client);
void GFLBansAPI_CallAdmin(int client, const char[] reason);
