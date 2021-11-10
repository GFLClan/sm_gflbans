#include <sourcemod>
#include "includes/utils"
#include "includes/chat"

void GFLBansChat_AnnounceAction(int client, int target, const InfractionBlock[] blocks, int total_blocks, int duration) {
    char admin[64], targ[64], s_duration[32], translation_str[12];
    GetClientName(client, admin, sizeof(admin));
    GetClientName(target, targ, sizeof(targ));
    for (int c = 1; c <= MaxClients; c++) {
        if (IsClientConnected(c) && !IsFakeClient(c)) {
            GFLBans_FormatDuration(c, duration, s_duration, sizeof(s_duration));
            if (total_blocks == 0) {
                Format(translation_str, sizeof(translation_str), "Warned");
                GFLBansChat_Announce(c, "%t", translation_str, admin, targ, s_duration);
            }
            
            for (int i = 0; i < total_blocks; i++) {
                if (blocks[i] == Block_Join) {
                    Format(translation_str, sizeof(translation_str), "Banned");
                } else if (blocks[i] == Block_Voice) {
                    Format(translation_str, sizeof(translation_str), "Muted");
                } else if (blocks[i] == Block_Chat) {
                    Format(translation_str, sizeof(translation_str), "Gagged");
                } else if (blocks[i] == Block_CallAdmin) {
                    Format(translation_str, sizeof(translation_str), "CallAdmin Banned");
                }
                GFLBansChat_Announce(c, "%t", translation_str, admin, targ, s_duration);
            }
        }
    }
}

void GFLBansChat_NotifyAdmin(int client, const char[] format, any ...) {
    char buffer[512];
    SetGlobalTransTarget(client);
    VFormat(buffer, sizeof(buffer), format, 3);
    if (client == 0) {
        PrintToServer("[GFLBans] %s", buffer);
    } else {
        c_print_to_chat(client, "\x070260db[GFLBans] \x0702ccdb%s", buffer);
    }
}

void GFLBansChat_NotifyAdmins(const char[] format, any ...) {
    char buffer[512];
    for (int c = 1; c < MaxClients; c++) {
        if (GFLBans_ValidClient(c) && CheckCommandAccess(c, "", ADMFLAG_KICK, true)) {
            SetGlobalTransTarget(c);
            VFormat(buffer, sizeof(buffer), format, 2);
            c_print_to_chat(c, "\x070260db[GFLBans] \x0702ccdb%s", buffer);
        }
    }
}

void GFLBansChat_Announce(int client, const char[] format, any ...) {
    char buffer[512];
    SetGlobalTransTarget(client);
    VFormat(buffer, sizeof(buffer), format, 3);
    c_print_to_chat(client, "\x07f1faee[GFLBans] \x07a8dadc%s", buffer);
}

void c_print_to_chat_ex(int[] clients, int num_clients, const char[] msg) {
    UserMsg id = GetUserMessageId("SayText2");
    if (id == INVALID_MESSAGE_ID) {
        for (int client = 0; client < num_clients; client++) {
            PrintToChat(clients[client], msg);
        }
    } else {
        Handle usr_msg = StartMessage("SayText2", clients, num_clients, USERMSG_RELIABLE | USERMSG_BLOCKHOOKS);
        if (GetFeatureStatus(FeatureType_Native, "GetUserMessageType") == FeatureStatus_Available && GetUserMessageType() == UM_Protobuf) {
            PbSetInt(usr_msg, "ent_idx", 0);
            PbSetBool(usr_msg, "chat", true);
            PbSetString(usr_msg, "msg_name", msg);
            PbAddString(usr_msg, "params", "");
            PbAddString(usr_msg, "params", "");
            PbAddString(usr_msg, "params", "");
            PbAddString(usr_msg, "params", "");
        } else {
            BfWriteByte(usr_msg, 0); // Message author
            BfWriteByte(usr_msg, true); // Chat message
            BfWriteString(usr_msg, msg); // Message text
        }
        EndMessage();
    }
}

void c_print_to_chat(int client, const char[] msg, any ...) {
    char buffer[1024];
    VFormat(buffer, sizeof(buffer), msg, 3);
    int clients[1];
    clients[0] = client;

    c_print_to_chat_ex(clients, 1, buffer);
}
