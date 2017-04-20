if (!isServer and hasInterface) exitWith{};

_tskTitle = localize "Str_tsk_resRefugees";
_tskDesc = localize "Str_tskDesc_resRefugees";

_marcador = _this select 0;
_posicion = getMarkerPos _marcador;

_POWs = [];

_tam = [_marcador] call sizeMarker;
_casas = nearestObjects [_posicion, ["house"], _tam];
_poscasa = [];
_casa = _casas select 0;
while {count _poscasa < 5} do
	{
	_casa = _casas call BIS_Fnc_selectRandom;
	_poscasa = [_casa] call BIS_fnc_buildingPositions;
	if (count _poscasa < 5) then {_casas = _casas - [_casa]};
	};

_nombredest = [_marcador] call AS_fnc_localizar;

_tsk = ["RES",[side_blue,civilian],[format [_tskDesc,_nombredest, A3_Str_INDEP],_tskTitle,_marcador],getPos _casa,"CREATED",5,true,true,"run"] call BIS_fnc_setTask;
misiones pushBack _tsk; publicVariable "misiones";

_grupo = createGroup side_blue;

_num = count _poscasa;
if (_num > 8) then {_num = 8};

for "_i" from 1 to (_num) - 1 do
	{
	_unit = _grupo createUnit [guer_POW, _poscasa select _i, [], 0, "NONE"];
	_unit allowdamage false;
	_unit disableAI "MOVE";
	_unit disableAI "AUTOTARGET";
	_unit disableAI "TARGET";
	_unit setBehaviour "CARELESS";
	_unit allowFleeing 0;
	_unit setSkill 0;
	removeHeadgear _unit;
	removeGoggles _unit;
	removeAllWeapons _unit;
	removeVest _unit;
	removeBackpack _unit;
	_POWs = _POWs + [_unit];
	[[_unit,"refugiado"],"AS_fnc_addActionMP"] call BIS_fnc_MP;
	};

sleep 5;

{_x allowDamage true} forEach _POWs;

sleep 30;

[_casa] spawn
	{
	private ["_casa"];
	_casa = _this select 0;
	sleep 300 + (random 1800);
	if ("RES" in misiones) then {[position _casa] remoteExec ["patrolCA",HCattack]};
	};

waitUntil {sleep 1; ({alive _x} count _POWs == 0) or ({(alive _x) and (_x distance getMarkerPos guer_respawn < 50)} count _POWs > 0)};

if ({alive _x} count _POWs == 0) then
	{
	_tsk = ["RES",[side_blue,civilian],[format [_tskDesc,_marcador, A3_Str_INDEP],_tskTitle,_nombredest],getPos _casa,"FAILED",5,true,true,"run"] call BIS_fnc_setTask;
	_cuenta = count _POWs;
	[_cuenta,0] remoteExec ["prestige",2];
	[0,-15,_posicion] remoteExec ["AS_fnc_changeCitySupport",2];
	[-10,Slowhand] call playerScoreAdd;
	}
else
	{
	_tsk = ["RES",[side_blue,civilian],[format [_tskDesc,_marcador, A3_Str_INDEP],_tskTitle,_nombredest],getPos _casa,"SUCCEEDED",5,true,true,"run"] call BIS_fnc_setTask;
	_cuenta = {(alive _x) and (_x distance getMarkerPos guer_respawn < 150)} count _POWs;
	_hr = _cuenta;
	_resourcesFIA = 100 * _cuenta;
	[_hr,_resourcesFIA] remoteExec ["resourcesFIA",2];
	[0,_cuenta,_marcador] remoteExec ["AS_fnc_changeCitySupport",2];
	[_cuenta,0] remoteExec ["prestige",2];
	{if (_x distance getMarkerPos guer_respawn < 500) then {[_cuenta,_x] call playerScoreAdd}} forEach (allPlayers - hcArray);
	[round (_cuenta/2),Slowhand] call playerScoreAdd;
	{[_x] join _grupo; [_x] orderGetin false} forEach _POWs;
	// BE module
	if (activeBE) then {
		["mis"] remoteExec ["fnc_BE_XP", 2];
	};
	// BE module
	};


sleep 60;
{deleteVehicle _x} forEach _POWs;
deleteGroup _grupo;

[1200,_tsk] spawn borrarTask;