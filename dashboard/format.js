"use strict";
(function(root) {
  function parts(value) {
    if(value == null) return null;
    const text=typeof value==="number" && Number.isFinite(value)
      ? value.toLocaleString("en-US",{useGrouping:false,maximumFractionDigits:20})
      : String(value);
    const match=/^(-?)(\d+)(?:\.(\d+))?$/.exec(text);
    if(!match) return null;
    return {sign:match[1],integer:match[2].replace(/^0+(?=\d)/,""),fraction:(match[3]||"").replace(/0+$/,"")};
  }
  function formatExact(value) {
    const p=parts(value);
    if(!p) return "?";
    return p.sign+p.integer.replace(/\B(?=(\d{3})+(?!\d))/g,"\u202f")+(p.fraction?","+p.fraction:"");
  }
  function formatCompact(value) {
    const p=parts(value);
    if(!p) return "?";
    const unit=Math.min(4,Math.floor((p.integer.length-1)/3));
    if(unit===0) return formatExact(value);
    const head=p.integer.slice(0,-unit*3);
    const tail=p.integer.slice(-unit*3)+p.fraction;
    // Display-only policy inferred from the user's game examples: truncate,
    // one fractional digit below100, whole values at100+. Never alter data.
    const fraction=head.length<3 && tail[0]!=="0" ? ","+tail[0]:"";
    return p.sign+head+fraction+["","K","M","B","T"][unit];
  }
  const api={formatCompact,formatExact};
  if(typeof module!=="undefined" && module.exports) module.exports=api;
  else root.RewardFormat=Object.freeze(api);
})(globalThis);
