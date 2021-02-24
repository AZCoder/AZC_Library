params[["_commit",0]];
// credit to GEORGE FLOROS GR
_hndCol = ppEffectCreate ["colorCorrections",1501];
_hndCol ppEffectEnable true; 
_hndCol ppEffectAdjust [1,1.1,0.0,[0.0,0.0,0.0,0.0],[1.0,0.7,0.6,0.60],[0.200,0.600,0.100,0.0]]; 
_hndCol ppEffectCommit _commit;
