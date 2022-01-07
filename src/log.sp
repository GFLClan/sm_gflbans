#include <sourcemod>
#include <clientprefs>
#include "includes/log"
#include "includes/utils"

enum struct ClientLogState {
    LogLevel log_level;
}

LogLevel current_log_level = LogLevel_None;
ConVar cvar_log_level;
Cookie log_level_cookie;

ClientLogState client_logs[MAXPLAYERS+1];

void GFLBans_InitLogging() {
    cvar_log_level = CreateConVar("gflbans_log_level", "info", "GFLBans logging level");
    cvar_log_level.AddChangeHook(Cvar_LogLevelChanged);
    RegAdminCmd("sm_gflbans_showlogs", CommandShowLogs, ADMFLAG_RCON);
    log_level_cookie = new Cookie("gflbans_log_level", "", CookieAccess_Private);
}

public Action CommandShowLogs(int client, int args) {
    if (args < 1) {
        ReplyToCommand(client, "Usage sm_gflbans_showlogs <level>");
        return Plugin_Handled;
    }

    char buffer[12];
    GetCmdArgString(buffer, sizeof(buffer));
    TrimString(buffer);
    if (!LogLevelFromString(buffer, LogLevel_Warn, client_logs[client].log_level)) {
        ReplyToCommand(client, "Invalid log level %s", buffer);
    } else {
        SetClientCookie(client, log_level_cookie, buffer);
        ReplyToCommand(client, "Your LogLevel was set to %s", buffer);
    }

    return Plugin_Handled;
}

void GFLBansLogs_OnConfigsLoaded() {
    char val[12];
    cvar_log_level.GetString(val, sizeof(val));
    Cvar_LogLevelChanged(cvar_log_level, "", val);
}

void GFLBansLogs_OnClientDisconnected(int client) {
    client_logs[client].log_level = LogLevel_None;
}

void GFLBansLogs_OnClientCookiesCached(int client) {
    if (CheckCommandAccess(client, "", ADMFLAG_RCON, true)) {
        char buffer[12];
        GetClientCookie(client, log_level_cookie, buffer, sizeof(buffer));
        if (strlen(buffer) == 0) {
            client_logs[client].log_level = LogLevel_Warn;
        } else {
            LogLevelFromString(buffer, LogLevel_Warn, client_logs[client].log_level);
        }
    } else {
        client_logs[client].log_level = LogLevel_None;
    }
}

public void Cvar_LogLevelChanged(ConVar cvar, const char[] old_value, const char[] new_value) {
    if (!LogLevelFromString(new_value, LogLevel_Info, current_log_level)) {
        GFLBans_LogError("gflbans_log_level %s invalid; defaulting to info", new_value);
    }
    GFLBans_LogDebug("Set log level %s", new_value);
}

bool LogLevelFromString(const char[] string, LogLevel def, LogLevel &out) {
    if (StrEqual(string, "debug", false)) {
        out = LogLevel_Debug;
        return true;
    } else if (StrEqual(string, "info", false)) {
        out = LogLevel_Info;
        return true;
    } else if (StrEqual(string, "warn", false)) {
        out = LogLevel_Warn;
        return true;
    } else if (StrEqual(string, "error", false)) {
        out = LogLevel_Error;
        return true;
    } else {
        out = def;
        return false;
    }
}

void LogMsgToClients(const char[] msg, LogLevel level) {
    for (int c = 1; c <= MaxClients; c++) {
        if (GFLBans_ValidClient(c) && client_logs[c].log_level >= level) {
            char buffer[256];
            Format(buffer, sizeof(buffer), "[GFLBans] %s", msg);

            PrintToConsole(c, buffer);
            PrintToChat(c, buffer);
        }
    }
}

void GFLBans_LogDebug(const char[] msg, any ...) {
    if (current_log_level >= LogLevel_Debug) {
        char buffer[512];
        VFormat(buffer, sizeof(buffer), msg, 2);
        Format(buffer, sizeof(buffer), "[Debug] %s", buffer);
        LogMsgToClients(buffer, LogLevel_Debug);
        LogMessage(buffer);
    }
}

void GFLBans_LogInfo(const char[] msg, any ...) {
    if (current_log_level >= LogLevel_Info) {
        char buffer[512];
        VFormat(buffer, sizeof(buffer), msg, 2);
        Format(buffer, sizeof(buffer), "[Info] %s", buffer);
        LogMsgToClients(buffer, LogLevel_Info);
        LogMessage(buffer);
    }
}

void GFLBans_LogWarn(const char[] msg, any ...) {
    if (current_log_level >= LogLevel_Warn) {
        char buffer[512];
        VFormat(buffer, sizeof(buffer), msg, 2);
        Format(buffer, sizeof(buffer), "[Warn] %s", buffer);
        LogMsgToClients(buffer, LogLevel_Warn);
        LogMessage(buffer);
    }
}

void GFLBans_LogError(const char[] msg, any ...) {
    if (current_log_level >= LogLevel_Error) {
        char buffer[512];
        VFormat(buffer, sizeof(buffer), msg, 2);
        Format(buffer, sizeof(buffer), "[Error] %s", buffer);
        LogMsgToClients(buffer, LogLevel_Error);
        LogMessage(buffer);
    }
}
