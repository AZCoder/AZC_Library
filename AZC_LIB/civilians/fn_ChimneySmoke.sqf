/*
	Randomly creates chimney smokes for buildings with chimneys.
*/
params["_center","_range",["_chance",0.5]];

_houselist = nearestTerrainObjects [_center,["House"],_range];
_housesChecked = missionNamespace getVariable "AZC_SmokeHouseList";
if (isNil "_housesChecked") then
{
	_housesChecked = [];
	missionNamespace setVariable ["AZC_SmokeHouseList",_housesChecked];
};

// remove checked houses from list
_houselist = _houselist - _housesChecked;

{
	_obj = _x;
	// chimney smoke
	// save building as being checked
	_housesChecked pushBack _obj;
	
	for "_i" from 0 to 10 do
	{
		_pos = _obj selectionPosition format ["AIChimney_small_%1",_i];
		if (_pos distance [0,0,0] == 0) exitwith {};
		if (random 1 <= _chance) then
		{
			_worldpos = (_obj modelToWorld _pos);
			_PS = "#particlesource" createVehicle _worldpos;
			_PS setParticleCircle [0, [0, 0, 0]];
			_PS setParticleRandom [1, [0, 0, 0], [0.1, 0.1, 0.1], 2, 0.2, [0.05, 0.05, 0.05, 0.05], 0, 0];
			_PS setParticleParams [["\A3\data_f\ParticleEffects\Universal\Universal",16,9,8],"","Billboard",1,(4 + random 8),[0,0,0],[0.1,0.1,(0.5 + random 0.5)],1,1.275,1,0.066,[0.4,(1 + random 0.5),(2 + random 2)],[[0.4,0.4,0.4*1.2,(0.1 + random 0.1)],[0.5,0.5,0.5*1.2,(0.05 + random 0.05)],[0.7,0.7,0.7*1.2,0]],[0],1,0,"","",""];
			_PS setDropInterval .3;
		};
	};
} forEach _houselist;
missionNamespace setVariable ["AZC_SmokeHouseList",_housesChecked];
