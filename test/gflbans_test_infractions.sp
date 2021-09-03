#pragma semicolon 1

#include <sourcemod>

#include "../src/includes/infractions"

public Plugin myinfo = {
    name = "GFLBans Tests - Utils",
    author = "Dreae",
    description = "Part of the SM GFLBans Tests",
    version = "0.0.1", 
    url = "https://gitlab.gflclan.com/Dreae/sm_gflbans"
};

public void OnPluginStart() {
    LoadTranslations("gflbans.phrases");
    GFLBans_Test_InitCvars();
    RegConsoleCmd("sm_gflbans_testban", Command_TestBan);
    RegConsoleCmd("sm_gflbans_testgag", Command_TestGag);
    RegConsoleCmd("sm_gflbans_testmute", Command_TestMute);
}

public Action Command_TestBan(int client, int args) {
    char buffer[128];
    GetCmdArgString(buffer, sizeof(buffer));
    InfractionBlock blocks[] = {Block_Join};
    GFLBans_ApplyPunishments(client, blocks, sizeof(blocks), 1);
}

public Action Command_TestGag(int client, int args) {
    char buffer[128];
    GetCmdArgString(buffer, sizeof(buffer));
    InfractionBlock blocks[] = {Block_Chat};
    GFLBans_ApplyPunishments(client, blocks, sizeof(blocks), 1);
}

public Action Command_TestMute(int client, int args) {
    char buffer[128];
    GetCmdArgString(buffer, sizeof(buffer));
    InfractionBlock blocks[] = {Block_Voice};
    GFLBans_ApplyPunishments(client, blocks, sizeof(blocks), 1);
}
