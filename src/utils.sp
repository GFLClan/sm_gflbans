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

#include <sourcemod>

bool GFLBans_ValidClient(int client) {
    return client >= 1 && client <= MaxClients && IsClientConnected(client) && !IsFakeClient(client);
}

void GFLBans_FormatDuration(int client, int duration, char[] buffer, int max_size) {
    if (duration == 0) {
        Format(buffer, max_size, "%T", "Permanently", client);
    } else if (duration < 90) {
        Format(buffer, max_size, "%T", "Minutes", client, duration);
    } else if (duration < 1440) {
        int hours = RoundFloat(float(duration) / 60.0);
        Format(buffer, max_size, "%T", "Hours", client, hours);
    } else if (duration < 10080) {
        int days = RoundFloat(float(duration) / 1440.0);
        Format(buffer, max_size, "%T", "Days", client, days);
    } else {
        int weeks = RoundFloat(float(duration) / 10080.0);
        Format(buffer, max_size, "%T", "Weeks", client, weeks);
    }
}

int GFLBans_GetClientBySteamID(const char[] steamid) {
    char buffer[32];
    for (int c = 1; c < MaxClients; c++) {
        if (!GFLBans_ValidClient(c)) {
            continue;
        }

        GetClientAuthId(c, AuthId_SteamID64, buffer, sizeof(buffer));
        if (StrEqual(buffer, steamid)) {
            return c;
        }
    }

    return 0;
}
