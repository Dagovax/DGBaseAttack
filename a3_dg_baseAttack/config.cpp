class CfgPatches {
	class a3_dg_baseAttack {
		units[] = {};
		weapons[] = {};
		requiredVersion = 0.1;
		requiredAddons[] = {};
	};
};
class CfgFunctions {
	class DGBaseAttack {
		tag = "DGBaseAttack";
		class Main {
			file = "\x\addons\a3_dg_baseAttack\init";
			class init {
				postInit = 1;
			};
		};
	};
};
