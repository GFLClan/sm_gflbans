#include <sourcemod>

#include "../src/includes/infractions"

void GFLBansAPI_SaveInfraction(int client, int target, const InfractionBlock[] blocks, int total_blocks, int duration, const char[] reason) {
    PrintToServer("Saved infraction by %N against %N for %s", client, target, reason);
}

void GFLBansAPI_RevokeInfraction(int client, int target, const InfractionBlock[] blocks, int total_blocks) {
    PrintToServer("Saved infraction by %N against %N for %s", client, target, reason);
}
