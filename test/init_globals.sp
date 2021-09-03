#include "../src/includes/globals"

void GFLBans_Test_InitCvars() {
    g_cvar_gflbans_website = CreateConVar("gflbans_tests_website", "https://google.com", "Base URL for GFL Bans instance");
    g_cvar_gflbans_global_bans = CreateConVar("gflbans_tests_global_bans", "1", "Should this server accept global bans");
    g_cvar_gflbans_server_id = CreateConVar("gflbans_tests_server_id", "", "ID for this server in GFL Bans");
    g_cvar_gflbans_server_key = CreateConVar("gflbans_tests_server_id", "", "Key for this server in GFL Bans");
}
