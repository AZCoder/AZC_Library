// credit to GEORGE FLOROS GR
_hndCol = ppEffectCreate ["colorCorrections",1501];
_hndCol ppEffectEnable true;
_hndCol ppEffectAdjust [0.9,1,0,[0.1,0.1,0.1,-0.1],[1,1,0.8,0.528],[1,0.2,0,0]];
_hndCol ppEffectCommit 0;