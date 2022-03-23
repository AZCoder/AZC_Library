// credit to GEORGE FLOROS GR
_hndCol = ppEffectCreate ["colorCorrections",1501];
_hndCol ppEffectEnable true;
_hndCol ppEffectAdjust [1.0,1.0,0.0,[1.0,1.0,1.0,0.0],[1.0,1.0,0.9,0.35],[0.3,0.3,0.3,-0.1]];
_hndCol ppEffectCommit 0;