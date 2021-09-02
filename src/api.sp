// Copyright (c) 2021 dreae
// 
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

#include <sourcemod>
#include <ripext>

Handle heartbeat_timer;

void GFLBansAPI_StartHeartbeatTimer() {
    heartbeat_timer = CreateTimer(30.0, Timer_Heartbeat, _, TIMER_REPEAT);
}

void GFLBansAPI_SaveInfraction(int client, int target, const InfractionBlock[] blocks, int total_blocks, int duration, const char[] reason) {

}

void GFLBansAPI_RevokeInfraction(int client, int target, const InfractionBlock[] blocks) {

}

public Action Timer_Heartbeat(Handle timer) {
    
}
