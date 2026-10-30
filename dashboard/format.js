"use strict";
(function(root) {
  const separatorCache=new Map();
  function separators(locale) {
    if(!separatorCache.has(locale)) {
      const parts=new Intl.NumberFormat(locale).formatToParts(1234.5);
      separatorCache.set(locale,{decimal:parts.find(p=>p.type==="decimal")?.value||".",
        group:locale.startsWith("hu")?"\u202f":parts.find(p=>p.type==="group")?.value||","});
    }
    return separatorCache.get(locale);
  }
  function parts(value) {
    if(value == null) return null;
    const text=typeof value==="number" && Number.isFinite(value)
      ? value.toLocaleString("en-US",{useGrouping:false,maximumFractionDigits:20})
      : String(value);
    const match=/^(-?)(\d+)(?:\.(\d+))?$/.exec(text);
    if(!match) return null;
    return {sign:match[1],integer:match[2].replace(/^0+(?=\d)/,""),fraction:(match[3]||"").replace(/0+$/,"")};
  }
  function formatExact(value,locale="hu-HU") {
    const p=parts(value);
    if(!p) return "?";
    const sep=separators(locale);
    return p.sign+p.integer.replace(/\B(?=(\d{3})+(?!\d))/g,sep.group)+(p.fraction?sep.decimal+p.fraction:"");
  }
  function formatCompact(value,locale="hu-HU") {
    const p=parts(value);
    if(!p) return "?";
    const unit=Math.min(4,Math.floor((p.integer.length-1)/3));
    if(unit===0) return formatExact(value,locale);
    const head=p.integer.slice(0,-unit*3);
    const tail=p.integer.slice(-unit*3)+p.fraction;
    // Display-only policy inferred from the user's game examples: truncate,
    // one fractional digit below100, whole values at100+. Never alter data.
    const fraction=head.length<3 && tail[0]!=="0" ? separators(locale).decimal+tail[0]:"";
    return p.sign+head+fraction+["","K","M","B","T"][unit];
  }
  const api={formatCompact,formatExact};
  if(typeof module!=="undefined" && module.exports) module.exports=api;
  else root.RewardFormat=Object.freeze(api);
})(globalThis);
