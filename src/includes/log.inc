// Copyright (c) 2021 dreae
// 
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

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

#if defined SPCOMP
    #endinput
#endif
void GFLBans_InitLogging();
void GFLBansLogs_OnConfigsLoaded();
void GFLBansLogs_OnClientDisconnected(int client);
void GFLBansLogs_OnClientCookiesCached(int client);
void GFLBans_LogDebug(const char[] msg, any ...);
void GFLBans_LogInfo(const char[] msg, any ...);
void GFLBans_LogWarn(const char[] msg, any ...);
void GFLBans_LogError(const char[] msg, any ...);
