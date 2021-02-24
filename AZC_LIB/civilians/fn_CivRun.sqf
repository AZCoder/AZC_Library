/*
	Special thanks to PHRONK for releasing "run to the hills" script from which
	this is loosely based on.
*/

if (isNil "AZC_Debug") then { AZC_Debug = false; };

params["_civ"];

_housesInRange = _civ getVariable "AZC_PANIC_HOUSES";
_house = selectRandom _housesInRange;
_pos = getPos _house;

_buildingPositions = [_house] call BIS_fnc_buildingPositions;
if (count _buildingPositions > 0) then
{
	_index = floor random(count _buildingPositions);
	_pos = _buildingPositions select _index;
};

_idx = floor(random(3));
// yes 2 of these are identical, it gives that anim a 2/3 chance of being selected
_anims = ["ApanPercMstpSnonWnonDnon_G01","ApanPknlMstpSnonWnonDnon_G01","ApanPercMstpSnonWnonDnon_G01"];
_anim = _anims select _idx;
_civ switchMove "";
_civ enableAI "MOVE";
_civ enableAI "ANIM";
_civ switchMove _anim;
_civ setSpeedMode "FULL";
_civ setBehaviour "AWARE";
_civ forceWalk false;
_civ doMove _pos;

if (AZC_DEBUG) then
{
	_markerIndex = random 64320;
	_markerIndexName = format["AZC_MARKER_%1",_markerIndex];
	_marker = createMarker [_markerIndexName, position _house];
	_marker setMarkerShape "ICON";
	_markerIndexName setMarkerType "loc_Tourism";
};

//systemChat format["_anim: %1, _house: %2, _pos: %3",_anim,_civ distance _house,_pos];
