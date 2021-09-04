// Copyright (c) 2021 dreae
// 
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

#include <sourcemod>

bool GFLBans_ValidClient(int client) {
    return client >= 1 && client <= MaxClients && IsClientConnected(client);
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
