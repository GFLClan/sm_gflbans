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

void GFLBans_RegisterCommands() {
    AddCommandListener(CommandListener_Gag, "sm_gag");
    AddCommandListener(CommandListener_Mute, "sm_mute");
    AddCommandListener(CommandListener_Silence, "sm_silence");
    AddCommandListener(CommandListener_Ungag, "sm_ungag");
    AddCommandListener(CommandListener_Unmute, "sm_unmute");
    AddCommandListener(CommandListener_Unsilence, "sm_unsilence");
    RegAdminCmd("sm_gbabort", CommandAbort, ADMFLAG_KICK, "Aborts applying a menu punishment", "gflbans");
    RegAdminCmd("sm_warn", CommandWarn, ADMFLAG_KICK, "sm_warn <target> <minutes|0> [reason]", "gflbans");
    RegAdminCmd("sm_ban", CommandBan, ADMFLAG_BAN, "sm_ban <target> <minutes|0> [reason]", "gflbans");

    RegConsoleCmd("sm_calladmin", CommandCallAdmin, "sm_calladmin - Call an admin to the server");
    RegConsoleCmd("sm_report", CommandCallAdmin, "sm_report - Call an admin to the server");
    RegAdminCmd("sm_claim", CommandClaimCallAdmin, ADMFLAG_KICK, "Claim a calladmin call");
    RegAdminCmd("sm_caban", CommandBanCallAdmin, ADMFLAG_KICK, "CallAdmin Ban - sm_caban <target> <minutes|0> [reason]", "gflbans");
}

Action CallAdmin_OnClientSayCommand(int client, const char[] args)
{
    if (!g_b_calladmin_reason_listen[client])
        return Plugin_Continue;

    if (StrEqual(args, "cancel", false))
        PrintToChat(client, "%t", "CallAdmin Cancelled");
    else
        BuildMenu_CallAdminConfirm(client, args);

    g_b_calladmin_reason_listen[client] = false;
    return Plugin_Stop;
}

public Action CommandWarn(int client, int args) {
    int target_list[MAXPLAYERS+1];
    int target_count = -1;
    char reason[281];
    int time = 0;
    if (!ParseCommandArguments("sm_warn", client, target_list, target_count, reason, sizeof(reason), time)) {
        return Plugin_Handled;
    }

    InfractionBlock blocks[1];
    for (int c = 0; c < target_count; c++) {
        GFLBansAPI_SaveInfraction(client, target_list[c], blocks, 0, time, reason);
        GFLBansChat_AnnounceAction(client, target_list[c], blocks, 0, time);
    }

    return Plugin_Handled;
}

public Action CommandAbort(int client, int args) {
    GFLBansAM_Abort(client);
    return Plugin_Handled;
}

public Action CommandBan(int client, int args) {
    int target_list[MAXPLAYERS+1];
    int target_count = -1;
    char reason[281];
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
        GFLBansChat_AnnounceAction(client, target_list[c], blocks, sizeof(blocks), time);
        GFLBansAPI_SaveInfraction(client, target_list[c], blocks, sizeof(blocks), time, reason);
        GFLBans_ApplyPunishments(target_list[c], blocks, sizeof(blocks), time);
    }

    return Plugin_Handled;
}

public Action CommandCallAdmin(int client, int args) {
    if (!GFLBans_ValidClient(client))
        return Plugin_Handled;

    if (GFLBans_CallAdminBanned(client))
    {
        ReplyToCommand(client, "%t", "You're CallAdmin banned");
        return Plugin_Handled;
    }

    int remaining_cooldown = g_i_last_call_admin_time + g_cvar_gflbans_calladmin_cooldown.IntValue - GetTime();

    if (remaining_cooldown > 0)
    {
        GFLBansChat_Announce(client, "%t", "CallAdmin Rate Limit", remaining_cooldown);
        return Plugin_Handled;
    }

    Menu target_menu = new Menu(MenuHandler_CallAdminTarget);

    for (int target = 1; target <= MaxClients; target++)
    {
        if (!GFLBans_ValidClient(target) || client == target)
            continue;

        char target_name[64];
        GetClientName(target, target_name, sizeof(target_name));
        char target_buffer[8];
        IntToString(GetClientUserId(target), target_buffer, sizeof(target_buffer));

        target_menu.AddItem(target_buffer, target_name);
    }

    if (target_menu.ItemCount == 0)
    {
        ReplyToCommand(client, "%t", "No CallAdmin Targets");
    }
    else
    {
        target_menu.SetTitle("%t", "Select CallAdmin Target");
        target_menu.Display(client, MENU_TIME_FOREVER);
    }

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
    int target_list[MAXPLAYERS+1];
    int target_count = -1;
    char reason[281];
    int time = 0;
    if (!ParseCommandArguments("sm_caban", client, target_list, target_count, reason, sizeof(reason), time)) {
        return Plugin_Handled;
    }

    InfractionBlock blocks[] = {Block_CallAdmin};
    for (int c = 0; c < target_count; c++) {
        GFLBansChat_AnnounceAction(client, target_list[c], blocks, sizeof(blocks), time);
        GFLBansAPI_SaveInfraction(client, target_list[c], blocks, sizeof(blocks), time, reason);
        GFLBans_ApplyPunishments(target_list[c], blocks, sizeof(blocks), time);
    }

    return Plugin_Handled;
}

public int MenuHandler_CallAdminTarget(Menu menu, MenuAction action, int param1, int param2)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            char target_buffer[8];
            menu.GetItem(param2, target_buffer, sizeof(target_buffer));
            g_i_calladmin_targets[param1] = StringToInt(target_buffer);

            Menu reason_menu = new Menu(MenuHandler_CallAdminReason);

            char custom_reason[64];
            Format(custom_reason, sizeof(custom_reason), "%t", "CallAdmin Custom Reason");
            reason_menu.AddItem("custom_reason", custom_reason);

            for (int i = 0; i < g_calladmin_reasons.Length; i++)
            {
                char reason[121];
                g_calladmin_reasons.GetString(i, reason, sizeof(reason));

                reason_menu.AddItem(reason, reason);
            }

            reason_menu.SetTitle("%t", "Select CallAdmin Reason");
            reason_menu.Display(param1, MENU_TIME_FOREVER);
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }

    return 0;
}

public int MenuHandler_CallAdminReason(Menu menu, MenuAction action, int param1, int param2)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            if (param2 == 0)
            {
                g_b_calladmin_reason_listen[param1] = true;
                PrintToChat(param1, "%t", "CallAdmin Custom Reason Message");
            }
            else
            {
                char reason[121];
                menu.GetItem(param2, reason, sizeof(reason));
                BuildMenu_CallAdminConfirm(param1, reason);
            }
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }

    return 0;
}

public int MenuHandler_CallAdminConfirm(Menu menu, MenuAction action, int param1, int param2)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            if (param2 != 0)
                return 0;

            int target = GetClientOfUserId(g_i_calladmin_targets[param1]);
            char reason[121];
            menu.GetItem(param2, reason, sizeof(reason));

            if (!GFLBans_ValidClient(target))
            {
                PrintToChat(param1, "%t", "CallAdmin Target Disconnected");
                return 0;
            }

            GFLBansAPI_CallAdmin(param1, target, reason);
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }

    return 0;
}

void BuildMenu_CallAdminConfirm(int client, const char[] reason)
{
    Menu confirm_menu = new Menu(MenuHandler_CallAdminConfirm);

    char yes[32];
    char no[32];
    Format(yes, sizeof(yes), "%t", "CallAdmin Confirm Yes");
    Format(no, sizeof(no), "%t", "CallAdmin Confirm No");

    confirm_menu.AddItem(reason, yes);
    confirm_menu.AddItem(reason, no);

    confirm_menu.SetTitle("%t", "CallAdmin Confirm");
    confirm_menu.ExitButton = false;
    confirm_menu.Display(client, MENU_TIME_FOREVER);
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

bool ParseCommandArguments(const char[] command, int client, int target_list[MAXPLAYERS+1], int &target_count, char[] reason, int reason_max, int &time) {
    if (GetCmdArgs() < 2) {
        ReplyToCommand(client, "%t", "Infraction Usage", command);
        return false;
    }

    char arguments[256];
    GetCmdArgString(arguments, sizeof(arguments));

    char target[65];
    int len = BreakString(arguments, target, sizeof(target));

    if (!GetCommandTargets(client, target, target_list, MAXPLAYERS+1, target_count)) {
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

Action HandleChatInfraction(const char[] command, int client, int admin_flags, const InfractionBlock[] blocks, int total_blocks) {
    if (client && !CheckCommandAccess(client, "", admin_flags, true)) {
        return Plugin_Continue;
    }

    int target_list[MAXPLAYERS+1];
    int target_count = -1;
    char reason[281];
    int time = 0;
    if (!ParseCommandArguments(command, client, target_list, target_count, reason, sizeof(reason), time)) {
        return Plugin_Stop;
    }

    for (int c = 0; c < target_count; c++) {
        GFLBansAPI_SaveInfraction(client, target_list[c], blocks, total_blocks, time, reason);
        GFLBans_ApplyPunishments(target_list[c], blocks, total_blocks, time);
        GFLBansChat_AnnounceAction(client, target_list[c], blocks, total_blocks, time);
    }

    return Plugin_Stop;
}

Action HandleRemoveChatInfraction(int client, int admin_flags, const InfractionBlock[] blocks, int total_blocks) {
    if (client && !CheckCommandAccess(client, "", admin_flags, true)) {
        return Plugin_Continue;
    }

    char arguments[256];
    GetCmdArgString(arguments, sizeof(arguments));

    char target[65], reason[281];
    int len = BreakString(arguments, target, sizeof(target));
    if (len == -1) {
        len = 0;
        arguments[0] = '\0';
    }
    Format(reason, sizeof(reason), arguments[len]);

    int target_list[MAXPLAYERS+1];
    int target_count = -1;
    if (!GetCommandTargets(client, target, target_list, MAXPLAYERS+1, target_count)) {
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
    return HandleChatInfraction(command, client, ADMFLAG_CHAT, blocks, sizeof(blocks));
}

public Action CommandListener_Mute(int client, const char[] command, int args) {
    InfractionBlock blocks[] = {Block_Voice};
    return HandleChatInfraction(command, client, ADMFLAG_CHAT, blocks, sizeof(blocks));
}

public Action CommandListener_Silence(int client, const char[] command, int args) {
    InfractionBlock blocks[] = {Block_Chat, Block_Voice};
    return HandleChatInfraction(command, client, ADMFLAG_CHAT, blocks, sizeof(blocks));
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
