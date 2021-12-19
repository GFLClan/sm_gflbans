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

#if defined _gflbans_log_include
    #endinput
#endif
#define _gflbans_log_include

enum LogLevel {
    LogLevel_None,
    LogLevel_Error,
    LogLevel_Warn,
    LogLevel_Info,
    LogLevel_Debug
}

void GFLBans_InitLogging();
void GFLBansLogs_OnConfigsLoaded();
void GFLBansLogs_OnClientDisconnected(int client);
void GFLBansLogs_OnClientCookiesCached(int client);
void GFLBans_LogDebug(const char[] msg, any ...);
void GFLBans_LogInfo(const char[] msg, any ...);
void GFLBans_LogWarn(const char[] msg, any ...);
void GFLBans_LogError(const char[] msg, any ...);
