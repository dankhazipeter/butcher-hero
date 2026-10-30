const test=require("node:test");
const assert=require("node:assert/strict");
const {collectorStatus}=require("../dashboard/status.js");
const now=Date.parse("2026-10-30T20:00:10Z");
const fresh="2026-10-30T20:00:09Z";
const active={stateKnown:true,running:true,lastCheckedAt:fresh,waitingForMouseRelease:false};
const status=(watcher,generatedAt=fresh,at=now,connected=true)=>collectorStatus(watcher,generatedAt,at,connected);

test("only a live worker with fresh successful frames is green",()=>{
  assert.equal(status(active).state,"running");
  assert.equal(status(active).label,"Fut");
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
