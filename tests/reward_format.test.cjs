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

async function renderDashboard(data,frequencyWidth=0,{savedLanguage=null,failFetch=false}={}) {
  const vm=require("node:vm");
  class Element {
    constructor(tagName="") {this.tagName=tagName;this.children=[];this.dataset={};this.attributes={};this.listeners={};this.style={};this.classList={add(){},remove(){}};}
    append(...children) {this.children.push(...children);}
    replaceChildren(...children) {this.children=children;}
    setAttribute(key,value) {this.attributes[key]=value;if(key==="class") this.className=value;}
    addEventListener(name,callback) {this.listeners[name]=callback;}
    getBoundingClientRect() {return {width:this.width||0,left:0,top:0};}
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
    documentElement:{},
    getElementById(id) {
      if(!elements.has(id)) {const element=new Element();if(id==="frequency-chart") element.width=frequencyWidth;elements.set(id,element);}
      return elements.get(id);
    },
    createElement(tag) {return new Element(tag);},createElementNS(ns,tag) {return new Element(tag);},
    createTextNode(text) {return {textContent:text};},
    querySelectorAll() {return [];}, addEventListener() {},
  };
  let requests=0,scheduled;
  const storage={getItem(){return savedLanguage;},setItem(key,value){savedLanguage=value;}};
  vm.runInNewContext(fs.readFileSync(path.join(__dirname,"../dashboard/app.js"),"utf8"),{
    document,Intl,Date,URLSearchParams,AbortSignal,
    localStorage:storage,RewardI18n:require("../dashboard/i18n.js"),
    RewardLocales:{hu:require("../dashboard/locales/hu.js"),en:require("../dashboard/locales/en.js")},
    RewardFormat:require("../dashboard/format.js"),RewardStatus:require("../dashboard/status.js"),
    RewardAnimation:require("../dashboard/animation.js"),
    ResizeObserver:class {observe() {}},setInterval(){},setTimeout(fn){scheduled=fn;},clearTimeout(){},
    fetch:async()=>{requests++;if(typeof failFetch==="function"?failFetch(requests):failFetch) throw new Error("offline");return {ok:true,json:async()=>data};},
  });
  await new Promise(resolve=>setImmediate(resolve));
  elements.document=document;elements.storage=storage;elements.requests=()=>requests;
  elements.poll=()=>scheduled();
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
  assert.equal(cells[2].attributes["aria-label"],"Életerő: +2\u202f360\u202f000");
  assert.equal(cells[5].title,undefined,"missing amounts must not fabricate a zero");
  assert.deepEqual(data.recent.map(row=>row.amount),amounts,"rendering must not change source amounts");
});

test("cards, legend and chart share the requested order without reordering source data or changing line identities",async()=>{
  const original=["hp","regeneration","piercing_damage","cutting_damage","smash_damage","piercing_defense","cutting_defense","smash_defense"];
  const at="2026-10-30T20:00:00Z";
  const data={generatedAt:at,range:{from:at,to:at,bucketSeconds:60},
    kinds:original.map(kind=>({kind,label:kind,total:"100"})),
    collectionCounts:Object.fromEntries(original.map(kind=>[kind,1])),
    collectionSeries:Object.fromEntries(original.map(kind=>[kind,[{at,count:0},{at,count:1}]])),series:{},
    confirmedClaims:8,pendingClaims:0,clickAttempts:8,logExists:true,recent:[]};
  const elements=await renderDashboard(data,600);
  const expected=["hp","regeneration","piercing_damage","cutting_defense","cutting_damage","smash_defense","smash_damage","piercing_defense"];
  assert.deepEqual(elements.get("stats-grid").children.map(card=>card.dataset.kind),expected);
  assert.deepEqual(data.kinds.map(row=>row.kind),original);
  const buttons=elements.get("frequency-legend").children;
  const messages=require("../dashboard/locales/hu.js").messages;
  assert.deepEqual(buttons.map(button=>button.querySelector(".frequency-name").textContent),expected.map(kind=>messages[`kind.${kind}`]));
  const lines=elements.get("frequency-svg").children.filter(group=>(group.className||"").startsWith("frequency-series "));
  assert.deepEqual(lines.map(group=>group.attributes["data-kind"]),expected);
  const patterns={hp:"",regeneration:"7 3",piercing_damage:"",cutting_damage:"2 3",smash_damage:"",piercing_defense:"8 3 2 3",cutting_defense:"5 3",smash_defense:"1 4"};
  expected.forEach((kind,index)=>{
    assert.equal(lines[index].querySelector(".frequency-line").attributes["stroke-dasharray"],patterns[kind]);
    assert.equal(buttons[index].querySelector("path").attributes["stroke-dasharray"],patterns[kind]);
  });
  const hit=elements.get("frequency-svg").querySelector(".frequency-hit");
  hit.listeners.pointermove({clientX:300,clientY:100});
  assert.deepEqual(elements.get("frequency-tooltip").children.slice(1).map(row=>row.children[0].textContent),expected.map(kind=>messages[`kind.${kind}`]));
  const css=fs.readFileSync(path.join(__dirname,"../dashboard/style.css"),"utf8");
  for(const [,body] of css.matchAll(/\.(?:stats-grid|frequency-legend)\{([^}]+)\}/g)) {
    const columns=/grid-template-columns:([^;]+)/.exec(body);
    if(columns) assert.equal(columns[1],"repeat(2,minmax(0,1fr))","four rows of two cards at every breakpoint");
  }
});

test("live language switch updates existing cards, legend, amounts and ledger without another request or filter reset",async()=>{
  const at=new Date().toISOString();
  const data={generatedAt:at,range:{from:at,to:at,bucketSeconds:60},
    watcher:{stateKnown:true,running:true,lastCheckedAt:at},
    kinds:[{kind:"hp",label:"Health",total:"18300",count:1}],collectionCounts:{hp:1},collectionSeries:{},series:{},
    confirmedClaims:1,pendingClaims:0,clickAttempts:1,logExists:true,
    recent:[{at,amount:"18300",label:"Health",kind:"hp",confirmed:true}]};
  const elements=await renderDashboard(data);
  const card=elements.get("stats-grid").children[0];
  assert.equal(card.querySelector(".stat-value").textContent,"+18,3K");
  const from=elements.get("from").value,to=elements.get("to").value;
  const legendButton=elements.get("frequency-legend").children[0];legendButton.listeners.click();
  const picker=elements.get("language");picker.value="en";picker.listeners.change();
  assert.equal(elements.document.documentElement.lang,"en");
  assert.equal(elements.storage.getItem(),"en");
  assert.equal(elements.get("collector").textContent,"Running");
  assert.equal(elements.get("stats-grid").children[0],card,"language switch must preserve the card and its state");
  assert.equal(card.querySelector("h3").textContent,"Health");
  assert.equal(card.querySelector(".stat-value").textContent,"+18.3K");
  assert.equal(card.querySelector(".stat-value").title,"Exact logged value: +18,300");
  assert.equal(elements.get("entries").children[0].children[2].textContent,"+18.3K");
  assert.equal(elements.get("entries").children[0].children[3].textContent,"Claimed");
  assert.equal(elements.get("frequency-legend").children[0].querySelector(".frequency-name").textContent,"Health");
  assert.equal(elements.get("from").value,from);assert.equal(elements.get("to").value,to);
  assert.equal(legendButton.attributes["aria-pressed"],"false","hidden chart lines must stay hidden");
  assert.equal(elements.requests(),1);
  picker.value="hu";picker.listeners.change();
  assert.equal(elements.get("collector").textContent,"Fut");
  assert.equal(card.querySelector("h3").textContent,"Életerő");
  assert.equal(card.querySelector(".stat-value").textContent,"+18,3K");
});

test("saved English selection is used at startup",async()=>{
  const at=new Date().toISOString();
  const elements=await renderDashboard({generatedAt:at,range:{from:at,to:at,bucketSeconds:60},kinds:[],
    collectionCounts:{},collectionSeries:{},confirmedClaims:0,pendingClaims:0,clickAttempts:0,logExists:true,recent:[]},0,{savedLanguage:"en"});
  assert.equal(elements.document.documentElement.lang,"en");
  assert.equal(elements.get("language").value,"en");
  assert.equal(elements.get("last-claim").textContent,"None yet");
});

test("switching language after a connection failure cannot mark the collector healthy",async()=>{
  const at=new Date().toISOString();
  const elements=await renderDashboard({generatedAt:at,range:{from:at,to:at,bucketSeconds:60},kinds:[],
    watcher:{stateKnown:true,running:true,lastCheckedAt:at},collectionCounts:{},collectionSeries:{},
    confirmedClaims:1,pendingClaims:0,clickAttempts:1,logExists:true,recent:[]},0,{failFetch:request=>request>1});
  assert.equal(elements.get("collector").textContent,"Fut");
  elements.poll();await new Promise(resolve=>setImmediate(resolve));
  const picker=elements.get("language");picker.value="en";picker.listeners.change();
  assert.equal(elements.get("collector-panel").dataset.state,"unknown");
  assert.equal(elements.get("collector").textContent,"Cannot verify");
  assert.equal(elements.get("connection").textContent,"DISCONNECTED");
  assert.ok(elements.get("notice").textContent.includes("last successfully loaded data"));
  assert.equal(elements.requests(),2);
});
