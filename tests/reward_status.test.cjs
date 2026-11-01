const test=require("node:test");
const assert=require("node:assert/strict");
const {collectorStatus,gameStatus}=require("../dashboard/status.js");
const now=Date.parse("2026-10-30T20:00:10Z");
const fresh="2026-10-30T20:00:09Z";
const active={stateKnown:true,running:true,lastCheckedAt:fresh,waitingForMouseRelease:false,
  captureSourceVerified:true,captureStatus:"ok",screenState:"hud"};
const {createI18n}=require("../dashboard/i18n.js");
const t=createI18n({catalogs:{hu:require("../dashboard/locales/hu.js")}}).t;
const status=(watcher,generatedAt=fresh,at=now,connected=true)=>collectorStatus(watcher,generatedAt,at,connected,t);

test("only a live worker with fresh successful frames is green",()=>{
  assert.equal(status(active).state,"running");
  assert.equal(status(active).label,"Fut");
});
test("fresh captures with a foreign or missing source are never green",()=>{
  for(const value of [false,undefined,null,"true",1]) {
    assert.equal(status({...active,captureSourceVerified:value}).state,"source_unverified");
  }
  for(const value of [undefined,"starting","invalid"]) {
    assert.equal(status({...active,captureStatus:value}).state,"source_unverified");
  }
});
test("capture errors and unrecognized game frames are warnings even with a live fresh worker",()=>{
  assert.equal(status({...active,captureStatus:"error"}).state,"capture_error");
  for(const screenState of [undefined,null,"unrecognized","browser","invalid"]) {
    assert.equal(status({...active,screenState}).state,"unrecognized");
  }
  assert.equal(status({...active,captureStatus:"error",running:false}).state,"stopped");
  assert.equal(status({...active,captureStatus:"error",lastCheckedAt:"2026-10-30T19:59:50Z"}).state,"stale");
});
test("recognized workflows are distinct from blocked and manual panels",()=>{
  for(const screenState of ["crystal","event"]) {
    assert.equal(status({...active,screenState}).state,"processing");
  }
  for(const change of [{crystalPhase:"blocked"},{eventEndPhase:"blocked"},{screenState:"manual_crystal"}]) {
    assert.equal(status({...active,...change}).state,"blocked");
  }
  assert.equal(status({...active,screenState:"crystal",waitingForMouseRelease:true}).state,"waiting");
});
test("a stopped or dead worker is explicitly stopped even with a recent old frame",()=>{
  assert.equal(status({...active,running:false}).state,"stopped");
});
test("startup without a successful frame is not advertised as healthy",()=>{
  assert.equal(status({...active,lastCheckedAt:null}).state,"starting");
});
test("stale frames become a warning and keep ageing without another HTTP response",()=>{
  assert.equal(status({...active,lastCheckedAt:"2026-10-30T19:59:50Z"}).state,"stale");
  assert.equal(status(active,fresh,now+10000).state,"stale");
  assert.equal(status({...active,lastCheckedAt:"2026-10-30T19:59:50Z",waitingForMouseRelease:true}).state,"stale");
});
test("human mouse activity is a waiting state, not a stopped program",()=>{
  assert.equal(status({...active,waitingForMouseRelease:true}).state,"waiting");
});
test("connection failure or old responses cannot leave a green stale badge",()=>{
  assert.equal(status(active,fresh,now,false).state,"unknown");
  assert.equal(status(active,fresh,now+21000).state,"unknown");
  assert.equal(status(active,fresh,now,false).checkedAt,fresh);
});
test("missing or unreadable state is unknown, not falsely stopped or running",()=>{
  for(const watcher of [undefined,{}, {running:true,lastCheckedAt:fresh}, {...active,stateKnown:false}]) {
    assert.equal(status(watcher).state,"unknown");
  }
});
const game={known:true,installed:true,running:false,hidden:false,windowVisible:false,checkedAt:fresh};
test("independent native game status distinguishes stopped, invisible and visible games",()=>{
  assert.equal(gameStatus(game,fresh,now,true,t).state,"not_running");
  assert.equal(gameStatus(game,fresh,now,true,t).canLaunch,true);
  assert.equal(gameStatus({...game,running:true,hidden:true},fresh,now,true,t).state,"window_unavailable");
  assert.equal(gameStatus({...game,running:true},fresh,now,true,t).state,"window_unavailable");
  assert.equal(gameStatus({...game,running:true,windowVisible:true},fresh,now,true,t).state,"running");
  assert.equal(gameStatus({...game,installed:false},fresh,now,true,t).state,"not_installed");
  assert.equal(gameStatus({...game,installed:false},fresh,now,true,t).canLaunch,false);
});
test("unavailable, malformed and stale game probes never claim the game is stopped or enable launch",()=>{
  for(const current of [undefined,{}, {...game,known:false},{...game,running:"false"},{...game,windowVisible:"false"},
    {...game,checkedAt:"2026-10-30T19:59:30Z"},{...game,checkedAt:"2026-10-30T20:01:00Z"}]) {
    const result=gameStatus(current,fresh,now,true,t);
    assert.equal(result.state,"unknown");assert.equal(result.canLaunch,false);
  }
  assert.equal(gameStatus(game,fresh,now,false,t).canLaunch,false);
  assert.equal(gameStatus(game,fresh,now+21000,true,t).state,"unknown");
});
test("collector waits explicitly for a known stopped game or invisible window, not generic stale frames",()=>{
  const stale={...active,lastCheckedAt:"2026-10-30T19:00:00Z"};
  assert.equal(collectorStatus(stale,fresh,now,true,t,game).state,"waiting_game");
  assert.equal(collectorStatus(stale,fresh,now,true,t,{...game,running:true}).state,"waiting_window");
  assert.equal(collectorStatus({...stale,running:false},fresh,now,true,t,game).state,"stopped");
  assert.equal(collectorStatus(stale,fresh,now,true,t,{...game,known:false}).state,"stale");
  assert.equal(collectorStatus(stale,fresh,now,false,t,game).state,"unknown");
});
