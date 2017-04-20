player enableFatigue false;
player enableStamina false;
player setCustomAimCoef 0.1;

if (isDedicated) exitWith {};
private ["_nuevo","_viejo"];
_nuevo = _this select 0;
_viejo = _this select 1;

if (isNull _viejo) exitWith {};

waitUntil {alive player};

[_viejo] spawn postmortem;

_owner = _viejo getVariable ["owner",_viejo];

if (_owner != _viejo) exitWith {hint "Died while AI Remote Control"; selectPlayer _owner; disableUserInput false; deleteVehicle _nuevo};

[0,-1,getPos _viejo] remoteExec ["AS_fnc_changeCitySupport",2];

_score = _viejo getVariable ["score",0];
_punish = _viejo getVariable ["punish",0];
_dinero = _viejo getVariable ["dinero",0];
_dinero = round (_dinero - (_dinero * 0.1));
_elegible = _viejo getVariable ["elegible",true];
_rango = _viejo getVariable ["rango","PRIVATE"];

_dinero = round (_dinero - (_dinero * 0.05));
if (_dinero < 0) then {_dinero = 0};

_nuevo setVariable ["score",_score -1,true];
_nuevo setVariable ["owner",_nuevo,true];
_nuevo setVariable ["punish",_punish,true];
_nuevo setVariable ["respawning",false];
_nuevo setVariable ["dinero",_dinero,true];
//_nuevo setUnitRank (rank _viejo);
_nuevo setVariable ["compromised",0];
_nuevo setVariable ["elegible",_elegible,true];
_nuevo setVariable ["BLUFORSpawn",true,true];
_viejo setVariable ["BLUFORSpawn",nil,true];
_nuevo setCaptive false;
_nuevo setRank (_rango);
_nuevo setVariable ["rango",_rango,true];
//if (!activeACEMedical) then {[_nuevo] call initRevive};
disableUserInput false;
//_nuevo enableSimulation true;
if (_viejo == Slowhand) then
	{
	[_nuevo] call stavrosInit;
	};


removeAllItemsWithMagazines _nuevo;
{_nuevo removeWeaponGlobal _x} forEach weapons _nuevo;
removeBackpackGlobal _nuevo;
removeVest _nuevo;
if ((not("ItemGPS" in unlockedItems)) and ("ItemGPS" in (assignedItems _nuevo))) then {_nuevo unlinkItem "ItemGPS"};
if ((!activeTFAR) and ("ItemRadio" in (assignedItems player)) and (not("ItemRadio" in unlockedItems))) then {player unlinkItem "ItemRadio"};
if (!isPlayer (leader group player)) then {(group player) selectLeader player};
player addEventHandler ["FIRED",
	{
	_player = _this select 0;
	if (captive _player) then
		{
		if ({((side _x== side_red) or (side _x== side_green)) and (_x knowsAbout player > 1.4)} count allUnits > 0) then
			{
			_player setCaptive false;
			if (vehicle _player != _player) then
				{
				{if (isPlayer _x) then {[_x,false] remoteExec ["setCaptive",_x];}} forEach ((assignedCargo (vehicle _player)) + (crew (vehicle _player)));
				};
			}
		else
			{
			_ciudad = [ciudades,_player] call BIS_fnc_nearestPosition;
			_size = [_ciudad] call sizeMarker;
			_datos = server getVariable _ciudad;
			if (random 100 < _datos select 2) then
				{
				if (_player distance getMarkerPos _ciudad < _size * 1.5) then
					{
					_player setCaptive false;
					if (vehicle _player != _player) then
						{
						{if (isPlayer _x) then {[_x,false] remoteExec ["setCaptive",_x];}} forEach ((assignedCargo (vehicle _player)) + (crew (vehicle _player)));
						};
					};
				};
			};
		}
	}
	];

player addEventHandler ["InventoryOpened",
	{
	_control = false;
	//if !(isnull (uinamespace getvariable ["BIS_fnc_arsenal_cam",objnull])) then
	if (_this select 1 == caja) then
		{
		if !([_this select 0] call isMember) then
			{
			_control = true;
			hint "You are not in the Member's List of this Server.\n\nAsk the Commander in order to be allowed to access the HQ Ammobox.\n\nIn the meantime you may use the other box to store equipment and share it with others.";
			};
		};
	_control
	}];
player addEventHandler ["Fired",
		{
		_tipo = _this select 1;
		if ((_tipo == "Put") or (_tipo == "Throw")) then
			{
			if (player distance petros < 50) then
				{
				deleteVehicle (_this select 6);
				if (_tipo == "Put") then
					{
					if (player distance petros < 10) then {[player,60] spawn AS_fnc_punishPlayer};
					};
				};
			};
		}];
player addEventHandler ["HandleHeal",
	{
	_player = _this select 0;
	if (captive _player) then
		{
		if ({((side _x== side_red) or (side _x== side_green)) and (_x knowsAbout player > 1.4)} count allUnits > 0) then
			{
			_player setCaptive false;
			}
		else
			{
			_ciudad = [ciudades,_player] call BIS_fnc_nearestPosition;
			_size = [_ciudad] call sizeMarker;
			_datos = server getVariable _ciudad;
			if (random 100 < _datos select 2) then
				{
				if (_player distance getMarkerPos _ciudad < _size * 1.5) then
					{
					_player setCaptive false;
					};
				};
			};
		}
	}
	];
player addEventHandler ["WeaponAssembled",{
	params ["_EHunit", "_EHobj"];
	if (_EHunit isKindOf "StaticWeapon") then {
		_EHobj addAction [localize "Str_act_moveAsset", {[_this select 0,_this select 1,_this select 2,"static"] spawn AS_fnc_moveObject},nil,0,false,true,"","(_this == Slowhand)"];
		if !(_EHunit in staticsToSave) then {
			staticsToSave pushBack _EHunit;
			publicVariable "staticsToSave";
			[_EHunit] spawn VEHinit;
		};
	} else {
		_EHobj addEventHandler ["Killed",{[_this select 0] remoteExec ["postmortem",2]}];
	};
}];
player addEventHandler ["WeaponDisassembled",
		{
		_bag1 = _this select 1;
		_bag2 = _this select 2;
		//_bag1 = objectParent (_this select 1);
		//_bag2 = objectParent (_this select 2);
		[_bag1] spawn VEHinit;
		[_bag2] spawn VEHinit;
		}
	];

player addEventHandler ["InventoryClosed", {
	[] spawn AS_fnc_skillAdjustments;
}];

player addEventHandler ["Take",{
	[] spawn AS_fnc_skillAdjustments;
}];

[missionNamespace, "arsenalClosed", {
	[] spawn AS_fnc_skillAdjustments;
}] call BIS_fnc_addScriptedEventHandler;

if (!(isMultiplayer) && (activeACEMedical)) then {
	player setVariable ["inconsciente",false,true];
	player setVariable ["respawning",false];
	player addEventHandler ["HandleDamage", {
		if (player getVariable ["ACE_isUnconscious", false]) then {
			0 = [player] spawn ACErespawn;
		};
	}
	];
};

[0,true] remoteExec ["pBarMP",player];
[true] execVM "reinitY.sqf";
statistics= [] execVM "statistics.sqf";

[player] execVM "OrgPlayers\unitTraits.sqf";
0 = [player] spawn rankCheck;