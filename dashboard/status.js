"use strict";
(function(root) {
  function collectorStatus(watcher, generatedAt, now=Date.now(), connected=true,t=key=>key) {
    const parsed=Date.parse(watcher?.lastCheckedAt);
    const checkedAt=Number.isFinite(parsed)?watcher.lastCheckedAt:null;
    const result=(state,detail,values={})=>({state,label:t(`status.${state}`),detail:t(detail,values),checkedAt});
    const unknown=detail=>result("unknown",detail);
    const generated=Date.parse(generatedAt);
    if(!connected || !Number.isFinite(generated) || now-generated>20000) {
      return unknown("status.connection");
    }
    if(!watcher || watcher.stateKnown!==true || typeof watcher.running!=="boolean") {
      return unknown("status.unavailable");
    }
    if(!watcher.running) return result("stopped","status.stoppedDetail");
    if(!checkedAt) return result("starting","status.startingDetail");
    const age=Math.max(0,(now-parsed)/1000);
    if(age>10) return result("stale","status.staleDetail",{seconds:Math.floor(age)});
    if(watcher.waitingForMouseRelease) return result("waiting","status.waitingDetail");
    return result("running","status.runningDetail");
  }
  if(typeof module!=="undefined" && module.exports) module.exports={collectorStatus};
  else root.RewardStatus=Object.freeze({collectorStatus});
})(globalThis);
