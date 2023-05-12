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

#if defined _gflbans_included
	#endinput
#endif
#define _gflbans_included

enum InfractionBlock
{
	Block_Join,
	Block_Chat,
	Block_Voice,
	Block_CallAdmin,
	Block_AdminChat,
	Block_None
}

/**
 * Creates an infraction for a player.
 *
 * @param client		Client index of the player to create an infraction for.
 * @param blocks		Punishment blocks to apply for the infraction.
 * @param total_blocks	Number of punishment blocks to apply for the infraction.
 * @param duration		Duration of the infraction in minutes, 0 for permanent.
 * @param reason		Reason for the infraction.
 */
native void GFLBans_CreateInfraction(int client, const InfractionBlock[] blocks, int total_blocks, int duration, const char[] reason = "Infraction created through natives");

/**
 * Removes an infraction for a player.
 *
 * @param client		Client index of the player to remove an infraction for.
 * @param blocks		Punishment blocks the infraction has.
 * @param total_blocks	Number of punishment blocks the infraction has.
 * @param reason		Reason for removing the infraction.
 */
native void GFLBans_RemoveInfraction(int client, const InfractionBlock[] blocks, int total_blocks, const char[] reason = "Infraction removed through natives");

public SharedPlugin __pl_gflbans =
{
	name = "gflbans",
	file = "gflbans.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_gflbans_SetNTVOptional()
{
	MarkNativeAsOptional("GFLBans_CreateInfraction");
	MarkNativeAsOptional("GFLBans_RemoveInfraction");
}
#endif