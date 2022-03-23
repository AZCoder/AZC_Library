// credit to GEORGE FLOROS GR
_hndCol = ppEffectCreate ["colorCorrections",1501];
_hndCol ppEffectEnable true;
_hndCol ppEffectAdjust [1.0,1.0,0.0,[0.2,0.2,1.0,0.0],[0.4,0.75,1.0,0.60],[0.5,0.3,1.0,-0.1]];
_hndCol ppEffectCommit 0;
