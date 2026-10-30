const test=require("node:test");
const assert=require("node:assert/strict");
const fs=require("node:fs");
const path=require("node:path");
const vm=require("node:vm");

function setup() {
  let clock=1000,id=0,reduced=false,hidden=false;
  const frames=new Map(),node={tagName:"DIV",innerHTML:""};
  Object.defineProperty(node,"textContent",{get(){return this.innerHTML;},set(v){this.innerHTML=v;}});
  const context=vm.createContext({
    requestAnimationFrame:fn=>{frames.set(++id,fn);return id;},
    cancelAnimationFrame:key=>frames.delete(key),clearTimeout(){},
  });
  for(const file of ["vendor/countUp.umd.js","format.js","animation.js"])
    vm.runInContext(fs.readFileSync(path.join(__dirname,"../dashboard",file),"utf8"),context);
  assert.equal(new context.countUp.CountUp(node,0).version,"2.10.1");
  const update=context.RewardAnimation.createAnimator({CountUp:context.countUp.CountUp,
    ...context.RewardFormat,reducedMotion:()=>reduced,hidden:()=>hidden});
  return {node,frames,update,
    step(ms) {clock+=ms;const callbacks=[...frames.values()];frames.clear();callbacks.forEach(fn=>fn(clock));},
    reduced(value) {reduced=value;},hidden(value) {hidden=value;}};
}
test("CountUp animates only changed totals and lands on the exact compact target",()=>{
  const s=setup();s.update(s.node,"18300");
  assert.equal(s.node.textContent,"+18,3K");assert.equal(s.frames.size,0);
  s.update(s.node,"36600");s.step(0);s.step(200);
  assert.notEqual(s.node.textContent,"+18,3K");assert.notEqual(s.node.textContent,"+36,6K");
  const pending=[...s.frames.keys()];s.update(s.node,"36600");
  assert.deepEqual([...s.frames.keys()],pending,"unchanged polling must not restart animation");
  s.step(450);assert.equal(s.node.textContent,"+36,6K");assert.equal(s.frames.size,0);
});
test("rapid updates retarget the current frame, support decreases and decimals",()=>{
  const s=setup();s.update(s.node,"10.5");s.update(s.node,"20.5");s.step(0);s.step(200);
  const current=s.node.textContent;
  s.update(s.node,"30.5");assert.equal(s.node.textContent,current);
  s.step(0);s.step(650);assert.equal(s.node.textContent,"+30,5");
  s.update(s.node,"5.5");s.step(0);s.step(650);assert.equal(s.node.textContent,"+5,5");
});
test("range changes, hidden pages and reduced motion snap without an animation",()=>{
  const s=setup();s.update(s.node,"100","run");s.update(s.node,"200","run");
  s.reduced(true);s.update(s.node,"200","run");
  assert.equal(s.frames.size,0);assert.equal(s.node.textContent,"+200");
  s.update(s.node,"300","run");assert.equal(s.frames.size,0);
  s.reduced(false);s.hidden(true);s.update(s.node,"400","run");assert.equal(s.frames.size,0);
  s.hidden(false);s.update(s.node,"1000000","all");
  assert.equal(s.node.textContent,"+1M");assert.equal(s.frames.size,0);
});
test("unsafe integers, invalid data and unavailable library preserve display-only fallback",()=>{
  const s=setup();s.update(s.node,"100");s.update(s.node,"999999999999999999.5");
  assert.equal(s.node.textContent,"+999999T");assert.equal(s.frames.size,0);
  s.update(s.node,null);assert.equal(s.node.textContent,"+?");
  const {createAnimator}=require("../dashboard/animation.js");
  const update=createAnimator({...require("../dashboard/format.js")});
  update(s.node,"18300");update(s.node,"2360000");assert.equal(s.node.textContent,"+2,3M");
});
test("scripts load pinned local CountUp and animator before the dashboard",()=>{
  const html=fs.readFileSync(path.join(__dirname,"../dashboard/index.html"),"utf8");
  assert.ok(html.indexOf('src="/vendor/countUp.umd.js"')<html.indexOf('src="/animation.js"'));
  assert.ok(html.indexOf('src="/animation.js"')<html.indexOf('src="/app.js"'));
});
