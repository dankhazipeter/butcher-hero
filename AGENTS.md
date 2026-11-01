# Butcher Hero — aktív projektutasítások

## Pierce549: két engedélyezett pontosítás és új9minta — 2026-11-01 (340)

User kivizsgálást, majd konkrétan két +549beírást és a további felismerés
javítását engedélyezte.6F6EA993(21:12:18Z) és43E4FD3B(21:13:23Z) kártya+
utókép is549nyíl. Nemcrop: háromglyph45/57/68px X,567pxY,16pxmagas.
5/4jó,9error.1010417/8error.1246875; margin.0236458<.035, ezért nil.
Mindkettőhöz külön reward_corrected549 append,flock/O_APPEND,forrássorok
és claimcount/időpont változatlan. Eredeti byteprefixSHA egyezik, nincs
duplázás; API+CLI két549=1098Pierce,0unknown az adott szűk időablakban.
Csak e két történeti tétel korrigált, nem globálisreconcile.
Futómodell/source azonos58glyph. Új mintából csak9adódik hozzá:20forrás/
59glyph, az első58objektum változatlan. Nincs readerkód/crop/küszöb/
típusfüggés-változás. Első kép kalibráció, másikclaim külön teszt, de
azonosglyphrács és előzetesen látott, nem vak új betűméret-validáció.
Korpusz54→56eredetikép,1újunit először4hibával piros; új9hiba0,
8hiba.1246875. Teljes224teszt+7JS PASS,21:23:29Zadat-only atomi runtime+
staging bundlecsere gyűjtőstop nélkül; source/mindkétbundle SHAa8a20b41…
egyezik, releaseinspect549jó. Worker25484 frissképes; új élő549 még kell.
Élő betöltés igazolása a340doksiban.

## Egységes típusszínek a statonkénti grafikonokon — 2026-11-01 (339)

User kéri az összesített grafikon nyolc típusszínét a Növekedés kártyáin is.
A statkártyák ugyanazt a frequency-{kind} palettaosztályt kapják, mint a
közös görbék és a legenda; nincs másolt vagy külön új paletta. Sparkvonal/
végpont/terület ugyanazt a --series-color változót örökli, kitöltés12%.
Meglévő világos/sötét színpárok és neutrális tengelyek változatlanok.
2újNode DOM/CSS-regresszió, teljes223teszt+7JSkapu. Élő böngészőben mind
a8vonal/végpont/kitöltés RGB-je megegyezett a közös diagram megfelelő
vonalával, mindegyikareaopacity.12. Helyi proof339-stat-colours.png,
saját tesztlap bezárva. Frontend-only, nincs gyűjtőrestart/reset/logírás.
Részletek docs/339-egyseges-statgrafikon-szinek.md; userlap reloadkell.

## Statonkénti átlagos egység/perc — 2026-11-01 (338)

User kéri a Növekedés kártyák összegéhez az átlagot. Minden kártyán a nagy
összeg mellett Átlag: érték/perc; HU/EN, K/M-formázás, statonkénti egység,
NEM átvételi darabszám. Osztó az alkalmazott API range.to-from TELJES percei,
így24h nézetben az állásidő is benne van, nem csak a bot aktív ideje.
BigInt racionális számítás a nyers decimális row.total-ból, nincs kompakt
szám visszafejtés vagy naplómódosítás. Kijelzés csonkolt2tizedes,1000+
meglévőgameformátum; pozitív<.01 esetén <0,01, nemhamis0. Nulla/hibás
időablak vagy ismeretlenösszeg: —. Tooltip/aria elmagyarázza az osztót.
5újNode (3unit+2app.jsDOM), teljes221teszt+7JSkapu. Csakstatikusfrontend:
nincs worker/backend/releaseváltozás vagy restart. Élő run/day megjelenítés
ellenőrzött, day Health+2,3M/Átlag1,6K/perc. Saját tesztlap bezárva;
proof .build/ui-proof/338-rates-day.png helyi, nem Git. Részletek338.

## Látható kiválasztott időszak és intervallumhossz — 2026-11-01 (337)

User kéri a Mostani futás/Minden és más nézetek tényleges határait. A filter
alatt külön panel: alkalmazott időszak neve, teljes helyi év/hó/nap/óra/perc/
másodperces Kezdet és Vége, intervallumhossz nap/óra/perc/mp bontással.
Kizárólag API range.mode/from/to: nem a saját inputmezők piszkozata, nem a
worker/chat indulása vagy Date.now-ból újraszámolt kezdet. HU/EN, IANAzone
megmarad, DST-hosszt UTCinstantokból számolunk. Run-hint kimondja, hogy
szüneteket is tartalmaz, nem aktív játékidő; All a megőrzött teljes napló.
Új poll frissíti, nyelvváltás nincs fetch/reset.3új Node integrációs teszt,
216teszt+7JS teljeskapu. Backend/gyűjtő/logok változatlanok, restart NINCS.
Élő IAB runkezdés2026-11-01 10:45:57, All2026-10-29 21:56:28 Budapest;
mindkettő vizuálisan ellenőrzött. Saját tesztlap bezárva, userlap reloadkell.
Helyi képi proof .build/ui-proof/337-{run,all}.png nem Gitadat. Részletek337.

## Csak igazolt játékablak és valós gyűjtőállapot — 2026-11-01 (336)

A user mindkét bizonyított hibát javíttatja. A régi Capture.frame OR-szűrése
(`bundle==game || title contains Butcher Hero`) a nagyobb Safari dashboardot
választotta; saját10:04:21Z/10:04:51Z diagnosztikai képek ezt mutatják.
Ezek nem jutalomfelismerési negatív képek, hanem rossz képforrások. A user
Health18.2K képe offline jól olvasható; ebből nem következik botátvétel.
Most GameCapturePolicy csak pontos com.multicastgames.butcher+pozitívPID+
WindowID+használható méret alapján választ, címalapú fallback NINCS. Pure
metaadat-tesztek több nagyobb böngészővel/játék nélkül/hibásazonosítókkal;
a személyes böngészős képek nem kerülnek publikus Gitbe.
Workerstate: captureSourceBundleID/PID/WindowID, captureStatus, screenState.
Backend külön ellenőrzi a forrásidentitást, nem fogad bemondott verifiedflaget.
UIcsak friss+igazolt+ok+HUD esetben zöld; régi worker metaadat nélkül sem
zöld. Képrögzítési hiba/ismeretlenUI/blokkolt vagy kézi panel külön warning;
ismert event/kristály processing, nem Freegyűjtési ígéret. Captureerror
azonnal állapotba kerül, nem csak naplóba. Stagingbuild+teljeskapu után
rövidstop/resume-run, statreset/naplóátírás nincs.4Swift+2Python+4Nodeújteszt,
végső213teszt+7JScheck.10:28:37Zstop→58Zresume, worker13630/session90840;
frissstatejátékbundle/PID13534/Window546,ok/hud,APIverifiedtrue.10:29:30.948Z
újRegen83UIigazolt, utóképen+83regen. ÚjIABlapfrissszöveg ellenőrzött;
meglévőSafari egyszerreloadkell. További kapuk alatt nincs stop. Részletek336.

## Kristálypanel 623×863: levágott cím javítása — 2026-11-01 (335)

A user kéri: a most megnyitott saját inventoryból x1-gyel továbbmenni,
nyitható geode nélkül a saját jobb felső X-szel visszatérni. Nem általános
ismeretlenpanel-kattintás. A 623×863 élő panel régi titlecropja `A EEE`-t
olvasott; a pink X 73px-es komponenséből számolt scale a cím tetejét vágta.
Egyetlen szűk felső titlecrop-tartalék: x.38/y.337/w.25/h.041 a meglévő
X-hez kötve. Pontos CRYSTALSTATS+CRYSTALS, külön arany X1 és frisspreclick
továbbra kötelező. Sem pöttyküszöb, sem próbakeret/600s recoveryguard nem
változik.4eredeti kép+4újunit, végső203teszt+7JScheck szükséges.
09:54:03Zsaját D2BE operatorrecovery az eredeti kezdettől565s, nem lejárt
2DEátvétel.09:54:06Zx1→ütések→piros40/Pierce89K→19ZContinue→22ZX→
23.681Zcompleted_ui.09:54:56.064Zúj Health18200Freeigazolt. Helyreállított,
nem megszakításmentes új kristálykör. Gyűjtő6390/runner6381/session4985;
frissruntimeJSONelsődleges. További offline/Git-kapuk alatt nincs stop.
Részletek és tényleges betöltési eredmény: docs/335-kristalypanel-623-cim.md.

## Geode kisablakos javítás; élő folytatás TCC miatt blokkolt — 2026-11-01 (334)

A user jóváhagyta333javítását. Klasszikus fehérgyűrű ág változatlan:
18/24 fehér205+ és16/24 sötét105-. Új kizárólag<=12px AA-ág: arány>=.85,
kitöltés>=.70, piros3x3közép>=8/9, >=4 erős fehér irány legalább3negyedben,
>=20/24 semleges150+ perem és>=20/24 sötét körvonal UGYANAZON illesztésen.
Csak ±1px közép,±.5px sugár,75fix jelölt; kék ikon/HUD/2képes kapu megmarad.
7valódi HUD-minta:4fejlesztési,3különvalidációs; a közben hibát feltáró
eredeti heldoutok fejlesztési névre lettek átnevezve. Nem nevezzük őket
utólag független tesztnek. Konfetti/nincs-pötty továbbra negatív, 5mesterséges
gyűrű-/kontúr-/maghiányos ellenpélda és4átméretezett konfetti is tesztelt.
Éles2DE3B93123:02:28Znyitás eljutott inventoryig, majd új crop-hiba miatt
23:03:58Ztimeout. InventoryCRYSTALS két szűk felfelé cropban kereshető,
de szöveg továbbra pontos; goldX1 és sajátX szükséges. Egyszeri operátori
helyreállítás23:08:05Z, eredeti attempts megtartva: x1+5ütés, piros40/
PierceDamage89Keredmény látható. Result header díszítőszél WE/=OCR-zaja
szűkebb cropot kapott, továbbra pontos CRYSTALSTATS+CONTINUE kell.
NINCS elküldöttContinue/X/HUDigazolás, tehát NEMcompleted_ui és nem
megszakításmentes siker! 10új eredetiPNG,5újSwift+1Pythonunit;199teszt+
7JSsyntax helybenPASS. Stagingreleasekész; véglegesbináris atomikusan
betöltve LEÁLLÍTOTT worker mellett, modellek változatlanok.

Külön környezeti blokk:23:10–23:11ZTCC képrögzítés-elutasítás, nincs új
sikeres kép. Saját runner/supervisor/helper leállítva23:11:56Z; nem userSTOP,
hanem engedély miatti biztonsági szünet. Ne induljon capture/input újra,
amíg user nem rendezi a macOSScreenRecording-jogot és nem jelez. A játék
natív metadata szerint fut; CUA két eltérő bundle-path miatt nem oldotta
fel, egyszeri snapshot sem adott képet, megszakítva. Az okát nem bizonyítja,
hogy a TCC-visszautasítást maga a user kattintotta. Read-only dashboard
külön session4073,8765 él. SupervisorJSONfalse, worker26601halott, annak
state.running=true maradt SIGKILL után: ezt nem tekintjük futásnak/nem
hamisítjuk át. A dashboard PID-ellenőrzése helyesen leállást mutat.
Régi2DEtranzakció10perces helyreállítási ablaka lejárt; NEM tágítjuk.
Folytatásnál engedély és szükség esetén kéziContinue→inventoryX→HUD kell.

Új wrapperflag `butcher-hero start --recover-crystal`: csak ugyanazt az
eddigi operátori flaget adja át egyszer a supervisornak; natív600s/saját-
napló/attemptkorlát megmarad, automatikus restart nem ismétli. `--new-run`-nal
kizárják egymást, nincs implicit statreset. Mostani lejárt panelre nem
használható! Részletek docs/334-kisablakos-geode-javitas-es-tcc-blokk.md.

## Nyitott: geode-jelzés elutasítása kis ablakban — 2026-10-31 (333)

A felhasználó jelezte, hogy lenne nyitható geode. 22:42–22:44Z friss,
637×882 HUD-képeken látható a valódi piros jelzés; a release inspect-crystal
mégis notification=false / ringDot=absent. Blue0.371–0.378 elegendő, HUDtrue.
Azonos CG DeviceRGB pixelekkel a piros komponens közép624/428,9×9px,
kitöltés0.852, ROI-szél rendben. Sötét körvonal24/24, de a három fix
sugáron vizsgált fehér szegély8/24 a szükséges18 helyett. Ez a konkrét
elutasítás oka, nem workerleállás, egérvárakozás vagy beragadt tranzakció:
worker4143 frissképekkel, crystal=idle/event=idle; közben Free575 igazolt.
A legutóbbi kristálykör21:21:35.706Z completed_ui. Nincs vak ikonnyitás,
küszöblazítás vagy --recover-crystal ebből a diagnózisból. A user most
magyarázatot kért; a javításra külön rövid jóváhagyást kértünk. Válaszig
a felismerő és a gyűjtő változatlanul fut. Részletek docs/333-geode-jelzes-kisablak-diagnozis.md.

## CI: korán elutasított HTTP-kérés tesztversenye — 2026-10-31 (332)

A 331/c135ae3 távoli run41247735058 új session-suite-jában a tiltott
Transfer-Encoding kérésnél urllib BrokenPipe történt a chunk-záró írásakor:
a szerver a fejléc alapján már jogszerűen elutasította/bezárta a kapcsolatot.
Nem lazítjuk a production guardot és nem fogadunk el hálózati hibát PASS-nak.
Új közös tests/http_test_support.py a kis izolált POST teljes fejlécét és
testét egy sendall-ba teszi, majd valódi HTTPResponse-ból továbbra pontos
400/403/stb választ ellenőrzünk. A game-launch teszt ugyanilyen kliensét
is erre cseréljük, elvárásmódosítás nélkül; tiltott chunked eset 10 ismétlés.
Production/UI/gyűjtő nem változik, restart nincs. Teljes kapu193teszt+7JS
marad, távoli eredmény a javított commit saját runjából ellenőrzendő.
Részletek docs/332-ci-http-kliens-verseny.md. A 330 DNS-fix ettől külön ügy.

## Dashboard: új statisztikai munkamenet — 2026-10-31 (331)

Új felhasználói engedély: az időszaksúgó modalban „Új munkamenet indítása”,
külön Igen/Mégse megerősítéssel. Csak a dashboard Mostani futás nézetének
kezdetét menti; nem töröl/módosít jutalomnaplót, nem indít/állít le gyűjtőt,
nem küld játékinputot. A Ma/Utolsó óra/24 óra/Minden/custom továbbra minden
saját időszakbeli adatot tartalmaz. Frissítés, szerverrestart és --resume-run
megőrzi a kézi kezdőpontot; egy későbbi watcher_started új kezdet lehet.
A kezdőpont a kettő közül a későbbi. Kattintási idő szerint sorolunk, nem
későbbi igazolási idő szerint. Új fájl: data/free-rewards/stat-session.json;
nem kerül Gitbe. Atomi csere, külön flock + threadlock, expectedSessionID
CAS és az előző kérés idempotens ismétlése védi a több lap/duplakattintás
helyzetet. Sérült/írhatatlan metadata nem hallgatólagos reset vagy régi
nézet: hiba. POST /api/statistics/session csak loopback/azonos Origin/
Host/Sec-Fetch-Site + külön szerverenkénti token és szűk JSONtest mellett.
Ez a 320/315 korábbi „csak játékindítás az íróhatás” leírás SZŰK új kivétele;
a jutalomnapló továbbra csak olvasható. Nem általános fájlíró/reset/game API.
UI csak friss kapcsolattal engedélyez, nincs automatikus POST-újrapróba,
siker után run nézet, régi függő poll nem írhatja vissza a számlálókat.
HU/EN külön nyelvi fájl, biztonságos Mégse kezdeti fókusz, modalzárás törli
a még el nem küldött megerősítést. A tényleges munkamenetet fejlesztési
tesztből NEM nullázzuk: izolált adatokon 4→0 run és Ma=4 igazolt.
10 új Python + 6 Node regresszió, teljes 193 teszt + 7 JS-check.
Részletek docs/331-uj-statisztikai-munkamenet.md; friss runtime mindig JSON.

## CI-indulás: DNS-független loopback szerver — 2026-10-31 (330)

A felhasználó kérte a CI javítását. A 41241697382 futásban mind a négy
launcher-folyamatteszt a 6 s-os setUp-készültségnél bukott; a Swift képi
tesztek sikeresek voltak. A régi HTTPServer.server_bind még a 127.0.0.1
címhez is socket.getfqdn-t hívott. Ezt egy először piros regresszió
bizonyítja: a loopback bind nem függhet külső/reverz DNS-től.
LoopbackHTTPServer most közvetlen TCPServer-bindot használ, saját numerikus
server_name/valódi server_port értékekkel. Bindcím/Host/Origin/tokenvédelem
változatlan. Az izolált launcher teszt most a valódi dashboard-kódot futtatja,
álgyűjtővel és csak a fixture folyamatokra tiltott getfqdn-nel. A teszt
6 s-os, a production health-várakozás 8 s-os határa nem lazult; hiba esetén
az állapot és a gyermek kimenete is látszik, a kapu verbose launcher-tesztet
futtat. Sem kihagyott teszt, sem continue-on-error nincs. Helyi Python 3.13
ellenőrzés is szükséges; távoli zöldet csak az adott GitHub-runból állítunk,
nem pusztán helyi PASS-ból. A régi runner DNS-stackjét nem rögzítette a log,
ezért a pontos történeti blokkolási hely nem nevezhető bizonyítottnak.
A gyűjtő és a már futó dashboard ehhez nem áll le, nincs capture/input/
napló- vagy statmódosítás. Az új bindkód következő szerverindításkor töltődik.
Részletek: docs/330-ci-loopback-dns.md.

330 távoli igazolás: 7473696 commit, GitHub-run 41246121213, 22:02:23Z
completed/success, teljes 177 teszt + 7 JS-szintaxis. Mind a négy korábban
bukó folyamatteszt ok; 19 launcher 2.944 s, 23 dashboard 0.576 s, 7 game
1.537 s. A korábbi 35.679/36.579/26.192 s + négy hiba helyett sikeres kör.
A launcher-CI ügy lezárt e konkrét javításra; a 325-ös processzeltűnés nem.

## Ismeretlen jutalmak feltárása és javítása — 2026-10-31 (329)

User előbb visszanézést, majd kifejezetten a további felismerés javítását
engedélyezte, régi napló átírása nélkül.21:23Z-ig a logikai futás46bizonytalan
claimjének eredeti képét ellenőriztük:14típusunknown+32ismerttípus/összegnil.
Ebből13már a régi aktuális kóddal is jó volt (5CutDefense593+8szám), de a
történeti napló nem változott magától. Új javítás után46/46 típus+érték jó
offline replayben, vizuális címkékkel; nem könyveltük őket újra.
9külső788x1083ikon vágása4px-szel túl alacsony volt. Matchdy most
[-4,-2,0,2], dx[-1,0,1], nem küszöblazítás (error<0.48, margin>0.035).
22régi521nyílnál a2/8különbség0.03177<0.035;692nél9/8fontütközés.
Új5ellenőrzött kalibrációval19forrás/58glyph, régi41glyph változatlan.
Health18.4K-nál a K mögötti háttérfolt hatodik komponens volt: numerikus
baseline-konszenzus szűri, nem parserből tippelt prefix. Új9minta8-konfliktusát
két külön18.1K/18.6Kforrással fogtuk meg;18.4K különheldout maradt.
16eredetiPNG+fixképi elvárás, korpusz38→54,3újSwiftunit; teljes176teszt és
7JSsyntaxPASS, stagingreleasePASS. Régi elvárás/összeg/napló nem változott.
Betöltés21:42:17Zközösrunner90106/dashboard90117/supervisor90118/worker90119,
session2092, resume-run; frissPID mindigJSONból.21:42:27.450Zúj575Pierce
UIigazolt, frissképek. Ez nem élő9Smash/Cut-eset igazolása: azokat a
mentett valódi képek igazolják. Kalibrációs képből nem csinálunk heldoutot;
ismeretlenből nem lesz kitalált összeg. Részletek329. KorábbiCI4launcher-
startuptimeout külön nyitott, ebben a körben nem módosítottuk a launchert.

329új éles normálkörök:21:42:59.394ZCutDamage557/ADC2067F,
21:43:32.949ZHealth18600/F4FC302F,21:44:37.344ZCutDefense631/8F07BA21.
Cut557ésHealth18.6Kvalidált előkép külön vizuálisan is egyezik a naplóval;
nem567helyett félreolvasott557. A játék közben637x882ablakra változott,
ez friss másméretű siker, nem az összes újkülső788hiba éles ismétlése.

## Helyi időzóna és játékbeli statnevek — 2026-10-31 (328)

A user már nem Romániában van. Dashboardidő nem rögzítettBucharest:
Intl böngésző-IANAzone minden pollnál, timezone query a backendnek.
Minden dátum/tooltip/tengely/szűrőmező ugyanazt használja; nyelvváltás nem
időzónaváltás. Ma=ennek helyi éjfele, customnaiv idő is ebben értelmezett;
explicitUTC/offset változatlan, APIzone nélkülUTC. Hibás/többszöröszone
elutasított, DSTnemlétező falióraidő hiba, ismétlődő óra elsőfold.
Nincs naplóátírás vagy statreset: ellenőrzött13190UTC/offsetes timestamp,
0naiv. A magyarfelületen is Health, HealthRegen, Pierce/Cut/SmashDamage és
Pierce/Cut/SmashDefense a játék szerinti angol nevekkel; a tényleges címkék
szóközösek, a többiUI magyar. Ez szándékosan felülírja310statnévfordítását.
3újPython+3újNode regresszió; a régi dátumteszt explicitBucharestre maradt,
nem elvártérték-lazítás. Scope: UI/APIidőszak, nem gyűjtő/vision/input.
Korábbi launcherCI4startup-timeout külön nyitott, nem javítottuk ebben.
Részletek328; a gyűjtő csak az új szerverkód rövid betöltésére állhat meg.

328betöltés:21:17:09.087Zstop→09.646Zresume, nincs újwatcher_started.
Runner80593/dashboard80612/supervisor80613/worker80614/session74565;
friss runtime továbbra JSONból.21:17:41.373ZHealth18100UIigazolt,
frissképek. ÚjIABtesztlap22:18:32helyi idő/EuropeBudapest, eredeti8név,
lista és legenda igazolt. Régi lap eszközösreloadja nem volt elérhető;
azt a usernek egyszer frissítenie kell. Helyi173teszt+7JSsyntaxPASS.
Proof .build/ui-proof/dashboard-local-time.jpg, nem commitolt személyesadat.

## Üres dashboardlap helyreállt újratöltéssel — 2026-10-31 (327)

Userképen kapcsolódás/üresnyelvválasztó/alapértékek, miközben gyűjtés fut.
Ellenőrzéskor runner70886/worker él, frissképidő,8765listener és HTTPhealth/
rewardsAPI jó; címváltozás nincs. A tényleges IABlapon ugyanaz az üres UI
látszott. Egy reload után nyelvválasztó, ÉLŐ NAPLÓ, játékfut és gyűjtőFut,
grafikonok/lista visszatért;1349igazolt a pillanatképben. Nem futtatókiesés,
nem bizonyított cache-/JS-/CSPgyökérok; nincs kód- vagy küszöbmódosítás,
gyűjtő-/szerverrestart. CUAread-onlyevaluate scope nem megbízható bizonyíték
a lapglobálisok hiányára; UI/HTTP és reload eredménye az érvényes tény.
Helyi proof .build/ui-proof/dashboard-restored.jpg, nem Gitadat. Részletek327.

## Közös Terminal-indító — 2026-10-31 (326)

A felhasználó saját Terminalból futtatható, közös indítót kért. Új
`make start` / `make stop` / `make status`, illetve opcionális
`make install-cli` → `~/.local/bin/butcher-hero start|stop|status`.
Az indító a saját checkoutjára oldja fel az útvonalakat, más cwd-ből és
symlinken át is működik. Alapból --resume-run; új statkezdés csak külön
`butcher-hero start --new-run`. Nem indít játékot/böngészőt, nem fordít
aktív release-re, nem módosít PATH/shellprofile/engedélyt/login/startupot.
Előtérben marad, közös kimenet+10s állapot, Ctrl+C/TERM/HUP a saját két
szolgáltatást és azok leszármazottait takarítja. Foglaltport/aktív régi
gyűjtő esetén nincs átvétel vagy idegenfolyamat-kill. A dashboard indul és
HTTP-egészségellenőrzésen átmegy a gyűjtő előtt; bármelyik szolgáltatás
kilépése leállítja a másikat, nem marad csendes félüzem. Külön runnerlock,
stophoz PID+eredeti parancs+indulásiidő+checkoutellenőrzés. Fejlesztéskor
ugyanezt a runnerstopot használjuk, átadáskor nincs párhuzamos watcher.
Új19offline unit/valódi álfolyamat-teszt a kötelezőkapuban; nem valódi
játékinput. Játékos éles átvétel ettől nem tekinthető újraigazoltnak.
Teljes használat lent és docs/326. A325execsession-tartóssági gondját nem
állítjuk gyökérokában javítottnak: normál üzemben a felhasználó Terminalja
tartja életben az indítót, nem a chatben indított futtatás.

326helyi próba: user-local CLI telepítve, loginzsh is megtalálja.
Régi saját standalonepéldányok ellenőrzötten leállítva. Másikcwd-ből
stop→HTTPportzárás→új make -C start igazolt. A gyorsrestart közben talált
TIME_WAIT-téves portfoglalást SO_REUSEADDR-próbával és külön regresszióval
javítottuk; valódi foglaltport továbbra tiltott. Végső helyi runner70886,
dashboard70890, supervisor70891/session2352,20:55:51Z; frissPID aJSONból.
Az első próbakor a játék zárva volt, később a user újraindította:
frissképek és E5662CA8 új, helyreállítás nélküli kristálykör20:56:44Z→
20:57:04Zcompleted_ui. Eredményképen zöld40/Lifesteal+10.5K, utóképen HUD,
nem Free-stat. Saját Terminalos átvétel: butcher-hero stop, majd ugyanott
butcher-hero start; nincs duplaindítás. A sima make továbbra csak setup,
sosem rejtett gyűjtőstart.

## Újabb folyamatkiesés — 2026-10-31 (325)

20:36Z körüli ellenőrzéskor sem a57653felügyelő/57658worker, sem a8765
dashboard-listener nem élt. A39912/86104execsession sem volt elérhető.
Utolsó frisskép20:20:00.998Z; előtte BFC40697Health18600kattintás
20:19:57.751Z és igazolás20:20:00.003Z. Nincs szabályos supervisor_stopped
vagy friss releváns crashreport; a kilépés gyökéroka NEM bizonyított.
Ez nem új Healthfelismerési bizonyíték, és a kimaradt kézi jutalmat nem
könyveljük. Dashboard17574session újraindítva, /healthPASS. Gyűjtő12456
session --resume-run, indulóworker65067; a felhasználó bezárt játékára vár,
nem indítja azt el. Friss runtime mindig JSON+valódiPID+képidő alapján.
Külön Terminal-futtatásra kérdés elküldve; válasz nélkül nincs új launchd,
login/startup szolgáltatás vagy engedélymódosítás. A foregroundexecsession
önmagában most már NEM igazolt tartós megoldás. Részletek325.

## Pierce Damage összegolvasás javítva — 2026-10-31 (324)

Konkrét567/575hibát reprodukáltunk: az új21pxmagas5 elsőhelyes hibája
0.15440,9-é0.17727, különbség0.02286<0.035, ezért helyesen nem tippelt.
Nem küszöblazítás:14ellenőrzött kalibrációs kép/41glyph (új5/6/7 a korábbi
user567képből). Két különélő575kép held-out, nemkalibráció; mindhárom
teljesHUD/Pierce/összeg új rögzítettkor­puszban (összes38kép). Újunit,
teljes148teszt+7JSsyntaxPASS. A számolvasó kód/elfogadás/típusfüggetlenség
változatlan, történeti napló/reconcile nem módosult. Aktív ésstagingbundle
JSONatomi csere, NINCS gyűjtőleállás az adatbetöltéshez.20:13:26.963Z
BDF9D157 új575Pierceinput→29.216Zclaim_confirmed_ui amount575: élesPASS.
Induláskor a régi53842worker/saját53735supervisor már nem létezett, bár
JSONtrue maradt; oka nem bizonyított. Új --resume-run57658worker/session39912,
frissképek, folytatott statmunkamenet. Dashboard újsession86104. Nem
állítunk tartós stabilitást pusztaPIDből. Új különnyitottC2B1DD70:
képenSmashDamage692, olvasóunknown/összegnil; ezt nem nevezzük javítottnak.
Piercekonkrét hiba lezárható, általánoshibamentesség nem. Részletek324.

## Külső kijelző élő igazolása és geodesor — 2026-10-31 (323)

323kiegészítés: minden újresult új sajátContinue-t igényel, korábbi geode
Continue-ja nem felhatalmazás. continuePending kapu+meglévőteszt bővítve;
teljes147teszt kötelező. Nincs új művelet vagy limitreset.

19:42:33Z537BAD04Freeigazolt, utóképen+575nyíl, Quartz/cursorcél egyezik
−773.628/319.06967; előolvasásamountnil külön nyitott ügy. Ablak−828/−370/
788/1083. KristályC1F57DA9 új x1+x2paneljén322ablakszélesség-scale hibás;
most ténylegespinkX-méret adja a panelXYscale-t, külön aranykomponensben
csak pontosX1 választható.19:47:49Zsaját friss naplós --recover-crystal,
x1→ütések→kék40/PierceDefense140Kresult. SajátContinue automatikusan új
1/9geodet hozott, újOpen nélkül. Szűk continuing→breaking csak saját
Continue+kétgeodekép után; eredeti16ütés/3Continue/90s keret nem nullázódik.
Második felügyelt sajátfolytatás19:50:34Z;19:50:47ZContinue→49.891ZX→
52Zcompleted_ui. Javításokkal helyreállított kör, NEM megszakításmentes új
önálló kör. Utána19:51:06.077Z16C91DCF+84RegenFreeigazolt! Worker50020/
supervisor50014/session40809 futva marad; runtimeJSONelsődleges.
2újteszt+5valódi képminta, teljes147teszt+7JSsyntax/releasePASS. Következő
új önálló értesítéses kör még igazolandó. Részletek323.

## Kristály téves pötty és üres panel helyreállítása — 2026-10-31 (322)

Userkonfettis HUD-ja régiCrystalVisionnel reprodukált false-positive:
különállópiros5,79%+fehér3,42%+kékkristály38,82% elég volt. Most egyetlen
kompaktpiroskör, körkörösen fehérgyűrű+sötétkörvonal kell; nem független
színösszeg. A userképen márnotification=false, a3valódi pozitívontrue.
Inventoryt sajátfelsőX-hez, szélességalapú elrendezéshez kötjük; CRYSTAL
STATS+CRYSTALS kell. inventoryUnavailable: panelbiztos, Open nem biztos;
ilyenkor nincs openOne, csak a sajátfolyamat zárhat. DinamikusX/Openpont
frisspreclickből, nem régi fixY. Kézi panel nem automatikus cél és Free-t is
tiltja még HUDszín-tévesztésnél. Eltűnt értesítés kétHUDképen feloldja az
openinget60scooldownnal. Sajátüres panel readyből is closing; timeout után
egyszeri max10s ismertürespanel-cleanup, eredeti3X-próbakeret, sosem unknownX.
Nincs siker eredmény+sajátContinue+X+kétHUD nélkül. Ez a313blokkszabályának
SZŰK kiegészítése, nem általánosmodal- vagy idegenfolyamat-helyreállítás.
7újteszt, teljes145teszt+7JSsyntaxPASS, releasebuildPASS. Külső788×1083
frisskép valódi pöttyét felismeri; játékQuartzkeret−828/−370/788/1083.
A gyűjtőbiztonsági szünet után --resume-run-nal újraindult, de közben újra
0aktív/3alvó kijelző lett; nincs még éles új kristálykör vagy kattintás-
igazolás. Runtime aJSONból, nem történetiPIDből. Részletek322.

## Külső kijelző kattintásvédelme és diagnózisa — 2026-10-31 (321)

User külső monitoron rossz helyre menő inputot jelzett. Pontos történeti
félrekattintás NEM reprodukált: régi log nem tárolt célpontot. Két külső
Quartz kijelzőeredet−5120/−553 és−2560/−553, laptop1512×982/2x;
a negatív koordináta szabályos, nem vágjuk nullára és nem szorozzukRetinával.
Most minden Free/kristály/event input friss CGWindowID+PID szerintiQuartz
ablakkeretből indul, összevetve a képkerettel; aktívkijelző+azonosarány+
előtér kell. Warp hiba/2pontnál nagyobbkurzoreltérés/ablakmozgás esetén
nincs mouse-down. MouseMoved esemény is frissíti aCatalyst kurzorhelyét;
ennek valódi külsőmonitoros hatása még NEM igazolt. input_geometry napló
cél/kurzor/ablak/képméret/aktívkijelző adatokkal, külön a jutalomkönyveléstől.
6új offline geometriai teszt, user567Pierce-kép kártyánbelüli célponttal;
teljes138teszt+7JSsyntaxPASS. A kép összegét a jelenlegi olvasó nilként
adja: külön nyitott számolvasási eset, nem írunk be567-et bizonyíték nélkül.
Alvó kijelzőn a program vár és nem próbál streamet indítani. A320hibája
idején most mindhárom kijelző asleep; ez nem minden régi streamhiba oka.
--resume-run új build betöltve; frissPID/data/free-rewards/state.json.
Éles külsőmonitoros siker még kell; felhasználótól ébren hagyott, azon a
kijelzőn lévő játékot kértünk. Részletek321. Régi bot/heartbeatPAUSED.

## Külön játékállapot és kézi indítógomb — 2026-10-31 (320)

A dashboard külön jelzi a játékot és a gyűjtőt. game-status csak natív
folyamat-/telepítés-/ablakmetaadat, nem képrögzítés vagy input. 5s cache;
hibás/elavult próba UNKNOWN, sosem automatikusan „nem fut”. Telepített,
biztosan nem futó játékhoz explicit Játék indítása gomb. Nincs automatikus
indítás, gyűjtőstart vagy statreset. A korábbi teljes read-only dashboard-
leírást ez SZŰKEN felülírja: a statnapló továbbra csak olvasható; az egyetlen
új íróhatás POST /api/game/launch, loopback+azonosOrigin+szerverenkénti token,
üresJSON, fix /usr/bin/open -b com.multicastgames.butcher. Már futó játékot
nem nyit/fókuszál újra; nincs más alkalmazás vagy argumentum. 10s cooldown.
7Python+6Node újteszt, összesen132teszt+7JSsyntax a kötelező kapuban.
Éles státusz18:54:51Z: játék fut/ablaka látható, de ScreenCaptureKit stream-
hiba miatt nincs sikeres gyűjtőkép. Nem állítunk működő gyűjtést. Új build
--resume-run, supervisor30241/elsőworker30268/session92768; dashboard újraindítva,
session49803. FrissPID mindig runtimeJSONból. Valódi játékot tesztből nem
zártunk/indítottunk; indítószerződés mockkal ellenőrzött. Részletek320.

## Időszakszűrő súgó — 2026-10-31 (319)

Current run/Mostani futás = a legutolsó watcher_started óta megőrzött
logikai gyűjtési munkamenet, nem processz/chat/játék életideje. A --resume-run
watcher_resumed-et ír, nem nulláz: szünet/automatikus újraindítás/éjfél/UI-
frissítés/eseményvége sem új kezdet. Új alapindítás új watcher_started-et
ír; a régi napló nem törlődik, Minden nézetben megmarad. Kezdőjel nélküli
naplónál a megőrzött napló legkorábbi ideje a fallback. Backend változatlan.
A szűrőgombok mellett i-ikon natívdialogot nyit, HU/EN fájlból fordítva;
Escape/X/háttérkattintás bezár, fókusz azikonra vissza. Nemdata-rangegomb,
nincs reset/újfetch/gameinput.3Node+3Pythonúj regresszió. IzoláltChrome
asztali/mobilUI+Escape+fókusz ellenőrzött;119helyi tesztes teljes kapu.
Gyűjtő21386 nem állt le; csak statikusUI-fájlok változtak, meglévőoldal
egyszer újratöltendő. Nem indítunk új statfutást pusztaUIkérésből.319.

## Kiegészítő gyűjtésvédelmi javítás — 2026-10-31 (318)

317élesfigyelésekor677E54A4kristálynyitás ismételten preclickopenInventory/hud
elutasításba futott: frissképen nincs jelzés, NEM történtinput, mégis az
openingfázis90s-ig foglalta aFreegyűjtést. Most kizárólag a még egyáltalán
el nem küldött elsőnyitás ilyen nem-egérhibájánál visszaadjuk az inputgazdát,
60s kristálycooldownnal. Már elküldött input/feltörés sosem dobható el így;
kézi húzás továbbra csak várakozás. Nincs új kártyaérték vagy modalinput.
Új regresszió, teljes113teszt; éles újraellenőrzés318-ban. A317-es konkrét
DiamondLeague NO,THANKS→CONTINUE kezelés és annak korlátai változatlanok.
Végső318build18:24:10Zsupervisor21358/worker21386/session51821,
--resume-run, frissHUD/idle. A konkrét régi preclickelutasítás új előfordulása
még nincs igazolva ezzel a builddel; a szűk állapotátmenet unitból ellenőrzött.

## Aktív új engedély — eseményzáró képernyők, 2026-10-31 (317)

A felhasználó két konkrét DiamondLeague záróképet adott: Time is over
ajánlat NO,THANKS → EVENT ENDS! összesítő CONTINUE → játékHUD. Csak ezek
a bemutatott elutasítások engedélyezettek; az áras zöld ajánlatokra nincs input.
EventEndVision a konkrét fejléc+kontextus+gombszöveg+szín alapján dönt,
MÉG a régi HUDheurisztika elfogadása előtt: az ajánlat pinkgomb+zöldcsíkja
tévesHUDtrue-t okoz. EventEndFlow két stabilkezdőkép, frisspreclick/azonosablak/
STOP/egérvédelem, max3elküldöttpróba/lépés,1s újrapróba,60s határ.
Az összesítő önállóan is kezelhető, ha aNO,THANKS-et ember nyomta meg.
Kézi HUD-visszatérés feloldja a sajátUIvárakozást, nem gyárt automatikus sikert.
Sorrend:event → kristály → Free. Első felismert eventképnél a megszakított
függőFreeclaim claim_unconfirmed, nincs utólagos eltűnésből jutalomkönyvelés.
Napló külön:data/event-dismissals/events.jsonl+evidence; state.eventEndPhase.
10újteszt/2valódi userkép+47régiFree/kristálynegatív; teljes112tesztPASS.
Elsőbetöltéskor18:10Znem volt játékablak; most újra elérhető. Végsőbuild
18:17:20Zsupervisor18213/worker18248/session63806 --resume-run.18:17:37Z
PierceDamage575igazolt, AE1DB63Butóképen explicit+575nyíl. Az esemény-
képernyő jelenleg nincs nyitva: éleseventbezárás még nem igazolt. Friss
runtime mindigstate.jsonból. Régi
bot/heartbeatPAUSED; más modal/league nincs általánosan engedélyezve.317.

## ELSŐBBSÉG — GYŰJTÉS ÚJRA ENGEDÉLYEZVE, 2026-10-31 (316)

Új kifejezett felhasználói kérés: „indítsd el a programot, hadd szedje a
jutalmakat”. Ez felülírja314STOP-ját kizárólag a jelenlegi Free+kristály
automatizációra. Nincs mozgás/harc/bolt/eladás/fejlesztés/vásárlás/reklám.
12:22:09Zsupervisor95036/worker95041, tartóssession91364, --resume-run,
1s figyelés, meglévő statfutás megtartva.12:22:31.699ZHealth18100igazolt;
37F08443utóképen explicit+18.1Kszív. Frissstate.running=true és képidő.
Kristályág is aktív, új kristálynyitást ebben a körben még nem igazoltunk.
Régi bot és heartbeatPAUSED; nem indul második watcher. Runtime mindig
data/free-rewards/state.jsonból, nem a történetiPID-kből. PierceDamage-
összegnil külön nyitott kérdés marad. Részletek316; az alábbiSTOP történeti.

## ELSŐBBSÉG — FELHASZNÁLÓI STOP, 2026-10-31 11:40 Bucharest (314)

A felhasználó leállította a programot és a figyelést, este folytatjuk.
Free- és kristályinput/képernyőfigyelés LEÁLLÍTVA. Worker52120 és a saját
felügyelő52048 kilépett; state.running=false, supervisor_stopped
2026-10-31T09:40:27.872073Z. Nincs automatikus újraindítás vagy esti ütemezés;
új kifejezett folytatási kérés kell. Heartbeat továbbraPAUSED. A read-only
statisztika nem vezérel vagy figyel játékablakot. Naplók/képek/kód megmaradnak.
Folytatáskor friss játékállapotból indulunk; a313-as runtimePID-k történetiek.
Nyitott: külön PierceDamage-összegnil eset a06-os doksiban. Részletek314.

## Setup and usage — for users, contributors and their AI assistants (315)

This is the complete current setup guide. The dated STOP above is the
maintainer's local session state, not a reason to modify someone else's
checkout. On **any** machine, reading these instructions or asking for setup
does not authorize screen capture, game input, purchases or starting a bot.
Explain the steps first and start collection only when that user asks.
Never reuse historical PIDs or launch the legacy `ButcherHeroBot` executable.

### What this tool does

- Runs locally on **macOS**, against the **iPad version of Butcher Hero
  installed and running on the Mac**. This is not an iPad-side app, a cloud
  service, iPad mirroring driver, Windows build or autonomous combat bot.
- Checks approximately once per second for the left event **FREE** stat
  reward, clicks it when safe, and confirms collection only after its card
  is absent on two subsequent game-HUD frames. It logs the displayed type
  and amount; this is not an independently measured character-stat increase.
- Opens geodes when the right-hand blue crystal icon has its red dot:
  inventory → active gold x1 Open → repeated, visually checked strikes →
  Continue → inventory's red X → HUD. No selling, upgrading or equipping.
  The dot requires a connected round red centre with a white ring; red and
  white confetti elsewhere are not enough. A known empty/unreadable-Open
  inventory opened by our own transaction is closed without claiming a
  reward. A timed-out owned empty inventory has one bounded cleanup only;
  unknown/manual panels never get a generic close click. See docs/322.
- Dismisses the demonstrated expired **Diamond League** screens: **NO,
  THANKS** on the timed-out offer, then **CONTINUE** on its EVENT ENDS
  summary. Paid extension offers and unrelated Continue buttons are not
  targets. The summary can also be handled after a manual No Thanks.
- Supplies a local, automatically refreshing **HU/EN statistics dashboard**
  for FREE rewards. Crystal transactions have a separate journal and images;
  crystal stats are not added to FREE-reward totals.
- Uses local image matching and Tesseract, not a hosted AI API. The collector
  needs no AI API key. An AI assistant can help explain/install/develop it,
  but is not required for each runtime image check.

**No Ads:** the maintainer reports that the game's FREE tasks appear only
after purchasing the in-game **No Ads** item. Without that purchase those
tasks do not appear, so the FREE branch has nothing to click; geode opening
can still run in the same watcher. There is no separate crystal-only flag
and no purchase-receipt detector: actions are gated by the actual visible UI.
Do not purchase No Ads for the user, start an ad or bypass a purchase. A
missing FREE task without No Ads is expected, not an installation failure.
The No Ads rule is a game-behaviour statement supplied by the maintainer;
it was not retested by removing a purchase from this account.

### 1. Requirements and installation

Use an **Apple silicon Mac capable of running the game's iPad app** and
macOS **14+**. Current CI runs on macOS 15. Other systems/game layouts are
not claimed to be supported. Required tools:

- Git, Make and Swift **5.9+** with a compatible macOS SDK (Xcode Command
  Line Tools or Xcode). If absent, install Apple's tools with
  `xcode-select --install` and complete any interactive installation first.
- Python **3.10+** for the supervisor and dashboard.
- Tesseract **5** with its **English (`eng`) model** for local OCR.
- Node.js **18+** for development/tests, not for the running dashboard.

With Homebrew already installed, dependencies can be installed using:

```sh
brew install python node tesseract
```

Do not run an unreviewed remote installer or change the user's system/tool
configuration silently. If Homebrew or Apple tools are missing, explain that
prerequisite and let the user approve/complete the installation. Check tools:

```sh
git --version
swift --version
python3 --version
node --version
tesseract --version
tesseract --list-langs
```

`eng` must be listed. Install/repair that model if missing; do not weaken OCR
checks to compensate. All following commands run from the repository root.
For a new checkout (do not clone over an existing project):

```sh
git clone https://github.com/dankhazipeter/butcher-hero.git
cd butcher-hero
make setup
make test
swift build -c release --product ButcherHeroAutomation
```

`make setup` installs this clone's mandatory pre-commit/pre-push test hooks.
It deliberately refuses to overwrite a different existing hook setup;
integrate those hooks rather than bypassing them. `make test` is offline:
it uses saved fixtures, does not need the game and never sends game input.
It also enables the hooks. Keep the generated release binary **and its Swift
resource bundle** together in `.build/release/`; copying only the executable
to another machine is not a supported installation method. There is no
versioned downloadable app/release yet; this is a source checkout.

### 2. Permissions and game preparation

The user must grant macOS **Screen Recording** (the setting's name varies
by macOS version) and **Accessibility** access to the terminal/app/runner
macOS identifies as requesting capture/input. Find these under System
Settings → Privacy & Security. Permissions cannot be bypassed by the AI.
If macOS requests relaunching the host, do so with the user's approval.

The user should launch the iPad game on the Mac, reach the normal gameplay
HUD, and leave the portrait game window visible and unminimized. Avoid
covering it, leaving menus open, changing its aspect ratio or locking/sleeping
the Mac during unattended collection. Screenshots are window-relative and
clicks re-read the window geometry, but arbitrary new layouts/resolutions
have not all been validated. Moving a window is not a promise of support
for hidden/minimized windows or every resize.
For multiple monitors,321 validates Quartz global logical points against
the fresh window and active displays, including negative monitor origins
and1x/2x backing scales. Before mouse-down it verifies the actual cursor
position and that the window has not moved. It waits with no active display.
This is guarded input, not yet a claim of live verification on every monitor.
`input_geometry` journal records show the target/cursor/window coordinates;
they are diagnostics, never extra rewards. See docs/321.
Recognition currently uses the game's English labels (FREE, CRYSTAL STATS,
TAP TO OPEN GEODE, NO THANKS, EVENT ENDS, CONTINUE); keep that game UI available. The dashboard's
HU/EN selector changes only the dashboard, not the supported game labels.

The current input path briefly activates the game and moves/restores the
cursor and focus; **it is not a completely non-intrusive background input
solution**. A held mouse button or a recent drag defers automatic clicks;
after release, the next fresh check can retry. An AI doing documentation or
offline tests must not capture the current screen to "check" a stopped game.

### 3. Starting, resuming and stopping

**Recommended: one foreground command for both services.** After the
requirements, release build and permissions above are ready, and only when
you intend to enable collection, run in your own Terminal at the repo root:

```sh
make start
```

This starts the dashboard, checks its local HTTP health, then starts the
existing Free/geode/event collector supervisor. It keeps their output in
this Terminal and reports collector progress every 10 seconds. Open the
printed URL (`http://127.0.0.1:8765/` by default); the launcher does not open
or focus a browser or launch the game. Keep the Terminal running. Ctrl+C
stops **both** services and the owned worker; closing the Terminal normally
requests the same cleanup via SIGHUP. There is no login/startup service,
sleep prevention or guaranteed survival of SIGKILL/system shutdown.
From another terminal in this checkout, use `make status` or `make stop`.
The latter also works for this combined launcher started by an AI during
development, after checking the current runner's identity. It never stops
an unrelated server or separately started legacy service.

`make start` **continues the existing logical statistics run** by default
(`--resume-run`). For a deliberately new logical run, use
`python3 scripts/butcher-hero.py start --new-run`; existing history is not
deleted. Alternative port: `make start PORT=8766`.
No automatic build/install happens during start: missing dependencies or
binary/resources produce instructions instead of overwriting a live build.
An already-running collector or occupied port is an error, not permission
to take it over. Stop the original service in its own terminal first.
If either managed service exits, the launcher prints an error, shuts down
its other service and exits rather than leaving a silent partial setup.

**Optional short command from any directory:** run once in this checkout:

```sh
make install-cli
```

This creates only a symlink `~/.local/bin/butcher-hero` to this checkout's
`scripts/butcher-hero.py`; an unrelated existing command is never replaced.
It does not install the game or enable collection. If that folder is on
your PATH, use these from any directory:

```sh
butcher-hero start
butcher-hero status
butcher-hero stop
```

Otherwise `~/.local/bin/butcher-hero start` works directly; the installer
also prints an optional PATH command for the current Terminal. No shell
startup file is edited. `butcher-hero start --port 8766` selects another
port. Paths are tied to this clone, not the caller's current directory;
keep that clone and its release executable/resource bundle in place.
Without installing anything, an absolute path works from any directory:
`python3 /absolute/path/to/checkout/scripts/butcher-hero.py start` (quote
paths containing spaces). Likewise `make -C /absolute/path/to/checkout start`.

The native Terminal may need its own macOS Screen Recording/Accessibility
permission even if the AI runner already has it. Check for a **fresh
successful screen check and actual collection**, not just the runner's PID.
Stopped/absent game and capture errors are not reported as successful
collection. Journals stay in this checkout's existing data directories;
the launcher adds only `data/local-app/state.json` and `runner.lock`.

**Advanced: collector-only / dashboard-only development entry points.**
Do not mix these with an active combined launcher. The older scripts below
remain supported; they do not manage each other's services.

Only after explicit permission to start, leave this command running in a
terminal (or a persistent foreground AI execution session):

```sh
./scripts/start-free-rewards.sh
```

Despite the historical filename, it starts **both** current automations in
one worker, under one supervisor. Do not start a second watcher. The lock
rejects another live worker. Do not detach it from a short-lived execution
session with `nohup` and assume it survived; the verified deployment method
keeps the supervisor attached to a foreground session. The maintainer has
observed AI execution sessions disappearing; for unattended use, prefer
the user's own Terminal with the combined launcher above.

To continue the existing logical statistics run after a technical restart:

```sh
./scripts/start-free-rewards.sh --resume-run
```

Without `--resume-run`, starting a watcher begins a new logical run in the
journal (previous data is preserved). Do not reset/delete logs to fix a
display. The supervisor restarts only its own crashed/stalled worker; it
does not launch the game. A manual STOP must stop the supervisor as well:

```sh
./scripts/stop-free-rewards.sh
```

Alternatively Ctrl+C in the supervisor's terminal requests a complete stop.
Verify `running: false` in both `data/free-rewards/state.json` and
`data/free-rewards/supervisor.json`, and verify the identified worker and
supervisor exited. Do not kill arbitrary Python/game processes. No automatic
evening resume or scheduling is implied by "we'll continue later".

An optional **live, capture-only** test, with separate user approval, is:

```sh
.build/release/ButcherHeroAutomation watch-free --dry-run --seconds 15 --resume-run
```

It observes but never clicks; it still writes local journal/diagnostic data
and needs screen-capture permission. It is NOT an offline test and must not
be run while another watcher is active or while the user requested STOP.

### 4. Dashboard, logs and inspecting results

In a **second** terminal at the repository root:

```sh
./scripts/start-reward-dashboard.sh
```

Open `http://127.0.0.1:8765/`. If that port is occupied, use
`./scripts/start-reward-dashboard.sh --port 8766` and open that port instead;
do not kill an unrelated server. Ctrl+C in this terminal stops only the
dashboard. Reward journals remain read-only and the server is bound to loopback.
It checks native game process/window metadata without capturing screenshots.
The only game-control action is the explicit **Launch game** button: it
opens the fixed installed Butcher Hero app only when it is not running.
It never starts the collector, resets statistics, installs the game or
automatically opens it. Stopping collection does not require closing the dashboard.
Do not expose it publicly without a separate security review.

The page supports HU/EN, period/run filters, per-stat growth, a shared chart
of **collection counts**, and recent reward rows. It reads the journal
automatically; the status indicator distinguishes a fresh live worker,
mouse-related waiting, stopped/stale state and an unreachable backend.
Dates use the browser's current IANA time zone, rechecked during polling,
not a fixed Romanian zone or the chosen UI language. The page sends that
zone to the API so Today starts at the same local midnight and custom
datetime-local inputs are interpreted consistently. API requests without
`timezone` default to UTC; explicit-offset timestamps retain their instant.
Invalid time zones and nonexistent spring-DST custom times are rejected.
The eight game stat names stay in English even on the Hungarian page,
matching the game; surrounding explanations and number formats still switch.
The small info button next to the time-range buttons explains their meaning
in a keyboard-accessible dialog. Inside that dialog, **Start new session**
asks for confirmation and saves a separate statistics boundary without
stopping collection or changing the reward journal. Only **Current run**
starts over; Today, Last hour, 24 hours, All time and custom ranges preserve
their existing data. It then selects Current run. The effective start is
the later of the latest `watcher_started` and this saved manual boundary,
not a single process or calendar day. `--resume-run`, server restarts and
page reloads preserve it; a new non-resumed collector launch starts a new
view too. Rewards belong to a range by click time, not confirmation time.
Merely refreshing or selecting a range never resets anything. See docs/331.
A process PID alone is not proof of successful collection.
Game status is separate: not running, not installed, running with no usable
visible window, running, or unknown. An unavailable/stale probe is not proof
that the game stopped. Launch appears only for a known installed, stopped
game. An accepted launch request is not displayed as running until the next
native check confirms it. Window metadata does not prove the game is
unobscured or screen capture works; read the collector indicator too.
Updating from an older version requires rebuilding the native helper and
restarting the dashboard; the UI needs one reload. See docs/320.

Local files (not committed to Git):

- `data/free-rewards/events.jsonl`: append-only FREE attempts/confirmations.
- `data/free-rewards/evidence/`: original before/validated/after screenshots.
- `data/free-rewards/state.json`: worker status and crystal phase.
- `data/free-rewards/stat-session.json`: dashboard-only manual statistics
  boundary, written only after explicit confirmation; never reward data.
- `data/free-rewards/supervisor.json` and `supervisor-events.jsonl`: supervision.
- `data/crystal-rewards/events.jsonl` and `evidence/`: crystal flow and images.
- `data/event-dismissals/events.jsonl` and `evidence/`: known event-popup
  dismissal attempts and HUD-return verification, never FREE reward totals.

An offline CLI summary is available without starting capture or input:

```sh
.build/release/ButcherHeroAutomation stats --from 2026-10-31T00:00:00+02:00 --to 2026-11-01T00:00:00+02:00
```

Use explicit time-zone offsets matching the desired period. Journal times
are UTC; the dashboard formats them for its browser/user locale. Amounts
are the rounded values shown by the game (18.1K ≈ 18100), not exact hidden
internal stats. Unknown amounts stay unknown; they must not become invented
zeros or values copied from another reward. Pending/failed attempts are not
confirmed rewards, and manual collections are not attributed to the bot.

### 5. Troubleshooting and updating

- Missing binary: run the release build above. Build errors: check Swift/SDK
  and macOS versions; do not start the legacy bot as a fallback.
- Missing window: the watcher waits; check that the game is open on this
  Mac and unminimized. It does not launch the game automatically.
- No input: check Accessibility, mouse-release waiting and the last successful
  frame time. Missing/denied Screen Recording is not solved by relaxing
  recognition thresholds. Relaunch a permission-granted runner if required.
- No FREE tasks without No Ads: expected according to the maintainer. Geode
  availability is independent; it waits for an actual red-dot notification.
- Unexpected modal, layout or blocked crystal flow: stop, preserve evidence,
  inspect it and add a reviewed regression fixture. Do not click unknown
  buttons, ads or purchase confirmations. The bounded crystal flow can block;
  `--recover-crystal` is an **operator-only** recovery for a recent unfinished
  transaction in its own journal, not a normal startup flag. See docs/313.
  The combined launcher also accepts `butcher-hero start --recover-crystal`
  for that same explicit operator-only recovery. It preserves statistics,
  rejects `--new-run`, and forwards the flag only once; native ownership,
  10-minute freshness and input limits still apply. An expired/manual panel
  must not be adopted or closed generically. See docs/334.
  The specifically authorised Diamond League expiry offer/summary in
  docs/317 is an exception: the watcher dismisses only those recognised
  screens before returning to normal collection. Other leagues/layouts
  require reviewed examples; there is no generic "click any Continue" rule.
- A known open issue is a Pierce Damage reward collected with an unreadable
  amount; evidence and current limitations are in `docs/06-nyitott-kerdesek.md`.
  Do not advertise perfect recognition, every layout, or fully general
  unattended recovery. Do not run `reconcile` casually to rewrite history.
- Logs/screenshots grow on disk. Preserve evidence and agree on a retention
  policy before deleting anything; never automatically wipe the data folder.

For a user-managed update: stop the worker/supervisor first, inspect dirty
files and preserve them, then `git pull --ff-only`, `make test`, and rebuild
the release target. Restart only with current user authorization. Do not
force-pull/reset, overwrite user changes or rebuild over a running release
binary. During active authorized development, use a separate staging build
and only a short verified deployment pause (see docs/300 and docs/313).

### 6. Working with an AI and contributing

Suggested prompt after opening/cloning this repository in an AI coding tool:

> Read AGENTS.md's setup guide. Explain what the tool does, check my Mac's
> prerequisites, and walk me through installation and permissions. Do not
> start screen capture or click the game until I explicitly ask. Explain
> No Ads versus geode opening, show me the dashboard, and explain how to stop.

No particular AI vendor or paid AI integration is required by this program.
When advising, an assistant must inspect the current scripts rather than
invent flags. Keep the guide and the magyar `docs/` knowledge base current
with changes to dependencies, permissions, actions, UI or supported commands.
Do not purchase anything, change global credentials or push to upstream
merely because a newcomer asks for installation help.

For **external contributors**, fork the repository, work on a feature branch,
run `make setup` and `make test`, include reviewed screenshot fixtures for
recognition changes, and submit a PR to `dankhazipeter/butcher-hero`. Push
only to a remote/branch the contributor has authorized. The dated automatic
`origin/main` commit/push rule below is the **maintainer's own working
arrangement**, not authority for another user's AI to push upstream/main.
The maintainer reviews and merges suitable PRs; the PR's own fresh GitHub
`Reward tests (macOS)` check must pass. Do not bypass hooks or rewrite fixed
expected outputs to fit broken code. See `CONTRIBUTING.md` for the PR process.

There are no versioned releases yet; main is evolving. Check back for changes
and record the tested commit when reporting a bug. No project-wide license
has been selected in this checkout; do not claim an MIT/Apache license based
on the separate third-party CountUp license. Do not add a license without
the owner's choice. This guide does not lift the maintainer's current STOP.

## Aktív — Free + kristálynyitás, 2026-10-31 (313)

A felhasználó MOST engedélyezte a bemutatott kristályfolyamatot; ez felülírja
312 előjegyzett/Free-only korlátját kizárólag erre a műveletsorra. Két friss
HUD-on piros, fehér szegélyű jel + kék kristályok → ismert inventory aktív
arany x1 → geode ütései → Continue → inventory piros X → két friss HUD.
Az első ütés után eltűnő barna panel NEM hiba: repedt lila kő + TAP TO OPEN
GEODE szöveg külön felismerési ág. Ismeretlen képernyőn nincs input.
Egy inputgazda: kristály közben nincs Free-kattintás, utána automatikus
visszatérés; függő Free-igazolás alatt új kristályfolyamat nem indul.
Kézi húzás/STOP minden lépést véd; aktiválás utáni frisskép kötelező.
Nincs Sell All, Crystal Upgrade, felszereléscsere, vásárlás/reklám/gemköltés.
Kristálynapló: data/crystal-rewards/events.jsonl + evidence; NEM Free-stat.
Számláló OCR-0/S nem számszerű tény, eredménystat nem karakterstat-növekedés.
Siker csak eredmény+Continue+visszatért panel+bezárás+HUD, nem puszta input.
1s mintavétel/újrapróba, max3lépéskattintás/16ütés/90s tranzakció.
Blokkolásnál nem vak bezárás. Újraindított worker nem vesz át önkényesen
egy nyitott modalt; kizárólag friss saját naplóhoz --recover-crystal egyszeri,
felügyelt helyreállítás (max10perc, régi próbakeret megtartva). Ez nem
automatikus timeout-megkerülés, a felügyelő újraindításra nem ismétli a kapcsolót.
Első élő tranzakció0D44E692: a közteskép miatt egyszer javítva/helyreállítva,
09:21:59Zlezárult; kék40 PierceDefense+291K eredménykép.09:22:21Zúj Free581
CutDefenseigazolt. Ez NEM bizonyított teljes megszakításmentes első kör.
Végsőbuild52120worker/52048supervisor/session91902,09:29:05Zresume-run;
09:29:23ZHealth18100újraigazolt.42Swift+16Pythonstats+3Gitkapu+
10felügyeleti+31Node=102teszt és7JSszintaxisPASS; távoliCI külön ellenőrzendő.
Részletek313; a régi bot/heartbeatPAUSED. Runtime mindigstate.jsonból.

312következő feladat: a jobb oldali kék kristályikon piros pontja a felhasználó
szerint törhető kristályt jelez. Referenciakép elmentve. A belső folyamat,
költségmentesség, eredmény és ismétlési feltételek még nincsenek feltárva.
Ez előjegyzett következő automatizáció, NEM bekapcsolt kristálykattintó;
Free-only engedély változatlan. Vásárlás/gemköltés/reklám nem engedélyezett.

## Aktuális Free-javítás — 2026-10-31 (311)

A Healthkimaradás frissképpel bizonyított oka: FREE→FRE OCRtévesztés,
Regen81nél *+REE. Elsőként képi jelvénysablon dolgozik (3kézből ellenőrzött
forrás,48×24maszk,0.82küszöb), aTesseract csak szűkített tartalék.
Ikonvágás a zöld jelvényhez kötött, nem az ingadozó OCRszókerethez.
Külön kártyaszegély-védelem szűri a fű téves card=true jelenlétét.
Max3friss preclickkép/1.2s; hiányzó olvasás csak új képet enged, régi
adatból nincs kattintás. Másablak/összegváltozás/STOP azonnali elutasítás.
Rövid szövegkiesés csak láthatóHUD+kártya mellett2.5s-ig hidalható át.
click_sent és könyvelés a végső validált kép/reward alapján, kézi jutalom
és puszta click_validated/diagnosztika nem számolható sikernek.

Élesworker36820,supervisor36813,session21801; backendpixel-free+pixel-digits-v2,
--resume-run,1s.08:35:01Zindulás, első3perc6igazolt ebből3Health18100;
utóképen+18.1Kszív is igazolt.35rögzítettkép,27pozitív/8negatív;
3jelvénykalibrációs és24további pozitív.88helyi tesztPASS. A309/310
„Healthjavítás még nincs” állapotát ez felülírja; nem örökhibamentesség-ígéret.
Diagnosztika friss elutasítási/idle képpel és konkrét okkal (folyamatonként40
extra képre korlátozva). Részletek311; friss runtime mindigstate.jsonból.

310: fejlécbeli HU/EN nyelvválasztó, külön dashboard/locales/hu.js és en.js,
közös i18n.js. Magyar alapértelmezés, helyi választás megjegyezve; élő váltás
megtartja az időszakot és elrejtett görbéket. Dátum/szám/tooltipek/állapotok
is fordulnak, nem csak statikus fejlécek. Új UI-szöveghez mindkét nyelvi kulcs
kötelező; automatikus kulcs-/helyőrző-/scriptellenőrzés. Új nyelv útmutatója:
dashboard/locales/README.md. Nyers gyűjtőnapló üzenete nem írható át fordításra.
Worker66095 végig fut; csak read-only szerver2459/session3264 indult újra.
A309-es Healthpreclickhiba ettől NEM javult meg, továbbra külön nyitott ügy.

309: közös orderedKinds rendezi a statkártyákat, darabgrafikont,
jelmagyarázatot és rámutatásos listát a308-as párok szerint. Jelmagyarázat
is két oszlop. A vonalminta immár típushoz kötött, nem tömbindexhez;
átrendezéstől nem változhat az azonosítása. API/napló változatlan.
Ez felülírja308 jelmagyarázat-változatlanságát; a kártyapárok megmaradnak.
Külön309incidens: worker66095friss,SmashDefense83321:32:03Zigazolt,
deHealth18300kattintás előtti guardon elutasítva, többször nincs input.
A konkrét guardág még nem ismert; a frissképidő nem jelent hibátlan gyűjtést.
309kiegészítés: azonos18300fingerprint új claimID-kkel ismétlődik, köztes
reward=nil miatt törlődik a kétstabilképes kapu; nem végleges foglalás.
A felvillanást az aktiválás+hiba esetén is fókuszvisszaadás magyarázza.
Felhasználó most nem kér külön takartablak-támogatást. Pontos hibás képi
előszűrés továbbra ismeretlen; a mostani kör csak diagnózis, nincs javítás.

308: statkártyák két oszlopban, négy sorban: Health/HealthRegen;
PierceDamage/CutDefense; CutDamage/SmashDefense; SmashDamage/PierceDefense.
Kizárólag a kártyák másolt listája rendezett; API/napló/jelmagyarázat nem.
Valódi appkirajzolási teszt védi a sorrendet és a kéthasábos töréspontokat.

307: a statkártyák összértéke CountUp.js2.10.1 helyi, rögzített könyvtárral
0,65s alatt animálódik. Első betöltés/időszakváltás/reduced-motion/háttérlap
nem animál; azonos poll nem indítja újra, gyors új cél a jelenlegi képkockáról
indul. Pontos tooltip/aria/napló változatlan. Nem biztonságosan ábrázolható
számnál az eredeti pontos szövegből formázott végérték azonnal jelenik meg.
5 új, valódi könyvtárral futó Node-regresszió. Gyűjtő66095 nem állt le;
csak read-only szerver új PID89001/session10556 az új statikus útvonalakhoz.

306: a Mikor/mit/mennyit lista mennyisége is közös K/M/B/T formátumú,
például18300→+18,3K. A teljes érték title/aria-label mezőben megmarad;
napló/API változatlan. A tényleges app.js listakirajzolását Node-teszt
futtatja teszt-DOMon, K/M/100M/kisérték/hiányzóösszeg esetekkel.

305: a dashboard mindhárom jutalomikon-helyén átlátszó CSS-háttér kell
(statkártya, Mikor/mit/mennyit táblázat, darabgrafikon-jelmagyarázat).
A PNG-k már RGBA átlátszók voltak; a fehér csempét a CSS okozta.
Ez felülírja294 fehér CSS-háttérre vonatkozó döntését, nem a képi sablonokat.
Új regresszió ellenőrzi, hogy egyik ikon-szabály se kapjon fedő hátteret.
Gyűjtő/szerver újraindítása nem szükséges; a meglévő oldal újratöltendő.

304: a statisztika tetején külön GYŰJTŐPROGRAM ÁLLAPOTA sáv jelzi a Fut,
Leállítva, Indul/újraindul, Mozgás miatt várakozik, Nincs friss képolvasás
és Nem ellenőrizhető állapotot. Ez független az oldal adatkapcsolat-jelzésétől.
Zöldhöz élő PID és legfeljebb10s sikeres képidő kell; hiányzó első kép nem Fut.
Kapcsolathiba vagy20s-nál régebbi APIválasz nem maradhat zöld. KülönJSlogika,
7újNode/2újPython teszt; összesen23Swift+15statisztika+3kapu+9felügyelet+
12NodehelybenPASS. Gyűjtő66095 végig futott; csak a read-only statisztikaszerver
indult újra,PID77612/session3504. Böngészőben láthatóFut+frissképidő igazolt.

## Állandó munkarend és a tesztek célja — felhasználói megerősítés, 2026-10-30

Minden lezárt kód-, teszt-, konfiguráció- és dokumentációmódosítás után
kötelező a sikeres tesztellenőrzés, commit és automatikus push az origin/mainre.
Ehhez nem várunk újabb felhasználói kérésre; a feltöltés eredményét ellenőrizzük.
Pusztán olvasási körhöz nem készítünk üres commitot.

A tesztek elsődleges célja a nyilvános repó regresszióvédelme: külső
közreműködő PR-ján is látszódjon, ha a korábban igazolt helyes képolvasást,
jutalomkönyvelést vagy statisztikát elrontja. PR-felülvizsgálatkor az adott
PR friss GitHub-ellenőrzését nézzük, nem egy korábbi main-futás zöld jelét.
Hibás ellenőrzésű PR nem tekinthető elfogadásra késznek. A rögzített képi
elvárásokat nem írjuk át pusztán azért, hogy egy hibás módosítás átmenjen.
A helyi hook mellett ezért kötelező a push/PR GitHub-ellenőrzés is.

## AKTUÁLIS — APPLE VISION OCR KIVEZETVE A FREE-KÖRBŐL (303)

Az újraindítás és aCPU-kísérlet nem oldotta meg a visszatérő
TextRecognition.CRImageReaderError1hibát. Az aktívFreefelismerés többé
NEM hív AppleVisiont/CoreMLt: strukturált zöld badge → különTesseractfolyamat
csak aFREEszóra → játékbeli számjegyek saját pixelmintái → meglévő ikonillesztés.
Üres jutalomhelyen nincsOCRhívás. Tesseractkérés3shatáridős; kell az angol
modell (`brew install tesseract`). CIugyanezt telepíti, ugyanazt teszteli.

Most29rögzített korpuszkép,22pozitív/7negatív.36→38kalibrált glyph,
13vizuálisan ellenőrzött kalibrációs kép,9további pozitív ellenőrzőkép.
Elvárt teszteredményt nem írtunk át; két élőnilösszeges esetből új regresszió.
FREEfeliratot nem tekintünk pusztán zöldfűnek; bizonytalan glyphből nem lesz
kitalált szám. K/M/B/Tparser megmaradt, képiM/B/Tglyph még nincs igazolva.

Élő54705felügyelet utódja66038/worker66095/session91624.19:43:25indulás;
19:52:11ig16igazolt átvétel,0OCRhiba,0közbensőújraindítás, frissképidő.
A karaktermodell pontosítása atomiJSONcserével, leállítás nélkül történt;
legújabbRegen83már helyes. Friss valós állapot mindigdata/free-rewards/state.json.
A régiCPU/névlegesrunning=truejegyzet nem aktuális működési bizonyíték.
Lezárási303bizonyíték:4490c33kódcommitGitHubCI41119975619/job124283917935
SUCCESSmacOS15környezetben, helyi23Swift/13statisztika/3kapu/9felügyelet/
5NodeisPASS.20:05:33Zugyanaz a66095worker,36igazolt átvétel/0OCRhiba/
0közbensőújraindítás. A régebbiCI-hibák történetiek, ez a kód távol is átment.

302:a push előtti tesztkör különOCRellenőrzése is hibával állt meg; a live-
hibával való azonosság nem igazolt. A kapu BLOKKOLTA a feltöltést, nem került
megkerülésre. Most támogatott
VisioncomputeStageenkéntCPU-eszközt választunk a hivatalos macOS14+APIval.
Ez az accelerator-munkamenetek hibáját kerülő HIPOTÉZIS, nem bizonyított
véglegesgyökérok.20Swift/13statisztika/3kapu/9felügyelet/5NodehelybenPASS.
Előre fordítottCPUrelease betöltve;54705felügyelő/54789worker,session90309.
19:10:19HP18300igazolás,19:10:34frissképidő, hosszú távú stabilitás nem állított.
A remoteCIeredmény még külön igazolandó. Futó gyűjtőt ne állítsuk le a tesztekhez.

## Élő gyűjtés elsőbbsége és tartós felügyelete — 2026-10-30 (300–301)

A felhasználó nem kértSTOPot: a teszt/CIfejlesztés alatt aFreegyűjtést
folytatni kell. Tesztet külön másolaton végzünk, csak éles betöltéskor rövid
leállás; az utólagos élő igazolás kötelező. PusztaPID/running=true nem
bizonyít működést: friss lastCheckedAt és valódi átvétel kell.
Ne hagyjunk percekig régi képidővel futó folyamatot felügyelet nélkül.

Indító: scripts/start-free-rewards.sh [--resume-run], ELŐTÉRBEN tartott
tartós execsessionben, nem rövid parancsból leválasztott nohupgyerekként.
Pythonfelügyelő:30sfriss sikeres feldolgozás nélkül újraindítja kizárólag
a sajátFreeworkerét; induláskor45sgrace,5sSIGINTután szükség eseténkill.
Technikai újraindulás --resume-run, nem nullázza a statisztikát. STOPkor
stop-free-rewards.sh a felügyelőt is leállítja, nincs automatikus visszaindulás.
Utolsó igazolt felügyelet48519/session68833, jelenlegworker50644.
18:54:53élőVisionelakadást önállóan felismert,18:54:59újworker,
18:56:06újPierce540igazolás és18:56:28frissképidő. Nem kéziSTOPvolt.
19Swift+13statisztika+3Gitkapu+9felügyelet+5NodehelybenPASS.

301:a másodikCI már lefordult, de régebbiVision két esetben eltért:
593CutDefenseunknown és takart18Kösszegnil. Rögzített címkék változatlanok;
szűk±1/±2pixeles ikonillesztés, változatlan küszöbök, valamint számsor-only
fehér/feketeOCRtartalék. Külön regresszió mindkét ágra, nincs kitalált jutalom.

299:elsőGitHubCI valóban futott, de a Swift6.1.2fordító a régi bottargeten
még a tesztek előtt hibázott. Nem OCRhiba és nem pusztán runnerkapacitás.
Az@mainforrás BotMain.swiftnévre váltott, swipe-sugár explicitDouble/CGFloat,
ExpandedMapDetectorösszetett kifejezése azonos számítású ciklusra bontva.
A régi bot továbbraPAUSED, nincs új játékinput vagy stratégiamódosítás.
Bizonyíték és a helyi/távoli eredmények külön követése:docs/299.

## Klónozók és PR-ok kötelező ellenőrzése — 2026-10-30 (298)

Új klón után `make setup`; minden érdemi körben `make test` kötelező.
Ez egyben a helyi commit/push kaput is bekapcsolja. `make test-vision`
csak gyors részellenőrzés, nem helyettesíti a teljes csomagot.
A CONTRIBUTING.md és a PR-sablon ugyanezt kéri minden közreműködőtől.
A `.github/workflows/reward-tests.yml` minden pushra és PR-ra ugyanazt a
teljes tesztet futtatja macOSon, helyi hook nélküli beküldőknél is.
Stabil checknév: `Reward tests (macOS)`. A workflow sikerét ne állítsuk
csak a helyi PASS alapján; a GitHub-futás külön ellenőrzendő.
Fork-futás jóváhagyásra várhat. Automatikus merge-tilalomhoz külön repó-
required-check szabály kell, ezt nem állítottuk be és nem állítjuk aktívnak.
Ez érinthetné a közvetlenmain-push munkarendet, nem módosítjuk hallgatólagosan.

## Kötelező képi regresszió commit ÉS push előtt — 2026-10-30 (297)

Minden lezárt változtatási körben a `scripts/check-rewards.sh` összes
ellenőrzésének sikeresnek kell lennie. A verziózott `.githooks/pre-commit`
és `pre-push` ezt automatikusan megköveteli: commit előtt az index pontos
tartalmát, push előtt a feltöltendő commit tartalmát teszteli, külön ideiglenes
másolatban. Nem elég egy másik, esetleg nem stage-elt munkapéldány sikere.
Hibánál nincs commit/push; javítunk, újratesztelünk. A kaput nem kerüljük meg
`--no-verify`, kapcsolók vagy az ellenőrzések kikommentezése útján.
Új klónban kötelező `./scripts/install-git-hooks.sh`; a helyi
`core.hooksPath=.githooks` beállítás nem kerül át automatikusan Gitből.

A `tests/reward-reading-corpus.json` vizuálisan ellenőrzött, rögzített
elvárásokat tartalmaz: kép → HUD/kártyajelenlét, típus és normalizált összeg.
Minden új felismerési esethez és hibajavításhoz adjunk valódi mintaképet és
képből ellenőrzött címkét; típusonként legalább két külön kép maradjon.
A felismerő kimenetéből tilos automatikusan átírni az elvárt eredményt.
Valódi címkehiba csak dokumentált képi bizonyítékkal javítható. A kalibrációs
kép mellett külön ellenőrző kép is kell; a negatív/eltűnéses eseteket megőrizzük.
A helyi kattintási és utóképek továbbra minden próbához megmaradnak; a Gitbe
csak a kiválasztott, ellenőrzött tesztreferenciák kerülnek, nem a teljes napló.

297:27kép,20pozitív/7negatív;17Swift+13statisztika+3Gitkapu+5NodePASS.
Az új teszt önállóan felfedte az555CutDamage→unknown hibát; valódi current
sablonnal javítva, külön kalibrációs és ellenőrző képpel, változatlan küszöbökkel.
Régi átvételeket nem könyvelünk újra. Free-only kör és PAUSED heartbeat marad.
Friss sablonnal figyelő37802/session48218, --resume-run; korábbi29305leállítva.
A18:09:22Zmentett képen inventorynyitva, HUDnemlátható: a függő18300nem
igazolt. Nem gyártunk utólagos átvételt és nem zárjuk be a felhasználó paneljét.

## Kötelező automatikus commit ÉS push minden lezárt változtatási kör után — 2026-10-30

A felhasználó kérése: minden érdemi kód-, teszt-, konfiguráció- vagy
dokumentációváltoztatási kör végén készüljön egy áttekinthető Git-commit,
majd automatikusan `git push origin main`, külön felhasználói kérés nélkül.
Előtte releváns ellenőrzés, dokumentációfrissítés, diff- és staged-ellenőrzés.
Csak a körhöz tartozó módosításokat stage-eljük; más felhasználói munkát nem
foglalunk bele és nem írunk felül. Az induló commit kivételként a meglévő
projekt egyértelműen jelölt alapállapotát is rögzíti; nem találunk ki múltbeli
commitokat. Pusztán olvasási/megfigyelési körhöz nem kell üres commit.

Nyers felvételek, futó naplók, build és titkok nem kerülhetnek commitba;
a szükséges kis tesztreferenciák igen. Ha a commit akadályba ütközik, ezt
jelezzük, nem állítjuk sikeresnek. Git-szerzői identitást nem találunk ki.
Ez állandó felhasználói felhatalmazás a körhöz tartozó commit feltöltésére;
felülírja a korábbi „push csak külön kérésre” szabályt. Force-push és
idegen változtatás felülírása nincs engedélyezve. Eltérő távoli történet,
hitelesítési vagy hálózati hiba esetén jelezzük az akadályt, nem állítunk
sikeres feltöltést. A commit után a távoli mainnel való egyezést ellenőrizzük.
291óta minden lezárt változtatási kör automatikus push-célja:
https://github.com/dankhazipeter/butcher-hero. Egyetlen munkág egyelőremain,
upstreamorigin/main. AzoriginSSH-címegit@github.com:dankhazipeter/butcher-hero.git;
SSHdankhazipeterként hitelesít, aHTTPSmásik fiókkal403-at adott. Globális
hitelesítést nem módosítunk; új ág/PR jelenleg nem szükséges.
Részletek289–291. Egy pusztán Git-munkarendre vonatkozó kérés önmagában
nem oldja fel a játék STOP-ját; a mostani felhasználó viszont külön kérte
a program újraindítását is, az alábbi szűkFree-körben.

## ELSŐBBSÉG — FREE-GYŰJTÉS ÚJRA ENGEDÉLYEZVE, 2026-10-30 (291)

Legújabb296: a hiányzó4smash damage (688) és3smash defense (809)
valójában igazolt, deunknown típusú átvétel volt. Valódi aktuális HUD-
sablonok hozzáadva; a küszöbök nem lazultak. Aktuális futás7típusát
képből pontosítottuk, csakreward_corrected sorokkal, régi futásokhoz nem nyúltunk.
MostSmashDamage4db/2752,SmashDefense4db/3236,0ismeretlen az ellenőrzött körben.
15Swift+13Python+5NodePASS. Újfigyelő29305/session9371, --resume-run:
watcher_resumed nem nullázza a Mostani futást (kezdés16:50:44.381Z).
Típusjavítás csakreconcile --current-run. Statisztikaszerver-session72899.

Legújabb295:közös8vonalas grafikonnal az IGAZOLT ÁTVÉTELEK DARABSZÁMA
hasonlítható, nem a jutalmak összege.1átvétel=1db, újrapróbák nem külön;
ismert típus hiányzó összeggel is darab, ismeretlen típus külön megjegyzés.
Százalékok nevezője az azonosított, igazolt darabszám. ÚjAPImezők:
collectionCounts/collectionSeries/unclassifiedClaims.12Python+5NodePASS.
Statisztikaszerverexecsession85053; gyűjtő2444változatlanul futott.

Legújabb294:statkártyák és tengelyek közösK/M/B/T-kijelzése,100alatti
skálaérték egy tizedeslevágással,100-tól egész.2360000→2,3M,99800000→99,8M.
Ez felhasználói példákból választott megjelenítési szabály, nem biztos
játékbelső algoritmus. Pontos napló/API/táblázat/tooltip változatlan.
Új áttetsző UI-ikonok:dashboard/icons/, fehér CSS-háttérrel; a gyűjtő
felismerési sablonjait NE cseréljük le ezekre.5Node+9Python-tesztPASS.
Csak statisztikaszerver indult újra,execsession2939;gyűjtő2444változatlanul fut.

Legújabb292–293:élő helyi statisztika http://127.0.0.1:8765/ (read-only,
2sfrissítés), forrásdata/free-rewards/events.jsonl. Újgyűjtővision3:
PID2444/session79280. Zöld fű tévesFreejelenlét és18.3K→8.3/8300hibák
javítva,13Swiftteszt+9statisztikai tesztPASS. Csak az ÚJ futás adatai
az alapnézet. A felhasználó legújabb prioritása:mostantól legyen jó;
a múltat ne javítgassuk, ne találjunk ki utólagos átvételt. Történeti
reconcile nem futott. Dashboardexecsession86374; a gyűjtőt nem vezérli.
Friss folyamatadat:data/free-rewards/state.json, végponti bizonyíték293-ban.
293élőPASS:16:52:31.854ZHP18300kattintás,34.166Zigazolás, utóképen+18.3K.
18:54:28Bucharest:újfutás6igazolt/0függő,Health54900(3×18300).
API/CLIugyanazonidőablakraegyezett. Az új nézet2sfrissül, nincs kézi reload.

A felhasználó: „indítsd el a programot, újra fut a játék, gyűjtsük a
jutalmakat”. Ez felülírja288STOP-ját kizárólag a bal oldali event alatti
Free-jutalom figyelésére és átvételére.1s mintavétel, kézi húzásvédelem,
1s újrapróba, eltűnés utáni egyszeri könyvelés és helyi naplózás marad.
Mozgás, harc, bolt, vásárlás, reklám és ismeretlen modal kezelése nincs.
A régi heartbeatPAUSED; nem indítunk második figyelőt. Friss futási állapot:
data/free-rewards/state.json, részletek291. Az alábbiSTOP-történet megmarad.

291élő indulás:90423PID/session95760,16:09:56Zwatcher_started,
16:10:02.768Zelső593CutDefenseigazolva. Következőstats-pillanatkép:
2claim,CutDefense1186,0függő. Utókép ellenőrizve; figyelő futva marad.

## ELSŐBBSÉG — FELHASZNÁLÓI STOP, 2026-10-30 12:50:59 Bucharest

A felhasználó: „álljunk le! most kikapcsolom a gépet”. A jutalomfigyelő
83220PID-je szabályosan leállt;10:50:59.818Zwatcher_stopped, running=false,
folyamatellenőrzés szerint nincs futófigyelő vagy játékbot. HeartbeatPAUSED
ellenőrizve. Nincs automatikus képernyőfigyelés/input, újraindítás csak új,
kifejezett felhasználói folytatásra. Napló, képek és kód megmaradtak. Részletek288.
Az alábbi futási állapotok történetiek; a287-es élő teszt eredménye megmarad.

## ELSŐBBSÉG — CSAK FREE-JUTALOM AUTOMATIZÁCIÓ, 2026-10-30

Legújabb287:az újraindított játék ablakát a83220figyelő automatikusan
visszatalálta. Élőképi+napló+felhasználói igazolás: kézi húzásnál várakozás,
elengedés után540PierceDamageés593CutDefenseátvétel, mindkettő egyszer
könyvelve.10:31:05.883Z/40.569Zinput_deferred→08.334Z/46.026Zclick_sent
→10.603Z/48.291Zclaim_confirmed_ui; utóképeken explicit+540/+593.
A286-os ablakhiány történeti. Figyelő fut,1s, nincs régi bot/heartbeat.
Hatástalan elküldött input utáni1sújrapróba még csak teszttel igazolt.

Legújabb286:FELHASZNÁLÓI JAVÍTÁSKÉRÉSRE kézi húzásvédelem és1sFree-újrapróba
elkészült. Lenyomott egérgomb vagy friss húzás alatt nincs automatikus
kattintás; elengedés után friss ellenőrzés. Megmaradt, olvashatóFreekártya
1s után újrapróbálható, nincs állandó foglalás. Siker csak két játékHUD-képen
eltűnt kártyából. Újrapróbák ugyanazonclaimID, egyszeri összeg; időszakot
az utolsó click_sent dönti el, click_attempts külön számláló.
Ez felülírja284elküldött inputot végleg tiltó szabályát. Releasebuild/11tesztPASS.
Új figyelőPID83220/session97973; aktuális állapot mindig state.json.
286végpont:10:24:33.239Zablaknemtalálható; figyelő él és vár, nincs még
új éles átvételi igazolás. Külön kérés nélkül nem indítunk játékot.

Legújabb285:578CutDefense felismerése jó;09:19:55.936Zclick_sent után
09:20:04.676Zclaim_unconfirmed, a kártya megmaradt. Előképen aktív kézi
joystick; inputütközés valószínű, nem bizonyított. Nem számolt sikeres átvétel.
Elküldött kattintás duplavédelme tiltotta az azonnali újrapróbát. Csak
diagnózis történt, nincs javítás/újraindítás. Kézi húzásvédelme még nincs.

Legújabb284:felhasználói képenFREE18Kkimaradt, majd kézzel vette fel.
Időzítővel összeragadt OCRés kattintás előtti elutasítás utáni beragadt
foglalás javítva. Szűk számmező és token-geometria; csak el nem küldött
kattintás foglalása oldható fel. A kézi átvételt nem írjuk bot-eredménynek.
Új6tesztes regresszió és a felhasználói kép18000HP-felismerésePASS.
Új figyelőfolyamat a build után indult; frissPID a data/free-rewards/state.jsonban.
Korábbi60266PID/52505sessionmár történeti, ne használjuk újra azonosításra.

284élőPASS:66033PID/79555session,09:00:51.489Zúj18000HP-kattintás,
09:00:53.168Z-visszaigazolás, utána550cutdamage is átvéve. A javítás működik,
figyelő fut; friss állapot:data/free-rewards/state.json.

A felhasználó újra folytatást kért, megadta a nyolc jutalom ikonos
statképeit, és engedélyezte a bal oldali event alattiFreejutalom észlelését,
átvételét és naplózását. Ez felülírja a tegnapi teljesSTOP-ot ezen a szűk körön.
Mozgás, harc, bolt és egyéb automatizáció nincs. A régi heartbeatPAUSED marad.

Program:ButcherHeroAutomation watch-free --interval1. Helyi napló:
data/free-rewards/events.jsonl, bizonyítékképek:evidence/, állapot:state.json.
Indítás/leállítás:scripts/start-free-rewards.sh / scripts/stop-free-rewards.sh.
Jutalomtípusok:hp,regeneration,piercing_damage,cutting_damage,smash_damage,
piercing_defense,cutting_defense,smash_defense. Nyolc névvel jelölt, friss
statikon alapján alak+színillesztés; a pajzs elkülöníti a védelmet. A régi
színheurisztika törölve. Bizonytalan ikonunknown,kép megőrzendő.
Napló:reward_detected→click_intent→click_sent→claim_confirmed_ui vagy
claim_unconfirmed. A kattintási idő UTC ISO8601; a kliens időzónájaBucharest.
Statisztikában a látott jutalomértékeket összegezzük, nem állítunk ezekből
szorzókkal módosított teljesHP-növekedést. Részletek282.

Utolsó ellenőrzés2026-10-30T08:39:42Z:60266PIDfut,1sfigyelés,
24igazolt átvétel,0hibás/besorolatlan/függő tétel. A frissebb futási státusz
mindig data/free-rewards/state.json. Aktívexecsession52505; nem indítunk
párhuzamos figyelőt. Jelenlegi bináris mind a8típust kezeli, nem a281félkész kód.

## ELSŐBBSÉG — FELHASZNÁLÓI STOP, 2026-10-29

A felhasználó a gép terhelése miatt teljes leállítást és a játék bezárását
kérte. A játék Command-Q-val bezárva; nincs játék-, bot- vagy jutalomfigyelő
folyamat. Heartbeat PAUSED. Új kifejezett kérésig nincs fejlesztési futás,
megfigyelés, játékindítás vagy automatizáció. Részletek:281.

Az első Free-jutalom-automatizáció kódja félkész. Csak dry-run futott,
jutalomra nem kattintott. A színalapú ikonbesorolás hibás: az591-es fejszés
jutalom védelem volt. Újrakezdéskor a nyolc típust (3sebzés,3védelem,HP,
regen) a kézzel feltárt statpanel szerint kell felismerni, majd élőben tesztelni.
A részletes statlista alsó sorainak kézi feltárása még nem sikerült teljesen.
Ne indítsuk a jelenlegiwatch-freekódot éles kattintással ellenőrzés nélkül.

## Új kezdet — 2026-10-29

A játék frissült. A felhasználó kérésére a taktikát nulláról építjük újra,
az általa megadott lépések szerint. Ez felülírja a korábbi folyamatos játék
és automatikus felügyelet utasításait.

**Aktuális mód: a felhasználó első lépésére várunk.**

- Nincs automatikus mozgás, kattintás, farmolás vagy játékindítás.
- Nincs folyamatos megfigyelés vagy automatikus képernyőmentés.
- Képet a felhasználó jelzésére nézünk; a „Látod?” egyetlen ellenőrzést enged.
- A korábbi heartbeat PAUSED; külön kérés nélkül nem kapcsoljuk vissza.
- A „folytasd” az előkészítés folytatása, önmagában nem mozgási engedély.

## Tiszta kiindulás

A régi állapotok, térképek, útvonalak, célok és időzítők visszaállítható
archívuma: `docs/archive/2026-10-29-before-restart/`. Mind a21korábbi felső
szintű JSON eredeti tartalommal megmaradt; SHA256-egyezés ellenőrizve.
Forráskód, tesztek, nyers képek és történeti jegyzetek megmaradtak.

A régi kód az előző verzió kísérleti eszköztára. Beégetett céljai, koordinátái,
harci küszöbei és UI-felismerése friss ellenőrzést igényelnek. Régi állapotot
ne állítsunk vissza automatikusan. A kód alapértékei nem valódi játékadatok.

Jelenlegi munkamenet: `docs/session-state.json`.
Újrakezdési jegyzet: `docs/280-frissitett-jatek-tiszta-kezdet.md`.

## Küldetés és munkamód

Helyben futó, képi visszacsatolásra épülő játékost fejlesztünk. A felhasználó
most az első lépéseket adja meg. Új mechanikát és taktikát az új verzió
bizonyítékaiból tanulunk; a régi napló ötletforrás, nem aktív előírás.

Egyetlen friss kép készült a „Látod?” kérésre:
`docs/runs/20261029-223657-10037739-observe/frame-00000.png`.
Vizuális feliratok: BOSS TOWER, 0/9, saját élet mellett473M.
A régi elemző7660-at és Island2-mozgást javasolt: ez elavult kimenet,
nem új stat és nem végrehajtott input. Új ellenőrzött harci stat vagy útvonal nincs.

## Működési korlátok

- Vásárlásra, gem-/pénzköltésre és reklámindításra nincs engedély.
- Kifejezett stop azonnal leállít minden inputot és automatikus felügyeletet.
- Régi PNG nem aktuális képernyő; kihagyott inputból nem tanulunk akadályt.
- Emberi közlés, vizuális tény, következtetés és hipotézis külön jelölendő.

## Kötelező dokumentáció

A `docs/` magyar, élő tudásbázis. Minden érdemi megfigyelés, döntés, cáfolat,
mechanika és javítás ugyanabban a ciklusban MD-be kerül, bizonyítékkal.
Új témához új sorszámozott fájl és indexbejegyzés kell. Kódváltozáskor az
architektúra és taktika is frissítendő. Történeti tudást archiválunk.

Indulási olvasmányok: ez a fájl, `docs/README.md`, `docs/session-state.json`,
`docs/280-frissitett-jatek-tiszta-kezdet.md`, majd az érintett aktuális témadoksi.
Lezáráskor az index, az aktuális állapot és a nyitott kérdések egyezését ellenőrizzük.
