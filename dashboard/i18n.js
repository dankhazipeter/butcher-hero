"use strict";
(function(root) {
  function createI18n({catalogs,storage,defaultLanguage="hu"}) {
    let language=defaultLanguage;
    try {const saved=storage?.getItem("butcher-dashboard-language");if(Object.hasOwn(catalogs,saved)) language=saved;} catch {}
    const has=key=>Object.hasOwn(catalogs[language].messages,key)||Object.hasOwn(catalogs[defaultLanguage].messages,key);
    const t=(key,values={})=>{
      const current=catalogs[language].messages,fallback=catalogs[defaultLanguage].messages;
      const text=Object.hasOwn(current,key)?current[key]:Object.hasOwn(fallback,key)?fallback[key]:key;
      return text.replace(/\{(\w+)\}/g,(match,name)=>Object.hasOwn(values,name)?String(values[name]):match);
    };
    function apply(document) {
      document.documentElement.lang=language;document.title=t("title");
      for(const node of document.querySelectorAll("[data-i18n]")) node.textContent=t(node.dataset.i18n);
      for(const attribute of ["aria-label","title"]) {
        for(const node of document.querySelectorAll(`[data-i18n-${attribute}]`))
          node.setAttribute(attribute,t(node.getAttribute(`data-i18n-${attribute}`)));
      }
    }
    return {t,has,apply,catalogs,get language(){return language;},get locale(){return catalogs[language].locale;},
      setLanguage(next) {if(!Object.hasOwn(catalogs,next)) return false;language=next;
        try {storage?.setItem("butcher-dashboard-language",language);} catch {} return true;},
    };
  }
  const api={createI18n};
  if(typeof module!=="undefined" && module.exports) module.exports=api;
  else root.RewardI18n=Object.freeze(api);
})(globalThis);
