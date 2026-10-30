# Térképi célkatalógus és fejlődési sorrend — 2026-09-19

## Felhasználói mechanikai közlés

A felhasználó megerősítette: a **piros fejjel jelölt ellenfelek a legnehezebbek,
legyőzésük nyitja az új pályákat**. Ez felhasználótól származó szabály,
nem új élő bossgyőzelemből kikövetkeztetett adat. Nem vonatkoztatjuk minden
kis piros minimappöttyre: a piros fej külön ikonosztály.

Kék/türkiz nyilas és zöld fegyverikonokat is célként kell figyelni.
Az ikon fegyverjutalmat/őrt jelezhet; önmagában nem bizonyít harci erőt vagy
járható utat. Narancsfejek külön gólemek: keleti4310/500szív legyőzve,
nyugati18800legutóbb7060maximumon vesztes. Nem globális narancsfejtilalom.

## Friss nagy térkép

205539-4953ef18-observe/0: nyugati narancs területen aktív türkiznyíl,
délre sárgászöld fegyverikon; keleten aktív limezöld fegyverikon. Két
narancsfej közül keleti fakó, nyugati élénk; északnyugaton piros fej.
Északkeletre ragyogó aranyikon a ködben; jelentése még ismeretlen.
Lila jel és szürke ikonok külön kategóriák; nem automatikus harcicél.
A körbejárható utak és az egyes ikonok pontos őrazonossága még nem mind igazolt.

## Megvalósítási döntés

A normál navigáció eddig világcél/pirospont után narancsfejet követett,
a színes fegyverikonok nem kaptak önálló prioritási csatornát. Ez konkrét
oka annak, hogy aktív őrök mellett is a gólemhez térhetett vissza.
Új cél: minden friss színes fegyverjel felvétele, külön céllista, következetes
kiválasztás és elakadás/hűtés nyilvántartása. Pirosboss külön progressziócél,
nem véletlen farm. Szürke/kimerült jel ne vonzza a botot.

## Implementáció és ellenőrzés

`MapObjectiveDetector`: külön szín+alak sablon türkiznyílra,zöldfegyverre,
narancsfejre,pirosfejre; normál és nagy térképen.205539/0négy osztály,
szürke keleti fej/szürke fegyverek kizárva. A sárgás harmadik fegyverjel
pontos osztálya még nincs igazolva, nem állítunk teljes ikonlefedettséget.
`MapObjectivePlanner` és `map-objectives.json`: minden észlelt cél osztálya,
terepcharton belüli becsült helye, utolsó észlelés, aktuális cél és útkarantén.
A fegyverőrök közül legközelebbi, majd céltartás; világcél/kispirosfarm
továbbra elsőbbséget kap. A vak narancsfej-visszatérés megszűnt: nagyfej
nem automatikus tartalékcél. Ez nem harci tiltás a külön igazolt4310-asra.
12végrehajtott, tényleges helyváltozás nélküli próbánál3percútkarantén;
kihagyott input nem számít, valós kerülőn növekvő céltávolság nem elakadás.
Térképikon nem egyedi globálisazonosító; eltérő chartokat nem egyesítünk.
Nagy térképi panpozíciót nem használunk játékos-világkoordinátának.

`map-pan`: csak képpel igazolt nagy térképen, belső kezdőpontból, fókusz-
visszaadással húz.210443/0északi pan: köd és víz, további igazolt őr nem.
210520/0déli pan: köd, további igazolt őr nem. Nem állítjuk, hogy a teljes
világot felderítettük.210620/0bezárás igazolt, karakter a kapunál7060HP.

269mért déli kerülője a62-es chartba bekötve: csak a házzsebből, nyugati-
déli fegyvercél esetén aktiválható. Végpont203725/0a malom északnyugati
nyílt oldala; nem közvetlen bosskontaktus. A pontlánc előre bejárt, teljes
autonóm bejárás még nincs igazolva. Nem időzített makró.

Map-objective tesztPASS:négyosztály/szürke-kizárás/fegyverprioritás/
inputkihagyás/útkarantén/valós kerülő. Build,quickfarm,overlap,gólemfelismerés
PASS. V2külön teszt:cyan célhoz előbbS,ugyanonnan narancsbossra nemfolyosó.
Következő25sélőpróba ellenőrzi az új fegyvercélágat.

## Élő eredmény és korlát

210801-e549c711-play/0–16: **aktív weapon-cyan** a tényleges navigációs cél,
nem a közelebb látható narancsfej. Négy ikonosztály bekerült a tartós
`map-objectives.json` listába. A ház mellett nyugati falba ütközött, utána
déli falmenti kitérő,16a kőív előtt. Nincs új ölés. Ez célválasztási siker,
**nem működő teljes navigáció**: a felhasználó jogosan jelezte a falat.
Az aktuális chart66, ezért a62-re kötött régi mért folyosó nem aktiválódott.
202640/0→210801/16képmérés39egyezőpont,2,93hiba,+38,164/+28,168elmozdulás;
a chartkapcsolás még nincs implementálva. Vak másolás helyett további igazolás kell.

Felhasználói kézi útbemutató felajánlva. Játékinput nincs, heartbeatPAUSED.
Új önjárómenet ne induljon a bemutató alatt. A következőlépés kizárólag
passzív felvétel a felhasználó indulási jelzésére; nincs még útbemutató felvéve.
