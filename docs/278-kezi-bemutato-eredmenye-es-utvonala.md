# Kézi bemutató: két győzelem és mért út a gólemhez

## Felvétel és leállítás

2026-09-19, `213216-9f59ae87-record`:628PNG,161,715másodperc,
634×878végig. Időbélyegek1789846336,852–1789846498,567Unix.
Felhasználói kész-jelzés után a pontosPID71075 SIGINT-tel lezárva;
ellenőrzéskor már nincs botfolyamat. Minden eseményinputExecuted:false.
HeartbeatPAUSED, játékinput nem indul az elemzés alatt.

## Képpel igazolt győzelmek és harc

- /275:1,22Kőr a kék sátor/koponyás tábla előtt. /285:Savage Fang24,
  **184→192damage**. Tartalék maradt, HUD-onBat14/Venom18.
- /288–290: az első őr helyén a koponyás tábla alatt4h26m hosszú időzítő.
  Valószínű napi kimerülés; NEM állítunk új20perces kört. A térbeli
  hozzárendelést újraellenőrizni kell, mert a környék fáin is ilyen idő van.
- /310–315:192HPőr a déli faépület és a keresztkerítés közötti udvarban.
  /320:Steel Splitter27, **312→324damage**, **19m59s**, saját7,06K.
  Ez is tartalék; felszerelés nem változott.
- /460:18,8K láncos gólem,25zöldszíves jutalomjel, saját7,06K.
  /485:saját0, boss10,3K; /490:YOU DIED; /495–500újraéledési átmenet.
  Legalább8,5K kijelzett sebzés, nincs gólemgyőzelem. Korábbi10,8K maradékhoz
  képest jobb, de ez nem elég a harc megnyeréséhez. Kimenő432 és1,12K,
  bejövő1,3K effektek láthatók. Bosspróba emberi vezérléssel történt,
  nem a bot új taktikai tesztje. Automatikus ismétlés nincs.
- /627:saját7,06K, újraéledési kőkör, Bat14/Venom18.

## Navigációs tanulságok

A mozgás /255után indul; /460-ig52,831másodperc telt el, közben két őr
legyőzése és térképnyitás is történt. Ez egy bemutató mért ideje, nem a bot
teljesítménye. A folyamatos emberi húzás pontos inputeseményeit nem vettük
fel; a képekről elmozdulást és útgeometriát tanulunk, nem vak inputmakrót.

1. Havas zárt kapu alól délnyugatra a kék sátor déli oldalához és az1220őrhöz.
2. Délkeletre a sziklakert mellett, aztán a faépület és keresztkerítés
   udvarába a192őrhöz. A kerítés végének megkerülése számít, nem az ikonirány.
3. Vissza az északabbi ösvényre, nyugatra aDusty Gulch2bejárathoz.
4. A barna ház/szikla nyugati falát NEM közvetlenül áttörni: déli kerülő,
   kőív/udvar, majd a nyílt területen nyugat és észak a sziklatömb körül.
5. Nyugati oldalról északkeletre, majd a gólem nyugati megközelítésére.

## Gépi útmérés

Új offline `tools/audit-demonstration.swift`: minden egymást követő PNG-pár
VisualOdometrymérése; érvénytelen vagy200pxfeletti átmenetnél új független
szakasz indul, nincs kitalált összekötés. Tartós játék-/navigációs állapotot
nem módosít. AJSON bizonyíték, önmagában nem automatikus útengedély.

`docs/demonstration-213216-island2-track.json`: /334–460,127kép,
egyetlen folytonos érvényes szakasz. Origó/334, irányxjobbra, ylefelé,
kameramozgás negatívja a mért karakterelmozdulás. Nem azonos a régi
terrain-chart-62/66koordinátákkal; nem szabad azokat vakon hozzáadni.
`docs/demonstration-213216-two-guards-track.json`: /255–320őrkör külön mérve.
66kép, ugyancsak egyetlen érvényes folytonos lánc.
A nagy térkép köztes képei kimaradnak. /320→334közvetlen képi ellenőrzés
34konszenzus,1,999reziduum,(-59,826,-49,234)elmozdulás: vizsgált híd,
nem azonos helyzet és nem nulla elmozdulás.

Következő fejlesztési lépés: a kijelölt kanyarok képi/minimap alapú
visszaazonosítása egy élő chartba, majd szakaszonkénti visszacsatolt
útvonalkövetés. A teljes önálló újrajátszás még NEM igazolt. Most nincs
automatikus játék: a felhasználó csak a bemutató végét jelezte.

## Feldolgozó ellenőrzése

BuildPASS. A/482–500halál–újraéledés teszten két külön szegmenst hozott
létre, pontosan/495-nél megszakítva(4konszenzus,999reziduum). Nem rajzol
járható utat a teleporton át. A két mozgási lánc továbbra1–1szegmens.
A nyers PNG-k megmaradtak; kontaktlapok a futásmappában. Az index, aktuális
taktika, architektúra, mechanikák, kronológia és nyitott kérdések frissítve.
