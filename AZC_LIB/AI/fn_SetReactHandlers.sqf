params["_leader"];

{
	_ehEvent = _x addEventHandler ["firedNear", {_this call AZC_fnc_React}];
	_leader setVariable["firedNear", _ehEvent];
	_ehEvent = _x addEventHandler ["hit", {_this call AZC_fnc_React}];
	_leader setVariable["hit", _ehEvent];
	_ehEvent = _x addEventHandler ["killed", {_this call AZC_fnc_React}];
	_leader setVariable["killed", _ehEvent];
} forEach units group _leader;
