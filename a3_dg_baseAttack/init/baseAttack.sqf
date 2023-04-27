if (!isServer) exitWith {};

if (isNil "DGBA_Configured") then
{
	["%1 Waiting until configuration completes...", "DG Base Attacks"] call DGCore_fnc_log;
	waitUntil{uiSleep 10; !(isNil "DGBA_Configured")}
};

["Initializing Dagovax Games Base Raids", DGBA_MessageName] call DGCore_fnc_log;

/****************************************************************************************************/
/********************************  DO NOT EDIT THE CODE BELOW!!  ************************************/
/****************************************************************************************************/
if(DGBA_DebugMode) then 
{
	["Running in Debug mode!", DGBA_MessageName, "debug"] call DGCore_fnc_log;
	DGBA_MinAmountPlayers = 0;
	DGBA_PlayerInBaseTMin	= 5; 	// Minimum time in seconds a player has to be in his base in order to start the raid
	DGBA_PlayerInBaseTMax	= 15; 	// Maximum time in seconds a player has to be in his base in order to start the raid
	DGBA_SleepTime = 10;
	DGBA_MaxRaidCount = 5;
};

if (DGBA_MinAmountPlayers > 0) then
{
	[format["Waiting for %1 players to be online.", DGBA_MinAmountPlayers], DGBA_MessageName, "debug"] call DGCore_fnc_log;
	waitUntil { uiSleep 10; count( playableUnits ) > ( DGBA_MinAmountPlayers - 1 ) };
};
[format["%1 players reached. Initializing main loop of base raids", DGBA_MinAmountPlayers], DGBA_MessageName, "debug"] call DGCore_fnc_log;

DGBA_AttackedBases = []; // Array containing attacked bases. Can be attacked multiple times if the config allowed it.
DGBA_RaidQueue = []; // Bases currently in the queue being raided.

_reInitialize = true; // Only initialize this when _reInitialize is true
while {true} do // Main Loop
{
	if(_reInitialize) then
	{
		_reInitialize = false;
		_objs = [];
		{
			if (((speed _x ) < 25 ) && ((vehicle _x) isEqualTo _x)) then
			{
				{
					_fndBase = _x;
					if (!( _x in DGBA_RaidQueue) && (({_x == _fndBase} count DGBA_AttackedBases) < DGBA_MaxRaidCount) &&(( _x getVariable "ExileTerritoryLevel" ) >= 1 )) then { _objs pushBack _x };
				} forEach ( nearestObjects [ position _x, [ "Exile_Construction_Flag_Static" ], 150 ] );
			};
		} forEach allPlayers;
		
		if ((count _objs) > 0 ) then
		{
			_base = selectRandom _objs;
			// NOW SPAWN CODE BELOW AND CONTINUE MAIN LOOP!
			_base spawn 
			{
				params ["_base"];
				_secondsPlayerIn =  (DGBA_PlayerInBaseTMin) + random((DGBA_PlayerInBaseTMax) - (DGBA_PlayerInBaseTMin));
				_pos = position _base;
				_baseNm = _base getVariable [ "exileterritoryname", "ERROR: UNKNOWN NAME" ];
				[format["Initializing raid on base '%1' on position %2", _baseNm, _pos], DGBA_MessageName, "debug"] call DGCore_fnc_log;
				_a = nearestObjects [_pos, ["Exile_Unit_Player"], _base getVariable [ "ExileTerritorySize", 200 ] ] select{alive _x};
				if ((count _a) > 0) then
				{
					DGBA_RaidQueue pushBack _base;
					[format["We found %1 player(s) on this base. Waiting %2 seconds now!", count _a, _secondsPlayerIn], DGBA_MessageName, "debug"] call DGCore_fnc_log;
					_waitedSeconds = 0;
					while {_waitedSeconds < _secondsPlayerIn} do
					{
						uiSleep 5;
						_waitedSeconds = _waitedSeconds + 5;
						_newCount = count (nearestObjects [ _pos, ["Exile_Unit_Player"], _base getVariable [ "ExileTerritorySize", 120 ] ] select{alive _x} ); 
						if (_newCount == 0) exitWith{}; // No more people on this base.
					};
					//uiSleep _secondsPlayerIn; // Sleep until wait time. Now check if there are still people in this base
					_newCount = count (nearestObjects [ _pos, ["Exile_Unit_Player"], _base getVariable [ "ExileTerritorySize", 120 ] ] select{alive _x} ); 
					if (_newCount > 0 ) then
					{
						_nrPlyr = selectRandom _a;
						if !(isNil "_nrPlyr") then
						{
							DGBA_AttackedBases pushBack _base;
							_baseSize = _base getVariable [ "ExileTerritorySize", 200 ];
							_baseLevel = _base getVariable "ExileTerritoryLevel";
							// START THE RAID
							[format["After waiting %1 seconds, there are still %2 player(s) on the base! Starting the raid now!", _secondsPlayerIn, _newCount], DGBA_MessageName, "debug"] call DGCore_fnc_log;
							
							_notificationTitle = "BASE RAID";
							_notificationMessage = format[ "%1 Bandits are now raiding player base '%2' @ %3", worldName, _baseNm, mapGridPosition _pos];
							if(DGBA_ShowNotification == 1) then // Exile notification
							{
								[
									"toastRequest",
									[
										"InfoEmpty",
										[
											format
											[
												"<t color='#FF0000' size='%1' font='%2'>%3</t><br/><t color='%4' size='%5' font='%6'>%7</t>",
												25,
												"puristaMedium",
												_notificationTitle,
												"#FFFFFF",
												19,
												"PuristaLight",
												_notificationMessage
											]
										]
									]
								] call ExileServer_system_network_send_broadcast;
							};
							if(DGBA_ShowNotification == 2) then // VeMR notification
							{
								["ColorRed", _notificationTitle, _notificationMessage] ExecVM ( "notificationToClient" call VEMFr_fnc_scriptPath );
							};
							
							if(DGBA_EnableAlarmSound) then
							{
								// Add a bit of alarm sounds
								{
									_soundArray = _x;
									_cfgSound = _soundArray select 0;
									_sndLength = _soundArray select 1;
									_pitch = _soundArray select 2;
									_objects = _soundArray select 3;
									
									if (!(isNil "_objects") && (count _objects > 0)) then
									{
										[format["Adding sound '%1' with length = %2 and pitch = %3 to %4 classes! They will loop this sound for %6 seconds in a range of %6m!", _cfgSound, _sndLength, _pitch, (count _objects), DGBA_AlarmSoundTime, DGBA_AlarmSoundRange], DGBA_MessageName, "debug"] call DGCore_fnc_log;
										{
											_nearbyObjects = nearestObjects [_pos, [_x], _baseSize];
											{
												_soundLoop = [_x, _cfgSound, _sndLength, _pitch];
												_soundLoop spawn {
													params ["_object", "_cfgSound", "_sndLength", "_pitch"];
													uiSleep (random 5);
													_timer = 0;
													while {_timer < DGBA_AlarmSoundTime} do
													{
														[_object,[_cfgSound, DGBA_AlarmSoundRange, _pitch]] remoteExec ["say3d",0,true];
														uiSleep _sndLength;
														_timer = _timer + _sndLength;
													};
												};
											} forEach _nearbyObjects;
											[format["Playing this sound on %1 objects with class '%2'!", count _nearbyObjects, _x], DGBA_MessageName, "debug"] call DGCore_fnc_log;
										} forEach _objects;
									};
								} forEach DGBA_AlarmSounds;
							};
							
							// Spawn marker
							_raidMarker = createMarker [format ["%1_%2_%3", "_baseRaidMission", _pos select 0, _pos select 1], _pos];
							if(DGBA_EnableMarker) then
							{
								_raidMarker setMarkerType DGBA_MarkerType;
								_raidMarker setMarkerSize [DGBA_MarkerSize, DGBA_MarkerSize];
								_raidMarker setMarkerColor DGBA_MarkerColor;
								_raidMarker setMarkerText "Base Raid";
							};	
							_mission = [_base, _pos, _raidMarker, _baseNm, _baseSize, _baseLevel];
							_mission spawn
							{
								params ["_base", "_pos", "_raidMarker", "_baseNm", "_baseSize", "_baseLevel"];
								if (isNil "_baseLevel") then
								{
									_baseLevel = 2; // Default
								};
								_enemyWaypointPos = [_pos,0,200,0,0,20,0, [], [_pos, _pos]] call BIS_fnc_findSafePos; // Defaults to _pos or find a valid position for this waypoint
								_enemyWaypointSeaPos = [_pos,0,200,0,2,20,0, [], [_pos, _pos]] call BIS_fnc_findSafePos; // Defaults to _pos or find a valid position for this sea waypoint
								_skillList = DGBA_AIEasySettings;
								_skillText = "EASY";
								if((_baseLevel < (DGBA_BaseLevelRange select 0))) then // EASY 
								{
									_skillList = DGDE_AIEasySettings;
									_skillText = "EASY";
								};
								if((_baseLevel >= (DGBA_BaseLevelRange select 0)) && (_baseLevel < (DGBA_BaseLevelRange select 1))) then // NORMAL 
								{
									_skillList = DGBA_AINormalSettings;
									_skillText = "NORMAL";
								};
								if((_baseLevel >= (DGBA_BaseLevelRange select 1)) && (_baseLevel < (DGBA_BaseLevelRange select 2))) then // HARD 
								{
									_skillList = DGBA_AIHardSettings;
									_skillText = "HARD";
								};
								if((_baseLevel >= (DGBA_BaseLevelRange select 2))) then // EXTREME 
								{
									_skillList = DGBA_AIExtremeSettings;
									_skillText = "EXTREME";
								};
								_maxTroopCount = ((_skillList select 1) call BIS_fnc_randomInt); // We will spawn this amount of troops
								_skillLevel = _skillList select 0;
								_inventoryItems = _skillList select 2; // Instadoc and foot etc.
								_money = ceil(random((_skillList select 3)));
								[format["Target base has level %1. Loading [%6] settings. Spawning %2 AI with skill level %3, maximum of %4 inventory items and maximum of %5 poptabs", _baseLevel, _maxTroopCount, _skillLevel, _inventoryItems, _money, _skillText], DGBA_MessageName, "debug"] call DGCore_fnc_log;
								_totalAICounter = 0;
								_firstGroupCount = _maxTroopCount; // Always spawn
								_secondGroupCount = 0; // Normal + 
								_thirdGroupCount = 0; // Hard + 
								
								_spawnAIVehicleGround = false;
								_spawnAIVehicleAir = false;
								if((_baseLevel >= (DGBA_BaseLevelRange select 1)) && DGBA_AISpawnVehicle) then
								{
									_spawnAIVehicleGround = true;
								};
								if((_baseLevel >= (DGBA_BaseLevelRange select 2)) && DGBA_AISpawnAirdrop) then
								{
									_spawnAIVehicleAir = true;
								};
								
								//diag_log format["%1 Groups to be spawned: 1 (ground):[%2], 2 (vehicle):[%3], 3 (troop airdrop):[%4]", DGBA_MessageName, _firstGroupCount, _secondGroupCount, _thirdGroupCount];
								
								if(_firstGroupCount > 0) then
								{
									_firstGroupPos = [_pos,250,550,3,0,20,0] call BIS_fnc_findSafePos;
									_firstGroup = createGroup east;
									_firstGroup setVariable ["_attackingBase", _base];
									for "_i" from 1 to _firstGroupCount do 
									{
										_unit = _firstGroup createUnit ["O_A_soldier_F", _firstGroupPos, [], 0, "FORM"];
										_totalAICounter = _totalAICounter + 1;
										_unit setCombatMode "RED";
										_unit addMPEventHandler ["MPKILLED",  
										{
											_this spawn
											{
												params ["_unit", "_killer", "_instigator"];
												_group = group _unit;
												_base = _group getVariable "_attackingBase";
												if (isNil "_base") exitWith {};
												_count = _base getVariable "_firstGroupCount";
												if (!isNil "_count") then
												{
													_count = _count - 1;
													_base setVariable ["_firstGroupCount", _count];
												};
												if (isNull _killer || {isNull _instigator}) exitWith {};
												["FD_CP_Clear_F"] remoteExec ["playSound",_instigator];
												if (_instigator isKindOf "Exile_Unit_Player") then
												{
													_msg = format[
														"%1 killed %2 (AI) with %3 at %4 meters!",
														name _instigator, 
														name _unit, 
														getText(configFile >> "CfgWeapons" >> currentWeapon _instigator >> "displayName"), 
														_unit distance _instigator
													];
													[_msg] remoteExec["systemChat",-2];
												};
											};
										}];
										removeAllWeapons _unit;
										removeBackpack _unit;
										removeVest _unit;
										removeHeadgear _unit;
										removeGoggles _unit;
										_unit addVest selectRandom DGBA_AIVests;
										_unit addBackpackGlobal selectRandom DGBA_Backpacks; // Add random backpack
										_unitWeapon = selectRandom DGBA_AIWeapons;
										_ammo = _unitWeapon call DGCore_fnc_selectMagazine;
										for "_i" from 1 to 3 do 
										{ 
											_unit addMagazineGlobal _ammo;
										};
										_unit addWeaponGlobal _unitWeapon;
										_unit addPrimaryWeaponItem selectRandom DGBA_AIWeaponOptics;
										_unit setVariable ["ExileMoney",_money ,true]; // Add some money
										_unit forceAddUniform selectRandom DGBA_SkinList;
										_unit addHeadgear selectRandom DGBA_HeadgearList;
										for "_i" from 1 to _inventoryItems do
										{
											_unit addItem (selectRandom DGBA_AIItems);
										};
										_unit setskill ["aimingAccuracy",_skillLevel];
										_unit setskill ["aimingShake",_skillLevel];
										_unit setskill ["aimingSpeed",_skillLevel];
										_unit setskill ["spotDistance",_skillLevel];
										_unit setskill ["spotTime",_skillLevel];
										_unit setskill ["courage",_skillLevel];
										_unit setskill ["reloadSpeed",_skillLevel];
										_unit setskill ["commanding",_skillLevel];
										_unit setskill ["general",_skillLevel];
									};
									_firstGroup setCombatMode "RED";
									_firstGroup setBehaviour "AWARE";
									
									 _wp = _firstGroup addWaypoint [ _enemyWaypointPos, 20, 1 ];
									 _wp setWaypointBehaviour "AWARE";
									 _wp setWaypointCombatMode "RED";
									 _wp setWaypointCompletionRadius 10;
									 _wp setWaypointFormation "DIAMOND";
									 _wp setWaypointSpeed "FULL";
									 _wp setWaypointType "SAD";
									 _firstGroup setCurrentWaypoint _wp;
									
									[format["Spawned first group %1 @ %2 and it is targeting '%3'", _firstGroup, _firstGroupPos, _baseNm], DGBA_MessageName, "debug"] call DGCore_fnc_log;
									_count = _base getVariable "_firstGroupCount";
									if (!isNil "_count") then
									{
										_count = _count + count(units _firstGroup);
										_base setVariable ["_firstGroupCount", _count];
									} else
									{
										_base setVariable ["_firstGroupCount", count(units _firstGroup)];
									};
									_base setVariable ["_firstGroup", _firstGroup];
								};
								
								if(DGBA_AISpawnVehicle && _spawnAIVehicleGround) then
								{
									_groundVehicleClass = selectRandom DGBA_AIVehicleGround;
									_secondGroupPos = [_pos, 350,1000,2,0,20,0] call BIS_fnc_findSafePos;
									_isNavalInvasion = false;
									if(DGBA_AINavalInvasion) then
									{
										_seaVehicleClass = selectRandom DGBA_AIVehicleSea;
										_seaPos = [_pos, 350,1000,1,2,20,0,[],[[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
										if(_seaPos isEqualTo [0,0,0]) then
										{
											[format["Could not find a valid position for naval invasion. _seaPos equals %1", _seaPos], DGBA_MessageName, "debug"] call DGCore_fnc_log;
										} else
										{
											[format["Found a valid _seaPos @ %1. Spawning naval invasion boat instead of ground vehicle!", _seaPos], DGBA_MessageName, "debug"] call DGCore_fnc_log;
											_secondGroupPos = _seaPos;
											_groundVehicleClass = _seaVehicleClass;
											_isNavalInvasion = true;
										};
									};

									_secondGroup = createGroup east;
									_secondGroup setVariable ["_attackingBase", _base];
									_vehicleObj = createVehicle [_groundVehicleClass, _secondGroupPos, [], 0, "CAN_COLLIDE"];
									_vehicleObj allowDamage true;
									_vehicleObj disableAI "LIGHTS"; // override AI
									_vehicleObj action ["LightOn", _vehicleObj];	
									_vehicleObj spawn
									{
										params ["_vehicleObj"];
										if(!isNil "_vehicleObj" && alive _vehicleObj) then
										{
											_oldPos = getPos _vehicleObj;
											uiSleep 60;
											_newPos = getPos _vehicleObj;
											if ((_newPos distance2D _oldPos) <= 25) then // If vehicle didn't move at all, destroy it.
											{
												_vehicleObj setDamage 1;
											};
										};
									};
									[format["Created a [%1] @ %2", _groundVehicleClass, _secondGroupPos], DGBA_MessageName, "debug"] call DGCore_fnc_log;
									_secondGroupCount = count(fullCrew [_vehicleObj, "", true]);
									if(_secondGroupCount == 0) then
									{
										_secondGroupCount = 2; // At least 2 units on this vehicle
									} else
									{
										if (_secondGroupCount > 5) then
										{
											_secondGroupCount = 5;
										};
									};
									[format["We will be adding %1 units to this %2", _secondGroupCount, _groundVehicleClass], DGBA_MessageName, "debug"] call DGCore_fnc_log;
									for "_i" from 1 to _secondGroupCount do 
									{
										_unit = _secondGroup createUnit ["O_A_soldier_F", _secondGroupPos, [], 0, "FORM"];
										_totalAICounter = _totalAICounter + 1;
										_unit moveInAny _vehicleObj; // Add unit to the vehicle
										_unit setCombatMode "RED";
										_unit addMPEventHandler ["MPKILLED",  
										{
											_this spawn
											{
												params ["_unit", "_killer", "_instigator"];
												_group = group _unit;
												_base = _group getVariable "_attackingBase";
												if (isNil "_base") exitWith {};
												_count = _base getVariable "_secondGroupCount";
												if (!isNil "_count") then
												{
													_count = _count - 1;
													_base setVariable ["_secondGroupCount", _count];
												};
												if (isNull _killer || {isNull _instigator}) exitWith {};
												["FD_CP_Clear_F"] remoteExec ["playSound",_instigator];
												if (_instigator isKindOf "Exile_Unit_Player") then
												{
													_msg = format[
														"%1 killed %2 (AI) with %3 at %4 meters!",
														name _instigator, 
														name _unit, 
														getText(configFile >> "CfgWeapons" >> currentWeapon _instigator >> "displayName"), 
														_unit distance _instigator
													];
													[_msg] remoteExec["systemChat",-2];
												};
											};
										}];
										removeAllWeapons _unit;
										removeBackpack _unit;
										removeVest _unit;
										removeHeadgear _unit;
										removeGoggles _unit;
										_unit addVest selectRandom DGBA_AIVests;
										_unit addBackpackGlobal selectRandom DGBA_Backpacks; // Add random backpack
										_unitWeapon = selectRandom DGBA_AIWeapons;
										_ammo = _unitWeapon call DGCore_fnc_selectMagazine;
										for "_i" from 1 to 3 do 
										{ 
											_unit addMagazineGlobal _ammo;
										};
										_unit addWeaponGlobal _unitWeapon;
										_unit addPrimaryWeaponItem selectRandom DGBA_AIWeaponOptics;
										_unit setVariable ["ExileMoney",_money ,true]; // Add some money
										_unit forceAddUniform selectRandom DGBA_SkinList;
										_unit addHeadgear selectRandom DGBA_HeadgearList;
										for "_i" from 1 to _inventoryItems do
										{
											_unit addItem (selectRandom DGBA_AIItems);
										};
										_unit setskill ["aimingAccuracy",_skillLevel];
										_unit setskill ["aimingShake",_skillLevel];
										_unit setskill ["aimingSpeed",_skillLevel];
										_unit setskill ["spotDistance",_skillLevel];
										_unit setskill ["spotTime",_skillLevel];
										_unit setskill ["courage",_skillLevel];
										_unit setskill ["reloadSpeed",_skillLevel];
										_unit setskill ["commanding",_skillLevel];
										_unit setskill ["general",_skillLevel];
									};
									_secondGroup setCombatMode "RED";
									_secondGroup setBehaviour "COMBAT";
									
									[format["Spawned second group %1 @ %2 and it is targeting '%3'", _secondGroup, _secondGroupPos, _baseNm], DGBA_MessageName, "debug"] call DGCore_fnc_log;
									_wpPos = _enemyWaypointPos;
									if(_isNavalInvasion) then
									{
										_wpPos = _enemyWaypointSeaPos;
									};
									//_secondGroup move _pos;
									 _wp = _secondGroup addWaypoint [ _wpPos, 25, 1 ];
									 _wp setWaypointBehaviour "COMBAT";
									 _wp setWaypointCombatMode "RED";
									 _wp setWaypointCompletionRadius 10;
									 _wp setWaypointFormation "DIAMOND";
									 _wp setWaypointSpeed "FULL";
									 _wp setWaypointType "SAD";
									 _secondGroup setCurrentWaypoint _wp;
									
									_count = _base getVariable "_secondGroupCount";
									if (!isNil "_count") then
									{
										_count = _count + count(units _secondGroup);
										_base setVariable ["_secondGroupCount", _count];
									} else
									{
										_base setVariable ["_secondGroupCount", count(units _secondGroup)];
									};
									_base setVariable ["_secondGroup", _secondGroup];
								};
								
								if(DGBA_AISpawnAirdrop && _spawnAIVehicleAir) then
								{
									_airVehicleClass = selectRandom DGBA_AIVehicleAir;
									_thirdGroupPos = [_pos, 750,6000,10,0,0.5,0] call BIS_fnc_findSafePos; // Heli
									_heliDirection = random 360;
									_dir = ((_thirdGroupPos select 0) - (_thirdGroupPos select 0)) atan2 ((_thirdGroupPos select 1) - (_thirdGroupPos select 1));
									//_flyPosition = [(_thirdGroupPos select 0) + (sin _dir) * 2000, (_thirdGroupPos select 1) + (cos _dir) * 2000, (_thirdGroupPos select 2) + 200];
									
									_thirdGroup = createGroup east;
									_thirdGroup setVariable ["_attackingBase", _base];
									[_thirdGroup, _thirdGroupPos] spawn
									{
										params ["_thirdGroup", "_thirdGroupPos"];
										_oldPos = _thirdGroupPos;
										uiSleep 120; // Wait 2 minutes
										{
											_newPos = getPos _x;
											if ((_newPos distance2D _oldPos) <= 100) then
											{
												_x setDamage 1;
												deleteVehicle _x;
											};
										} forEach units _thirdGroup;
									};
									_aircraftObject = createVehicle [_airVehicleClass, _thirdGroupPos, [], 0, "CAN_COLLIDE"];
									_aircraftObject disableAI "LIGHTS"; // override AI
									_aircraftObject action ["LightOn", _aircraftObject];
									_aircraftObject setCollisionLight true;
									_aircraftObject allowDamage false;
									[_aircraftObject, _thirdGroup] spawn
									{
										params ["_aircraftObject", "_thirdGroup"];
										if(!isNil "_aircraftObject" && alive _aircraftObject) then
										{
											_oldPos = getPos _aircraftObject;
											uiSleep 180; // Taking off etc might take some time
											_newPos = getPos _aircraftObject;
											if ((_newPos distance2D _oldPos) <= 100) then // If vehicle didn't move at all, destroy it.
											{
												_aircraftObject allowDamage true;
												deleteVehicleCrew _aircraftObject;
												_aircraftObject setDamage 1;
												deleteVehicle _aircraftObject;
												{
													_x setDamage 1;
													deleteVehicle _x;
												} foreach units _thirdGroup;
											};
										};
									};
									//_aircraftObject setPosATL (_vehicleObj modelToWorld [0,0,75]);
									_spawnAngle = [_thirdGroupPos,_pos] call BIS_fnc_dirTo;
									_aircraftObject setDir _spawnAngle;
									//_vehicleObj setVelocity [100 * (sin _spawnAngle), 100 * (cos _spawnAngle), 0];
									//_aircraftObject flyInHeight 50;

									_pilotGroup = createGroup east;
									_pilotGroup setCombatMode "BLUE";
									_pilotGroup setBehaviour "CARELESS";
									_pilotCrew = driver _aircraftObject;
									_pilotCrew = _pilotGroup createUnit ["O_A_soldier_F", _thirdGroupPos, [], 0, "NONE"];
									_pilotCrew moveInDriver _aircraftObject;
									_pilotCrew allowDamage false;
									
									[format["Created a [%1] @ %2", _airVehicleClass, _thirdGroupPos], DGBA_MessageName, "debug"] call DGCore_fnc_log;
									_thirdGroupCount = (count(fullCrew [_aircraftObject, "", true]) -1); // Minus pilot
									if(_thirdGroupCount == -1) exitWith
									{
										// Vehicle failed to create
										deleteVehicleCrew _aircraftObject;
										deleteVehicle _pilotCrew;
										deleteVehicle _aircraftObject;
									};
									if(_thirdGroupCount == 0) then
									{
										_thirdGroupCount = 1; // Spawn at least 1 other dude
									} else
									{
										if (_thirdGroupCount > 8) then
										{
											_thirdGroupCount = 8;
										};
									};
									[format["We will be adding %1 units to this %2", _thirdGroupCount, _airVehicleClass], DGBA_MessageName, "debug"] call DGCore_fnc_log;
									for "_i" from 1 to _thirdGroupCount do 
									{
										_unit = _thirdGroup createUnit ["O_A_soldier_F", _thirdGroupPos, [], 0, "FORM"];
										//_unit assignAsCargo _aircraftObject; // Assign unit to the cargo
										_unit setCombatMode "RED";
										_unit addMPEventHandler ["MPKILLED",  
										{
											_this spawn
											{
												params ["_unit", "_killer", "_instigator"];
												_group = group _unit;
												_base = _group getVariable "_attackingBase";
												if (isNil "_base") exitWith {};
												_count = _base getVariable "_thirdGroupCount";
												if (!isNil "_count") then
												{
													_count = _count - 1;
													_base setVariable ["_thirdGroupCount", _count];
												};
												if (isNull _killer || {isNull _instigator}) exitWith {};
												["FD_CP_Clear_F"] remoteExec ["playSound",_instigator];
												if (_instigator isKindOf "Exile_Unit_Player") then
												{
													_msg = format[
														"%1 killed %2 (AI) with %3 at %4 meters!",
														name _instigator, 
														name _unit, 
														getText(configFile >> "CfgWeapons" >> currentWeapon _instigator >> "displayName"), 
														_unit distance _instigator
													];
													[_msg] remoteExec["systemChat",-2];
												};
											};
										}];
										removeAllWeapons _unit;
										removeBackpack _unit;
										removeVest _unit;
										removeHeadgear _unit;
										removeGoggles _unit;
										_unit addVest selectRandom DGBA_AIVests;
										_unit addBackpackGlobal selectRandom DGBA_Backpacks; // Add random backpack
										_unitWeapon = selectRandom DGBA_AIWeapons;
										_ammo = _unitWeapon call DGCore_fnc_selectMagazine;
										for "_i" from 1 to 3 do 
										{ 
											_unit addMagazineGlobal _ammo;
										};
										_unit addWeaponGlobal _unitWeapon;
										_unit addPrimaryWeaponItem selectRandom DGBA_AIWeaponOptics;
										_unit setVariable ["ExileMoney",_money ,true]; // Add some money
										_unit forceAddUniform selectRandom DGBA_SkinList;
										_unit addHeadgear selectRandom DGBA_HeadgearList;
										for "_i" from 1 to _inventoryItems do
										{
											_unit addItem (selectRandom DGBA_AIItems);
										};
										_unit setskill ["aimingAccuracy",_skillLevel];
										_unit setskill ["aimingShake",_skillLevel];
										_unit setskill ["aimingSpeed",_skillLevel];
										_unit setskill ["spotDistance",_skillLevel];
										_unit setskill ["spotTime",_skillLevel];
										_unit setskill ["courage",_skillLevel];
										_unit setskill ["reloadSpeed",_skillLevel];
										_unit setskill ["commanding",_skillLevel];
										_unit setskill ["general",_skillLevel];
									};
									//_thirdGroup addVehicle _aircraftObject;
									_thirdGroup setCombatMode "BLUE";
									_thirdGroup setBehaviour "CARELESS";
									[format["Spawned third group %1 @ %2 and it is targeting '%3'", _thirdGroup, _thirdGroupPos, _baseNm], DGBA_MessageName, "debug"] call DGCore_fnc_log;
									
									_commanderFree = _aircraftObject emptyPositions "Commander";
									_gunnerFree = _aircraftObject emptyPositions "Gunner";
									_turretFree = _aircraftObject emptyPositions "Turret";
									_cargoFree = _aircraftObject emptyPositions "Cargo";
									
									{ // Assign units to the aircraft and let them move in
										if(_commanderFree > 0) then
										{
											_commanderFree = _commanderFree -1;
											_x assignAsCommander _aircraftObject;
											[_x] orderGetIn true;
										};
										if (_gunnerFree > 0) then
										{
											_gunnerFree = _gunnerFree - 1;
											_x assignAsGunner _aircraftObject;
											[_x] orderGetIn true;
										};
										if (_turretFree > 0) then
										{
											_turretFree = _turretFree -1;
											_x assignAsTurret _aircraftObject;
											[_x] orderGetIn true;
										};
										if (_cargoFree > 0) then
										{
											_cargoFree = _cargoFree -1;
											_x assignAsCargo _aircraftObject;
											[_x] orderGetIn true;
										};
										if(_commanderFree == 0 && _gunnerFree == 0 && _turretFree == 0 && _cargoFree == 0) then
										{
											_x setDamage 1; // Kill of unit because there are no more seats!
										};
										if(alive _x) then
										{
											_totalAICounter = _totalAICounter + 1;
											[format["Assigned %1 to the %2 with position %3", _x, _airVehicleClass, (assignedVehicleRole _x select 0)], DGBA_MessageName, "debug"] call DGCore_fnc_log;
											waitUntil {vehicle _x == _x};
											[format["%1 is now in the %2", _x, _airVehicleClass], DGBA_MessageName, "debug"] call DGCore_fnc_log;
										};
									} forEach units _thirdGroup;
									
									_pilotCrew allowDamage true;
									_aircraftObject allowDamage true;
									
									_heliSpawnCode = [_aircraftObject, _pos, _pilotGroup, _thirdGroup, _baseNm, _thirdGroupPos];
									_heliSpawnCode spawn
									{
										params ["_aircraftObject", "_pos", "_pilotGroup", "_thirdGroup", "_baseNm", "_thirdGroupPos"];
										_wp0 = _pilotGroup addWaypoint [_pos, 0, 1];
										[_pilotGroup,1] setWaypointBehaviour "CARELESS";
										[_pilotGroup,1] setWaypointCombatMode "BLUE";
										[_pilotGroup,1] setWaypointSpeed "FULL";
										waitUntil { (currentWaypoint (_pilotGroup)) > 1};
										[format["Aircraft reached base '%1'. Current waypoint: %2", _baseNm, currentWaypoint (_pilotGroup)], DGBA_MessageName, "debug"] call DGCore_fnc_log;
										while { alive _aircraftObject && not unitReady _aircraftObject } do
										{
											uiSleep 1;
										};
										if (alive _aircraftObject) then
										{
											_aircraftObject land "GET OUT";
										};
										
										waitUntil { uiSleep 1; (getPosATL _aircraftObject select 2) <= 0.5 };
										{
											doGetOut _x;
											unassignVehicle _x; 
											diag_log format["%1 %2 is now off the %3", DGBA_MessageName, _x, _aircraftObject];
										} foreach units _thirdGroup;
										uiSleep 5;
										
										//_aircraftObject allowDamage true;
										{ _x allowDamage true; } forEach units _pilotGroup;
										[format["Aircraft reached base '%1' and landed. Unloaded troops. Current waypoint: %2", _baseNm, currentWaypoint (_pilotGroup)], DGBA_MessageName, "debug"] call DGCore_fnc_log;
										_thirdGroup setCombatMode "RED";
										_thirdGroup setBehaviour "COMBAT";
										 _wp = _thirdGroup addWaypoint [ _enemyWaypointPos, 25, 1 ];
										 _wp setWaypointBehaviour "COMBAT";
										 _wp setWaypointCombatMode "RED";
										 _wp setWaypointCompletionRadius 10;
										 _wp setWaypointFormation "DIAMOND";
										 _wp setWaypointSpeed "FULL";
										 _wp setWaypointType "SAD";
										 _thirdGroup setCurrentWaypoint _wp;
										
										_pilotGroup move _thirdGroupPos;
										while {alive _aircraftObject} do
										{
											if (((getPos _aircraftObject) distance2D _thirdGroupPos) <= 150) exitWith {
												[format["The %1 reached its end. Cleaning up the aircraft.", _aircraftObject], DGBA_MessageName, "debug"] call DGCore_fnc_log;
												deleteVehicleCrew _aircraftObject;
												deleteGroup _pilotGroup;
												deleteVehicle _aircraftObject;
											};
											uiSleep 2;
										};
									};
									
									_count = _base getVariable "_thirdGroupCount";
									if (!isNil "_count") then
									{
										_count = _count + count(units _thirdGroup);
										_base setVariable ["_thirdGroupCount", _count];
									} else
									{
										_base setVariable ["_thirdGroupCount", count(units _thirdGroup)];
									};
									_base setVariable ["_thirdGroup", _thirdGroup];
								};
								
								while {true} do // Continue until all AI are dead.
								{
									_newCount = 0;
									_firstGroup = _base getVariable "_firstGroup";
									if !(isNil "_firstGroup") then
									{
										_newCount = _newCount + ({alive _x } count(units _firstGroup));
									};
									_secondGroup = _base getVariable "_secondGroup";
									if !(isNil "_secondGroup") then
									{
										_newCount = _newCount + ({alive _x } count(units _secondGroup));
									};
									_thirdGroup = _base getVariable "_thirdGroup";
									if !(isNil "_thirdGroup") then
									{
										_newCount = _newCount + ({alive _x } count(units _thirdGroup));
									};
									
									if (DGBA_CountAliveAI) then
									{
										if(_newCount == 1) then
										{
											_raidMarker setMarkerText format["%1 (%2 Unit remaining)", "Base Raid", _newCount];
										} else
										{
											_raidMarker setMarkerText format["%1 (%2 Units remaining)", "Base Raid", _newCount];
										};
									};
									uiSleep 5;
								
									_finished = false;
									if (_newCount < 1) exitWith
									{
										_finished = true;
										[format["Base with name '%1' has no more AI remaining! Base raid over", _baseNm], DGBA_MessageName, "debug"] call DGCore_fnc_log;
									};
									if (_finished) exitWith {};
								};
								
								_endTitle = "BASE RAID";
								_endMessage = format[ "The raid on base '%1' has ended!",_baseNm];
								if(DGBA_ShowNotification == 1) then // Exile notification
								{
									[
										"toastRequest",
										[
											"SuccessEmpty",
											[
												format
												[
													"<t color='#0080ff' size='%1' font='%2'>%3</t><br/><t color='%4' size='%5' font='%6'>%7</t>",
													25,
													"puristaMedium",
													_endTitle,
													"#FFFFFF",
													19,
													"PuristaLight",
													_endMessage
												]
											]
										]
									] call ExileServer_system_network_send_broadcast;
								};
								if(DGBA_ShowNotification == 2) then // VeMR notification
								{
									[ "ColorWhite", _endTitle, _endMessage ] ExecVM ( "notificationToClient" call VEMFr_fnc_scriptPath );
								};

								deleteMarker _raidMarker;
								DGBA_RaidQueue deleteAt ( DGBA_RaidQueue find _base );
							};
						};
					} else
					{
						DGBA_RaidQueue deleteAt ( DGBA_RaidQueue find _base );
						//DGBA_AttackedBases deleteAt ( DGBA_AttackedBases find _base );
						[format["After waiting %1 seconds, there are no more players on the base [%2] that was initialized to be raided!", _waitedSeconds, _base], DGBA_MessageName, "warning"] call DGCore_fnc_log;
					};
				};
			};
		} else 
		{
			["There are currently no players on bases that can be raided!", DGBA_MessageName, "warning"] call DGCore_fnc_log;
		};
	};
	_reInitialize = true;

	
	_baseNames = []; // Array containing attacked base names
	{
		_localName = _x getVariable "exileterritoryname";
		if !(isNil "_localName") then
		{
			_baseNames pushBack _localName;
		} else
		{
			_baseNames pushBack (position _x);
		};
	} forEach DGBA_AttackedBases;
	[format["List of raided bases [%1]: %2", count DGBA_AttackedBases,_baseNames], DGBA_MessageName, "debug"] call DGCore_fnc_log;
	
	_queueBaseNames = []; // Array containing queued base names
	{
		_localName = _x getVariable "exileterritoryname";
		if !(isNil "_localName") then
		{
			_queueBaseNames pushBack _localName;
		} else
		{
			_queueBaseNames pushBack (position _x);
		};
	} forEach DGBA_RaidQueue;
	[format["List of queued bases [%1]: %2", count DGBA_RaidQueue,_queueBaseNames], DGBA_MessageName, "debug"] call DGCore_fnc_log;
	[format["Waiting %1 seconds for next base raid iteration", DGBA_SleepTime], DGBA_MessageName, "debug"] call DGCore_fnc_log;
	uiSleep DGBA_SleepTime;
};