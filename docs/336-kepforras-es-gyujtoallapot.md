# Képforrás és gyűjtőállapot: a nagyobb Safari nem játékablak

2026-11-01, Europe/Budapest. User: kimaradt Health és Regen, miközben a web
zöld Fut-ot írt. A diagnózis után mindkét javítást kifejezetten jóváhagyta.

## Bizonyított ok, nem ikon- vagy engedélyküszöb

A user1274×1764 képe a változatlan335olvasóval hp/18200, pixel FREE,
HUD=true/card=true. Nem bizonyít botátvételt: a user kézzel gyűjtötte.
A worker folyamata futott és másodpercenként frissített. Saját
`943118F7…-diagnostic-17.png` (10:04:21.444Z) és `…-18.png`
(10:04:51.770Z) viszont a teljes2560×1440 Safari dashboardot tartalmazza.
HUD=false volt, ezért nem kattintott. Személyes böngészőfülek miatt ezeket
nem másoljuk a publikus regressziós korpuszba.

A Capture.frame az OS ablaklistájából a játék bundleazonosítóját VAGY a
Butcher Hero szót tartalmazó címet elfogadta, majd terület szerint választott.
Így a dashboard Safariablaka nyert. Más ablaklistán ismét a játékot választva
10:05:54.765Z-kor PierceDefense614igazolt. A változó siker nem bizonyítja,
hogy a Health ikonja hibás, és az aktuális capture nem TCC-elutasítás.

Második hiba: a dashboard csak élő PID-et és friss lastCheckedAt-ot kért
a zöld Fut-hoz. A screenshot attól még friss volt, hogy nem a játéké.

## Szűk forrásazonosítás

Új tesztelhető GameCapturePolicy: pontos `com.multicastgames.butcher`,
pozitív processID és WindowID, véges és legalább350×550méret. Csak ezekből
választhat legnagyobbat. Az ablak címe nem is bemenete a szabálynak.
Nincs másik appra fallback, ha a játék hiányzik. A Capture.frame valamennyi
normál és friss preclick-rögzítése ugyanazt a szabályt használja.
Régi egér-/ablakgeometria-/előtérellenőrzés továbbra is megmarad.

## A zöld jelzés új szerződése

A workerstate a tényleges SCWindow forrásának bundleID/PID/WindowID adatait,
captureStatus és screenState értékét menti. A backend külön ellenőrzi a
forrás típusait és pontos bundleazonosítóját, nem fogad el a fájlból egy
önmagában álló captureSourceVerified=true állítást. Az API ezt a származtatott
értéket és az állapotokat adja tovább.

Friss élő worker csak igazolt forrás+ok+HUD esetben zöld. Régi worker vagy
hiányos adat: képforrás nem igazolt. Hiba: képrögzítési hiba. A játékból
érkező, de fel nem ismert képernyő külön warning. Blokkolt event/kristály
vagy kézi kristálypanel blokkolt. Ismert, nem blokkolt modal processing:
Free addig szünetel. Mouse wait, stopped, stale, kapcsolat-/játékhiány
továbbra külön állapot. Nem az utolsó jutalom idejéből következtetünk
képrögzítési hibára. Nincs minden modalra tévedhetetlen felismerési ígéret:
a HUD-ot továbbra a meglévő vizuális felismerő dönti el.

A capture/feldolgozás catch ág azonnal error állapotot ment; az előző friss
timestamp nem hagyhat zöldet hibánál. Naplóhiba továbbra leállítja a workert.
Régi megnyitott dashboardlap egyszeri reloadot igényel az új JS-hez.

## Tesztek és betöltés

4új Swift metaadat-unit, a kötelező filterben külön RewardCaptureTests.
Nagyobb Safari+Chrome mellett csak a játék, nincs játék esetén nil, hibás
PID/WindowID és használhatatlan méretek kizárása. Személyes böngészőképek
helyett ezek a valódi kiválasztási határfeltételeket ellenőrzik.
2új Python teszt: származtatott forrás és régi metadatahiány, hibás/bool/
túl nagy azonosítók;4új Node teszt a forrás/hiba/UIállapotokhoz, ebből egy
valódi app.js DOM-integráció poll+HU/EN váltással+rossz→jó→rossz állapottal.
A meglévő
HU/EN és DOM-integráció új protokolladatait frissítjük; külön teszt marad
arra, hogy metadata nélkül nem lehet zöld. A régi megállt/stale tesztek nem
lazultak. A teljes új kapu213teszt+7JS-check, stagingrelease külön build.

## Élő betöltés és ellenőrzés

Az első212teszt+7JS-check és stagingrelease sikeres, az utolsó DOM-tesztet
és a felirat pontosítását tartalmazó végső213kapu is sikeres:85Swift,
25dashboardPython,7game-control,10statsession,3Git,10supervisor,
20launcher,53Node és7JS-szintaxis. Nincs kihagyás vagy elvártérték-lazítás.
Saját workerstop10:28:37.475Z, normál resume10:28:58.378Z: kb.21s szünet.
Atomikus bináriscsere csak leállított worker mellett. Nincs recover-crystal,
új statkezdés vagy jutalomnapló-átírás.

10:29:11Z friss workerstate: source bundle com.multicastgames.butcher,
PID13534/WindowID546, captureStatus=ok, screenState=hud. Az élő API
captureSourceVerified=true, a külön játékmetaadat futó/látható állapot.
10:29:28.665Z7CDA730F saját Regen83 input,10:29:30.948Z UIigazolás;
utóképen explicit +83 és zöldregenikon. Ez új botátvétel, nem a korábbi,
user által jelzett kézi Health vagy Regen utólagos könyvelése.

Új, rejtett IAB tesztlap11:30:33helyi időkor a friss protokoll alapján Fut,
az új igazolt játékablak/HUD részletszöveg és Legutóbbi képrögzítés felirat.
Képi ellenőrzés `.build/ui-proof/336-source-verified.png` helyben, nem Git;
a saját tesztlap bezárva. A user meglévő Safari lapja egyszer frissítendő.
A hiba-/forrás-/modal warningok a valódi app.js integrációs tesztben is
ellenőrzöttek; nem váltottunk valódi játékot hibaképernyőre a teszt kedvéért.

RuntimeJSONelsődleges: runner13621/dashboard13626/supervisor13627/worker13630,
persistent foregroundsession90840 itt történeti indulási adatok. A gyűjtő
futva marad a további teszt-, commit- és push-kapuk alatt.
