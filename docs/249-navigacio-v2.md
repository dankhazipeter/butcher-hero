# Navigáció V2 — új vezérlés, 2026-09-19

## Legfrissebb élő ellenőrzés — 18:23

Folytatás18:25: `182501-160b7311-play/4` a174HP/10szíves fa találata516,
új4m kör.21képen saját6,5K, gépi maximum még6490: következő friss számos
konszenzusig a pontos6500maximum nincs tartósítva.35s alatt végigment délre
a tábor nyílt oldalán; végkép67HPfa kerítés mellett,192HPőr délnyugatra.
Következő menet friss képből, ne a régi északi cél felé induljon.

`20260919-182329-426c45db-play`: 40 másodperc, 28 döntési kép.
3: első179HPfa helyén4m0s,516találat. 16–17: két eredménytelen nyugati
próba a szélmalom nyugati kerítésének belső oldalán. 18–20: tartós déli
falkövetés;21–23: nyugati átjárópróba;24képen a játékos ténylegesen
a kerítés nyugati oldalán, az ösvényen. 27: másik179HPfa helyén3m59s,
516találat és+1fejsze. **Két aratás, egy önálló kerítéskerülés.**
Saját kijelzett HP végig6,49K; az időzítős takarás nem bizonyított sérülés.

A kerítés nyugati kijáratának használata tehát élőben is működött, nem
pusztán a szimulációban. Nem bizonyít minden akadályra általános megoldást:
a térképrészek összeillesztése és többféle terepszint továbbra nyitott.
Újrafuttatott szimuláció: vastag fal39/37input normál/dupla sebességen,
szűk kapu18input; input nélküli tanulás és újraindítás-invariánsPASS.

## Miért váltunk

248javítás megszüntette a célválasztók kapuversenyét, de a piros pont
közvetlen iránya a sziklafalba vezetett.164949/8–25ennek képi bizonyítéka.
A felhasználó teljesen új megközelítést kért. Nem minősítjük ezt megoldott
navigációnak; új modul veszi át a normál célhozjutást.

## Új felépítés

- Egyetlen navigációs tulajdonos: NavigationV2. Normál módban a régi
  szigetmakrók iránya, házkarantén, kapufolt és LocalWorldMap.steer nem vezérel.
  A LocalWorldMap csak mérési forrás marad. Harc/bolt/gyógyulás külön megmarad.
- Világpozíció: jó minőségű narancskoponya-támpont, minimappixelben. Rövid,
  legfeljebb8képes hiányt ellenőrzött kameramozgás hidalhat át, becsült
  képernyő/minimap léptékkel. Nagy ugrásnál nincs akadálytanulás.
-3pixeles helyi rács, irányított mért sikeres és sikertelen átmenetek,
  képhivatkozásokkal a navigation-v2-map.json fájlban. Ismeretlen nem igazolt járható.
- A* az ismert tiltások körül; az ismeretlen él többe kerül, átlós sarokvágás tiltott.
- Két eredménytelen végrehajtás után tartós, azonos oldali falkövetés,
  legalább18minimappixel mért haladásig. Utána rövid újraközelítési próba.
  A kerülő hossza nem swipe-szám, ezért gyorsító mellett is mérhető.
- Nincs végrehajtott input→nincs faladat. Friss pozíció vagy cél nélkül vár,
  nem tér vissza vak makróhoz. A12inputos külső haladásőr megmarad.

Az events.jsonl új navigation mezője mutatja a pozíciót, célt, állapotot,
akadályélszámot és a mért falmenti haladást. Ez ellenőrizhető, nem puszta indokszöveg.

## Teszt és határ

ReleasebuildPASS. Szimuláció:60minimappixel hosszú összefüggő fal megkerülése
normál és kétszeres sebességen egyaránt33input; input nélküli20kép0akadályél.
Ez algoritmusteszt, **nem élő játékbeli siker**. Az aktuális fal élő próbája következik.
Globális atlasz, magassági rétegek, tartósan eltűnő támpontok még nem megoldottak.
Nem állítjuk, hogy már minden pályán jól navigál.

## Első élő próba és konkrét tanulság

165646-play/0–12: sziklánál indul26,5/36,5narancsminimappozícióról,
12képen24/15, nyílt kapu-előudvar; végig5860HP. A falkövetés20mért
minimappixelt haladt északra, nem az előző helyben forgó kerülő.
13–19azonban túl korán délkeletre fordult, és a kapu előtti zsebből visszacsúszott.
Haladásőr megállította. Új változat: a falkövetés után a fal normálirányában
9mért pixeles kijutási szakasz, csak utána célra fordulás. Egy sikeres
átlós lépés nem bizonyít teljes falmegkerülést. Vastag falas szimulációval teszteljük.

Vastag60×8pixeles falteszt42/40input normál/gyorsított mozgássalPASS.
165857új élő próba még12inputos haladásőrrel megállt. Az apró falmenti
rezdülések nem számíthatnak teljes haladásnak; minimum1px/35%elvárt elmozdulás.
Sebességet csak2,5px feletti sikeres mozgásból tanul, nem falzajból.
Újraindításkor a kerülőállapot csak3px-en belüli minimappozíció **és**
3alatti átlagos terepképaláírás-eltérés mellett folytatható. Más helyen újratervez.
Ez a felügyelt rövid futások között nem felejti el az éppen megtalált kerülőirányt.

## Keskeny átjáró — harmadik korrekció

170132/0–59: tartós kerülés működik, de18px-es nyíláskeresési ritmus átugorja
a keskeny kaput.51képen már a kapu fölötti oszlopnál jár, nem a nyílásban.
Új ritmus6mért pixel; a kerülési oldal ettől nem változik, csak próbát tesz
a falra merőlegesen. A9px-es teljes kijutás továbbra kell a célra forduláshoz.

A163957/53–56 és164534/0–3két igazolt irányított átkelése a
navigation-v2-corridors.json adatforrásba került. Ez csak olcsóbb, bizonyított
éleket ad az A*-nak; nincs fordított él, teleport vagy swipe-számláló.
Ismeretlen él költsége3, igazolté1; friss tiltott élt a régi út nem old fel.

Teszt: vastag fal39/37input normál/dupla sebességen; végtelen fal6pixeles
nyílásán18input. Input nélküli akadálytanulás tiltása és kettős képi
azonosításos kerülőfolytatásPASS. Élő szűk kapu még ellenőrzendő.

## Élő átjutás

170838-play/0–5: a topológiai átjárótervező előbb délre közelíti a mért
kapupontokat, majd keletre áthalad.5pozíció33/12;13pozíció46,5/7,5;
17kép már a zöld oldali hajó mellett,1,22Kőr látható. **Önálló átjutás igazolt.**
Ez még nem teljes jó navigáció: a hajósziklánál újabb elakadás,27haladásőrSTOP.
13–14egy közeli fenyegetés miatt a régi makró még átcsúszott a V2eligibility
résén. Új kizárás: általános navigációs swipe V2feltételek nélkül vár,
nem hajt végre régi szigetmakrót. Harci/gyógyulási döntés továbbra külön ág.

## Új terület és önálló helyi térképrész

171540-play/0–7helyi piros célhoz jut,7képen516találat és**+1fejsze**, új
8h44m kör; tényleges kisfa-aratás,5860HP. Utána a narancskoponya eltűnt,
a régi8képes hiánykorlát miatt16–97várakozott. Ez lokalizációs korlát,
nem fal vagy felhasználói aktivitás. Utólagos diagnózis: állóképek is
fogyasztották a hiánykeretet, amit nem lett volna szabad.

ÚjAtlasz-mód: megbízható képi mozgás esetén különlocal-UUIDkoordinátatér
indul; saját rácsélek, sem régi kapupont, sem globális akadály nem kerül bele.
Tiszta helyi képi mozgással továbbmehet. Narancstámpont visszatérésekor
a globális tér visszaáll, de a helyi úticél/kerülő törlődik. Állókép nem
növeli a sodródási keretet. Bizonytalan/nagy képi ugrás továbbra nem inputengedély.
Helyi chartok automatikus globális összeillesztése **nincs**; ezt nem állítjuk SLAM-késznek.

A quick-farm régi„zöldképen mindenképpnullpose” elvárását pontosítottuk:
hamisVenomikon tiltott, de jó minőségű, valóban látszó narancskoponya megengedett.
Ez szükséges a kapu után is folyamatos pozícióhoz; nem tesztcsendesítés.

171908/1: izolált helyi charton elindult, majd157px-es biztonságos fa mellett
megállt: a korábbi180px-es V2átadási kapu és régi szigetmakró közti rés.
Ez nem helyhiány. A V2most a kiválasztott biztonságos világcélt is megközelíti,
képi delta→mért térképlépték alapján, azonnali elsőbbséggel a minimapcél fölött.
Harci/gyógyulási waitet továbbra nem ír felül. Ezt új célváltási teszt fedi.

## Legfrissebb igazolt eredmény — 17:21

172137-play/1–9: a157px-es67HP-s fa megközelítése,9képen516sebzés és
új4m0s kör.13–18a kerítés jobb végét megkerülve ténylegesen a déli oldalra
jutott;18képen az192HPőr szabadon elérhető.21–23**Steel Splitter24,
276→288**,19m59s kör, majd25képen az őr helye üres. Végig5860sajátHP.
Ez nem puszta mozgás: egy kisfa és egy fegyverőr tényleges legyőzése,
új helyi charton, narancstámpont nélkül. A közeli támadásigazítás még7váróképet
vesztett, a célzár/OCR még javítandó.36végkép új80HP-s cél felé kerülő.

Legfrissebb build és NavigationV2szimuláció/célcsere/chartváltás/újraindítás
tesztPASS; quick-farm, small-guard és HP-takarás célzott regresszióPASS.
A teljes történeti tesztcsomag korábbi bossoldalkerülő18képes hibája nincs
megoldottnak nyilvánítva. A globális és helyi chartok automatikus összeillesztése nincs.

172354következő kör:7képen újabb516találat,**+2szív** jutalomanimáció
és8h35m kör. Pontos maximumot kerekített5,86K-ból nem állítunk5862-nek;
statpanelmérés kell.16képen a kapuőrház északi megkerülése, jobbra48HP/10szíves fa.
19–20már a fa felé,44új respawnkör. A közeli célzár még néha régi irányt tart.
Felügyelet aktív,min-user-idle0,nagy bossmód nélkül;60s kör szabályosan befejeződött.
