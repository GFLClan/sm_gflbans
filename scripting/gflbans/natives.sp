#pragma semicolon 1
#pragma newdecls required

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    RegPluginLibrary("gflbans");

    CreateNative("GFLBans_CreateInfraction", CreateInfraction);
    CreateNative("GFLBans_RemoveInfraction", RemoveInfraction);

    return APLRes_Success;
}

int CreateInfraction(Handle plugin, int numParams)
{
    int client = GetNativeCell(1);
    int total_blocks = GetNativeCell(3);
    int duration = GetNativeCell(4);

    InfractionBlock[] blocks = new InfractionBlock[total_blocks];
    GetNativeArray(2, blocks, total_blocks);

    char reason[281];
    GetNativeString(5, reason, sizeof(reason));

    if (!GFLBans_ValidClient(client))
    {
        ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index %i", client);
        return 0;
    }

    GFLBansChat_AnnounceAction(0, client, blocks, total_blocks, duration);
    GFLBansAPI_SaveInfraction(0, client, blocks, total_blocks, duration, reason);
    GFLBans_ApplyPunishments(client, blocks, total_blocks, duration);

    return 0;
}

int RemoveInfraction(Handle plugin, int numParams)
{
    int client = GetNativeCell(1);
    int total_blocks = GetNativeCell(3);

    InfractionBlock[] blocks = new InfractionBlock[total_blocks];
    GetNativeArray(2, blocks, total_blocks);

    char reason[281];
    GetNativeString(4, reason, sizeof(reason));

    if (!GFLBans_ValidClient(client))
    {
        ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index %i", client);
        return 0;
    }

    GFLBansAPI_RemoveInfraction(0, client, blocks, total_blocks, reason);
    GFLBans_RemovePunishments(client, blocks, total_blocks);

    return 0;
}