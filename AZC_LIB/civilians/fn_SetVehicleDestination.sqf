params["_vehicle","_roadDestination"];
if (_vehicle isEqualTo objNull) exitWith {};

if (!(isNil "_roadDestination")) then
{
	while { count (waypoints (group _vehicle)) > 0 } do
	{
		deleteWaypoint ((waypoints (group _vehicle)) select 0);
	};
	
	_vehicle engineOn true;
	// give waypoints
	_destWP = [_vehicle,_roadDestination,"MOVE","SAFE","LIMITED","BLUE"] call AZC_fnc_AddWaypoint;
	if (isNil "_destWP") exitWith {};
	
	_vehicle setVariable["AZC_DESTINATION",_destWP];
	_housesInRange = _roadDestination nearObjects ["house",100];
	if (count(_housesInRange) > 0) then
	{
		_index = floor(random(count(_housesInRange)));
		_house = _housesInRange select _index;
		_driver = driver _vehicle;
		[_vehicle,_house,"GetOut","SAFE","LIMITED","BLUE"] call AZC_fnc_AddWaypoint;
		[_driver,_house,"Dismiss","SAFE","LIMITED","BLUE"] call AZC_fnc_AddWaypoint;
	};
	
	_vehicle limitSpeed 50;
	_vehicle setVariable ["AZC_VEH_DESTINATION",_roadDestination];
	_vehicle setBehaviour "SAFE";
};
