# HP-sor geometriai elkülönítése — 2026-09-19

175128-observe/0friss helyzet:5,93K, tábor délkeleti nyílt oldala.
Kisfahelyek8h8m körön, a palánk mögött élő64HPőrök. Nem régiPNG-ből indítunk.

253után a0.5jutalom1.5félreolvasása még hamis5HP-t adott. Új módszer:
az OCR megtartja a tágabb képi környezetét, de minden felismert szöveg
saját képi téglalapját is ellenőrzi. Csak a konkrét piros csík saját
sorába eső szövegközép lehetHP. A fölötte lévő jutalomsor számai nem
versenyeznek vele, akár0.5,1.5vagy más hibás alakban olvassa őket.

Ez nem extra teljes OCR-kör képenként; a meglévő felismerési eredmény
geometriáját szűri. Bizonytalan/kis/képszéli olvasatnál a korábbi szűk
felnagyított csíksoros tartalék megmarad. A játékosHP-felismerést nem érinti.

Mérés:174156teljes replay és új174801/0–3őrök; továbbá korábbi428/1160
és közeli csíkmaradék ellenőrzése. Élő sikerfeltétel továbbra valódi
kerítésmegkerülés és célkontaktus, nem csak helyes számkiírás.

Első geometriai replay FAIL: a Vision téglalapját teljes képre vetítve
minden szélesHP-sor kiesett. Külön, csak olvasó Vision-próba a174156/3
képen igazolta, hogy a bbox a megadottROI-n belül normalizált.
Helyes transzformáció:roi.maxY−bbox.midY×roi.height. Ezzel a64szövegközép
191px, az érintett csík187–194px; a0.5külön fölötte marad.
A regresszió többé nem követeli a kizárandó0.5jelenlétét aHP-OCR-listában,
de továbbra megköveteli a felismert64-et és tiltja a hamis5/50HP-t.

Javított build és mindkét teljes pajzsregresszió PASS; quick-farmPASS,
beleértve1160képszéli célt,2320valódi sajátHP-t és közeli csíkmaradékot.

## Élő kör és új geometriai tévesztés

175529/4–6az őr64HP-ja helyesen olvasott;6képen a torony másik oldalán
áll, sebzés nincs.19–24falmenti mozgás délnyugatra,25–33a tábor délnyugati
sarka felé.40végképen továbbra kívül vagyunk,5,93K, új fejlődés nincs.

34–40megállás: a játékos cipőjének297..306×479..486piros foltja8px-magas
elfogyott csíknak tűnt, üresOCR-rel közeli fenyegetéssé vált. A254HP-szűrés
ezt nem okozta; a244csíkmaradék-felismerés túl kevés keretbizonyítékot kért.
Új feltétel a rövid, közel négyzetes vörös maradékokra: a pirosrészen túl
legalább18pixeles vizsgált oldalszakaszon felső és alsó sötét keret is kell.
Saját cipőre negatív, a161504/0valódi DOC-csíkmaradékra pozitív replay készül.

## Élő áttörés — 17:58

Rövidcsík-keret negatívcipő/pozitívDOCreplay és quick-farm PASS.
175849/0–3a délnyugati sarkot elhagyja;3–6észak a kerítés külső nyugati
oldalán;9képen egyértelműen a palánktól nyugatra.12és14keleti próba
a tényleges résen át;16képen már a belső oldalon a szélmalom alatt,
**két látható+0,5pajzs jutalomeffektus**. Ez valódi bejutás és őrharc,
nem pusztán a kamera csúszása. Saját5,93K, két kis10-es sebzésszám látszik,
gyors regeneráció mellett nincs tartós HP-esés.

19–25a szélmalom fölötti431HP/20szíves fa felé halad.26képen**+20szív**,
új3m59s kör és**5,95K** sajátHP. A régi5,93K→5,95K kijelzés és jutalom
együtt igazolja a fejlődést. Teljes kerítésmegkerülés és aratás ebben a45s
körben sikerült. A későbbi ismételhetőséget külön kell mérni.

Mért bejárat (orange-skull koordinátatér, nem swipe-makró):
3:(−30;33,5) →9:(−30,58;20,98) →12:(−30,82;14,17)
→14:(−27,02;14,13) →16:(−23,5;12,5).
3és16biztos narancstámpont, a köztes részen kameraodometriai áthidalás;
a köztes pontok nem külön, nagy pontosságú minimap-fixek.
Külön gépi mérési fájl:camps-west-entry.json; automatikus globális portálként
nem importáljuk a köztes odometriai bizonytalanság ellenőrzése nélkül.
