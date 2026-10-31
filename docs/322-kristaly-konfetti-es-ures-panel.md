# Kristály: konfetti ne legyen értesítés, üres saját panel ne ragadjon be

2026-10-31. User: a program piros pötty nélkül ismételten megnyitja a
kristálypanelt; nincsOpen, nem záródik, gyűjtés megáll. A hibásinputot a
sajátworker/supervisor leállításával szüneteltettük, nem zártuk be a játékot.

## Bizonyított téves értesítés

`references/2026-10-31/crystals/hud-no-dot-confetti-user.png`: usereredeti
1274×1765-ös kép, jobb oldalt kék kristályok értesítési kör nélkül; konfetti
piros és fehér elemekkel. Régi inspect-crystal: notification=true,
dotRed0.05788244, dotWhite0.03424711, blue0.38819625. A küszöb3,5%piros,
2,5%fehér,12%kék volt, térbeli összetartozást nem ellenőrzött. Ez konkrét
reprodukció, nem feltételezés a konfetti szerepéről.

Új CrystalNotificationMatcher: összefüggőpiroskomponens, szélesség/magasság
0,70–1,40, méret az ablakszélesség0,9–2,9%-a, legalább55%kitöltés.
A kör körül24irányból legalább18fehérgyűrű és16sötétperem kell; az alatta
lévő kékikon feltétele megmaradt. Nem engedtünk le felismerési küszöböt.
Usernegatív most false, két régi valódi pozitív továbbra true.

Új státuszkéréskor készült külsőmonitoros788×1083 frisskép:
`hud-notification-external-live.png`. Kézzel is látható valódi piros/fehér
pötty. Új felismerőtrue: center771.5/522, átmérő13,24/24fehér,19/24sötét.
Ez új held-out pozitív, nem a matcher kidolgozásához használt régi két kép.
A játékQuartzbounds−828/−370/788/1083, tehát valóban külső kijelzőn volt.

## Mi változott a beragadás ellen

A konkrét beragadt panelről még nincs friss userkép, így annak történeti
okát nem állítjuk reprodukáltnak. Kódban viszont két hiány látszott:
csak fixmagasságú panelrégiókat vizsgált, és üresnek csak olvasható szürke
OPENnel minősített. A readyállapot inventoryEmptyre sem tért closingba.

- A főpanel sajátpinkX-gombjának összefüggő alakja/fehérközepe a horgony;
  az inventoryCRYSTALSTATS ésCRYSTALS címkéje együtt kötelező. A geodeX
  másikmagasságban van, nem inventoryzárás.
- A panelrégiók szélességalapúan, az aktuálisX-hez viszonyulnak. Dinamikus
  closePoint/openPoint az aktiválás utáni friss képből; a321Quartz/kurzor-
  védelmei változatlanok.
- inventoryUnavailable = biztosismertfőpanel, de nem biztos az aktívx1.
  Nem jogosít Openre. Sajátfolyamat kétstabilképpel zárhatja; nem vár vakon
 90s-ot csak azért, mert azOPENbetűk hiányoznak.
- Saját readyfázis ismertürespanelre is closing. Eltűnt pötty kétHUDképen
  megszakítja az openinget60scooldownnal; a régi értesítésből nincs új input.
- Timeout után kizárólag saját, tényleges openInventoryinputtal megkezdett
  folyamat ismertüres/Unavailable panelje zárható egyszeri, legfeljebb10s
  cleanupban. Eredeti max3X-próba megmarad; nincs végtelen timeout-reset,
  újopen/ütés vagy ismeretlenmodalbezárás.
- Kézi panel nem aktivál tranzakciót. Előforduló hamisHUD mellett is tiltja
  a Freeinputot, függőFreeclaimet nem igazol az overlay eltűnéséből.
- Siker csak eredmény+sajátCONTINUE+X+kétHUD. Üresbezárás és emberiContinue
  nem gépi jutalom. A meglévő naplózást/összegeket nem írtuk át.

## Tesztek és korlátok

7új CrystalTests: userkonfetti mintanegatív, eltűntpötty, saját/kézipanel,
ready→empty, timeoutcleanup tulajdon/limit/időkorlát, hiányzósajátContinue
nem siker, horgonyeltolás és letakartOpen, kézipanel inputfoglalás.
A882/951/1010magasságok és azOpenmaszkolás memória-beli, szintetikus
tesztvariánsok az eredeti inventory-empty-live képből; nem új valós minták.
Az eredeti képi elvárásokat nem írtuk át.20→21Crystalteszt, teljes145teszt
(66Swift+19statisztika+7game+3git+10supervisor+40Node),7JSsyntax a kapuban.
Végső teljes helyi kapu és stagingrelease sikeres19:42Z előtt; új változat
--resume-run-nal betöltve19:42Z. Commit/push a pontos Gitfát újra teszteli.

Az inventoryaspektus rugalmasabb lett, a geode/result új képaránya ettől
még nincs automatikusan támogatottnak igazolva. Külön élőkép kell, ha ott
is eltérés jelentkezik. Ismeretlen képernyőn továbbra nincs input.

## Éles állapot

A felhasználó félbeszakította az előző menetet; a gyűjtő ténylegesen állt,
a javítás csak munkapéldányban volt. A mostani folytatásban a külsőablak
és képrögzítés működött, valódi pöttyet rögzítettünk. Az újbuild --resume-run
betöltésekor a kijelzők ismét asleep/0active lettek (system_profiler is
megerősítette), ezért nincs új gépi kattintás vagy sikeres tranzakció.
Ébresztést, energia-/engedélyváltoztatást vagy játékújraindítást nem végeztünk.
Program futhat várakozva, de ezt nem nevezzük működő gyűjtési bizonyítéknak.
Friss runtime astate.json/supervisor.json fájlokban. Az új éles teljes kör
és Free-visszatérés még ellenőrizendő, nincs kitalált jutalom.
