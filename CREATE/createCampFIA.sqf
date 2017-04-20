if (!isServer and hasInterface) exitWith {};

private ["_marcador","_posicion","_grupo","_campGroup","_fire"];

_objs = [];

_marcador = _this select 0;
_posicion = getMarkerPos _marcador;

_camp = selectRandom AS_campList;
_posicion = _posicion findEmptyPosition [5,50,"I_Heli_Transport_02_F"];
_objs = [_posicion, floor(random 361), _camp] call BIS_fnc_ObjectsMapper;

sleep 2;

{
	call {
		if (typeof _x == campCrate) exitWith {[_x] call cajaAAF; [[_x,"heal_camp"],"AS_fnc_addActionMP"] call BIS_fnc_MP;};
		if (typeof _x == "Land_MetalBarrel_F") exitWith {[[_x,"refuel"],"AS_fnc_addActionMP"] call BIS_fnc_MP;};
		if (typeof _x == "Land_Campfire_F") exitWith {_fire = _x;};
	};
	_surface = surfaceNormal (position _x);
	_x setVectorUp _surface;
} forEach _objs;

_grupo = [_posicion, side_blue, ([guer_grp_sniper, "guer"] call AS_fnc_pickGroup)] call BIS_Fnc_spawnGroup;
_grupo setBehaviour "STEALTH";
_grupo setCombatMode "GREEN";

{[_x] spawn AS_fnc_initialiseFIAGarrisonUnit;} forEach units _grupo;

_shorecheck = [_posicion, 0, 50, 0, 0, 0, 1, [], [0]] call BIS_fnc_findSafePos;
if ((typename _shorecheck) == "ARRAY") then {[[_fire,"seaport"],"AS_fnc_addActionMP"] call BIS_fnc_MP;};

sleep 10;
_fire inflame true;

waitUntil {sleep 5; (not(spawner getVariable _marcador)) or ({alive _x} count units _grupo == 0) or (not(_marcador in campsFIA))};

if ({alive _x} count units _grupo == 0) then
	{
	campsFIA = campsFIA - [_marcador]; publicVariable "campsFIA";
	campList = campList - [[_marcador, markerText _marcador]]; publicVariable "campList";
	usedCN = usedCN - [markerText _marcador]; publicVariable "usedCN";
	marcadores = marcadores - [_marcador]; publicVariable "marcadores";
	deleteMarker _marcador;
	[["TaskFailed", ["", "Camp Lost"]],"BIS_fnc_showNotification"] call BIS_fnc_MP;
	};

waitUntil {sleep 5; (not(spawner getVariable _marcador)) or (not(_marcador in campsFIA))};

{deleteVehicle _x} forEach units _grupo;
deleteGroup _grupo;

_fire inflame false;
sleep 2;
{deleteVehicle _x} forEach _objs;
