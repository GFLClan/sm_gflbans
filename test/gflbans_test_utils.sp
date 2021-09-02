// Copyright (c) 2021 Dreae
// 
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

#pragma semicolon 1

#include <sourcemod>
#include <testing>

#include "../src/includes/utils"

public Plugin myinfo = {
    name = "GFLBans Tests - Utils",
    author = "Dreae",
    description = "Part of the SM GFLBans Tests",
    version = "0.0.1", 
    url = "https://gitlab.gflclan.com/Dreae/sm_gflbans"
}

public void OnPluginStart() {
    LoadTranslations("gflbans.phrases");
}

public void OnMapStart() {
    char buffer[35];
    GFLBans_FormatDuration(0, 76, buffer, sizeof(buffer));
    AssertTrue("Formats minutes correctly", StrEqual(buffer, "76 minutes"));
    GFLBans_FormatDuration(0, 186, buffer, sizeof(buffer));
    AssertTrue("Formats hours correctly", StrEqual(buffer, "3 hours"));
    GFLBans_FormatDuration(0, 2890, buffer, sizeof(buffer));
    AssertTrue("Formats days correctly", StrEqual(buffer, "2 days"));
    GFLBans_FormatDuration(0, 32000, buffer, sizeof(buffer));
    AssertTrue("Formats weeks correctly", StrEqual(buffer, "3 weeks"));
}
