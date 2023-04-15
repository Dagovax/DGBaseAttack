waitUntil {uiSleep 5; !(isNil "DGCore_Initialized")}; // Wait until DGCore was initialized

["Starting Dagovax Games Base Attacks"] call DGCore_fnc_log;
execvm "\x\addons\a3_dg_baseAttack\config\DG_config.sqf";
execvm "\x\addons\a3_dg_baseAttack\init\baseAttack.sqf";
