// Copyright (c) 2021 dreae
// 
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT
#if defined _gflbans_globals_include
    #endinput
#endif
#define _gflbans_globals_include


#include <sourcemod>

ConVar g_cvar_gflbans_website;
ConVar g_cvar_gflbans_global_bans;
ConVar g_cvar_gflbans_server_id;
ConVar g_cvar_gflbans_server_key;

char g_s_server_os[32];
char g_s_server_mod[12];
char g_s_server_hostname[128];
char g_s_current_map[64];
bool g_b_server_locked;
