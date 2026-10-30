"use strict";
(() => {
  const $ = id => document.getElementById(id);
  const zone = "Europe/Bucharest";
  const date = new Intl.DateTimeFormat("hu-HU", {timeZone:zone,month:"2-digit",day:"2-digit",hour:"2-digit",minute:"2-digit",second:"2-digit"});
  const clock = new Intl.DateTimeFormat("hu-HU", {timeZone:zone,hour:"2-digit",minute:"2-digit",second:"2-digit"});
  const short = new Intl.DateTimeFormat("hu-HU", {timeZone:zone,hour:"2-digit",minute:"2-digit"});
  let mode = "run", snapshot, sequence = 0, pollVersion = 0, timer, lastCount;
  let cards = new Map();
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
      card.querySelector(".stat-count").textContent=`${row.count} igazolt átvétel`;
      draw(card,row,data.series[row.kind]);
    }
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
  new ResizeObserver(()=>{if(snapshot) for(const row of snapshot.kinds) draw(cards.get(row.kind),row,snapshot.series[row.kind]);}).observe($("stats-grid"));
  function poll() {const version=++pollVersion;clearTimeout(timer);refresh().finally(()=>{if(version===pollVersion) timer=setTimeout(poll,document.hidden?10000:2000);});}
  document.addEventListener("visibilitychange",()=>{if(!document.hidden) poll();});
  poll();
})();
