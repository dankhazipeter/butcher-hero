"use strict";
(() => {
  const $ = id => document.getElementById(id);
  const zone = "Europe/Bucharest";
  let storage;try {storage=globalThis.localStorage;} catch {}
  const i18n=RewardI18n.createI18n({catalogs:RewardLocales,storage});
  const t=i18n.t;
  const labelOf=row=>i18n.has(`kind.${row.kind}`)?t(`kind.${row.kind}`):row.label;
  let date,clock,short;
  function applyLanguage() {
    i18n.apply(document);
    $("range-description").textContent=t("timezone",{zone});
    date=new Intl.DateTimeFormat(i18n.locale,{timeZone:zone,month:"2-digit",day:"2-digit",hour:"2-digit",minute:"2-digit",second:"2-digit"});
    clock=new Intl.DateTimeFormat(i18n.locale,{timeZone:zone,hour:"2-digit",minute:"2-digit",second:"2-digit"});
    short=new Intl.DateTimeFormat(i18n.locale,{timeZone:zone,hour:"2-digit",minute:"2-digit"});
  }
  applyLanguage();
  let mode = "run", snapshot, sequence = 0, pollVersion = 0, timer, lastCount;
  let statusConnected=false,connectionError=null;
  let launchBusy=false,launchUntil=0,launchFeedback=null;
  let cards = new Map();
  const hiddenKinds=new Set();
  const frequencyButtons=new Map();
  const linePatterns=new Map([
    ["hp",""],["regeneration","7 3"],["piercing_damage",""],["cutting_damage","2 3"],
    ["smash_damage",""],["piercing_defense","8 3 2 3"],["cutting_defense","5 3"],["smash_defense","1 4"],
  ]);
  const statOrder=new Map(["hp","regeneration","piercing_damage","cutting_defense",
    "cutting_damage","smash_defense","smash_damage","piercing_defense"].map((kind,index)=>[kind,index]));
  const orderedKinds=kinds=>[...kinds].sort((a,b)=>(statOrder.get(a.kind)??statOrder.size)-(statOrder.get(b.kind)??statOrder.size));
  const decimal=value=>RewardFormat.formatExact(value,i18n.locale);
  const compact=value=>RewardFormat.formatCompact(value,i18n.locale);
  const connectionMessage=()=>t("connectionError",{message:connectionError?.status?t("httpError",{status:connectionError.status}):connectionError?.message||""});
  const animateValue=RewardAnimation.createAnimator({
    CountUp:globalThis.countUp?.CountUp,formatCompact:compact,formatExact:decimal,
    reducedMotion:()=>typeof matchMedia==="function" && matchMedia("(prefers-reduced-motion: reduce)").matches,
    hidden:()=>document.hidden,
  });
  function renderCollector() {
    const now=Date.now();
    const game=RewardStatus.gameStatus(snapshot?.game,snapshot?.generatedAt,now,statusConnected,t);
    if(game.state==="running") {launchUntil=0;if(!launchBusy) launchFeedback=null;}
    if(launchUntil && now>=launchUntil && !launchBusy) {
      launchUntil=0;launchFeedback=game.state==="window_unavailable"?null:"game.launchFailed";
    }
    const launching=launchBusy || (now<launchUntil && ["not_running","window_unavailable"].includes(game.state));
    $("game-panel").dataset.state=launching?"launching":game.state;
    $("game-status").textContent=launching?t("game.launching"):game.label;
    $("game-detail").textContent=launching?t("game.launchingDetail"):game.detail;
    const launchButton=$("game-launch");
    launchButton.hidden=!game.canLaunch;
    launchButton.disabled=launchBusy || launching || !snapshot?.gameLaunchToken;
    launchButton.textContent=t(launching?"game.launching":"game.launch");
    $("game-launch-feedback").textContent=launchFeedback?t(launchFeedback):"";
    const status=RewardStatus.collectorStatus(snapshot?.watcher,snapshot?.generatedAt,now,statusConnected,t,snapshot?.game);
    $("collector-panel").dataset.state=status.state;
    if($("collector").textContent!==status.label) $("collector").textContent=status.label;
    $("collector-detail").textContent=status.detail;
    $("collector-frame").textContent=t("lastFrame",{time:status.checkedAt?clock.format(new Date(status.checkedAt)):t("noData")});
  }
  $("game-launch").addEventListener("click",async()=>{
    const game=RewardStatus.gameStatus(snapshot?.game,snapshot?.generatedAt,Date.now(),statusConnected,t);
    if(launchBusy || Date.now()<launchUntil || !game.canLaunch || !snapshot?.gameLaunchToken) return;
    launchBusy=true;launchFeedback=null;renderCollector();
    try {
      const response=await fetch("/api/game/launch",{method:"POST",cache:"no-store",
        headers:{"Content-Type":"application/json","X-Game-Launch-Token":snapshot.gameLaunchToken},
        body:"{}",signal:AbortSignal.timeout(6000)});
      const data=await response.json();
      if(!response.ok || !["requested","already_running"].includes(data.status)) {
        launchFeedback=data.error==="not_installed"?"game.notInstalledDetail":data.error==="launch_cooldown"?"game.cooldown":"game.launchFailed";
      } else {
        launchUntil=Date.now()+15000;launchFeedback="game.launchRequested";
      }
    } catch {launchFeedback="game.launchFailed";}
    finally {launchBusy=false;renderCollector();refresh();}
  });
  function field(tag, text, className) {
    const node = document.createElement(tag); node.textContent = text;
    if(className) node.className=className;
    return node;
  }
  function svgNode(tag, attrs, text) {
    const node = document.createElementNS("http://www.w3.org/2000/svg",tag);
    for(const [key,value] of Object.entries(attrs)) node.setAttribute(key,value);
    if(text != null) node.textContent=text;
    return node;
  }
  function draw(card, row, points) {
    const svg=card.querySelector("svg");
    const width=Math.round(svg.getBoundingClientRect().width);
    if(width<=0) return;
    const height=110, left=33, right=7, top=12, bottom=85;
    svg.setAttribute("viewBox",`0 0 ${width} ${height}`); svg.replaceChildren();
    svg.append(svgNode("title",{},t("statChartTitle",{label:labelOf(row),amount:decimal(row.total),count:decimal(row.count)})));
    const start=Date.parse(snapshot.range.from),end=Date.parse(snapshot.range.to);
    const max=Math.max(1,...points.map(p=>Number(p.value)));
    const x=t=>left+(Date.parse(t)-start)/Math.max(1,end-start)*(width-left-right);
    const y=v=>bottom-Number(v)/max*(bottom-top);
    svg.append(svgNode("path",{d:`M${left},${top}V${bottom}H${width-right}`,class:"guide"}));
    svg.append(svgNode("text",{x:left-5,y:top+3,"text-anchor":"end"},compact(max)));
    svg.append(svgNode("text",{x:left-5,y:bottom+3,"text-anchor":"end"},"0"));
    let path=`M${x(points[0].at)},${y(points[0].value)}`;
    for(let i=1;i<points.length;i++) path+=`H${x(points[i].at)}V${y(points[i].value)}`;
    svg.append(svgNode("path",{d:path+`V${bottom}H${left}Z`,class:"area"}));
    svg.append(svgNode("path",{d:path,class:"series"}));
    const last=points[points.length-1];
    svg.append(svgNode("circle",{cx:x(last.at),cy:y(last.value),r:2.5,class:"endpoint"}));
    const longRange=end-start>24*3600e3;
    const tick=t=>longRange?new Intl.DateTimeFormat(i18n.locale,{timeZone:zone,month:"2-digit",day:"2-digit"}).format(new Date(t)):short.format(new Date(t));
    svg.append(svgNode("text",{x:left,y:104,"text-anchor":"start"},tick(start)));
    svg.append(svgNode("text",{x:width-right,y:104,"text-anchor":"end"},tick(end)));
    const hit=svgNode("rect",{x:left,y:top,width:Math.max(1,width-left-right),height:bottom-top,class:"hit"});
    const title=svgNode("title",{},t("chartHit")); hit.append(title);
    hit.addEventListener("pointermove",event=>{
      const box=svg.getBoundingClientRect();
      const cursor=start+Math.max(0,Math.min(1,(event.clientX-box.left-left)/(width-left-right)))*(end-start);
      let nearest=points[0];
      for(const point of points) {if(Date.parse(point.at)>cursor) break;nearest=point;}
      title.textContent=t("chartPoint",{time:date.format(new Date(cursor)),amount:decimal(nearest.value),label:labelOf(row)});
    });
    svg.append(hit);
  }
  function drawFrequency() {
    if(!snapshot || !snapshot.collectionSeries) return;
    const svg=$("frequency-svg"),host=$("frequency-chart"),tooltip=$("frequency-tooltip");
    const width=Math.round(host.getBoundingClientRect().width);
    if(width<=0) return;
    const height=Math.round(svg.getBoundingClientRect().height)||300,left=52,right=20,top=24,bottom=height-42;
    const start=Date.parse(snapshot.range.from),end=Date.parse(snapshot.range.to);
    const maxCount=Math.max(1,...Object.values(snapshot.collectionCounts));
    const raw=Math.max(1,Math.ceil(maxCount/5)),power=10**Math.floor(Math.log10(raw));
    const step=[1,2,5,10].find(value=>value>=raw/power)*power;
    const ceiling=Math.ceil(maxCount/step)*step;
    const x=value=>left+(value-start)/Math.max(1,end-start)*(width-left-right);
    const y=value=>bottom-value/ceiling*(bottom-top);
    svg.setAttribute("viewBox",`0 0 ${width} ${height}`);svg.replaceChildren();tooltip.hidden=true;
    svg.append(svgNode("title",{},t("frequencyDescription")));
    svg.append(svgNode("text",{x:left,y:13,class:"frequency-axis-label"},t("countAxis")));
    for(let count=0;count<=ceiling;count+=step) {
      svg.append(svgNode("line",{x1:left,y1:y(count),x2:width-right,y2:y(count),class:"frequency-grid"}));
      svg.append(svgNode("text",{x:left-9,y:y(count)+4,"text-anchor":"end"},decimal(count)));
    }
    const tickCount=width<600?3:5;
    const timeFormat=end-start>24*3600e3
      ? new Intl.DateTimeFormat(i18n.locale,{timeZone:zone,month:"2-digit",day:"2-digit"}):short;
    for(let i=0;i<tickCount;i++) {
      const time=start+(end-start)*i/(tickCount-1);
      svg.append(svgNode("text",{x:x(time),y:height-18,"text-anchor":i===0?"start":i===tickCount-1?"end":"middle"},timeFormat.format(new Date(time))));
    }
    svg.append(svgNode("text",{x:width-right,y:height-1,"text-anchor":"end",class:"frequency-axis-label"},t("timeAxis",{zone})));
    orderedKinds(snapshot.kinds).forEach(row=>{
      if(hiddenKinds.has(row.kind)) return;
      const points=snapshot.collectionSeries[row.kind];
      let path=`M${x(Date.parse(points[0].at))},${y(points[0].count)}`;
      for(let i=1;i<points.length;i++) path+=`H${x(Date.parse(points[i].at))}V${y(points[i].count)}`;
      const group=svgNode("g",{class:`frequency-series frequency-${row.kind}`,"data-kind":row.kind});
      const line=svgNode("path",{d:path,class:"frequency-line","stroke-dasharray":linePatterns.get(row.kind)||""});
      line.append(svgNode("title",{},`${labelOf(row)}: ${t("count",{count:decimal(snapshot.collectionCounts[row.kind])})}`));
      group.append(line,svgNode("circle",{cx:x(end),cy:y(points[points.length-1].count),r:3,class:"frequency-endpoint"}));
      svg.append(group);
    });
    const guide=svgNode("line",{x1:left,y1:top,x2:left,y2:bottom,class:"frequency-guide",visibility:"hidden"});svg.append(guide);
    const hit=svgNode("rect",{x:left,y:top,width:Math.max(1,width-left-right),height:bottom-top,class:"frequency-hit"});
    hit.addEventListener("pointermove",event=>{
      const box=svg.getBoundingClientRect(),localX=Math.max(left,Math.min(width-right,event.clientX-box.left));
      const at=start+(localX-left)/(width-left-right)*(end-start);
      guide.setAttribute("x1",localX);guide.setAttribute("x2",localX);guide.setAttribute("visibility","visible");
      tooltip.replaceChildren(field("strong",date.format(new Date(at))));
      for(const row of orderedKinds(snapshot.kinds)) {
        if(hiddenKinds.has(row.kind)) continue;
        let count=0;
        for(const point of snapshot.collectionSeries[row.kind]) {if(Date.parse(point.at)>at) break;count=point.count;}
        const detail=field("div","","frequency-tooltip-row");detail.append(field("span",labelOf(row)),field("span",t("count",{count:decimal(count)})));tooltip.append(detail);
      }
      tooltip.hidden=false;
      const tw=tooltip.offsetWidth,th=tooltip.offsetHeight;
      tooltip.style.left=`${Math.max(0,Math.min(width-tw,localX+12))}px`;
      tooltip.style.top=`${Math.max(0,Math.min(height-th,event.clientY-box.top+12))}px`;
    });
    hit.addEventListener("pointerleave",()=>{guide.setAttribute("visibility","hidden");tooltip.hidden=true;});
    svg.append(hit);
  }
  function renderFrequency(data) {
    const classified=Object.values(data.collectionCounts).reduce((sum,value)=>sum+value,0);
    orderedKinds(data.kinds).forEach(row=>{
      let button=frequencyButtons.get(row.kind);
      if(!button) {
        button=field("button","",`frequency-key frequency-${row.kind}`);button.type="button";
        button.setAttribute("aria-controls","frequency-svg");
        const swatch=svgNode("svg",{viewBox:"0 0 24 8","aria-hidden":"true",class:"frequency-swatch"});
        swatch.append(svgNode("path",{d:"M1 4H23","stroke-dasharray":linePatterns.get(row.kind)||""}));
        const image=document.createElement("img");image.src=`/icons/${row.kind}.png`;image.alt="";
        button.append(swatch,image,field("span",labelOf(row),"frequency-name"),field("span","","frequency-amount"));
        button.addEventListener("click",()=>{
          if(hiddenKinds.has(row.kind)) hiddenKinds.delete(row.kind);else hiddenKinds.add(row.kind);
          button.setAttribute("aria-pressed",String(!hiddenKinds.has(row.kind)));drawFrequency();
        });
        $("frequency-legend").append(button);frequencyButtons.set(row.kind,button);
      }
      button.querySelector(".frequency-name").textContent=labelOf(row);
      const count=data.collectionCounts[row.kind],share=classified?count/classified*100:0;
      button.setAttribute("aria-pressed",String(!hiddenKinds.has(row.kind)));
      button.querySelector(".frequency-amount").textContent=t("legendCount",{count:decimal(count),share:share.toLocaleString(i18n.locale,{maximumFractionDigits:1})});
    });
    $("frequency-summary").textContent=t("frequencySummary",{count:decimal(classified)})+
      (data.unclassifiedClaims?" "+t("unclassifiedSummary",{count:decimal(data.unclassifiedClaims)}):"");
    drawFrequency();
  }
  function render(data,fresh=true) {
    snapshot=data;
    if(fresh) {statusConnected=true;connectionError=null;}
    $("connection").textContent=t(statusConnected?"live":"disconnected");
    if(statusConnected) $("connection").classList.remove("error");
    renderCollector();
    $("updated").textContent=t("updated",{time:clock.format(new Date(data.generatedAt))});
    $("confirmed").textContent=decimal(data.confirmedClaims);
    $("pending").textContent=decimal(data.pendingClaims);
    $("last-claim").textContent=data.lastConfirmedAt?clock.format(new Date(data.lastConfirmedAt)):t("noClaims");
    $("attempts").textContent=t("attempts",{count:decimal(data.clickAttempts)});
    $("range-description").textContent=t("rangeDescription",{from:date.format(new Date(data.range.from)),to:date.format(new Date(data.range.to)),zone,minutes:decimal(Math.round(data.range.bucketSeconds/60))});
    const warnings=[];
    $("data-quality-note").hidden=!data.historicalDataWarning;
    if(!data.logExists) warnings.push(t("noLog"));
    if(data.malformedLines) warnings.push(t("malformed",{count:decimal(data.malformedLines)}));
    if(data.unknownConfirmed) warnings.push(t("uncertain",{count:decimal(data.unknownConfirmed)}));
    if(data.observationError) warnings.push(t("observationError",{message:data.observationError}));
    if(connectionError) warnings.push(connectionMessage());
    $("notice").hidden=!warnings.length; $("notice").textContent=warnings.join(" ");
    for(const row of orderedKinds(data.kinds)) {
      let card=cards.get(row.kind);
      if(!card) {
        card=field("article","","stat"); card.dataset.kind=row.kind;
        const heading=field("div","","stat-head"),icon=document.createElement("img");
        icon.src=`/icons/${row.kind}.png`;icon.alt="";
        heading.append(icon,field("h3",labelOf(row)));
        card.append(heading,field("div","","stat-value"),field("div","","stat-count"));
        card.append(svgNode("svg",{class:"spark",role:"img","aria-label":t("statChartAria",{label:labelOf(row)}) }));
        $("stats-grid").append(card);cards.set(row.kind,card);
      }
      card.querySelector("h3").textContent=labelOf(row);
      card.querySelector("svg").setAttribute("aria-label",t("statChartAria",{label:labelOf(row)}));
      const value=card.querySelector(".stat-value");
      animateValue(value,row.total,`${i18n.language}:${mode==="custom"?`${mode}:${$("from").value}:${$("to").value}`:mode}`);
      value.title=t("exact",{amount:decimal(row.total)});
      value.setAttribute("aria-label",`${labelOf(row)}: +${decimal(row.total)}`);
      card.querySelector(".stat-count").textContent=t("confirmedCount",{count:decimal(data.collectionCounts[row.kind])});
      draw(card,row,data.series[row.kind]);
    }
    renderFrequency(data);
    $("entries").replaceChildren();
    for(const row of data.recent) {
      const tr=document.createElement("tr");
      const type=field("td",""),label=field("span","","entry-kind");
      if(cards.has(row.kind)) {const image=document.createElement("img");image.src=`/icons/${row.kind}.png`;image.alt="";label.append(image);}
      label.append(document.createTextNode(labelOf(row)));type.append(label);
      const amount=field("td",row.amount==null?"?":`+${compact(row.amount)}`,"numeric");
      if(row.amount!=null) {
        amount.title=t("exact",{amount:decimal(row.amount)});
        amount.setAttribute("aria-label",`${labelOf(row)}: +${decimal(row.amount)}`);
      }
      tr.append(field("td",date.format(new Date(row.at))),type,
        amount,
        field("td",t(row.confirmed?"claimed":"unconfirmed"),`claim-state${row.confirmed?"":" pending"}`));
      $("entries").append(tr);
    }
    $("empty").hidden=!!data.recent.length;
    $("recent-count").textContent=t("recentCount",{count:decimal(data.recent.length)});
    if(lastCount!==data.confirmedClaims) $("announcer").textContent=t("announcement",{count:decimal(data.confirmedClaims)});
    lastCount=data.confirmedClaims;
  }
  async function refresh() {
    const version=++sequence;
    const query=new URLSearchParams({range:mode});
    if(mode==="custom") {query.set("from",$("from").value);query.set("to",$("to").value);}
    try {
      const response=await fetch(`/api/rewards?${query}`,{cache:"no-store",signal:AbortSignal.timeout(6000)});
      const data=await response.json();
      if(version!==sequence) return;
      if(!response.ok) throw Object.assign(new Error("HTTP"),{status:response.status});
      render(data);
    } catch(error) {
      if(version!==sequence) return;
      $("connection").textContent=t("disconnected");$("connection").classList.add("error");
      statusConnected=false;connectionError=error;renderCollector();
      $("notice").hidden=false;$("notice").textContent=connectionMessage();
    }
  }
  function choose(value) {
    mode=value;
    for(const button of document.querySelectorAll("[data-range]")) button.setAttribute("aria-pressed",String(button.dataset.range===mode));
    refresh();
  }
  for(const button of document.querySelectorAll("[data-range]")) button.addEventListener("click",()=>choose(button.dataset.range));
  const rangeHelp=$("range-help");
  $("range-help-open").addEventListener("click",()=>{if(!rangeHelp.open) rangeHelp.showModal();});
  $("range-help-close").addEventListener("click",()=>rangeHelp.close());
  rangeHelp.addEventListener("close",()=>$("range-help-open").focus({preventScroll:true}));
  rangeHelp.addEventListener("click",event=>{
    if(event.target!==rangeHelp) return;
    const box=rangeHelp.getBoundingClientRect();
    if(event.clientX<box.left || event.clientX>box.right || event.clientY<box.top || event.clientY>box.bottom) rangeHelp.close();
  });
  $("custom-range").addEventListener("submit",event=>{event.preventDefault();choose("custom");});
  function localInput(now) {
    const parts=new Intl.DateTimeFormat("sv-SE",{timeZone:zone,year:"numeric",month:"2-digit",day:"2-digit",hour:"2-digit",minute:"2-digit",hourCycle:"h23"}).formatToParts(now);
    const p=Object.fromEntries(parts.map(x=>[x.type,x.value]));return `${p.year}-${p.month}-${p.day}T${p.hour}:${p.minute}`;
  }
  const languagePicker=$("language");
  for(const catalog of Object.values(i18n.catalogs)) {
    const option=field("option",catalog.name);option.value=catalog.language;languagePicker.append(option);
  }
  languagePicker.value=i18n.language;
  languagePicker.addEventListener("change",()=>{
    if(!i18n.setLanguage(languagePicker.value)) return;
    applyLanguage();lastCount=undefined;
    if(snapshot) render(snapshot,false);else {
      renderCollector();$("connection").textContent=t(connectionError?"disconnected":"connecting");
      if(connectionError) {$("notice").hidden=false;$("notice").textContent=connectionMessage();}
    }
  });
  $("to").value=localInput(new Date());$("from").value=localInput(new Date(Date.now()-3600e3));
  const layout=new ResizeObserver(()=>{
    if(snapshot) {for(const row of snapshot.kinds) draw(cards.get(row.kind),row,snapshot.series[row.kind]);drawFrequency();}
  });
  layout.observe($("stats-grid"));layout.observe($("frequency-chart"));
  function poll() {const version=++pollVersion;clearTimeout(timer);refresh().finally(()=>{if(version===pollVersion) timer=setTimeout(poll,document.hidden?10000:2000);});}
  document.addEventListener("visibilitychange",()=>{if(!document.hidden) {renderCollector();poll();}});
  setInterval(renderCollector,1000);
  renderCollector();
  poll();
})();
