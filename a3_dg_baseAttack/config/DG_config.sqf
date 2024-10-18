
DGBA_MessageName = "DG Base Attacks";

if (!isServer) exitWith {
	["Failed to load configuration data, as this code is not being executed by the server!", DGBA_MessageName] call DGCore_fnc_log;
};

["Loading configuration data...", DGBA_MessageName] call DGCore_fnc_log;

/****************************************************************************************************/
/********************************  CONFIG PART. EDIT AS YOU LIKE!!  ************************************/
/****************************************************************************************************/

// Generic
DGBA_DebugMode			= false; // For testing purposes. Do not set this on live server or players will die
DGBA_SleepTime			= 60; 
DGBA_MinAmountPlayers	= 1; 	// Amount of players required to start the missions spawning. Set to 0 to have no wait time for players

// Base raid settings
DGBA_PlayerInBaseTMin	= 3 * 60; 	// Minimum time in seconds a player has to be in his base in order to start the raid
DGBA_PlayerInBaseTMax	= 20 * 60; 	// Maximum time in seconds a player has to be in his base in order to start the raid
DGBA_MaxRaidCount		= 1; 	// Maximum amount of raids a player can have per restart
DGBA_ShowNotification	= 2;	// Broadcast notification to all players? [0 = off | 1 = exile | 2 = vemr_reloaded 
DGBA_EnableAlarmSound	= true; // Setting this to false willl disable the alarm soundss
DGBA_AlarmSounds		= 	[ 	// Sound names, length, pitch, array of objects that will play this sound
								["air_raid", 10, 1, ["Land_Radar_Small_F", "Land_Radar_F", "Land_Airport_Tower_F", "Land_AirHorn_01_F", "Land_Cargo_Tower_V2_F"]],
								["alarm_independent", 7, 1, ["Exile_Construction_Flag_Static"]]
							];
DGBA_AlarmSoundTime		= 60; 	// Amount of seconds the alarms will be played
DGBA_AlarmSoundRange	= 2000; // range around the sound that it will be hearable

DGBA_EnableMarker		= true; // Adds a marker and text showing remaining AI to the base being raided
DGBA_MarkerType 		= "KIA";
DGBA_MarkerText			= "Base Raid";
DGBA_MarkerColor		= "ColorRed";
DGBA_MarkerSize			= 1;

// AI Settings
DGBA_BaseLevelRange		= [3, 6, 8]; // Range of base level it reaches next difficulty level. [easy > normal, normal > hard, hard > extreme]
DGBA_AIEasySettings		= [0.3, [3,5], 1, 100]; // AI easy general level, followed by array containing min - max troops, followed by inventory items | max poptabs
DGBA_AINormalSettings	= [0.5, [5,8], 2, 250]; // AI normal general level, followed by array containing min - max troops, followed by inventory items | max poptabs
DGBA_AIHardSettings		= [0.7, [8,12], 3, 500]; // AI hard general level, followed by array containing min - max troops, followed by inventory items | max poptabs
DGBA_AIExtremeSettings	= [0.9, [10,15], 4, 1000]; // AI extreme general level, followed by array containing min - max troops, followed by inventory items | max poptabs
DGBA_AISpawnVehicle		= true; // This will spawn a second group for normal +  level bases 
DGBA_AINavalInvasion	= true; // If DGBA_AISpawnVehicle equals true and a base is near water, a boat will replace the vehicle.
DGBA_AISpawnAirdrop		= true; // This will spawn a helicopter which will unload troops at the players base when level is hard +. 
DGBA_CountAliveAI		= true;
DGBA_AIUseNVG			= true; // If set to true, AI might spawn with NVG goggles. The random percentage is defined below.
DGBA_AINVGSpawnChance	= 60;	// Percentage. So a valid value between <0> and <100>. 0 will mean that no unit will spawn with NVG. 100 means they all have NVG

// AI Group Cleanup settings
DGBA_Vehicle_MaxWaitT	= 60; // Amount of seconds the script will wait before checking the vehicle group state. Set this high enough if your vehicle group needs more time to load troops, and moving to the base.
DGBA_Vehicle_IdleRange	= 25; // Distance in meters the spawned vehicle should at least have moved since it has spawned. If the distance is less than this number, the vehicle will be exploded and the units will be killed.
DGBA_Airdrop_MaxWaitT	= 180; // Amount of seconds the script will wait before checking its state. By default this is 3 minutes. Set this higher if your heli has a lot of troops to load and you don't want to despawn it this soon.
DGBA_Airdrop_IdleRange	= 100; // The minimum 2d range distance the airdrop should have moved since it has spawned. If the heli did not move this distance, it will be removed after above max waiting time.

// Loadout settings
DGBA_AIWeapons		=	[
							"arifle_Katiba_F",
							"arifle_Katiba_C_F",
							"arifle_Katiba_GL_F",
							"arifle_MXC_F",
							"arifle_MX_F",
							"arifle_MX_GL_F",
							"arifle_MXM_F",
							"arifle_SDAR_F",
							"arifle_TRG21_F",
							"arifle_TRG20_F",
							"arifle_TRG21_GL_F",
							"arifle_Mk20_F",
							"arifle_Mk20C_F",
							"arifle_Mk20_GL_F",
							"arifle_Mk20_plain_F",
							"arifle_Mk20C_plain_F",
							"arifle_Mk20_GL_plain_F",
							"srifle_EBR_F",
							"srifle_GM6_F",
							"srifle_LRR_F",
							"srifle_DMR_01_F",
							"MMG_02_sand_F",
							"MMG_02_black_F",
							"MMG_02_camo_F",
							"MMG_01_hex_F",
							"MMG_01_tan_F",
							"srifle_DMR_05_blk_F",
							"srifle_DMR_05_hex_F",
							"srifle_DMR_05_tan_F"
						];
DGBA_AILaunchers	=	[
							"rhs_weap_igla",
							"CUP_launch_Javelin",
							"CUP_launch_NLAW",
							"launch_RPG7_F",
							"launch_B_Titan_tna_F",
							"launch_B_Titan_F",
							"launch_O_Titan_short_F",
							"launch_B_Titan_short_F",
							"launch_RPG32_F",
							"CUP_launch_APILAS",
							"CUP_launch_M47"
						];
DGBA_AIWeaponOptics	=	[
							"bipod_01_F_snd",
							"bipod_02_F_blk",
							"optic_LRPS",
							"optic_LRPS_tna_F",
							"optic_LRPS_ghex_F",
							"optic_DMS",
							"RPG32_F",
							"optic_AMS","optic_AMS_khk","optic_AMS_snd",
							"optic_DMS",
							"optic_KHS_blk","optic_KHS_hex","optic_KHS_old","optic_KHS_tan",
							"optic_LRPS",
							"optic_NVS",
							"optic_SOS"
						];
						
DGBA_AIVests=			[
							"V_Press_F",
							"V_Rangemaster_belt",
							"V_TacVest_blk",
							"V_TacVest_blk_POLICE",
							"V_TacVest_brn",
							"V_TacVest_camo",
							"V_TacVest_khk",
							"V_TacVest_oli",
							"V_TacVestCamo_khk",
							"V_TacVestIR_blk",
							"V_I_G_resistanceLeader_F",
							"V_BandollierB_blk",
							"V_BandollierB_cbr",
							"V_BandollierB_khk",
							"V_BandollierB_oli",
							"V_BandollierB_rgr",
							"V_Chestrig_blk",
							"V_Chestrig_khk",
							"V_Chestrig_oli",
							"V_Chestrig_rgr",
							"V_HarnessO_brn",
							"V_HarnessO_gry",
							"V_HarnessOGL_brn",
							"V_HarnessOGL_gry",
							"V_HarnessOSpec_brn",
							"V_HarnessOSpec_gry",
							"V_PlateCarrier1_blk",
							"V_PlateCarrier1_rgr",
							"V_PlateCarrier2_rgr",
							"V_PlateCarrier3_rgr",
							"V_PlateCarrierGL_blk",
							"V_PlateCarrierGL_mtp",
							"V_PlateCarrierGL_rgr",
							"V_PlateCarrierH_CTRG",
							"V_PlateCarrierIA1_dgtl",
							"V_PlateCarrierIA2_dgtl",
							"V_PlateCarrierIAGL_dgtl",
							"V_PlateCarrierIAGL_oli",
							"V_PlateCarrierL_CTRG",
							"V_PlateCarrierSpec_blk",
							"V_PlateCarrierSpec_mtp"
						];
DGBA_Backpacks =		[
							"B_Carryall_ocamo",
							"B_Carryall_oucamo",
							"B_Carryall_mcamo",
							"B_Carryall_oli",
							"B_Carryall_khk",
							"B_Carryall_cbr"
						];
DGBA_Headgear = 		[
							"H_Cap_blk",
							"H_Cap_blk_Raven",
							"H_Cap_blu",
							"H_Cap_brn_SPECOPS",
							"H_Cap_grn",
							"H_Cap_headphones",
							"H_Cap_khaki_specops_UK",
							"H_Cap_oli",
							"H_Cap_press",
							"H_Cap_red",
							"H_Cap_tan",
							"H_Cap_tan_specops_US",
							"H_Watchcap_blk",
							"H_Watchcap_camo",
							"H_Watchcap_khk",
							"H_Watchcap_sgg",
							"H_MilCap_blue",
							"H_MilCap_dgtl",
							"H_MilCap_mcamo",
							"H_MilCap_ocamo",
							"H_MilCap_oucamo",
							"H_MilCap_rucamo",
							"H_Bandanna_camo",
							"H_Bandanna_cbr",
							"H_Bandanna_gry",
							"H_Bandanna_khk",
							"H_Bandanna_khk_hs",
							"H_Bandanna_mcamo",
							"H_Bandanna_sgg",
							"H_Bandanna_surfer",
							"H_Booniehat_dgtl",
							"H_Booniehat_dirty",
							"H_Booniehat_grn",
							"H_Booniehat_indp",
							"H_Booniehat_khk",
							"H_Booniehat_khk_hs",
							"H_Booniehat_mcamo",
							"H_Booniehat_tan",
							"H_Hat_blue",
							"H_Hat_brown",
							"H_Hat_camo",
							"H_Hat_checker",
							"H_Hat_grey",
							"H_Hat_tan",
							"H_StrawHat",
							"H_StrawHat_dark",
							"H_Beret_02",
							"H_Beret_blk",
							"H_Beret_blk_POLICE",
							"H_Beret_brn_SF",
							"H_Beret_Colonel",
							"H_Beret_grn",
							"H_Beret_grn_SF",
							"H_Beret_ocamo",
							"H_Beret_red",
							"H_Shemag_khk",
							"H_Shemag_olive",
							"H_Shemag_olive_hs",
							"H_Shemag_tan",
							"H_ShemagOpen_khk",
							"H_ShemagOpen_tan",
							"H_TurbanO_blk",
							"H_CrewHelmetHeli_B",
							"H_CrewHelmetHeli_I",
							"H_CrewHelmetHeli_O",
							"H_HelmetCrew_I",
							"H_HelmetCrew_B",
							"H_HelmetCrew_O",
							"H_PilotHelmetHeli_B",
							"H_PilotHelmetHeli_I",
							"H_PilotHelmetHeli_O"	
						];
DGBA_Helmets = 			[
							"H_HelmetB",
							"H_HelmetB_black",
							"H_HelmetB_camo",
							"H_HelmetB_desert",
							"H_HelmetB_grass",
							"H_HelmetB_light",
							"H_HelmetB_light_black",
							"H_HelmetB_light_desert",
							"H_HelmetB_light_grass",
							"H_HelmetB_light_sand",
							"H_HelmetB_light_snakeskin",
							"H_HelmetB_paint",
							"H_HelmetB_plain_blk",
							"H_HelmetB_sand",
							"H_HelmetB_snakeskin",
							"H_HelmetCrew_B",
							"H_HelmetCrew_I",
							"H_HelmetCrew_O",
							"H_HelmetIA",
							"H_HelmetIA_camo",
							"H_HelmetIA_net",
							"H_HelmetLeaderO_ocamo",
							"H_HelmetLeaderO_oucamo",
							"H_HelmetO_ocamo",
							"H_HelmetO_oucamo",
							"H_HelmetSpecB",
							"H_HelmetSpecB_blk",
							"H_HelmetSpecB_paint1",
							"H_HelmetSpecB_paint2",
							"H_HelmetSpecO_blk",
							"H_HelmetSpecO_ocamo",
							"H_CrewHelmetHeli_B",
							"H_CrewHelmetHeli_I",
							"H_CrewHelmetHeli_O",
							"H_HelmetCrew_I",
							"H_HelmetCrew_B",
							"H_HelmetCrew_O",
							"H_PilotHelmetHeli_B",
							"H_PilotHelmetHeli_I",
							"H_PilotHelmetHeli_O",
							"H_Helmet_Skate",
							"H_HelmetB_TI_tna_F",
							"H_HelmetB_tna_F",
							"H_HelmetB_Enh_tna_F",
							"H_HelmetB_Light_tna_F",
							"H_HelmetSpecO_ghex_F",
							"H_HelmetLeaderO_ghex_F",
							"H_HelmetO_ghex_F",
							"H_HelmetCrew_O_ghex_F"			
						];
DGBA_HeadgearList = DGBA_Headgear + DGBA_Helmets;

DGBA_AIItems = 			[
							"Exile_Item_InstaDoc",
							"Exile_Item_BBQSandwich",
							"Exile_Item_BeefParts",
							"Exile_Item_Catfood",
							"Exile_Item_Cheathas",
							"Exile_Item_ChristmasTinner",
							"Exile_Item_Dogfood",
							"Exile_Item_EMRE",
							"Exile_Item_GloriousKnakworst",
							"Exile_Item_InstantCoffee",
							"Exile_Item_MacasCheese",
							"Exile_Item_Moobar",
							"Exile_Item_Noodles",
							"Exile_Item_Raisins",
							"Exile_Item_SausageGravy",
							"Exile_Item_SeedAstics",
							"Exile_Item_Surstromming"
						];

//This defines the skin list, some skins are disabled by default to permit players to have high visibility uniforms distinct from those of the AI.
DGBA_SkinList = 		[
							"Exile_Uniform_Woodland",
							"U_BG_Guerilla1_1",
							"U_BG_Guerilla2_1",
							"U_BG_Guerilla2_2",
							"U_BG_Guerilla2_3",
							"U_BG_Guerilla3_1",
							"U_BG_Guerrilla_6_1",
							"U_BG_leader",
							"U_B_CTRG_1",
							"U_B_CTRG_2",
							"U_B_CTRG_3",
							"U_B_CombatUniform_mcam",
							"U_B_CombatUniform_mcam_tshirt",
							"U_B_CombatUniform_mcam_vest",
							"U_B_CombatUniform_mcam_worn",
							"U_B_HeliPilotCoveralls",
							"U_B_PilotCoveralls",
							"U_B_SpecopsUniform_sgg",
							"U_B_Wetsuit",
							"U_B_survival_uniform",
							"U_C_HunterBody_grn",
							"U_C_Journalist",
							"U_C_Poloshirt_blue",
							"U_C_Poloshirt_burgundy",
							"U_C_Poloshirt_salmon",
							"U_C_Poloshirt_stripped",
							"U_C_Poloshirt_tricolour",
							"U_C_Poor_1",
							"U_C_Poor_2",
							"U_C_Poor_shorts_1",
							"U_C_Scientist",
							"U_Competitor",
							"U_IG_Guerilla1_1",
							"U_IG_Guerilla2_1",
							"U_IG_Guerilla2_2",
							"U_IG_Guerilla2_3",
							"U_IG_Guerilla3_1",
							"U_IG_Guerilla3_2",
							"U_IG_leader",
							"U_I_CombatUniform",
							"U_I_CombatUniform_shortsleeve",
							"U_I_CombatUniform_tshirt",
							"U_I_G_Story_Protagonist_F",
							"U_I_G_resistanceLeader_F",
							"U_I_HeliPilotCoveralls",
							"U_I_OfficerUniform",
							"U_I_Wetsuit",
							"U_I_pilotCoveralls",
							"U_NikosAgedBody",
							"U_NikosBody",
							"U_O_CombatUniform_ocamo",
							"U_O_CombatUniform_oucamo",
							"U_O_OfficerUniform_ocamo",
							"U_O_PilotCoveralls",
							"U_O_SpecopsUniform_blk",
							"U_O_SpecopsUniform_ocamo",
							"U_O_Wetsuit",
							"U_OrestesBody",
							"U_Rangemaster",
							"U_B_FullGhillie_ard",
							"U_B_FullGhillie_lsh",
							"U_B_FullGhillie_sard",
							"U_B_GhillieSuit",
							"U_I_FullGhillie_ard",
							"U_I_FullGhillie_lsh",
							"U_I_FullGhillie_sard",
							"U_I_GhillieSuit",
							"U_O_FullGhillie_ard",
							"U_O_FullGhillie_lsh",
							"U_O_FullGhillie_sard",
							"U_O_GhillieSuit"
						];

DGBA_AIVehicleGround = 	[
							"B_MRAP_01_hmg_F",
							"B_LSV_01_armed_F",
							"B_Quadbike_01_F",
							"O_MRAP_02_hmg_F",
							"CUP_O_UAZ_MG_CSAT",
							"CUP_I_LR_SF_HMG_AAF",
							"BTR40_MG_TK_INS_EP1",
							"B_G_Offroad_01_armed_F",
							"Exile_Car_Offroad_Armed_Guerilla02"
						];

DGBA_AIVehicleSea = 	[
							"CUP_B_RHIB_HIL",
							"CUP_B_RHIB2Turret_HIL",
							"B_Boat_Armed_01_minigun_F",
							"CUP_O_LCVP_SLA",
							"rhsusf_mkvsoc",
							"CUP_C_Fishing_Boat_Chernarus",
							"O_Boat_Armed_01_hmg_F"
						];

DGBA_AIVehicleAir = 	[ // Only for transport
							"Exile_Chopper_Hellcat_FIA",
							"Exile_Chopper_Orca_Black",
							"B_Heli_Transport_03_unarmed_F",
							"B_Heli_Transport_03_F",
							"O_Heli_Transport_04_covered_F",
							"CUP_B_CH47F_GB",
							"CUP_B_MH47E_GB",
							"CUP_I_UH1H_slick_TK_GUE",
							"CUP_O_Mi8AMT_RU",
							"RHS_Mi8mt_Cargo_vdv",
							"CUP_I_412_Mil_Transport_AAF",
							"CUP_I_412_Mil_Transport_PMC",
							"CUP_B_412_Mil_Transport_HIL",
							"CUP_B_UH1Y_UNA_USMC",
							"RHS_CH_47F_10_cargo"
						];
						
["Configuration loaded", DGBA_MessageName] call DGCore_fnc_log;
