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

#if defined _gflbans_infractions_include
    #endinput
#endif
#define _gflbans_infractions_include

enum InfractionBlock {
    Block_Join,
    Block_Chat,
    Block_Voice,
    Block_CallAdmin,
    Block_AdminChat,
    Block_None
}
void GFLBans_ApplyPunishment(int client, InfractionBlock block, int duration);
void GFLBans_RemovePunishment(int client, InfractionBlock block);
void GFLBans_ApplyPunishments(int client, const InfractionBlock[] blocks, int total_blocks, int duration);
void GFLBans_RemovePunishments(int client, const InfractionBlock[] blocks, int total_blocks);
void GFLBans_ClearOtherPunishments(int client, const InfractionBlock[] blocks, int total_blocks);
void GFLBans_ClearPunishments(client);
bool GFLBans_StringToPunishment(const char[] string, InfractionBlock &punishment);
bool GFLBans_PunishmentToString(InfractionBlock punishment, char[] buffer, int max_size);
bool GFLBans_PunishmentExpiresBefore(int client, InfractionBlock block, int expires);
bool GFLBans_CallAdminBanned(int client);
void GFLBans_KillPunishmentTimers(int client);
