const test=require("node:test");
const assert=require("node:assert/strict");
const fs=require("node:fs");
const path=require("node:path");
const {createI18n}=require("../dashboard/i18n.js");
const {formatCompact,formatExact}=require("../dashboard/format.js");
const {collectorStatus}=require("../dashboard/status.js");
const folder=path.join(__dirname,"../dashboard/locales");
const catalogs=Object.fromEntries(fs.readdirSync(folder).filter(file=>file.endsWith(".js"))
  .map(file=>{const catalog=require(path.join(folder,file));return [catalog.language,catalog];}));
const placeholders=text=>[...text.matchAll(/\{(\w+)\}/g)].map(m=>m[1]).sort();

test("game stat names stay in English in both UI languages",()=>{
  const names={hp:"Health",regeneration:"Health Regen",piercing_damage:"Pierce Damage",cutting_damage:"Cut Damage",
    smash_damage:"Smash Damage",piercing_defense:"Pierce Defense",cutting_defense:"Cut Defense",smash_defense:"Smash Defense"};
  for(const [kind,name] of Object.entries(names)) for(const catalog of Object.values(catalogs))
    assert.equal(catalog.messages[`kind.${kind}`],name);
});

test("language files and translator also register correctly as browser scripts",()=>{
  const vm=require("node:vm"),context=vm.createContext({});
  for(const language of Object.keys(catalogs))
    vm.runInContext(fs.readFileSync(path.join(folder,language+".js"),"utf8"),context);
  vm.runInContext(fs.readFileSync(path.join(__dirname,"../dashboard/i18n.js"),"utf8"),context);
  for(const language of Object.keys(catalogs)) assert.equal(context.RewardLocales[language].language,language);
  const i18n=context.RewardI18n.createI18n({catalogs:context.RewardLocales});
  i18n.setLanguage("en");assert.equal(i18n.t("language"),"Language");
});

test("all language files have matching complete keys and interpolation placeholders",()=>{
  assert.ok(catalogs.hu&&catalogs.en);
  for(const [language,catalog] of Object.entries(catalogs)) {
    assert.equal(catalog.language,language);assert.ok(catalog.name);assert.ok(catalog.locale);
    assert.deepEqual(Object.keys(catalog.messages).sort(),Object.keys(catalogs.hu.messages).sort(),language);
    for(const [key,text] of Object.entries(catalog.messages)) {
      assert.equal(typeof text,"string");assert.ok(text.trim(),language+" "+key);
      assert.deepEqual(placeholders(text),placeholders(catalogs.hu.messages[key]),language+" "+key);
    }
  }
});
test("all static HTML keys and literal JS translation keys exist in every catalog",()=>{
  const html=fs.readFileSync(path.join(__dirname,"../dashboard/index.html"),"utf8");
  const app=fs.readFileSync(path.join(__dirname,"../dashboard/app.js"),"utf8");
  const keys=[...html.matchAll(/data-i18n(?:-aria-label|-title)?="([^"]+)"/g),...app.matchAll(/\bt\("([^"]+)"/g)].map(m=>m[1]);
  for(const catalog of Object.values(catalogs)) for(const key of keys) assert.ok(Object.hasOwn(catalog.messages,key),catalog.language+" "+key);
  for(const language of Object.keys(catalogs)) {
    const index=html.indexOf(`src="/locales/${language}.js"`);
    assert.ok(index>=0&&index<html.indexOf('src="/i18n.js"'),language+": load its file before i18n");
  }
  assert.ok(html.indexOf('src="/locales/hu.js"')<html.indexOf('src="/i18n.js"'));
  assert.ok(html.indexOf('src="/i18n.js"')<html.indexOf('src="/app.js"'));
});
test("selection persists, restores, and falls back safely when storage is unavailable or invalid",()=>{
  let saved=null;const storage={getItem:()=>saved,setItem:(key,value)=>saved=value};
  const first=createI18n({catalogs,storage});assert.equal(first.language,"hu");
  assert.equal(first.setLanguage("en"),true);assert.equal(saved,"en");
  assert.equal(createI18n({catalogs,storage}).language,"en");
  assert.equal(first.setLanguage("not-supported"),false);assert.equal(first.language,"en");
  saved="__proto__";assert.equal(createI18n({catalogs,storage}).language,"hu");
  const blocked={getItem(){throw Error("blocked");},setItem(){throw Error("blocked");}};
  const fallback=createI18n({catalogs,storage:blocked});assert.equal(fallback.language,"hu");
  assert.equal(fallback.setLanguage("en"),true);assert.equal(fallback.t("live"),"LIVE LOG");
});
test("translation fallback and interpolation preserve text rather than injecting HTML",()=>{
  const i18n=createI18n({catalogs:{...catalogs,xx:{...catalogs.en,locale:"en-GB",messages:{}}}});
  i18n.setLanguage("xx");assert.equal(i18n.t("heading"),catalogs.hu.messages.heading);
  assert.equal(i18n.t("missing"),"missing");assert.equal(i18n.t("__proto__"),"__proto__");
  assert.equal(i18n.t("observationError",{message:"<b>raw log</b>"}),"Gyűjtő: <b>raw log</b>");
});
test("static labels, accessible attributes, title and document language update together",()=>{
  const node={dataset:{i18n:"heading"},textContent:""},label={attributes:{},getAttribute:()=>"collectorLabel",setAttribute(k,v){this.attributes[k]=v;}};
  const document={documentElement:{},querySelectorAll(selector){return selector==="[data-i18n]"?[node]:selector==="[data-i18n-aria-label]"?[label]:[];}};
  const i18n=createI18n({catalogs});i18n.apply(document);
  assert.equal(document.documentElement.lang,"hu");assert.equal(node.textContent,"Amit összegyűjtöttünk");
  i18n.setLanguage("en");i18n.apply(document);
  assert.equal(document.documentElement.lang,"en");assert.equal(node.textContent,"What we've collected");
  assert.equal(label.attributes["aria-label"],"Collector status");assert.equal(document.title,"Butcher Hero · Live reward log");
});
test("English and Hungarian format numbers without changing the exact source",()=>{
  assert.equal(formatCompact("18300","hu-HU"),"18,3K");assert.equal(formatCompact("18300","en-GB"),"18.3K");
  assert.equal(formatExact("2360000.5","en-GB"),"2,360,000.5");
  assert.equal(formatExact("123456789012345678901.5","en-GB"),"123,456,789,012,345,678,901.5");
  assert.equal(formatCompact("99800000","en-GB"),"99.8M");assert.equal(formatCompact("100900000","en-GB"),"100M");
});
test("all collector states are translated without changing their health decisions",()=>{
  const i18n=createI18n({catalogs});i18n.setLanguage("en");
  const now=Date.now(),stamp=new Date(now).toISOString(),active={stateKnown:true,running:true,lastCheckedAt:stamp,
    captureSourceVerified:true,captureStatus:"ok",screenState:"hud"};
  const states=[
    [active,true,"running"],[{...active,running:false},true,"stopped"],
    [{...active,lastCheckedAt:null},true,"starting"],[{...active,lastCheckedAt:new Date(now-15000).toISOString()},true,"stale"],
    [{...active,waitingForMouseRelease:true},true,"waiting"],[active,false,"unknown"],
    [{...active,captureSourceVerified:false},true,"source_unverified"],
    [{...active,captureStatus:"error"},true,"capture_error"],
    [{...active,screenState:"unrecognized"},true,"unrecognized"],
    [{...active,screenState:"crystal"},true,"processing"],
    [{...active,crystalPhase:"blocked"},true,"blocked"],
  ];
  for(const [watcher,connected,expected] of states) {
    const status=collectorStatus(watcher,stamp,now,connected,i18n.t);
    assert.equal(status.state,expected);assert.equal(status.label,catalogs.en.messages[`status.${expected}`]);
    assert.ok(!status.detail.includes("status."));assert.ok(!status.detail.includes("{seconds}"));
  }
});
