// Copyright (c) 2021 dreae
// 
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

#include <sourcemod>
#include "includes/infractions"
#include "includes/utils"
#include "includes/api"
#include "includes/chat"

void GFLBans_RegisterCommands() {
    AddCommandListener(CommandListener_Gag, "sm_gag");
    AddCommandListener(CommandListener_Mute, "sm_mute");
    AddCommandListener(CommandListener_Silence, "sm_silence");
    AddCommandListener(CommandListener_Ungag, "sm_ungag");
    AddCommandListener(CommandListener_Unmute, "sm_unmute");
    AddCommandListener(CommandListener_Unsilence, "sm_unsilence");
    RegAdminCmd("sm_warn", CommandWarn, ADMFLAG_KICK, "sm_warn <target> <minutes|0> [reason]", "gflbans");
    RegAdminCmd("sm_ban", CommandBan, ADMFLAG_BAN, "sm_ban <target> <minutes|0> [reason]", "gflbans");
    RegAdminCmd("sm_unban", CommandUnban, ADMFLAG_UNBAN, "sm_unban <steamid|ip> [reason]", "gflbans");

    RegConsoleCmd("sm_calladmin", CommandCallAdmin, "Call an admin to the server");
    RegAdminCmd("sm_claim", CommandClaimCallAdmin, ADMFLAG_KICK, "Claim a calladmin call");
    RegAdminCmd("sm_caban", CommandBanCallAdmin, ADMFLAG_KICK, "CallAdmin Ban - sm_caban <target> <minutes|0> [reason]", "gflbans");
}

void AnnounceAction(int client, int target, const char[] translation_str, int duration) {
    char admin[64], targ[64], s_duration[32];
    GetClientName(client, admin, sizeof(admin));
    GetClientName(target, targ, sizeof(targ));
    for (int c = 1; c <= MaxClients; c++) {
        if (IsClientConnected(c) && !IsFakeClient(c)) {
            GFLBans_FormatDuration(c, duration, s_duration, sizeof(s_duration));
            GFLBansChat_Announce(c, "%t", translation_str, admin, targ, s_duration);
        }
    }
}

public Action CommandWarn(int client, int args) {
    int target_list[MAXPLAYERS];
    int target_count = -1;
    char reason[128];
    int time = 0;
    if (!ParseCommandArguments("sm_warn", client, target_list, target_count, reason, sizeof(reason), time)) {
        return Plugin_Handled;
    }

    InfractionBlock blocks[1];
    for (int c = 0; c < target_count; c++) {
        GFLBansAPI_SaveInfraction(client, target_list[c], blocks, 0, time, reason);
        AnnounceAction(client, target_list[c], "Warned", time);
    }

    return Plugin_Handled;
}

public Action CommandBan(int client, int args) {
    int target_list[MAXPLAYERS];
    int target_count = -1;
    char reason[128];
    int time = 0;
    if (!ParseCommandArguments("sm_ban", client, target_list, target_count, reason, sizeof(reason), time)) {
        return Plugin_Handled;
    }

    if (time == 0 && !CheckCommandAccess(client, "", ADMFLAG_UNBAN, false)) {
        ReplyToCommand(client, "%t", "No PermBan Permissions");
        return Plugin_Handled;
    }

    InfractionBlock blocks[] = {Block_Join};
    for (int c = 0; c < target_count; c++) {
        AnnounceAction(client, target_list[c], "Banned", time);
        GFLBansAPI_SaveInfraction(client, target_list[c], blocks, sizeof(blocks), time, reason);
        GFLBans_ApplyPunishments(target_list[c], blocks, sizeof(blocks), time);
    }

    return Plugin_Handled;
}

public Action CommandUnban(int client, int args) {
    return Plugin_Handled;
}

public Action CommandCallAdmin(int client, int args) {
    if (!GFLBans_ValidClient(client)) {
        return Plugin_Handled;
    }

    if (args < 1) {
        ReplyToCommand(client, "%t", "Usage CallAdmin");
        return Plugin_Handled;
    }

    if (GFLBans_CallAdminBanned(client)) {
        ReplyToCommand(client, "%t", "You're CallAdmin banned");
        return Plugin_Handled;
    }

    char reason[256];
    GetCmdArgString(reason, sizeof(reason));
    GFLBansAPI_CallAdmin(client, reason);
    return Plugin_Handled;
}

public Action CommandClaimCallAdmin(int client, int args) {
    if (!GFLBans_ValidClient(client)) {
        return Plugin_Handled;
    }
    GFLBansAPI_ClaimCallAdmin(client);
    return Plugin_Handled;
}

public Action CommandBanCallAdmin(int client, int args) {
    int target_list[MAXPLAYERS];
    int target_count = -1;
    char reason[128];
    int time = 0;
    if (!ParseCommandArguments("sm_caban", client, target_list, target_count, reason, sizeof(reason), time)) {
        return Plugin_Handled;
    }

    InfractionBlock blocks[] = {Block_CallAdmin};
    for (int c = 0; c < target_count; c++) {
        AnnounceAction(client, target_list[c], "CallAdmin Banned", time);
        GFLBansAPI_SaveInfraction(client, target_list[c], blocks, sizeof(blocks), time, reason);
        GFLBans_ApplyPunishments(target_list[c], blocks, sizeof(blocks), time);
    }

    return Plugin_Handled;
}

bool GetCommandTargets(int client, const char[] target_string, int[] target_list, int max_targets, int &target_count) {
    char target_name[MAX_TARGET_LENGTH];
    bool tn_is_ml;
    int result = ProcessTargetString(
        target_string, client, target_list, max_targets, 
        COMMAND_FILTER_CONNECTED | COMMAND_FILTER_NO_BOTS,
        target_name, sizeof(target_name), tn_is_ml);

    if (result < 0) {
        ReplyToTargetError(client, result);
        return false;
    } else if (result == 0) {
        ReplyToTargetError(client, result);
        return false;
    }
    target_count = result;
    return true;
}

bool ParseCommandArguments(const char[] command, int client, int target_list[MAXPLAYERS], int &target_count, char[] reason, int reason_max, int &time) {
    if (GetCmdArgs() < 2) {
        ReplyToCommand(client, "%t", "Infraction Usage", command);
        return false;
    }

    char arguments[256];
    GetCmdArgString(arguments, sizeof(arguments));

    char target[65];
    int len = BreakString(arguments, target, sizeof(target));

    if (!GetCommandTargets(client, target, target_list, MAXPLAYERS, target_count)) {
        return false;
    }

    char s_time[12];
    int next_len = BreakString(arguments[len], s_time, sizeof(s_time));
    time = StringToInt(s_time);
    if (next_len != -1) {
        len += next_len;
    } else {
        len = 0;
        arguments[0] = '\0';
    }
    Format(reason, reason_max, arguments[len]);

    return true;
}

Action HandleChatInfraction(const char[] command, const char[] translation_str, int client, int admin_flags, const InfractionBlock[] blocks, int total_blocks) {
    if (client && !CheckCommandAccess(client, "", admin_flags, true)) {
        return Plugin_Continue;
    }

    int target_list[MAXPLAYERS];
    int target_count = -1;
    char reason[128];
    int time = 0;
    if (!ParseCommandArguments(command, client, target_list, target_count, reason, sizeof(reason), time)) {
        return Plugin_Stop;
    }

    for (int c = 0; c < target_count; c++) {
        GFLBansAPI_SaveInfraction(client, target_list[c], blocks, total_blocks, time, reason);
        GFLBans_ApplyPunishments(target_list[c], blocks, total_blocks, time);
        AnnounceAction(client, target_list[c], translation_str, time);
    }

    return Plugin_Stop;
}

Action HandleRemoveChatInfraction(int client, int admin_flags, const InfractionBlock[] blocks, int total_blocks) {
    if (client && !CheckCommandAccess(client, "", admin_flags, true)) {
        return Plugin_Continue;
    }

    char arguments[256];
    GetCmdArgString(arguments, sizeof(arguments));

    char target[65], reason[128];
    int len = BreakString(arguments, target, sizeof(target));
    if (len == -1) {
        len = 0;
        arguments[0] = '\0';
    }
    Format(reason, sizeof(reason), arguments[len]);

    int target_list[MAXPLAYERS];
    int target_count = -1;
    if (!GetCommandTargets(client, target, target_list, MAXPLAYERS, target_count)) {
        return Plugin_Stop;
    }

    for (int c = 0; c < target_count; c++) {
        GFLBansAPI_RemoveInfraction(client, target_list[c], blocks, total_blocks, reason);
        GFLBans_RemovePunishments(target_list[c], blocks, total_blocks);
    }

    return Plugin_Stop;
}

public Action CommandListener_Gag(int client, const char[] command, int args) {
    InfractionBlock blocks[] = {Block_Chat};
    return HandleChatInfraction(command, "Gagged", client, ADMFLAG_CHAT, blocks, sizeof(blocks));
}

public Action CommandListener_Mute(int client, const char[] command, int args) {
    InfractionBlock blocks[] = {Block_Voice};
    return HandleChatInfraction(command, "Muted", client, ADMFLAG_CHAT, blocks, sizeof(blocks));
}

public Action CommandListener_Silence(int client, const char[] command, int args) {
    InfractionBlock blocks[] = {Block_Chat, Block_Voice};
    return HandleChatInfraction(command, "Silenced", client, ADMFLAG_CHAT, blocks, sizeof(blocks));
}

public Action CommandListener_Ungag(int client, const char[] command, int args) {
    InfractionBlock blocks[] = {Block_Chat};
    return HandleRemoveChatInfraction(client, ADMFLAG_CHAT, blocks, sizeof(blocks));
}

public Action CommandListener_Unmute(int client, const char[] command, int args) {
    InfractionBlock blocks[] = {Block_Voice};
    return HandleRemoveChatInfraction(client, ADMFLAG_CHAT, blocks, sizeof(blocks));
}

public Action CommandListener_Unsilence(int client, const char[] command, int args) {
    InfractionBlock blocks[] = {Block_Chat, Block_Voice};
    return HandleRemoveChatInfraction(client, ADMFLAG_CHAT, blocks, sizeof(blocks));
}
