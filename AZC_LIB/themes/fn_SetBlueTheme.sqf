// a cold theme, might be too blue for some
_hndCol = ppEffectCreate ["colorCorrections",1501];
_hndCol ppEffectEnable true;
_hndCol ppEffectAdjust [1.0,1.0,0.0,[1.0,1.0,1.0,0.0],[1.0,1.0,1.0,1.0],[1.0,1.0,1.0,1.0]];
_hndCol ppEffectCommit 10;
