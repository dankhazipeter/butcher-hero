"use strict";
(function(root) {
  function createAnimator({CountUp,formatCompact,formatExact,reducedMotion=()=>false,hidden=()=>false}) {
    const states=new WeakMap();
    return function update(node,value,scope="") {
      const key=formatExact(value),previous=states.get(node),number=Number(value);
      const decimals=(String(value).split(".")[1]||"").replace(/0+$/,"").length;
      const safe=value!=null && key!=="?" && decimals<=6 && Number.isSafeInteger(number*10**decimals);
      const snap=()=>{node.textContent=`+${formatCompact(value)}`;};
      const skip=!previous || previous.scope!==scope || !previous.safe || !safe ||
        !CountUp || reducedMotion() || hidden();
      if(previous?.key===key && previous.scope===scope) {
        if(skip && previous.animation) {previous.animation.onDestroy();previous.animation=null;snap();}
        return;
      }
      const start=previous?.animation?.frameVal ?? previous?.number;
      previous?.animation?.onDestroy();
      const state={key,number,decimals,safe,scope,animation:null};states.set(node,state);
      if(skip) {snap();return;}
      const animation=new CountUp(node,number,{
        startVal:start,decimalPlaces:Math.max(decimals,previous.decimals||0),duration:0.65,
        smartEasingThreshold:Infinity,
        formattingFn:n=>`+${formatCompact(n)}`,
        // Only the last frame is exact; interpolation is display-only.
        onCompleteCallback:()=>{state.animation=null;snap();},
      });
      if(animation.error) {animation.onDestroy();snap();return;}
      state.animation=animation;animation.start();
    };
  }
  const api={createAnimator};
  if(typeof module!=="undefined" && module.exports) module.exports=api;
  else root.RewardAnimation=Object.freeze(api);
})(globalThis);
