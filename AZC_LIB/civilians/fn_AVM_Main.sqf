if (isNil "AZC_Debug") then { AZC_Debug = false; };

// handles central part of AVM spawning loop
params ["_vehicleList","_chanceCrew","_nearestLocation","_origins","_whiteList","_blacklist"];
_activeSpawns = count(_vehicleList);
if (_activeSpawns >= _maxVehicles) exitWith { _vehicleList };
if (_nearestLocation isNotEqualTo [[0,0,0],0]) then
{
	_hasCrew = false;
	if ((floor(random(100))) < _chanceCrew) then
	{
		_hasCrew = true;
	};

	// where will vehicle be spawned?
	// if empty, must be _nearestLocation
	_spawnLocation = _nearestLocation;
	// 75% of all spawned cars will be local, 25% can be any nearby origin location
	_rand = random(100);
	if ((count _origins > 0) && _hasCrew && (_rand > 75)) then
	{
		_index = floor random(count(_origins));
		_spawnLocation = _origins select _index;
	};
	
	//systemChat format["_spawnLocation: %1, _origins: %2",_spawnLocation, _origins];
	//get houses for location
	_towns = missionNamespace getVariable "AZC_AVM_TOWNS";
	if (isNil "_towns") then { _towns = []; };
	// iterate through _towns to see if buildings were already saved, if not then get the buildings
	// AZC_fnc_GetBuildings can take several seconds to return after the game runs awhile which is
	// why we store buildings in the missionNamespace
	
	_spawnPosition = _spawnLocation select 0;
	_housesInRange = [];

	{
		_townBuildings = _x;
		//systemChat format["_townBuildings: %1, _spawnLocation: %2",count _townBuildings,_spawnLocation];
		if ((_townBuildings select 0) isEqualTo _spawnPosition) then
		{
			_housesInRange = _townBuildings select 1;
		};
	} forEach _towns;
	
	if (count _housesInRange < 1) then
	{
		//systemChat format["%1: %2",_spawnPosition,(_spawnLocation select 1)];
		_housesInRange = [_spawnPosition,(_spawnLocation select 1)] call AZC_fnc_GetBuildings;
		_townBuildings = [_spawnPosition,_housesInRange];
		_towns pushBack _townBuildings;
		missionNamespace setVariable ["AZC_AVM_TOWNS",_towns];
	};
	
	_vehicle = [(_nearestLocation select 0),(_spawnLocation select 0),(_spawnLocation select 1),_whiteList,_blackList,_housesInRange,_hasCrew,_allowOffroad] call AZC_fnc_CreateVehicle;
	if (!isNil "_vehicle") then
	{
		if (!isNull _vehicle) then
		{
			_vehicleList pushBack _vehicle;
			if (AZC_Debug) then
			{
				[_vehicle,str _vehicle] call AZC_fnc_AutoMarker;
			};
		}
		else
		{
			["Null vehicle, could not spawn."] call AZC_fnc_Debug;
		};

		[(format ["Vehicle: %3 --- _activeSpawns: %1 --- _maxVehicles: %2",_activeSpawns,_maxVehicles,_vehicle])] call AZC_fnc_Debug;
	};
};
_vehicleList