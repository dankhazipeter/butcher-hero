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

async function renderDashboard(data,frequencyWidth=0,{savedLanguage=null,failFetch=false,fetchReply=null,timeZone="UTC"}={}) {
  const vm=require("node:vm");
  class Element {
    constructor(tagName="") {this.tagName=tagName;this.children=[];this.dataset={};this.attributes={};this.listeners={};this.style={};this.classList={add(){},remove(){}};}
    append(...children) {this.children.push(...children);}
    replaceChildren(...children) {this.children=children;}
    setAttribute(key,value) {this.attributes[key]=value;if(key==="class") this.className=value;}
    addEventListener(name,callback) {this.listeners[name]=callback;}
    showModal() {this.open=true;this.showModalCalls=(this.showModalCalls||0)+1;}
    close() {this.open=false;this.listeners.close?.();}
    focus(options) {this.focused=true;this.focusOptions=options;}
    getAttribute(key) {return this.attributes[key];}
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
    querySelectorAll(selector) {
      if(selector==="[data-range]") return staticNodes.filter(node=>node.dataset.range);
      if(selector==="[data-i18n]") return staticNodes.filter(node=>node.dataset.i18n);
      const attribute=/^\[(data-i18n-(?:aria-label|title))\]$/.exec(selector)?.[1];
      return attribute?staticNodes.filter(node=>Object.hasOwn(node.attributes,attribute)):[];
    }, addEventListener() {},
  };
  // Register the real HTML's static hooks rather than fabricating modal labels.
  const staticNodes=[];
  const html=fs.readFileSync(path.join(__dirname,"../dashboard/index.html"),"utf8");
  for(const [,tag,attributes] of html.matchAll(/<([a-z][a-z\d-]*)\b([^<>]*)>/gi)) {
    const attrs=Object.fromEntries([...attributes.matchAll(/([\w-]+)="([^"]*)"/g)].map(m=>[m[1],m[2]]));
    const node=attrs.id?document.getElementById(attrs.id):new Element(tag);
    node.tagName=tag;
    for(const [key,value] of Object.entries(attrs)) {
      node.setAttribute(key,value);
      if(key.startsWith("data-")) node.dataset[key.slice(5).replace(/-([a-z])/g,(_,letter)=>letter.toUpperCase())]=value;
    }
    staticNodes.push(node);
  }
  let requests=0,scheduled;const requestLog=[];
  const browserIntl=Object.create(Intl);
  browserIntl.DateTimeFormat=function(locale,options) {
    return new Intl.DateTimeFormat(locale,{...options,timeZone:options?.timeZone??timeZone});
  };
  const storage={getItem(){return savedLanguage;},setItem(key,value){savedLanguage=value;}};
  vm.runInNewContext(fs.readFileSync(path.join(__dirname,"../dashboard/app.js"),"utf8"),{
    document,Intl:browserIntl,Date,URLSearchParams,AbortSignal,
    localStorage:storage,RewardI18n:require("../dashboard/i18n.js"),
    RewardLocales:{hu:require("../dashboard/locales/hu.js"),en:require("../dashboard/locales/en.js")},
    RewardFormat:require("../dashboard/format.js"),RewardStatus:require("../dashboard/status.js"),
    RewardAnimation:require("../dashboard/animation.js"),
    ResizeObserver:class {observe() {}},setInterval(){},setTimeout(fn){scheduled=fn;},clearTimeout(){},
    fetch:async(url,options)=>{requests++;requestLog.push({url,options});if(typeof failFetch==="function"?failFetch(requests):failFetch) throw new Error("offline");return fetchReply?fetchReply(url,options,requests):{ok:true,json:async()=>data};},
  });
  await new Promise(resolve=>setImmediate(resolve));
  elements.document=document;elements.storage=storage;elements.requests=()=>requests;elements.staticNodes=staticNodes;
  elements.requestLog=requestLog;
  elements.setTimeZone=value=>{timeZone=value;};
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
  assert.equal(cells[2].attributes["aria-label"],"Health: +2\u202f360\u202f000");
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
  assert.equal(card.querySelector("h3").textContent,"Health");
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

function helpData() {
  const at=new Date().toISOString();
  return {generatedAt:at,range:{mode:"run",from:"2026-10-30T16:50:44.381Z",to:at,bucketSeconds:60},kinds:[],
    collectionCounts:{},collectionSeries:{},confirmedClaims:3,pendingClaims:0,clickAttempts:3,logExists:true,recent:[]};
}

function sessionData() {
  return {...helpData(),statisticsSessionToken:"session-token",currentSession:{id:"old-session",startedAt:"2026-10-30T16:50:44.381Z"}};
}
test("new-session action requires confirmation; cancel, modal close and language changes never POST",async()=>{
  const elements=await renderDashboard(sessionData());
  const begin=elements.get("session-start"),confirm=elements.get("session-confirm");
  assert.equal(begin.disabled,false);assert.equal(confirm.hidden,true);
  begin.listeners.click();assert.equal(confirm.hidden,false);
  assert.equal(elements.get("session-cancel").focused,true,"safe cancel receives initial focus");
  assert.equal(elements.requests(),1);
  const picker=elements.get("language");picker.value="en";picker.listeners.change();
  assert.equal(elements.get("session-confirm-start").textContent,"Yes, start new session");
  assert.equal(confirm.hidden,false);
  elements.get("session-cancel").listeners.click();assert.equal(confirm.hidden,true);
  begin.listeners.click();elements.get("range-help").close();assert.equal(confirm.hidden,true);
  await elements.get("session-confirm-start").listeners.click();
  assert.equal(elements.requests(),1);assert.equal(elements.get("confirmed").textContent,"3");
});
test("confirmed session start sends its own token once and switches to Current run after acknowledgement",async()=>{
  let data=sessionData(),ack;
  const reply=new Promise(resolve=>ack=resolve);
  const elements=await renderDashboard(data,0,{fetchReply:async(url)=>url==="/api/statistics/session"?reply:{ok:true,json:async()=>data}});
  const today=elements.staticNodes.find(node=>node.dataset.range==="today");today.listeners.click();
  await new Promise(resolve=>setImmediate(resolve));
  elements.get("session-start").listeners.click();
  const pending=elements.get("session-confirm-start").listeners.click();
  await elements.get("session-confirm-start").listeners.click();
  assert.equal(elements.get("session-confirm-start").disabled,true);
  assert.equal(elements.get("confirmed").textContent,"3","never fabricate a reset before server acknowledgement");
  data={...data,currentSession:{id:"new-session"},confirmedClaims:0};
  ack({ok:true,json:async()=>({status:"started",currentSession:data.currentSession})});
  await pending;await new Promise(resolve=>setImmediate(resolve));
  const posts=elements.requestLog.filter(row=>row.options.method==="POST");assert.equal(posts.length,1);
  assert.equal(posts[0].options.headers["X-Statistics-Session-Token"],"session-token");
  assert.deepEqual(JSON.parse(posts[0].options.body),{expectedSessionID:"old-session"});
  assert.equal(new URL(elements.requestLog.at(-1).url,"http://localhost").searchParams.get("range"),"run");
  assert.equal(elements.get("confirmed").textContent,"0");
  assert.ok(elements.get("session-feedback").textContent.includes("elindult"));
});
test("session error never auto-retries POST and another attempt requires fresh confirmation",async()=>{
  const elements=await renderDashboard(sessionData(),0,{savedLanguage:"en",fetchReply:async(url)=>url==="/api/statistics/session"
    ?{ok:false,json:async()=>({error:"session_changed"})}:{ok:true,json:async()=>sessionData()}});
  elements.get("session-start").listeners.click();await elements.get("session-confirm-start").listeners.click();
  await new Promise(resolve=>setImmediate(resolve));
  assert.ok(elements.get("session-feedback").textContent.includes("Another session"));
  await elements.get("session-confirm-start").listeners.click();elements.poll();
  await new Promise(resolve=>setImmediate(resolve));
  assert.equal(elements.requestLog.filter(row=>row.options.method==="POST").length,1);
  assert.equal(elements.get("confirmed").textContent,"3");
  assert.equal(elements.get("session-confirm").hidden,true);
});
test("session start stays disabled for stale, disconnected or unsupported server state",async()=>{
  for(const data of [helpData(),{...sessionData(),generatedAt:"2020-01-01T00:00:00Z"}]) {
    const elements=await renderDashboard(data);
    assert.equal(elements.get("session-start").disabled,true);
    elements.get("session-start").listeners.click();await elements.get("session-confirm-start").listeners.click();
    assert.equal(elements.requests(),1);
  }
  const elements=await renderDashboard(sessionData(),0,{failFetch:count=>count>1});
  elements.poll();await new Promise(resolve=>setImmediate(resolve));
  assert.equal(elements.get("session-start").disabled,true);
});
test("an armed confirmation retains its original session ID while other tabs update the poll",async()=>{
  let data=sessionData();
  const elements=await renderDashboard(data,0,{fetchReply:async(url)=>url==="/api/statistics/session"
    ?{ok:false,json:async()=>({error:"session_changed"})}:{ok:true,json:async()=>data}});
  elements.get("session-start").listeners.click();data={...data,currentSession:{id:"other-tab-session"}};
  elements.poll();await new Promise(resolve=>setImmediate(resolve));
  await elements.get("session-confirm-start").listeners.click();
  const post=elements.requestLog.find(row=>row.options.method==="POST");
  assert.equal(JSON.parse(post.options.body).expectedSessionID,"old-session");
});
test("a pre-reset poll arriving late cannot replace the new-session counters",async()=>{
  let data=sessionData(),release,reads=0;
  const stale=new Promise(resolve=>release=resolve);
  const elements=await renderDashboard(data,0,{fetchReply:async(url)=>{
    if(url==="/api/statistics/session") {
      data={...data,currentSession:{id:"new-session"},confirmedClaims:0};
      return {ok:true,json:async()=>({status:"started",currentSession:data.currentSession})};
    }
    if(++reads===2) return stale;
    return {ok:true,json:async()=>data};
  }});
  elements.poll();
  elements.get("session-start").listeners.click();
  await elements.get("session-confirm-start").listeners.click();
  await new Promise(resolve=>setImmediate(resolve));
  release({ok:true,json:async()=>sessionData()});
  await new Promise(resolve=>setImmediate(resolve));
  assert.equal(elements.get("confirmed").textContent,"0");
});

test("all displayed dates and request filters use the browser zone, not the UI language or Romania",async()=>{
  const at="2026-10-31T20:00:00Z";
  const data={...helpData(),generatedAt:at,lastConfirmedAt:at,recent:[{at,kind:"hp",label:"Health",amount:"18100",confirmed:true}]};
  for(const [timeZone,hour] of [["Europe/Budapest","21:00:00"],["Europe/Bucharest","22:00:00"],["America/New_York","16:00:00"]]) {
    const elements=await renderDashboard(data,0,{timeZone});
    assert.equal(new URL(elements.requestLog[0].url,"http://localhost").searchParams.get("timezone"),timeZone);
    assert.match(elements.get("range-description").textContent,new RegExp(timeZone));
    assert.equal(elements.get("last-claim").textContent,hour);
    assert.ok(elements.get("entries").children[0].children[0].textContent.includes(hour));
    assert.ok(elements.get("updated").textContent.includes(hour));
    const picker=elements.get("language");picker.value="en";picker.listeners.change();
    assert.equal(elements.get("last-claim").textContent,hour,"language must not change timezone");
    assert.equal(elements.requests(),1);
  }
});

test("travel updates timezone on polling and custom date fields are sent with that same zone",async()=>{
  const at="2026-10-31T20:00:00Z";
  const elements=await renderDashboard({...helpData(),generatedAt:at,lastConfirmedAt:at},0,{timeZone:"Europe/Bucharest"});
  elements.setTimeZone("Europe/Budapest");elements.poll();
  await new Promise(resolve=>setImmediate(resolve));
  assert.equal(elements.get("last-claim").textContent,"21:00:00");
  elements.get("from").value="2026-10-31T09:15";elements.get("to").value="2026-10-31T10:15";
  elements.get("custom-range").listeners.submit({preventDefault(){}});
  await new Promise(resolve=>setImmediate(resolve));
  const query=new URL(elements.requestLog.at(-1).url,"http://localhost").searchParams;
  assert.equal(query.get("timezone"),"Europe/Budapest");
  assert.equal(query.get("from"),"2026-10-31T09:15");assert.equal(query.get("to"),"2026-10-31T10:15");
});
test("time-range info opens without selecting a range, refreshing or changing counters",async()=>{
  const elements=await renderDashboard(helpData());
  const opener=elements.get("range-help-open"),dialog=elements.get("range-help");
  const description=elements.get("range-description").textContent;
  assert.equal(opener.attributes["aria-haspopup"],"dialog");
  assert.equal(opener.attributes["aria-controls"],"range-help");
  assert.equal(opener.dataset.range,undefined,"info must not become a range selection");
  assert.equal(dialog.attributes["aria-labelledby"],"range-help-title");
  assert.equal(Boolean(dialog.open),false);
  opener.listeners.click();opener.listeners.click();
  assert.equal(dialog.open,true);assert.equal(dialog.showModalCalls,1);
  assert.equal(elements.requests(),1);
  assert.equal(elements.get("confirmed").textContent,"3");
  assert.equal(elements.get("range-description").textContent,description);
  elements.get("range-help-close").listeners.click();
  assert.equal(dialog.open,false);assert.equal(opener.focused,true);
  assert.equal(opener.focusOptions.preventScroll,true);
});
test("info dialog ignores inside clicks, closes on backdrop and keeps native Escape semantics",async()=>{
  const elements=await renderDashboard(helpData()),dialog=elements.get("range-help");
  const opener=elements.get("range-help-open");opener.listeners.click();
  dialog.getBoundingClientRect=()=>({left:100,right:600,top:100,bottom:500});
  dialog.listeners.click({target:elements.get("range-help-title"),clientX:150,clientY:150});
  assert.equal(dialog.open,true);
  dialog.listeners.click({target:dialog,clientX:150,clientY:150});
  assert.equal(dialog.open,true,"dialog padding is not its backdrop");
  dialog.listeners.click({target:dialog,clientX:50,clientY:150});
  assert.equal(dialog.open,false);assert.equal(opener.focused,true);
  assert.equal(dialog.listeners.cancel,undefined,"do not prevent the native Escape-to-close action");
  const html=fs.readFileSync(path.join(__dirname,"../dashboard/index.html"),"utf8");
  assert.match(html,/<dialog\b[^>]*id="range-help"/);
  assert.match(html,/<button\b[^>]*id="range-help-close"[^>]*autofocus/);
});
test("help is translated on first load and language changes preserve open state and filters",async()=>{
  const elements=await renderDashboard(helpData(),0,{savedLanguage:"en"});
  const title=elements.get("range-help-title"),opener=elements.get("range-help-open"),dialog=elements.get("range-help");
  assert.equal(title.textContent,"What do the time ranges mean?");
  assert.equal(opener.attributes["aria-label"],title.textContent);
  opener.listeners.click();
  const from=elements.get("from").value,to=elements.get("to").value;
  const picker=elements.get("language");picker.value="hu";picker.listeners.change();
  assert.equal(dialog.open,true);assert.equal(title.textContent,"Mit jelentenek az időszakok?");
  assert.equal(elements.get("range-help-close").attributes["aria-label"],"Bezárás");
  assert.equal(elements.staticNodes.find(node=>node.dataset.i18n==="rangeHelpTechnical").textContent,
    require("../dashboard/locales/hu.js").messages.rangeHelpTechnical);
  assert.equal(elements.get("from").value,from);assert.equal(elements.get("to").value,to);
  assert.equal(elements.requests(),1);
});

test("game-not-running is explicit and launch only occurs on a user action with the local token",async()=>{
  const data=helpData(),at=data.generatedAt;
  data.watcher={stateKnown:true,running:true,lastCheckedAt:at};
  data.game={known:true,installed:true,running:false,hidden:false,windowVisible:false,checkedAt:at};
  data.gameLaunchToken="fixture-server-token";
  let posts=0,release;
  const elements=await renderDashboard(data,0,{savedLanguage:"en",fetchReply:async(url)=>{
    if(url==="/api/game/launch") {posts++;await new Promise(resolve=>release=resolve);return {ok:true,json:async()=>({status:"requested"})};}
    return {ok:true,json:async()=>data};
  }});
  assert.equal(posts,0,"polling must never launch the game");
  assert.equal(elements.get("game-status").textContent,"The game is not running");
  assert.equal(elements.get("collector").textContent,"Waiting for game");
  const button=elements.get("game-launch");assert.equal(button.hidden,false);assert.equal(button.disabled,false);
  const action=button.listeners.click();
  assert.equal(button.disabled,true);assert.equal(elements.get("game-status").textContent,"Launching game…");
  await button.listeners.click();assert.equal(posts,1,"double clicks must not create two launch requests");
  const sent=elements.requestLog.find(row=>row.url==="/api/game/launch");
  assert.equal(sent.options.method,"POST");assert.equal(sent.options.headers["X-Game-Launch-Token"],"fixture-server-token");
  assert.equal(sent.options.body,"{}");
  release();await action;await new Promise(resolve=>setImmediate(resolve));
  assert.equal(elements.get("game-status").textContent,"Launching game…","request success is not running-game proof");
  assert.equal(elements.get("confirmed").textContent,"3","launch must not reset statistics");
});
test("hidden game, unknown status and stopped collector remain distinct; no unguarded launch",async()=>{
  for(const [game,expected] of [
    [{known:true,installed:true,running:true,hidden:true,windowVisible:false},"Game window is not visible"],
    [{known:false},"Cannot verify"],
    [{known:true,installed:false,running:false,hidden:false,windowVisible:false},"Game not found"],
  ]) {
    const data=helpData();data.game={...game,checkedAt:data.generatedAt};data.gameLaunchToken="fixture";
    data.watcher={stateKnown:true,running:false,lastCheckedAt:data.generatedAt};
    const elements=await renderDashboard(data,0,{savedLanguage:"en"});
    assert.equal(elements.get("game-status").textContent,expected);
    assert.equal(elements.get("collector").textContent,"Stopped");
    assert.equal(elements.get("game-launch").hidden,true);
    await elements.get("game-launch").listeners.click();
    assert.equal(elements.requests(),1,"programmatic click cannot bypass game-state checks");
  }
});
test("launch failure is translated, permits retry and cannot advertise the game as running",async()=>{
  const data=helpData();data.game={known:true,installed:true,running:false,hidden:false,windowVisible:false,checkedAt:data.generatedAt};data.gameLaunchToken="fixture";
  const elements=await renderDashboard(data,0,{savedLanguage:"en",fetchReply:async(url)=>url==="/api/game/launch"
    ?{ok:false,json:async()=>({error:"launch_failed"})}:{ok:true,json:async()=>data}});
  await elements.get("game-launch").listeners.click();await new Promise(resolve=>setImmediate(resolve));
  assert.equal(elements.get("game-status").textContent,"The game is not running");
  assert.equal(elements.get("game-launch").disabled,false);
  assert.ok(elements.get("game-launch-feedback").textContent.includes("could not be confirmed"));
  const picker=elements.get("language");picker.value="hu";picker.listeners.change();
  assert.equal(elements.get("game-launch").textContent,"Játék indítása");
  assert.equal(elements.get("game-status").textContent,"A játék nem fut");
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
