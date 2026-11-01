const test=require("node:test");
const assert=require("node:assert/strict");
const fs=require("node:fs");
const path=require("node:path");
const {createAnimator}=require("../dashboard/animation.js");
const format=require("../dashboard/format.js");

function setup({supported=true,throwsAt=0}={}) {
  let reduced=false,hidden=false;
  const effects=[];
  class Element {
    constructor(){this.children=[];this.attributes={};this.ownerDocument=doc;this.text="";}
    set textContent(value){this.text=value;this.children=[];}
    get textContent(){return this.text+this.children.map(child=>child.textContent).join("");}
    append(...children){this.children.push(...children);}
    replaceChildren(...children){this.text="";this.children=children;}
    setAttribute(key,value){this.attributes[key]=value;}
    animate(frames,timing){
      if(throwsAt===effects.length+1) throw Error("unsupported effect");
      const effect={node:this,frames,timing,cancelled:false,onfinish:null,oncancel:null,
        cancel(){this.cancelled=true;this.oncancel?.();},finish(){this.onfinish?.();}};
      effects.push(effect);return effect;
    }
  }
  const doc={createElement:()=>new Element()},node=new Element();
  if(!supported) node.animate=undefined;
  const update=createAnimator({...format,reducedMotion:()=>reduced,hidden:()=>hidden});
  return {node,effects,update,reduced:v=>reduced=v,hidden:v=>hidden=v,
    layers:()=>node.children[0]?.children||[],finish:()=>effects.at(-1)?.finish()};
}
test("rolls only the old and new compact labels, never intermediate values",()=>{
  const s=setup();s.update(s.node,"18300","run");
  assert.equal(s.node.textContent,"+18,3K");assert.equal(s.effects.length,0);
  s.update(s.node,"36600","run");
  assert.deepEqual(s.layers().map(n=>n.textContent),["+18,3K","+36,6K"]);
  assert.equal(s.layers()[0].attributes["aria-hidden"],"true");
  assert.equal(s.layers()[1].attributes["aria-hidden"],undefined);
  assert.deepEqual(s.effects[0].frames.map(f=>f.transform),["translateY(0)","translateY(-110%)"]);
  assert.deepEqual(s.effects[1].frames.map(f=>f.transform),["translateY(110%)","translateY(0)"]);
  assert.equal(s.effects[1].timing.duration,650);
  s.update(s.node,"36600","run");assert.equal(s.effects.length,2,"poll cannot restart roll");
  s.finish();assert.equal(s.node.textContent,"+36,6K");assert.equal(s.node.children.length,0);
  assert.ok(s.effects.every(e=>e.cancelled));
});
test("exact growth rolls even when both compact labels remain 100M",()=>{
  const s=setup();s.update(s.node,"100000000");s.update(s.node,"100018300");
  assert.deepEqual(s.layers().map(n=>n.textContent),["+100M","+100M"]);
  assert.equal(s.effects.length,2);s.finish();assert.equal(s.node.textContent,"+100M");
});
test("large exact strings, decimals, decreases and K/M transitions retain formatting",()=>{
  const s=setup();
  for(const [before,after] of [["999","1000"],["999999","1000000"],
    ["18300","999999999999999999.5"],["30.5","5.5"]]) {
    s.update(s.node,before,"initial");s.update(s.node,after,"initial");
    assert.equal(s.layers()[1].textContent,`+${format.formatCompact(after)}`);
    s.finish();assert.equal(s.node.textContent,`+${format.formatCompact(after)}`);
  }
});
test("rapid updates cancel both old effects and keep only the newest pair",()=>{
  const s=setup();s.update(s.node,"10");s.update(s.node,"20");
  const obsoleteFinish=s.effects[1].onfinish;
  s.update(s.node,"30");
  assert.ok(s.effects.slice(0,2).every(e=>e.cancelled));
  assert.deepEqual(s.layers().map(n=>n.textContent),["+20","+30"]);
  obsoleteFinish();assert.equal(s.layers()[1].textContent,"+30","stale completion cannot overwrite");
  s.finish();assert.equal(s.node.textContent,"+30");
});
test("range, language and session changes snap without suggesting a new reward",()=>{
  const s=setup();s.update(s.node,"100","hu:run:one");s.update(s.node,"200","hu:run:one");
  for(const scope of ["hu:all","en:all","en:run:two"]) {
    s.update(s.node,"300",scope);assert.equal(s.node.textContent,"+300");
    assert.equal(s.node.children.length,0);
  }
  assert.equal(s.effects.length,2);assert.ok(s.effects.every(e=>e.cancelled));
});
test("reduced motion and hidden pages cancel active rolls even on unchanged polls",()=>{
  for(const preference of ["reduced","hidden"]) {
    const s=setup();s.update(s.node,"100");s.update(s.node,"200");s[preference](true);
    s.update(s.node,"200");assert.equal(s.node.textContent,"+200");
    assert.ok(s.effects.every(e=>e.cancelled));
    s.update(s.node,"300");assert.equal(s.node.textContent,"+300");assert.equal(s.effects.length,2);
  }
});
test("missing or throwing native animation falls back to the exact target",()=>{
  for(const options of [{supported:false},{throwsAt:1},{throwsAt:2}]) {
    const s=setup(options);s.update(s.node,"18300");s.update(s.node,"2360000");
    assert.equal(s.node.textContent,"+2,3M");assert.equal(s.node.children.length,0);
    assert.ok(s.effects.every(e=>e.cancelled));
  }
});
test("invalid readings snap; external cancellation cleans all visual layers",()=>{
  const s=setup();s.update(s.node,"100");s.update(s.node,null);
  assert.equal(s.node.textContent,"+?");assert.equal(s.effects.length,0);
  s.update(s.node,"200");assert.equal(s.effects.length,0);
  s.update(s.node,"300");s.effects[0].cancel();
  assert.equal(s.node.textContent,"+300");assert.ok(s.effects.every(e=>e.cancelled));
});
test("dashboard loads the native animator without CountUp and clips overlapping labels",()=>{
  const html=fs.readFileSync(path.join(__dirname,"../dashboard/index.html"),"utf8");
  assert.ok(!html.includes('src="/vendor/countUp.umd.js"'));
  assert.ok(html.indexOf('src="/animation.js"')<html.indexOf('src="/app.js"'));
  const css=fs.readFileSync(path.join(__dirname,"../dashboard/style.css"),"utf8");
  assert.match(css,/\.value-roll\{[^}]*display:inline-grid;[^}]*overflow:hidden/);
  assert.match(css,/\.value-roll>span\{[^}]*grid-area:1\/1/);
});
