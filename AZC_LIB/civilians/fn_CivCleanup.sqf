/*
	Remove civilians that have gone far out of range.
*/

params["_civilianList","_minDistance","_nearestLocation","_lastLocation"];

// if player is closer to a new location, remove all civs not already at new location
if (!(_nearestLocation isEqualTo _lastLocation)) then
{
	_civsToDelete = [];

	{
		_civ = _x;
		_civDistance = _civ distance _nearestLocation;
		_playerDistance = _civ distance player;
		if ((_civDistance > _minDistance) && (_playerDistance > _minDistance)) then
		{
			// find civ in list
			_index = _civilianList find _civ;
			if (_index > -1) then
			{
				_civsToDelete pushBack _civ;
			}
			else
			{
				_msg = format["Can't find civilian %1 for deletion.",_civ];
				[_msg,true] call AZC_fnc_Debug;
			};
		};
	} forEach _civilianList;
	[_civsToDelete] call AZC_fnc_Delete;
	_civilianList = _civilianList - _civsToDelete;
};

_civilianList
