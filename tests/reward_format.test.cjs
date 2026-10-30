const test=require("node:test");
const assert=require("node:assert/strict");
const {formatCompact,formatExact}=require("../dashboard/format.js");
const fs=require("node:fs");
const path=require("node:path");
const {inflateSync}=require("node:zlib");

test("game-like K/M examples truncate, do not round up",()=>{
  for(const [input,expected] of [
    ["73200","73,2K"],["2360000","2,3M"],["99800000","99,8M"],
    ["99999999","99,9M"],["100000000","100M"],["100900000","100M"],
    ["999999","999K"],["1000000","1M"],["1000","1K"],["18300","18,3K"],
    ["1234567890","1,2B"],["100900000000000","100T"],
  ]) assert.equal(formatCompact(input),expected,input);
});
test("small and fractional values remain readable",()=>{
  assert.equal(formatCompact("0"),"0");
  assert.equal(formatCompact("0.5"),"0,5");
  assert.equal(formatCompact("83.00"),"83");
  assert.equal(formatCompact("999.9"),"999,9");
  assert.equal(formatCompact(73200),"73,2K");
});
test("exact underlying values are not converted to floating point",()=>{
  assert.equal(formatExact("2360000"),"2\u202f360\u202f000");
  assert.equal(formatExact("123456789012345678901.5"),"123\u202f456\u202f789\u202f012\u202f345\u202f678\u202f901,5");
  assert.equal(formatCompact("999999999999999.99"),"999T");
});
test("missing or invalid amounts do not become fabricated zeros",()=>{
  for(const value of [null,undefined,"bad","18K",Infinity,NaN]) {
    assert.equal(formatCompact(value),"?");
    assert.equal(formatExact(value),"?");
  }
});
test("all eight UI-only icons are small RGBA PNGs with a transparent corner",()=>{
  for(const kind of ["hp","regeneration","piercing_damage","cutting_damage","smash_damage","piercing_defense","cutting_defense","smash_defense"]) {
    const png=fs.readFileSync(path.join(__dirname,"../dashboard/icons",kind+".png"));
    assert.equal(png.subarray(0,8).toString("hex"),"89504e470d0a1a0a");
    assert.equal(png[24],8);assert.equal(png[25],6,"8-bit RGBA");
    assert.ok(png.readUInt32BE(16)<=96&&png.readUInt32BE(20)<=96);
    const chunks=[];
    for(let offset=8;offset<png.length;) {
      const size=png.readUInt32BE(offset),type=png.toString("ascii",offset+4,offset+8);
      if(type==="IDAT") chunks.push(png.subarray(offset+8,offset+8+size));
      offset+=size+12;
    }
    const decoded=inflateSync(Buffer.concat(chunks));
    assert.ok(decoded[0]<=4);
    // At the first pixel all PNG filter predictors are zero, so alpha is raw.
    assert.equal(decoded[4],0,kind+": transparent background, not a brown/black square");
  }
});

test("reward icons remain transparent on cards, ledger and frequency legend",()=>{
  const css=fs.readFileSync(path.join(__dirname,"../dashboard/style.css"),"utf8");
  const rules=[...css.matchAll(/([^{}]+)\{([^{}]*)\}/g)];
  for(const selector of [".stat-head img",".entry-kind img",".frequency-key img"]) {
    const backgrounds=rules.filter(([,selectors])=>selectors.split(",").map(s=>s.trim()).includes(selector))
      .flatMap(([, ,body])=>[...body.matchAll(/(?:^|;)\s*background(?:-color)?\s*:\s*([^;]+)/g)].map(m=>m[1].trim()));
    assert.ok(backgrounds.length>0,selector+": explicit transparent background required");
    assert.ok(backgrounds.every(value=>value==="transparent"),selector+": no opaque icon tile in any rule");
  }
});

async function renderDashboard(data) {
  const vm=require("node:vm");
  class Element {
    constructor(tagName="") {this.tagName=tagName;this.children=[];this.dataset={};this.attributes={};this.classList={add(){},remove(){}};}
    append(...children) {this.children.push(...children);}
    replaceChildren(...children) {this.children=children;}
    setAttribute(key,value) {this.attributes[key]=value;}
    addEventListener() {}
    getBoundingClientRect() {return {width:0};}
    querySelector(selector) {
      for(const child of this.children) {
        if(selector.startsWith(".")?(child.className||"").split(" ").includes(selector.slice(1)):child.tagName===selector) return child;
        const found=child.querySelector?.(selector);if(found) return found;
      }
      return null;
    }
  }
  const elements=new Map();
  const document={
    getElementById(id) {if(!elements.has(id)) elements.set(id,new Element());return elements.get(id);},
    createElement(tag) {return new Element(tag);},createElementNS(ns,tag) {return new Element(tag);},
    createTextNode(text) {return {textContent:text};},
    querySelectorAll() {return [];}, addEventListener() {},
  };
  vm.runInNewContext(fs.readFileSync(path.join(__dirname,"../dashboard/app.js"),"utf8"),{
    document,Intl,Date,URLSearchParams,AbortSignal,
    RewardFormat:require("../dashboard/format.js"),RewardStatus:require("../dashboard/status.js"),
    RewardAnimation:require("../dashboard/animation.js"),
    ResizeObserver:class {observe() {}},setInterval(){},setTimeout(){},clearTimeout(){},
    fetch:async()=>({ok:true,json:async()=>data}),
  });
  await new Promise(resolve=>setImmediate(resolve));
  return elements;
}

test("actual ledger rendering uses compact amounts and retains exact tooltips",async()=>{
  const at="2026-10-30T20:00:00Z";
  const amounts=["18300","540","2360000","99800000","100000000",null];
  const data={generatedAt:at,range:{from:at,to:at,bucketSeconds:60},kinds:[],
    collectionCounts:{},collectionSeries:{},confirmedClaims:6,pendingClaims:0,
    clickAttempts:6,logExists:true,recent:amounts.map(amount=>({at,amount,label:"Health",kind:"hp",confirmed:true}))};
  const elements=await renderDashboard(data);
  const cells=elements.get("entries").children.map(row=>row.children[2]);
  assert.deepEqual(cells.map(cell=>cell.textContent),["+18,3K","+540","+2,3M","+99,8M","+100M","?"]);
  assert.equal(cells[0].title,"Pontos naplóérték: +18\u202f300");
  assert.equal(cells[2].attributes["aria-label"],"Health: +2\u202f360\u202f000");
  assert.equal(cells[5].title,undefined,"missing amounts must not fabricate a zero");
  assert.deepEqual(data.recent.map(row=>row.amount),amounts,"rendering must not change source amounts");
});

test("stat cards render in the requested pairs without reordering source data or legend",async()=>{
  const original=["hp","regeneration","piercing_damage","cutting_damage","smash_damage","piercing_defense","cutting_defense","smash_defense"];
  const at="2026-10-30T20:00:00Z";
  const data={generatedAt:at,range:{from:at,to:at,bucketSeconds:60},
    kinds:original.map(kind=>({kind,label:kind,total:"100"})),
    collectionCounts:Object.fromEntries(original.map(kind=>[kind,1])),collectionSeries:{},series:{},
    confirmedClaims:8,pendingClaims:0,clickAttempts:8,logExists:true,recent:[]};
  const elements=await renderDashboard(data);
  assert.deepEqual(elements.get("stats-grid").children.map(card=>card.dataset.kind),
    ["hp","regeneration","piercing_damage","cutting_defense","cutting_damage","smash_defense","smash_damage","piercing_defense"]);
  assert.deepEqual(data.kinds.map(row=>row.kind),original);
  assert.deepEqual(elements.get("frequency-legend").children.map(button=>button.querySelector(".frequency-name").textContent),original);
  const css=fs.readFileSync(path.join(__dirname,"../dashboard/style.css"),"utf8");
  for(const [,body] of css.matchAll(/\.stats-grid\{([^}]+)\}/g)) {
    const columns=/grid-template-columns:([^;]+)/.exec(body);
    if(columns) assert.equal(columns[1],"repeat(2,minmax(0,1fr))","four rows of two cards at every breakpoint");
  }
});
