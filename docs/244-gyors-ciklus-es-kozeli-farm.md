# Gyors ciklus, közeli farm és DOC-harcdiagnózis — 2026-09-19

## Módszerváltás a felhasználó kérésére

Első mérce: igazolt ölés, HP/DPS/fegyverfejlődés percenként; mozgásszám nem siker.
Közeli, olcsó cél megelőzi a távoli szigetkeresést. Rövid felügyelt futások,
10–20másodpercenként kép/napló; javításonként először célzott regresszió.
Teljes regresszió csak a kapcsolódó javításcsoport végén, nem minden egyes
megközelítés előtt. Ciklusonként egy tömör összefoglaló MD; fontos új téma
továbbra indexelt. A kézi mozgás csak konkrét kísérlet, nem alapjátékmód.

## DOC-kísérlet: kudarc és biztos okok

161057:5W→161111/0;161132:7N→161144/0, kerítésvég;161208:2W→161218/0;
161249:4N→161309/0;161334:6E→161345/0;161406:5S→161416/0;
161442:3NE kontaktus. Mind0,50s, friss végpontképpel. Az előző kijárat fordítottja
nem volt automatikusan pontos: külön nyugati kerítéskorrekció és NEkontaktus kellett.

161504-play/0: saját3090, ellenfél3,08K, mégis0felismert piros csík.
A12×8pixeles,78piros pixeles csíkmaradékot a minimum16px/2,5arány kiszűrte.
10képen friss2320HP-t a régi pixeles teljescsík-őr100%-nak írta felül.
A visszavonulás délre a falba ment.161600/0képen37,6HP és1,55Kőr;
161638-nudge/0már zöld újjáéledő körben5860HP, majd161659/0Island1.
Halálátmenet nem lett lefotózva, de a kritikus harc→spawn erős vereségbizonyíték.
Nem állítjuk, hogy a DOCáltalában legyőzhetetlen: most felismerési/menekülési
hibák és az új kétpiercinges build hatása keveredett. Új próba előbb javítás után.

## Három kis javítás

1. Közeli kis piros csíkmaradék megtartása csak erős sötét vízszintes kerettel.
2. Friss elfogadott numerikus HP-t nem írhat felül teljesnek látszó pixelcsík.
3.400px-en belüli biztos safeTarget,legfeljebb800HP és sajátmaximum/3
   megelőzi az Island2-visszakereső makrót; a meglévő harci követő végzi az aratást.

Célzott regresszió:161504/0közeli fenyegetés,161504/10nem100%HP,
161659/0közeli67HP-s cél nem szigetmakró. Élő mérce: rövid körben tényleges
közeli ölés/jutalom, nem csak más irányú mozgás.

## Első mérhető gyors kör

162223-replay: a közeli csíkmaradék már1fenyegetés; HP-ja még hibás80a3,08K
helyett, tehát az OCRhelyesbítés nyitott, nem késznek nyilvánított DOC-felismerés.
162224-replay:2320HP→40%, nem100%; a67HP-s fa felé fordul, nem szigetmakró.

`162240-32041d4b-play`:0–3a67HP-s fa,3képen új4perces kör.4–7a192HP-s
fegyverhordozó,7képen **Steel Splitter23,264→276**,19m59s kör. Az első
10másodpercben két igazolt ölés.37képen **Savage Fang19,144→152**, új19m58s;
saját5860, nincs felszereléscsere. Ez fegyverfejlődés, nem automatikus DPS-növekedés.

38képen zöld Island1hajózsebben tévesVenom-minimaptámpont keletkezett.
Új biome-kapu: narancslefedettség<0,40esetén nincs DustyGulch-minimappozíció.
42képen234px-es174HP-s fa mellett egy másik, korábbi13Smakró még elvitte.
A közeli cél elsőbbségét ezért mindhárom régi visszatérő makróra kiterjesztettük,
400px-es határral. Ez a makrót szünetelteti, nem fogyasztja a lépéseit.
Következő célzott teszt:174HP-s fa kiválasztása és Island1hamis minimap kizárása.

`tests/quick-farm-regression.sh`: mind az öt eset sikeres; releasebuild sikeres.
Új75s élő kör:`162738-7547e4ca-play`,0képen175px-es közeli6HP-s célhoz
fordul, nem szigetmakrót indít. A teljes regresszió e javításcsoport után még
függőben; a következő felügyeleti kör leállított live mellett futtassa, ne
minden új mozgásszakasz előtt. A DOC3,08K→80OCR továbbra ismert korlát.

Második élő kör eredménye:162738/3új3m55s a learatott kis fánál;11képen
a291HP-s fa fehér szétesése és516sebzés.0–11összesen16s. A célok pontos
statnövekedését nem számszerűsítjük panelmérés nélkül.52képen márIsland2
északi házzsebe,5860HP; a távoli1,16K feliratot16K-nak olvassa, ez új
OCRkorlát. A háznál újabb általánosNWkeresési hurok kezdődött, ezért lejárt
75s után nincs változatlan újraindítás. Következő képi tervezés innen induljon,
ne a DOCpróbát ismételje. A helyi aratás javult, a globális útvonal még nem kész.
