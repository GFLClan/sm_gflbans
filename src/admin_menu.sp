#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <adminmenu>
#include "includes/chat"
#include "includes/infractions"
#include "includes/admin_menu"
#include "includes/utils"


// Most of this file is taken from how basebans handles the admin menu,
// pretty much verbatim.
// https://cs.alliedmods.net/sourcemod/source/plugins/basebans/ban.sp

TopMenu h_topmenu = null;
enum struct PlayerInfo {
    InfractionBlock infractionBlocks[Block_None];
    int infractionTarget;
    int infractionTargetUserId;
    int infractionTime;
    bool isWaitingForChatReason;
}

PlayerInfo playerinfo[MAXPLAYERS + 1];

public void OnAdminMenuReady(Handle admin_menu) {
    TopMenu topmenu = TopMenu.FromHandle(admin_menu);
    if (h_topmenu == topmenu) {
        return;
    }

    h_topmenu = topmenu;

    TopMenuObject player_commands = h_topmenu.FindCategory(ADMINMENU_PLAYERCOMMANDS);
    if (player_commands != INVALID_TOPMENUOBJECT) {
        h_topmenu.AddItem("sm_ban", AdminMenu_Ban, player_commands, "sm_ban", ADMFLAG_BAN);
        h_topmenu.AddItem("sm_mute", AdminMenu_Mute, player_commands, "sm_mute", ADMFLAG_KICK);
        h_topmenu.AddItem("sm_gag", AdminMenu_Gag, player_commands, "sm_gag", ADMFLAG_KICK);
        h_topmenu.AddItem("sm_silence", AdminMenu_Silence, player_commands, "sm_silence", ADMFLAG_KICK);
        h_topmenu.AddItem("sm_warn", AdminMenu_Warn, player_commands, "sm_warn", ADMFLAG_KICK);
        h_topmenu.AddItem("sm_caban", AdminMenu_CABan, player_commands, "sm_caban", ADMFLAG_KICK);
    }
}

Action GFLBansAM_OnClientSayCommand(int client, const char[] args) {
    if (StrEqual(args, "!gbabort", false) || StrEqual(args, "/gbabort", false)) {
        return Plugin_Stop;
    }

    if (playerinfo[client].isWaitingForChatReason) {
        playerinfo[client].isWaitingForChatReason = false;
        
        int original_target = GetClientOfUserId(playerinfo[client].infractionTargetUserId);
        if (original_target != playerinfo[client].infractionTarget) {
            GFLBansChat_NotifyAdmin(client, "%t", "Player no longer available");
            return Plugin_Stop;
        }

        int total_blocks = 0;
        for (int c = 0; c < view_as<int>(Block_None); c++) {
            if (playerinfo[client].infractionBlocks[c] == Block_None) {
                break;
            }
            total_blocks++;
        }

        GFLBansChat_AnnounceAction(
            client,
            playerinfo[client].infractionTarget,
            playerinfo[client].infractionBlocks,
            total_blocks,
            playerinfo[client].infractionTime
        );
        GFLBansAPI_SaveInfraction(
            client,
            playerinfo[client].infractionTarget,
            playerinfo[client].infractionBlocks,
            total_blocks,
            playerinfo[client].infractionTime,
            args
        );
        GFLBans_ApplyPunishments(
            playerinfo[client].infractionTarget,
            playerinfo[client].infractionBlocks,
            total_blocks,
            playerinfo[client].infractionTime
        );
        return Plugin_Stop;
    }

    return Plugin_Continue;
}

void GFLBansAM_Abort(int client) {
    playerinfo[client].isWaitingForChatReason = false;
    playerinfo[client].infractionTarget = 0;
    playerinfo[client].infractionBlocks[0] = Block_None;
    GFLBansChat_NotifyAdmin(client, "%t", "Punishment aborted");
}

public void AdminMenu_Ban(TopMenu topmenu, TopMenuAction action, TopMenuObject obj, int param, char[] buffer, int maxlength) {
    if (action == TopMenuAction_DisplayOption) {
        Format(buffer, maxlength, "%T", "Ban player", param);
    } else if (action == TopMenuAction_SelectOption) {
        playerinfo[param].infractionBlocks[0] = Block_Join;
        playerinfo[param].infractionBlocks[1] = Block_None;
        DisplayTargetMenu(param);
    }
}

public void AdminMenu_Gag(TopMenu topmenu, TopMenuAction action, TopMenuObject obj, int param, char[] buffer, int maxlength) {
    if (action == TopMenuAction_DisplayOption) {
        Format(buffer, maxlength, "%T", "Gag player", param);
    } else if (action == TopMenuAction_SelectOption) {
        playerinfo[param].infractionBlocks[0] = Block_Chat;
        playerinfo[param].infractionBlocks[1] = Block_None;
        DisplayTargetMenu(param);
    }
}


public void AdminMenu_Mute(TopMenu topmenu, TopMenuAction action, TopMenuObject obj, int param, char[] buffer, int maxlength) {
    if (action == TopMenuAction_DisplayOption) {
        Format(buffer, maxlength, "%T", "Mute player", param);
    } else if (action == TopMenuAction_SelectOption) {
        playerinfo[param].infractionBlocks[0] = Block_Voice;
        playerinfo[param].infractionBlocks[1] = Block_None;
        DisplayTargetMenu(param);
    }
}

public void AdminMenu_Silence(TopMenu topmenu, TopMenuAction action, TopMenuObject obj, int param, char[] buffer, int maxlength) {
    if (action == TopMenuAction_DisplayOption) {
        Format(buffer, maxlength, "%T", "Silence player", param);
    } else if (action == TopMenuAction_SelectOption) {
        playerinfo[param].infractionBlocks[0] = Block_Chat;
        playerinfo[param].infractionBlocks[1] = Block_Voice;
        playerinfo[param].infractionBlocks[2] = Block_None;
        DisplayTargetMenu(param);
    }
}

public void AdminMenu_Warn(TopMenu topmenu, TopMenuAction action, TopMenuObject obj, int param, char[] buffer, int maxlength) {
    if (action == TopMenuAction_DisplayOption) {
        Format(buffer, maxlength, "%T", "Warn player", param);
    } else if (action == TopMenuAction_SelectOption) {
        playerinfo[param].infractionBlocks[0] = Block_None;
        DisplayTargetMenu(param);
    }
}

public void AdminMenu_CABan(TopMenu topmenu, TopMenuAction action, TopMenuObject obj, int param, char[] buffer, int maxlength) {
    if (action == TopMenuAction_DisplayOption) {
        Format(buffer, maxlength, "%T", "CallAdmin ban player", param);
    } else if (action == TopMenuAction_SelectOption) {
        playerinfo[param].infractionBlocks[0] = Block_CallAdmin;
        playerinfo[param].infractionBlocks[1] = Block_None;
        DisplayTargetMenu(param);
    }
}

void DisplayTargetMenu(int client) {
    Menu menu = new Menu(MenuHandler_PlayerList);

    char title[32];
    Format(title, sizeof(title), "%T:", "Punish player", client);
    menu.SetTitle(title);
    menu.ExitBackButton = CheckCommandAccess(client, "sm_admin", ADMFLAG_GENERIC, false);

    AddTargetsToMenu2(menu, client, COMMAND_FILTER_NO_BOTS | COMMAND_FILTER_CONNECTED);
    menu.Display(client, MENU_TIME_FOREVER);
}

void DisplayBanTimeMenu(int client) {
    Menu menu = new Menu(MenuHandler_TimeList);

    char title[100];
    Format(title, sizeof(title), "%T: %N", "Punish player", client, playerinfo[client].infractionTarget);
    menu.SetTitle(title);
    menu.ExitBackButton = true;

    bool banning = false;
    for (int c = 0; c < view_as<int>(Block_None); c++) {
        if (playerinfo[client].infractionBlocks[c] == Block_None) {
            break;
        } else if (playerinfo[client].infractionBlocks[c] == Block_Join) {
            banning = true;
            break;
        }
    }

    if (!banning || (banning && CheckCommandAccess(client, "", ADMFLAG_UNBAN, false))) {
        menu.AddItem("0", "Permanent");
    }

    menu.AddItem("10", "10 Minutes");
    menu.AddItem("30", "30 Minutes");
    menu.AddItem("60", "1 Hour");
    menu.AddItem("240", "4 Hours");
    menu.AddItem("1440", "1 Day");
    menu.AddItem("10080", "1 Week");

    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_PlayerList(Menu menu, MenuAction action, int param1, int param2)
{
    if (action == MenuAction_End) {
        delete menu;
    } else if (action == MenuAction_Cancel) {
        if (param2 == MenuCancel_ExitBack && h_topmenu) {
            h_topmenu.Display(param1, TopMenuPosition_LastCategory);
        }
    } else if (action == MenuAction_Select) {
        char info[32], name[32];
        int userid, target;

        menu.GetItem(param2, info, sizeof(info), _, name, sizeof(name));
        userid = StringToInt(info);

        if ((target = GetClientOfUserId(userid)) == 0) {
            GFLBansChat_NotifyAdmin(param1, "%t", "Target not found");
        } else if (!CanUserTarget(param1, target)) {
            GFLBansChat_NotifyAdmin(param1, "%t", "Unable to target");
        } else {
            playerinfo[param1].infractionTarget = target;
            playerinfo[param1].infractionTargetUserId = userid;
            DisplayBanTimeMenu(param1);
        }
    }

    return 0;
}

public int MenuHandler_TimeList(Menu menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_End) {
        delete menu;
    } else if (action == MenuAction_Cancel) {
        if (param1 == MenuCancel_ExitBack && h_topmenu) {
            h_topmenu.Display(param1, TopMenuPosition_LastCategory);
        }
    } else if (action == MenuAction_Select) {
        char info[12];
        menu.GetItem(param2, info, sizeof(info));
        playerinfo[param1].infractionTime = StringToInt(info);
        playerinfo[param1].isWaitingForChatReason = true;
        GFLBansChat_NotifyAdmin(param1, "%t", "Enter infraction reason");
    }
    
    return 0;
}
