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
