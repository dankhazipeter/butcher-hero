"use strict";
(function(root) {
  function gameStatus(game,generatedAt,now=Date.now(),connected=true,t=key=>key) {
    const checked=Date.parse(game?.checkedAt),generated=Date.parse(generatedAt);
    const result=(state,detail,canLaunch=false)=>({state,label:t(`game.${state}`),detail:t(detail),canLaunch});
    if(!connected || !Number.isFinite(generated) || now-generated>20000 ||
       !Number.isFinite(checked) || now-checked>15000 || checked-now>5000 || game?.known!==true ||
       typeof game.running!=="boolean" || typeof game.installed!=="boolean" || typeof game.hidden!=="boolean" ||
       (game.windowVisible!=null && typeof game.windowVisible!=="boolean")) return result("unknown","game.unknownDetail");
    if(!game.running) return game.installed?result("not_running","game.notRunningDetail",true):result("not_installed","game.notInstalledDetail");
    if(game.hidden || game.windowVisible===false) return result("window_unavailable","game.windowUnavailableDetail");
    return result("running",game.windowVisible===true?"game.runningDetail":"game.windowUnknownDetail");
  }
  function collectorStatus(watcher, generatedAt, now=Date.now(), connected=true,t=key=>key,game=null) {
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
    const gameState=gameStatus(game,generatedAt,now,connected,t).state;
    if(gameState==="not_running" || gameState==="not_installed") return result("waiting_game","status.waitingGameDetail");
    if(gameState==="window_unavailable") return result("waiting_window","status.waitingWindowDetail");
    if(!checkedAt) return result("starting","status.startingDetail");
    const age=Math.max(0,(now-parsed)/1000);
    if(age>10) return result("stale","status.staleDetail",{seconds:Math.floor(age)});
    if(watcher.waitingForMouseRelease) return result("waiting","status.waitingDetail");
    return result("running","status.runningDetail");
  }
  if(typeof module!=="undefined" && module.exports) module.exports={collectorStatus,gameStatus};
  else root.RewardStatus=Object.freeze({collectorStatus,gameStatus});
})(globalThis);
