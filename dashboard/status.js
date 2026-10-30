"use strict";
(function(root) {
  function collectorStatus(watcher, generatedAt, now=Date.now(), connected=true) {
    const parsed=Date.parse(watcher?.lastCheckedAt);
    const checkedAt=Number.isFinite(parsed)?watcher.lastCheckedAt:null;
    const unknown=detail=>({state:"unknown",label:"Nem ellenőrizhető",detail,checkedAt});
    const generated=Date.parse(generatedAt);
    if(!connected || !Number.isFinite(generated) || now-generated>20000) {
      return unknown("Nincs friss kapcsolat a statisztikával. A gyűjtő közben tovább is futhat.");
    }
    if(!watcher || watcher.stateKnown!==true || typeof watcher.running!=="boolean") {
      return unknown("A gyűjtő állapotadata még nem érhető el.");
    }
    if(!watcher.running) return {state:"stopped",label:"Leállítva",detail:"A gyűjtőprogram nem fut. Nincs automatikus jutalomátvétel.",checkedAt};
    if(!checkedAt) return {state:"starting",label:"Indul / újraindul",detail:"A folyamat fut, de még várunk az első sikeres képolvasásra.",checkedAt:null};
    const age=Math.max(0,(now-parsed)/1000);
    if(age>10) return {state:"stale",label:"Nincs friss képolvasás",detail:`A folyamat él, de ${Math.floor(age)} mp óta nincs sikeres képolvasás.`,checkedAt};
    if(watcher.waitingForMouseRelease) return {state:"waiting",label:"Mozgás miatt várakozik",detail:"Az egérgomb elengedése után folytatja a jutalomgyűjtést.",checkedAt};
    return {state:"running",label:"Fut",detail:"Figyeli és átveszi az ingyenes jutalmakat.",checkedAt};
  }
  if(typeof module!=="undefined" && module.exports) module.exports={collectorStatus};
  else root.RewardStatus=Object.freeze({collectorStatus});
})(globalThis);
