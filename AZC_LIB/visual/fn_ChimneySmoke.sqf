params["_chance","_pos","_obj"];

if ((random 1 <= _chance) && (_pos distance [0,0,0] > 0)) then
{
	_worldpos = (_obj modelToWorld _pos);
	_eSmoke = "#particlesource" createVehicle _worldpos;
	_eSmoke setParticleCircle [0, [0, 0, 0]];
	_eSmoke setParticleRandom [1, [0, 0, 0], [0.1, 0.1, 0.1], 2, 0.2, [0.05, 0.05, 0.05, 0.05], 0, 0];
	_eSmoke setParticleParams [["\A3\data_f\ParticleEffects\Universal\Universal",16,9,8],"","Billboard",1,(4 + random 8),[0,0,0],[0.1,0.1,(0.5 + random 0.5)],1,1.275,1,0.066,[0.4,(1 + random 0.5),(2 + random 2)],[[0.4,0.4,0.4*1.2,0.2],[0.5,0.5,0.5*1.2,0.4],[0.7,0.7,0.7*1.2,0.1]],[0],1,0,"","",""];
	_eSmoke setDropInterval .3;
};
