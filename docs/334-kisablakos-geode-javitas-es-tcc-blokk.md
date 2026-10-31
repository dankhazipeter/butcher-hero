# Geode kis ablakon: javított felismerés, megszakadt élő igazolás

Budapest2026-11-01; a munka október31-ről nyúlt át. Az itt szereplő `Z`
időpontok UTC-sek, október31.23:08Z például november1.00:08 Budapesten.
A felhasználó kifejezetten jóváhagyta a333diagnózis utáni javítást.

## Piros jelzés: antialias és pixelillesztés

A régi, nagyobb képekre igazolt ág változatlan: legalább18/24 erősen fehér
mintairány és16/24 sötét körvonali irány kell. A piros komponens szín-
méret-/kitöltéskapui és a kék kristály/HUD kontextus szintén megmaradtak.

Kizárólag legfeljebb12pixel átmérőnél egy új, strukturális ág dolgozik:

- bbox-minor/major>=0.85, piros kitöltés>=0.70;
- a3×3középből legalább8pixel valóban piros;
- legalább4erősen fehér mintairány, legalább3külön negyedben;
- legalább20/24semleges világos perem és20/24sötét körvonal;
- a világos perem minRGB>150, maxRGB-minRGB<45; az erős fehér továbbra
  minRGB>205, a sötét maxRGB<105;
- mindez ugyanazon geometrián, legfeljebb±1pixel centrumkorrekció és
  ±0.5pixel sugárkorrekció mellett,75fix jelöltből.

Nem független piros/fehér színösszeget engedünk újra, és nem elég egy
szürke gyűrű. A kis átmérőn a fehér vonal sokszor antialiasos szürke,
a piros bbox pedig félpixellel nem a valódi körközepet adja. Mindkettőt
kezelni kellett: a puszta sugársűrítés változatlan centrum mellett nem
oldotta meg a hibát.

Az első prototípus a pulzáló11pixeles állapoton, majd két másik pixel-
fázison még elbukott. Ezeket nem neveztük kész javításnak. Az eredetileg
heldoutnak félretett, de közben hibafeltárásra felhasznált képeket
fejlesztési névre soroltuk át. Végső készlet:

| Fájl a crystals reference mappában | Felhasználás |
| --- | --- |
| hud-notification-small-development | 9CB445F5, eredeti9pixel |
| hud-notification-small-pulse-development | DB92B7FF,11pixel |
| hud-notification-small-phase-development-a | A962E322, eltérő fényesség/fázis |
| hud-notification-small-phase-development-b | 2A74AF95,11pixel/eltérő fázis |
| hud-notification-small-heldout-b | 5F49824C, külön claim |
| hud-notification-small-heldout-e | BA4CEAC8, végső paraméterek után kiválasztott kép |
| hud-notification-small-heldout-f | 7AC2DFF7, végső paraméterek után kiválasztott kép |

Mind eredeti, vizuálisan ellenőrzött teljes HUD. Nem állítunk külön
heldoutablakméretet: mind637×882, külön képkockák/claim-ek,9/11pixeles
pulzálással. Az utolsó két képet a paraméterek változtatása nélkül olvasta
a stagingrelease: true, ugyanakkor a régi release false volt.

## Inventory és eredmény: két további crop-hiba

Az új jelzésfelismerő élesben elindította a2DE3B931 tranzakciót, de a
kisebb inventory más függőleges hézagot használ. A saját X-hez rögzített
CRYSTALS-crop a betű tetejét levágta: `VASVIALS`, majd4pixelnyi korrekciónál
`UKJSTALS`. A -0.008/-0.016 eltolás viszont pontos CRYSTALS-t adott.
Most az eredeti régió után csak e két szűk felfelé régió próbálható,
kizárólag pontos CRYSTALSTATS cím mellett. A grid neve továbbra pontosan
CRYSTALS, a nyitható cél külön arany komponensen pontos X1. Nem lett
fuzzy stringmatch, általános Open-gomb vagy ismeretlen X-kattintás.

A megnyitott eredményképen a Continue már pontos volt, a széles titleROI
viszont a díszítőszélből `WE` és `=` jelet is olvasott: `WE CRYSTAL; STATS =`.
Csak pontos CONTINUE mellett egyszer egy szűkebb titlecrop próbálható:
x0.365/y0.562/w0.275/h0.037. Az eredmény `CRYSTAL;STATS;`, a korábbi
betű/szám-kompaktálással pontos CRYSTALSTATS. Nem dobunk el tetszőleges
idegen szavakat a szövegből. Cím és gomb együtt továbbra kötelező.

Két további eredeti pozitív és egy animációs negatív minta:
`inventory-ready-small-live`, `result-small-live`, `result-small-animation-live`.
Összesen10új eredeti PNG. A csillagos animáció Continue nélkül unknown marad.

## Tesztek és build

5új Swift-teszt:7valós jelzés+flow-kapuk; öt mesterséges negatív
(nincs erős fehér/egyoldali fehér/megszakadó világosgyűrű/nincs sötétkeret/
lyukas pirosmag);3régi no-dot +4újraméretezett konfetti; inventorypozitív+
kitakart gridnegatív; resultpozitív+animáció/cím/gomb nélküli negatív.
Az elvárt, kézzel ellenőrzött eredményeket nem írtuk át a hibás kódhoz.
Az első jelzésteszt9hibával piros volt. A meglévő régi pozitív és konfetti-
negatív képek továbbra is a teljes kapu részei.

Új Pythonunit tiltja az operátori recovery és a statreset összekeverését;
a meglévő launcher teszt a normál/new-run/recovery módok továbbítását
külön ellenőrzi. Összesen199teszt+7JS-szintaxis:77Swift,23dashboard,
7game-control,10statsession,3Git-kapu,10supervisor,20launcher,49Node.
Stagingrelease külön buildhelyen. A tényleges modell/ikonsablon/JSON-adatok
azonosak az aktívval; csak a staging FreeBadgesREADME-ja volt pluszban.
Nem írtunk futó gyűjtő binárisára: sajátstop után másoltunk, a végső
offlinebináris atomikus .next→rename cserével került a helyére.

## Mi történt élesben — és mi nem igazolt?

| UTC | Tény |
| --- | --- |
|23:02:26|normálresume, runner22807/supervisor22814/worker22815, session44557|
|23:02:27.665|2DE3B931 saját új tranzakció, valódi jelzés felismerve|
|23:02:28.072|inventorynyitás elküldve, friss9→11pixeles jelzésen validálva|
|23:03:58.821|inventoryszöveg miatt90s timeout, nincs vak folytatás|
|23:08:04|inventoryjavítás, runner25273/supervisor25281/worker25282, session97854|
|23:08:05.139|egyszeri explicit saját operator recovery, régi attempts megmaradt|
|23:08:07.793|X1 elküldve|
|23:08:09–17|öt ellenőrzött ütés; utána piros40/PierceDamage+89K eredmény látszik|
|23:09:11.459|mentett stabil eredménykép, de titleROI-zaj miatt még unknown|
|23:10–11|új workerindulásoknál TCC képrögzítés-elutasítás, nincs sikeres új kép|
|23:11:56|saját runner/supervisor leállítva, capture/input megszüntetve|

Nincs elküldött Continue, inventoryX, HUD-pár vagy completed_ui. Az eredmény
megjelenése nem önálló statmérés és nem Free-jutalom. Ez javításokkal
részben végrehajtott, majd engedélyblokkon megállt kör, nem bizonyított
megszakításmentes új geode-ciklus. A resultcrophiba már csak offline
ellenőrizhető volt a végső javítással.

## Engedélyblokk és biztonságos folytatás

A macOS által adott hiba: „A felhasználó elutasította az alkalmazás, az
ablak és a kijelző rögzítésére vonatkozó TCC-ket”. Ez nem bizonyítja,
hogy a user ténylegesen elutasító gombot nyomott. A játék natív metadata
szerint fut/ablaka látható; nem nevezzük ezt bezárt játéknak. Egy egyszeri
snapshot-helper sem adott képet, megszakítottuk. CUA bundle/path-feloldás
ambiguitás/not-found hibája sem volt új játékállapot-bizonyíték.

Nem próbáljuk megkerülni vagy átírni a TCC-t. A usertől ScreenRecording
engedély rendezését és visszajelzést kértünk. Addig nincs új capture/input.
A read-only dashboard külön session4073 alatt8765-ön él. A worker26601
már halott, supervisor.running=false; SIGKILL után a workerstate running=true
maradt, ezért önmagában ez a flag nem megbízható. Nem írtuk át kézzel a
workerjelentést: a dashboard tényleges PID-ellenőrzése leállást mutat.
Ez külön állapotnaplózási nyitott kérdés, nem működő gyűjtés.

A `butcher-hero start --recover-crystal` új wrapperlehetőség csak az eddigi
operátori flaget továbbítja egyszer a supervisornak. A natív saját napló,
600másodperces frissesség,16ütés/3lépéskattintás/90s keretek nem változtak;
automatikus restart sosem kapja meg újra. `--new-run`-nal kölcsönösen
kizárják egymást. Most a2DEtranzakció eredeti600s ablaka már lejárt, ezért
ezt nem szabad újra recoveryvel átvenni. Engedély után, ha a régi eredmény
ott maradt, kézi Continue→inventoryX→HUD szükséges, és csak utána normál
resume. Nem indítjuk újra magunktól és nem gyártunk befejezési könyvelést.
