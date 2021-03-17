/*
	Moves civ to a destination.
*/
params["_civ","_center","_range","_blacklist","_housesInRange"];
private["_animations"];

if (isNil "_blacklist") then { _blacklist = []; };
if (isNil "_housesInRange") then { _housesInRange = []; };

if (count _housesInRange < 1) then
{
	_housesInRange = [_center,_range,_blacklist] call AZC_fnc_GetBuildings;
};

_animations = ["AmovPercMstpSnonWnonDnon_gear","HubBriefing_lookAround2","HubStandingUC_move1","HubStandingUC_move2","HubStandingUB_move1","HubBriefing_think","HubStandingUB_move2","HubStandingUC_idle1","HubStandingUC_idle2","HubStandingUC_idle3","InBaseMoves_HandsBehindBack1","InBaseMoves_HandsBehindBack2","AmovPsitMstpSnonWnonDnon_ground","AmovPsitMstpSrasWrflDnon_Smoking","AmovPsitMstpSnonWnonDnon_smoking","Acts_CivilIdle_1","Acts_CivilIdle_2","Acts_CivilListening_1","Acts_CivilListening_2","Acts_CivilShocked_1","Acts_CivilShocked_2","Acts_CivilTalking_1","Acts_CivilTalking_2"];

if (count _housesInRange > 0) then
{
	_panic = false;
	while { alive _civ && !_panic } do
	{
		sleep 1;
		_targetHouse = selectRandom _housesInRange;
		if (!(isNull _targetHouse && (typeName _targetHouse == "OBJECT"))) then
		{
			_destPos = getPos _targetHouse;
			_startLoc = getPos _civ;
			
			// does destination building have positions?
			_buildingPositions = [_targetHouse] call BIS_fnc_buildingPositions;
			if (count _buildingPositions > 0) then
			{
				_index = floor random(count _buildingPositions);
				_destPos = _buildingPositions select _index;
			};
			
			if (typeName _destPos != "ARRAY") then { _destPos = getPos player; };
			_civ doMove _destPos;
			_civ setUnitPos "UP";
			// testing AWARE to keep them off the roadways
			_civ setBehaviour "AWARE";
			_civ forceWalk true;
			_civ setVariable ["AZC_CIV_OTM",true];
			[format["Civ %1 is moving to %2. Panic? %3",_civ,_destPos,(_civ getVariable ["AZC_PANIC",false])],false,true] call AZC_fnc_Debug;
			
			sleep 5;
			waitUntil {
				sleep 0.5;
				isNull _civ
				|| !(alive _civ)
				|| (_civ getVariable ["AZC_PANIC",false])
				|| (speed _civ < 0.1)
			};
			
			if (isNull _civ || !(alive _civ)) exitWith {};
			if (_panic) exitWith { [_civ] spawn AZC_fnc_CivRun; };
			
			// did Civ stop on the road like a dork?
			if (isOnRoad _civ) then { continue }; // repeat destination loop

			// are any other people within 30m?
			_nearby = [_civ] call AZC_fnc_GetClosestHuman;
			if (!isNull _nearby) then
			{
				_direction = [_civ,_nearby] call BIS_fnc_dirTo;
				_civ setFormDir _direction;
				_civ setDir _direction;
				_civ doWatch _nearby;
				_civ lookAt _nearby;
			};
			
			_anim = _animations select floor(random(count _animations));
			_civ disableAI "ANIM";
			_civ switchMove _anim;
			_civ setVariable ["AZC_CIV_OTM",false];

			// time to wait at destination
			_wait = floor random(30) + time + 10;
			if (_startLoc distance _civ < 5) then { _wait = time; };
			waitUntil { isNull _civ || ((time > _wait) || (_civ getVariable ["AZC_PANIC",false])) };
			if (isNull _civ || !(alive _civ)) exitWith {};
			_panic = _civ getVariable ["AZC_PANIC",false];
			if (_panic) exitWith { [_civ] spawn AZC_fnc_CivRun; };
			if (!_panic) then
			{
				_civ doWatch objNull;
				_civ lookAt objNull;
				_civ enableAI "ANIM";
				_civ switchMove "";
			};
		};
	};
};