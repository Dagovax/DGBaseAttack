# DGBaseAttack
DG Exile server-side script that let AI attack a player's base

# Description

This Arma 3 Exile script can be used to let AI raid a base from a player.
The script checks a certain amount of time how long a player is inside his base. 

After the timer completes and the player is still inside his base, the base will be under attack from AI.
Note that this script is built for Exile servers.
I decided to create this script because the `vemf reloaded` script I used on the server was quite buggy.

Based on your configuration, there are a couple of possibilities:

## Alarm Sounds
When the base is under attack, certain sounds will be player to notify the player that his base is under attack. Sounds can be configured, check the configuration section below.

## 3 Raid Groups
Based on the configuration and the base level, up to 3 different AI groups will be spawned around the base that will perform the raid.

### First Group
The first group is the standard one and will spawn for all base levels, although the AI count of this group can be configured.
They spawn a certain distance away from the base on foot and will move to the base and attack any player.

### Second Group
This group will spawn for medium leveled bases, and will use a ground vehicle, or a boat (when the base is near water), and then drive to the base.

### Third Group
The third group will spawn far away from the base, and will move in a helicopter that will drop them at the players base. This group will only be spawned for high level bases

# Installation

1. Be sure you have [@DGCore](https://github.com/Dagovax/DGCore) installed on your Exile server

2. Download the `DGBaseAttack-main.zip` and extract it to your documents.

3. Place the `a3_dg_baseAttack.pbo` inside your "@ExileServer\addons" folder on your server

# Configuration

You can configure the scipt to your needs by opening `a3_dg_baseAttack\config\DG_config.sqf`:
After you completed the configuration, don't forget to PBO the folder `a3_dg_baseAttack` and place it in your "@ExileServer\addons"

### DGBA_MessageName
This is the name of the script that will be used in the logging. Best to keep it at default value

### DGBA_DebugMode
For testing purposes. Do not set this on live server or players will die

### DGBA_SleepTime
Amount of seconds the script will 'sleep' until it starts looking for bases to be raided again. Default is 60 seconds.

### DGBA_PlayerInBaseTMin
Minimum time in seconds a player has to be in his base in order to start the raid

### DGBA_PlayerInBaseTMax
Maximum time in seconds a player has to be in his base in order to start the raid

### DGBA_ShowNotification
What kind of notification do you want to broadcast to all online players?
Options are:
`
`0 = off 
`1 = exile (Default)
`2 = vemf_reloaded
`
Note that for option 2 you need to have (client) side Vemf_reloaded installed! 

### DGBA_MaxRaidCount
Maximum amount of raids a player can have per server restart

### DGBA_EnableAlarmSound
Setting this to false will disable the alarm sounds

### DGBA_AlarmSounds
Array containing information about what sounds will play and on what buildings. Check the default for more info

### DGBA_AlarmSoundTime
Amount of seconds the alarms will be played

### DGBA_AlarmSoundRange
Maximum range around the sound that it will be hearable for all players

### DGBA_EnableMarker
Enable map marker

### DGBA_MarkerType 
Type of marker to show. 

### DGBA_MarkerText
Text displayed on the map after the marker icon

### DGBA_MarkerColor
Color of the marker and text

### DGBA_MarkerSize	
Size of the marker.

### DGBA_BaseLevelRange
Base levels ranges for different difficulties
Range of base level it reaches next difficulty level. [easy > normal, normal > hard, hard > extreme]

### DGBA_AIEasySettings
AI easy general level, followed by array containing min - max troops, followed by inventory items | max poptabs

### DGBA_AINormalSettings
AI normal general level, followed by array containing min - max troops, followed by inventory items | max poptabs

### DGBA_AIHardSettings
AI hard general level, followed by array containing min - max troops, followed by inventory items | max poptabs

### DGBA_AIExtremeSettings
AI extreme general level, followed by array containing min - max troops, followed by inventory items | max poptabs

### DGBA_AISpawnVehicle
This will spawn a second group for normal +  level bases inside a vehicle

### DGBA_AINavalInvasion
If DGBA_AISpawnVehicle equals true and a base is near water, a boat will replace the vehicle.

### DGBA_AISpawnAirdrop
This will spawn a helicopter which will unload troops at the players base when level is hard +. 

### DGBA_CountAliveAI
This will add the remaining AI count to the map marker that are to be killed to clear the base raid.

### DGBA_AIWeapons
Array of weapons the AI can use. They will be random selection from this array per AI unit.

### DGBA_AILaunchers
Array of launchers the AI can use. They will be random selection from this array per AI unit.

### DGBA_AIWeaponOptics
Array of optics the AI can use. They will be random selection from this array per AI unit.

### DGBA_AIVests
Array of vests the AI can use. They will be random selection from this array per AI unit.

### DGBA_Backpacks
Array of backpacks the AI can use. They will be random selection from this array per AI unit.

### DGBA_Headgear
Array of headgear the AI can use. They will be random selection from this array per AI unit.

### DGBA_Helmets
Array of helmets the AI can use. They will be random selection from this array per AI unit.

### DGBA_AIItems
Array of items the AI can use. They will be random selection from this array per AI unit.

### DGBA_SkinList
Array of uniforms the AI can use. They will be random selection from this array per AI unit.

### DGBA_AIVehicleGround
Types of ground vehicles that the second group will use. Also random

### DGBA_AIVehicleSea
Types of sea vehicles that the second group will use. Also random

### DGBA_AIVehicleAir
Types of helicopters that will bring the third group to the players base. Also random
