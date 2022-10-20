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

#pragma semicolon 1
#pragma newdecls required

#if defined _gflbans_globals_include
    #endinput
#endif
#define _gflbans_globals_include


#include <sourcemod>

enum VPNAction {
    VPNAction_Kick,
    VPNAction_Notify
}

ConVar g_cvar_gflbans_website;
ConVar g_cvar_gflbans_global_bans;
ConVar g_cvar_gflbans_server_id;
ConVar g_cvar_gflbans_server_key;
ConVar g_cvar_gflbans_vpn_mode;
ConVar g_cvar_gflbans_allow_cloud_gaming;
ConVar g_cvar_gflbans_calladmin_cooldown;

char g_s_server_os[32];
char g_s_server_mod[12];
char g_s_server_hostname[128];
char g_s_current_map[64];
bool g_b_server_locked;
VPNAction g_vpn_action;

ArrayList g_calladmin_reasons;
int g_i_last_call_admin_time = 0;
int g_i_calladmin_targets[MAXPLAYERS + 1];
bool g_b_calladmin_reason_listen[MAXPLAYERS + 1];