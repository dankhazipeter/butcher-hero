"use strict";
(() => {
  const $ = id => document.getElementById(id);
  const zone = "Europe/Bucharest";
  const date = new Intl.DateTimeFormat("hu-HU", {timeZone:zone,month:"2-digit",day:"2-digit",hour:"2-digit",minute:"2-digit",second:"2-digit"});
  const clock = new Intl.DateTimeFormat("hu-HU", {timeZone:zone,hour:"2-digit",minute:"2-digit",second:"2-digit"});
  const short = new Intl.DateTimeFormat("hu-HU", {timeZone:zone,hour:"2-digit",minute:"2-digit"});
  let mode = "run", snapshot, sequence = 0, pollVersion = 0, timer, lastCount;
  let cards = new Map();
  const hiddenKinds=new Set();
  const frequencyButtons=new Map();
  const linePatterns=["","7 3","","2 3","","8 3 2 3","5 3","1 4"];
  const {formatExact:decimal,formatCompact:compact}=RewardFormat;
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
    svg.append(svgNode("title",{},`${row.label}: ${decimal(row.total)}, ${row.count} átvétel; halmozott érték az idő függvényében.`));
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
    const tick=t=>longRange?new Intl.DateTimeFormat("hu-HU",{timeZone:zone,month:"2-digit",day:"2-digit"}).format(new Date(t)):short.format(new Date(t));
    svg.append(svgNode("text",{x:left,y:104,"text-anchor":"start"},tick(start)));
    svg.append(svgNode("text",{x:width-right,y:104,"text-anchor":"end"},tick(end)));
    const hit=svgNode("rect",{x:left,y:top,width:Math.max(1,width-left-right),height:bottom-top,class:"hit"});
    const title=svgNode("title",{},"Idő és gyűjtött mennyiség"); hit.append(title);
    hit.addEventListener("pointermove",event=>{
      const box=svg.getBoundingClientRect();
      const cursor=start+Math.max(0,Math.min(1,(event.clientX-box.left-left)/(width-left-right)))*(end-start);
      let nearest=points[0];
      for(const point of points) {if(Date.parse(point.at)>cursor) break;nearest=point;}
      title.textContent=`${date.format(new Date(cursor))} · ${decimal(nearest.value)} ${row.label} (időszakon belül, összesen)`;
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
    svg.append(svgNode("title",{},"Igazolt gyűjtések jutalomtípusonként; a jutalom nagysága nem számít, egy átvétel egy darab."));
    svg.append(svgNode("text",{x:left,y:13,class:"frequency-axis-label"},"Átvétel (db)"));
    for(let count=0;count<=ceiling;count+=step) {
      svg.append(svgNode("line",{x1:left,y1:y(count),x2:width-right,y2:y(count),class:"frequency-grid"}));
      svg.append(svgNode("text",{x:left-9,y:y(count)+4,"text-anchor":"end"},decimal(count)));
    }
    const tickCount=width<600?3:5;
    const timeFormat=end-start>24*3600e3
      ? new Intl.DateTimeFormat("hu-HU",{timeZone:zone,month:"2-digit",day:"2-digit"}):short;
    for(let i=0;i<tickCount;i++) {
      const time=start+(end-start)*i/(tickCount-1);
      svg.append(svgNode("text",{x:x(time),y:height-18,"text-anchor":i===0?"start":i===tickCount-1?"end":"middle"},timeFormat.format(new Date(time))));
    }
    svg.append(svgNode("text",{x:width-right,y:height-1,"text-anchor":"end",class:"frequency-axis-label"},"Idő · Europe/Bucharest"));
    snapshot.kinds.forEach((row,index)=>{
      if(hiddenKinds.has(row.kind)) return;
      const points=snapshot.collectionSeries[row.kind];
      let path=`M${x(Date.parse(points[0].at))},${y(points[0].count)}`;
      for(let i=1;i<points.length;i++) path+=`H${x(Date.parse(points[i].at))}V${y(points[i].count)}`;
      const group=svgNode("g",{class:`frequency-series frequency-${row.kind}`,"data-kind":row.kind});
      const line=svgNode("path",{d:path,class:"frequency-line","stroke-dasharray":linePatterns[index]});
      line.append(svgNode("title",{},`${row.label}: ${snapshot.collectionCounts[row.kind]} db`));
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
      for(const row of snapshot.kinds) {
        if(hiddenKinds.has(row.kind)) continue;
        let count=0;
        for(const point of snapshot.collectionSeries[row.kind]) {if(Date.parse(point.at)>at) break;count=point.count;}
        const detail=field("div","","frequency-tooltip-row");detail.append(field("span",row.label),field("span",`${count} db`));tooltip.append(detail);
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
    data.kinds.forEach((row,index)=>{
      let button=frequencyButtons.get(row.kind);
      if(!button) {
        button=field("button","",`frequency-key frequency-${row.kind}`);button.type="button";
        button.setAttribute("aria-controls","frequency-svg");
        const swatch=svgNode("svg",{viewBox:"0 0 24 8","aria-hidden":"true",class:"frequency-swatch"});
        swatch.append(svgNode("path",{d:"M1 4H23","stroke-dasharray":linePatterns[index]}));
        const image=document.createElement("img");image.src=`/icons/${row.kind}.png`;image.alt="";
        button.append(swatch,image,field("span",row.label,"frequency-name"),field("span","","frequency-amount"));
        button.addEventListener("click",()=>{
          if(hiddenKinds.has(row.kind)) hiddenKinds.delete(row.kind);else hiddenKinds.add(row.kind);
          button.setAttribute("aria-pressed",String(!hiddenKinds.has(row.kind)));drawFrequency();
        });
        $("frequency-legend").append(button);frequencyButtons.set(row.kind,button);
      }
      const count=data.collectionCounts[row.kind],share=classified?count/classified*100:0;
      button.setAttribute("aria-pressed",String(!hiddenKinds.has(row.kind)));
      button.querySelector(".frequency-amount").textContent=`${count} db · ${share.toLocaleString("hu-HU",{maximumFractionDigits:1})}%`;
    });
    $("frequency-summary").textContent=`${classified} azonosított, igazolt átvétel. Az arányok ezekre vonatkoznak; egy átvétel egy darab, a statértékétől függetlenül.`+
      (data.unclassifiedClaims?` További ${data.unclassifiedClaims} igazolt átvétel típusa még ismeretlen, ezért nincs a vonalakon.`:"");
    drawFrequency();
  }
  function render(data) {
    snapshot=data;
    $("connection").textContent="ÉLŐ NAPLÓ"; $("connection").classList.remove("error");
    const watcher=data.watcher;
    $("collector").textContent=!watcher.running?"A gyűjtő leállítva":watcher.waitingForMouseRelease?"Mozgás közben várakozik":watcher.frameAgeSeconds>10?"Nincs friss játékkép":"A gyűjtő fut";
    $("updated").textContent=`Frissítve ${clock.format(new Date(data.generatedAt))} · 2 mp`;
    $("confirmed").textContent=decimal(data.confirmedClaims);
    $("pending").textContent=decimal(data.pendingClaims);
    $("last-claim").textContent=data.lastConfirmedAt?clock.format(new Date(data.lastConfirmedAt)):"Még nincs";
    $("attempts").textContent=`${decimal(data.clickAttempts)} kattintási próbálkozás`;
    $("range-description").textContent=`${date.format(new Date(data.range.from))} → ${date.format(new Date(data.range.to))} · Europe/Bucharest · ${Math.round(data.range.bucketSeconds/60)} perces diagrambontás`;
    const warnings=[];
    $("data-quality-note").hidden=!data.historicalDataWarning;
    if(!data.logExists) warnings.push("A jutalomnapló még nem létezik. A következő átvételeknél megjelennek az adatok.");
    if(data.malformedLines) warnings.push(`${data.malformedLines} hibás naplósor kimaradt.`);
    if(data.unknownConfirmed) warnings.push(`${data.unknownConfirmed} igazolt átvétel típusa vagy mennyisége még bizonytalan; nincs beleszámolva a statösszegekbe.`);
    if(data.observationError) warnings.push(`Gyűjtő: ${data.observationError}`);
    $("notice").hidden=!warnings.length; $("notice").textContent=warnings.join(" ");
    for(const row of data.kinds) {
      let card=cards.get(row.kind);
      if(!card) {
        card=field("article","","stat"); card.dataset.kind=row.kind;
        const heading=field("div","","stat-head"),icon=document.createElement("img");
        icon.src=`/icons/${row.kind}.png`;icon.alt="";
        heading.append(icon,field("h3",row.label));
        card.append(heading,field("div","","stat-value"),field("div","","stat-count"));
        card.append(svgNode("svg",{class:"spark",role:"img","aria-label":`${row.label} halmozott gyűjtése` }));
        $("stats-grid").append(card);cards.set(row.kind,card);
      }
      const value=card.querySelector(".stat-value");
      value.textContent=`+${compact(row.total)}`;
      value.title=`Pontos naplóérték: +${decimal(row.total)}`;
      value.setAttribute("aria-label",`${row.label}: +${decimal(row.total)}`);
      card.querySelector(".stat-count").textContent=`${data.collectionCounts[row.kind]} igazolt átvétel`;
      draw(card,row,data.series[row.kind]);
    }
    renderFrequency(data);
    $("entries").replaceChildren();
    for(const row of data.recent) {
      const tr=document.createElement("tr");
      const type=field("td",""),label=field("span","","entry-kind");
      if(cards.has(row.kind)) {const image=document.createElement("img");image.src=`/icons/${row.kind}.png`;image.alt="";label.append(image);}
      label.append(document.createTextNode(row.label));type.append(label);
      tr.append(field("td",date.format(new Date(row.at))),type,
        field("td",row.amount==null?"?":`+${decimal(row.amount)}`,"numeric"),
        field("td",row.confirmed?"Átvéve":"Nem igazolt",`claim-state${row.confirmed?"":" pending"}`));
      $("entries").append(tr);
    }
    $("empty").hidden=!!data.recent.length;
    $("recent-count").textContent=`${data.recent.length} legutóbbi tétel · a kattintás időpontja szerint`;
    if(lastCount!==data.confirmedClaims) $("announcer").textContent=`${data.confirmedClaims} igazolt átvétel a kiválasztott időszakban.`;
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
      if(!response.ok) throw new Error(data.error||"A nézet most nem érhető el.");
      render(data);
    } catch(error) {
      if(version!==sequence) return;
      $("connection").textContent="NINCS KAPCSOLAT";$("connection").classList.add("error");
      $("notice").hidden=false;$("notice").textContent=`${error.message} Az utolsó sikeres adatok maradtak láthatók.`;
    }
  }
  function choose(value) {
    mode=value;
    for(const button of document.querySelectorAll("[data-range]")) button.setAttribute("aria-pressed",String(button.dataset.range===mode));
    refresh();
  }
  for(const button of document.querySelectorAll("[data-range]")) button.addEventListener("click",()=>choose(button.dataset.range));
  $("custom-range").addEventListener("submit",event=>{event.preventDefault();choose("custom");});
  function localInput(now) {
    const parts=new Intl.DateTimeFormat("sv-SE",{timeZone:zone,year:"numeric",month:"2-digit",day:"2-digit",hour:"2-digit",minute:"2-digit",hourCycle:"h23"}).formatToParts(now);
    const p=Object.fromEntries(parts.map(x=>[x.type,x.value]));return `${p.year}-${p.month}-${p.day}T${p.hour}:${p.minute}`;
  }
  $("to").value=localInput(new Date());$("from").value=localInput(new Date(Date.now()-3600e3));
  const layout=new ResizeObserver(()=>{
    if(snapshot) {for(const row of snapshot.kinds) draw(cards.get(row.kind),row,snapshot.series[row.kind]);drawFrequency();}
  });
  layout.observe($("stats-grid"));layout.observe($("frequency-chart"));
  function poll() {const version=++pollVersion;clearTimeout(timer);refresh().finally(()=>{if(version===pollVersion) timer=setTimeout(poll,document.hidden?10000:2000);});}
  document.addEventListener("visibilitychange",()=>{if(!document.hidden) poll();});
  poll();
})();
