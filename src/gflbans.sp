// Copyright (c) 2021 Dreae
// 
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

#pragma semicolon 1

#include <sourcemod>

#include "includes/commands"

public Plugin myinfo = {
    name = "GFLBans",
    author = "Dreae",
    description = "SourceMod integration with GFL Bans",
    version = "0.0.1", 
    url = "https://gitlab.gflclan.com/Dreae/sm_gflbans"
}

public void OnPluginStart() {
    GFLBans_RegisterCommands();
    g_cvar_gflbans_web = CreateConVar("gflbans_website", "", "Base URL for GFL Bans instance");

    LoadTranslations("common.phrases");
    LoadTranslations("gflbans.phrases");
}
