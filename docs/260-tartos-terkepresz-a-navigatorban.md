# A képi térképrész és a navigátor összekötése — 2026-09-19

## Biztos hiba

184143-play/0: LocalWorldMap **chart51,1176,68/251,03**, „keyframe + minimap
+ verified motion relocalized”. A navigátor ugyanitt „localization unavailable”,
1képen új `local-BCAF...` és0/0. A már meglévő képi visszaazonosítást nem
használta; újraindulásonként különUUID-térbe kerültek a falak/látogatások.
A tartós JSON önmagában nem jelentett újrafelhasználható térképet.

A259-es felső végpont után a bot új déli29HPcélhoz visszament, majd ismét
szikla mellett került22képen. Új ölés lehetséges/ellenőrizendő8képen, de
az északi átjáró autonóm hasznosítása **nem sikerült**. Nem ismételjük változatlanul.

## Javítás

A NavigationV2 most a LocalWorldMap validált chartazonosítóját és pozícióját
is megkapja. Minimap-landmark hiányában `terrain-chart-N` térben tervez,
rögzített0,045képpixel→rácstér léptékkel. Ugyanazon visszaazonosított chart
ugyanazokat a faléleket és látogatásokat kapja a következő futásban is.
A LocalWorldMap továbbra terepkép+minimap/ellenőrzött optikai áramlás alapján
azonosít; aV2 nem lazítja ezeket a kapukat, nem olvaszt össze külön chartokat.

Ugyanazon chart,3pixelen belüli pozíció és egyező terepkép esetén a kerülés
is folytatható. Chartváltáskor a cél/kerülés/pending input törlődik; régi
véletlenUUIDtérképeket nem importálunk találomra.18rácspixel feletti ugrás
nem taníthat akadályt. Atlaszmódban visszavillanó narancslandmark nem okoz
oda-vissza chartváltást. Az eleve megbízható narancstámpontos indulás és
annak régi mért kapuútjai továbbra működnek; külön koordinátaterek maradnak.

Ez az újratanulás hibáját javítja, nem bizonyít jó globális útvonalat vagy
korlátlanul pontos képi helymeghatározást. A259-es külön auditút importja
még nincs kész: nem kötjük be ismeretlen globális koordinátára.

## Tesztek

Újraindításkor azonos51-es chart+képi egyezés visszaállítja a falmenti
elköteleződést;52-es chart azonos számpozíció mellett sem örökli a célt.
Időszakos narancslandmark nem dobja el az atlaszt. A korábbi vastag/szűk
faltesztek, input nélküli tanulási tilalom és HP-próba-folytonosság is futnak.

Release build és a teljes célzottV2egységtesztPASS. Vastag fal39/37input,
szűk kapu18input; új atlasz-újraindítás/chartváltás/landmarkstabilitásPASS.
Quick-farm ésHP-takarás replayPASS.184143/8képi ellenőrzés:29HPfa516találattal
elpusztult,7h18m körre váltott. Ez nem végtelen4perces cél; ne húzzon vissza.

184555-play/0már **terrain-chart-51**,50,02/38,62, nincs kezdő elveszett
pozíciós várás.11ugyanaz a tér,43,21/30,38,2új akadályél, falmenti kerülés.
A szikla még akadály, önálló kijutás nincs. Rövid újraindítás következik,
hogy az azonos tér és kerülőfolytatás élőben is ellenőrizhető legyen.

184704-faa95f44-play/0: **ugyanazterrain-chart-51,43,21/30,38**,89akadályél,
4,11px falmenti haladás; azonnalwall-follow. Ez az újraindításos folytonosság
élő bizonyítéka, nem újUUIDés nem elsőképes pozícióhiány.10képen még mindig
szikla keleti oldala,46,16/36,92 (LocalWorldMap1025,73/820,46),6,51K.
Önálló átjutás/új jutalom nem történt. Nem futtatjuk változatlanul hosszú ideig.

Következő konkrét fejlesztés: a259-es ösvényút bekötése az51-es chartba,
keleti megközelítéssel, nem közvetlen átlóval a sziklán át. A felső végpont
184143/0aLocalWorldMap szerint1176,68/251,03; a259-es audittal való képi
azonosság külön ellenőrizendő. Ez lehet kalibrációs horgony, de még nem import.
A kezdőpont/megközelítés, irányítottság és aktuális térképtér mind ellenőrzendő.
