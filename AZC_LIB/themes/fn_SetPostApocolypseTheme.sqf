params[["_commit",0]];
// credit to GEORGE FLOROS GR
_hndCol = ppEffectCreate ["colorCorrections",1501];
_hndCol ppEffectEnable true;
_hndCol ppEffectAdjust [1,0.9,-0.002,[0.0,0.0,0.0,0.0],[1.0,0.6,0.4,0.6],[0.199,0.587,0.114,0.0]];
_hndCol ppEffectCommit _commit;
