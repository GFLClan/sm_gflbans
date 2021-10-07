## SM GFL Bans
[![Workflow](https://github.com/GFLClan/sm_gflbans/actions/workflows/sourcemod.yml/badge.svg)](https://github.com/GFLClan/sm_gflbans/actions)

### Required configuration
After running the plugin for the first time the plugin will create a configuration file at `config/sourcemod/gflbans.cfg`.
You will need to edit some of these console variables for the server to connect to GFL Bans
- `gflbans_website` This should be the base URL for GFL Bans, e.g. `https://bans.gflclan.com/`
- `gflbans_server_id` The ID for this server provided by GFL Bans
- `gflbans_server_key` The key for this server provided by GFL Bans

## Commands
GFL Bans adds the folowing console commands. Angle brackets `< >` indicate that a command argument is required, square
brackets `[ ]` indicate that a command argument is optional.

Note that all commands can be used with either a slash or exlamation point in chat,
or with the `sm_` prefix in console.

#### `calladmin <reason>`
Calls a admin to the server for the provided reason.
Requires no flags
 - `reason` - Reason for calling a admin
 
#### `claim`
Claims a call admin request, indicating you will deal with it.
Requires admin flag kick (`c`)

#### `caban`
Bans a player from from using `calladmin`
Requires admin flag kick (`c`)
 - `target` - Target player, see [How to Target](https://wiki.alliedmods.net/Admin_commands_(sourcemod)#How_to_Target)
 - `duration` - Punishment time in minutes
 - `reason` - Punishment reason

#### `gag <target> <duration> [reason]`
Prevents a player from using text chat for a duration.
Requires admin flag kick (`c`)
 - `target` - Target player, see [How to Target](https://wiki.alliedmods.net/Admin_commands_(sourcemod)#How_to_Target)
 - `duration` - Punishment time in minutes
 - `reason` - Punishment reason

#### `mute <target> <duration> [reason]`
Prevents a player from using voice chat for a duration.
Requires admin flag kick (`c`)
 - `target` - Target player, see [How to Target](https://wiki.alliedmods.net/Admin_commands_(sourcemod)#How_to_Target)
 - `duration` - Punishment time in minutes
 - `reason` - Punishment reason
 
#### `silence <target> <duration> [reason]`
Prevents a player from using text or voice chat for a duration.
Requires admin flag kick (`c`)
 - `target` - Target player, see [How to Target](https://wiki.alliedmods.net/Admin_commands_(sourcemod)#How_to_Target)
 - `duration` - Punishment time in minutes
 - `reason` - Punishment reason

 #### `ungag <target> [reason]`
Removes an existing gag from a player
Requires admin flag kick (`c`)
 - `target` - Target player, see [How to Target](https://wiki.alliedmods.net/Admin_commands_(sourcemod)#How_to_Target)
 - `reason` - Reason for removing punishment

#### `unmute <target> [reason]`
Removes an existing m,ute from a player
Requires admin flag kick (`c`)
 - `target` - Target player, see [How to Target](https://wiki.alliedmods.net/Admin_commands_(sourcemod)#How_to_Target)
 - `reason` - Reason for removing punishment
 
#### `unsilence <target> [reason]`
Removes an existing silence from a player
Requires admin flag kick (`c`)
 - `target` - Target player, see [How to Target](https://wiki.alliedmods.net/Admin_commands_(sourcemod)#How_to_Target)
 - `reason` - Reason for removing punishment

#### `warn <target> <duration> [reason]`
Issues a warning for a player for breaking the rules
Requires admin flag kick (`c`)
 - `target` - Target player, see [How to Target](https://wiki.alliedmods.net/Admin_commands_(sourcemod)#How_to_Target)
 - `duration` - Punishment time in minutes
 - `reason` - Punishment reason
 
#### `ban <target> <duration> [reason]`
Bans a player for a duration.
Requires admin flag ban (`d`)
Permanent bans require admin flag unban (`e`)
 - `target` - Target player, see [How to Target](https://wiki.alliedmods.net/Admin_commands_(sourcemod)#How_to_Target)
 - `duration` - Punishment time in minutes
 - `reason` - Punishment reason

#### `gflbans_showlogs <log_level>`
Sets the minimum level of GFL Bans logs you would like to receive.
Requires admin flag rcon (`m`)
 - `log_level` - Log level, valid values are `debug`, `info`, `warn`, `error`, and `none`

## Console variables
GFL Bans includes the following console variables for configuration.

#### `gflbans_website`
The base URL for GFL Bans, e.g. `https://bans.gflclan.com/`

#### `gflbans_server_id`
The ID for this server provided by GFL Bans

#### `gflbans_server_key`
The key for this server provided by GFL Bans

#### `gflbans_global_bans <0|1>`
Default value: `1`
Should this server take global bans. If set to 0 players will only be kicked for bans from this server.

#### `gflbans_vpn_mode <kick|notify>`
Default value: `kick`
Action to take when a player joins via a VPN. If `kick`, the player will be kick, if `notify` admins will
be notified, but the player will be allowed to join.

#### `gflbans_allow_cloud_gaming <0|1>`
Default value: `1`
Should cloud gaming IPs be allowed. If `0` cloud gaming IPs will be considered VPNs, otherwise cloud gaming
IPs will be allowed.

#### `gflbans_log_level <debug|info|warn|error|none>`
Default value: `info`
Sets the minimum log level for GFL Bans logs to be logged to the server console.
