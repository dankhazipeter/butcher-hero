"use strict";
(function(root) {
  // Roll formatted labels, never intermediate numbers. Exact keys also detect
  // growth hidden by K/M truncation (e.g. +100M -> +100M).
  function createAnimator({formatCompact,formatExact,reducedMotion=()=>false,hidden=()=>false}) {
    const states=new WeakMap();
    return function update(node,value,scope="") {
      const key=formatExact(value),text=`+${formatCompact(value)}`,previous=states.get(node);
      const valid=value!=null && key!=="?";
      const skip=!previous || previous.scope!==scope || !previous.valid || !valid ||
        typeof node.animate!=="function" || !node.ownerDocument || reducedMotion() || hidden();
      if(previous?.key===key && previous.scope===scope) {
        if(skip) previous.cleanup?.();
        return;
      }
      previous?.cleanup?.();
      const state={key,text,valid,scope,cleanup:null};states.set(node,state);
      const snap=()=>{node.textContent=text;};
      if(skip) {snap();return;}
      const doc=node.ownerDocument,roll=doc.createElement("span");
      const outgoing=doc.createElement("span"),incoming=doc.createElement("span");
      roll.className="value-roll";
      outgoing.className="value-roll-old";outgoing.textContent=previous.text;
      outgoing.setAttribute("aria-hidden","true");
      incoming.className="value-roll-new";incoming.textContent=text;
      roll.append(outgoing,incoming);node.replaceChildren(roll);
      const animations=[];
      const cleanup=()=>{
        if(state.cleanup!==cleanup) return;
        state.cleanup=null;
        for(const animation of animations) {
          animation.onfinish=null;animation.oncancel=null;animation.cancel();
        }
        snap();
      };
      state.cleanup=cleanup;
      const timing={duration:650,easing:"cubic-bezier(.22,.8,.25,1)",fill:"both"};
      try {
        animations.push(outgoing.animate([
          {transform:"translateY(0)",opacity:1},
          {transform:"translateY(-110%)",opacity:0},
        ],timing));
        animations.push(incoming.animate([
          {transform:"translateY(110%)",opacity:0},
          {transform:"translateY(0)",opacity:1},
        ],timing));
        for(const animation of animations) animation.oncancel=cleanup;
        animations[1].onfinish=cleanup;
      } catch {
        cleanup();
      }
    };
  }
  const api={createAnimator};
  if(typeof module!=="undefined" && module.exports) module.exports=api;
  else root.RewardAnimation=Object.freeze(api);
})(globalThis);
