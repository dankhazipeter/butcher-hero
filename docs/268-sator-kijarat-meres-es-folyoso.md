# A sátor kijárata: képi mérés és folyosó — 2026-09-19

## Sikeres képi bejárás

200602-28d827f3-observe/0: saját7060, a sátor keleti/palánk melletti zsebében.
200654 és200739: kétszer2×0,40sE;200742/0már nyílt keleti fű.
200829:3×0,40sS;200834/0a sziklasziget északi oldala.
200946:3×0,40sSW;200950/0szabad déli udvar,1,22Kőr balra. Ezzel
**felügyelői bejárással kijutottunk**; ez nem automatikus teljes útvonalsiker.
HP7060, felszerelésBat13/Venom18; új jutalom e bejárás közben nincs.

## Miért szakadt meg a korábbi képi útmérés?

Konkrét új adat:200602PNG **634×878**,200654/0 **637×882**. A régi
VisualOdometry minden méreteltérést azonnal elutasított, még a tényleges
pixel-összehasonlítás előtt. A két kép normalizálva154egyezőpontot,
**0elmozdulást/0hibát** ad. Ez megmagyarázza ezt a megszakadt mérési élt,
de nem állítjuk, hogy minden korábbi chartváltásnak ez volt az oka.

Javítás: legfeljebb1,2%szélesség/magasságeltérés és0,2százalékponton belüli
aránykülönbség megengedett a már létező közös318×440normalizálás előtt.
Nagy/aszimmetrikus ablakméretváltás továbbra érvénytelen. A pont-, hiba- és
geometriai ellenőrzések maradnak. +3/+4arányos raszterteszt és+40szélességi
negatívtesztPASS. A különbségből adódó kicsi koordinátabizonytalanság miatt
ez közelítő terepmérés, nem milliméterpontos globálistérkép.
`measure-route` elutasításkor már kiírja a mérethelytől független mérési adatokat is.

## Mért koordináták és két chart közti kalibráció

Origó200129/1,chart63,világ−180,671926/−76,519716. Minden köztesnudgePNG
ésobservekép egymáshoz mérve: a mozgó párokon74–128egyezőpont,hibák2,34–3,43.
Útpontok és adatok: `camp-tent-south-route.json`.

- zsebkezdet200602: világ−169,026231/−47,693488;
- keleti sarok200742:45,215353/−48,337406;
- déli sarok200834:46,071977/154,494006;
- kijárat200950:−107,159795/249,928588.

201233-9f6cab6d-play/0ugyanazvégpont,139egyezőpont,0elmozdulás/hiba;
LocalWorldMapittchart47-etazonosít,világ−21,988984/−780,185942.
Így mért chart63→47eltolás+85,170811/−1030,114530. Nem tetszőleges
azonosikon vagy közeli koordináták alapján kapcsoltuk össze a két helyet.
A folyosó mindkét igazoltchart koordinátáiban szerepel, máschartban nem aktiválódik.

## Programbeli folyosó

V2 `goalBounds`: csak a bejárattól nyugatra fekvő célhoz aktiválható a kerülő;
egy új keleti világcél az aktívfolyosót is feloldja. Indulási terület külön
korlátozott; a végponton kívül már ne térjen vissza a sátorhoz.
E→S→SWképi pontok,0,8térképi egységnyi érkezési sugár, a végső rövid
mozdulatoknál0,12sminimum: ne vágja le44px-ről a szűk sarkot.
Továbbra csak megfigyelt előreirány, a fordítottút nincs automatikusan engedélyezve.
Két eredménytelenfolyosóinput továbbra5perceshűtést és újratervezést jelent.

V2tesztek: nyugati célhoz előbbE, keletihez nemfolyosó, aktívnyugati célról
keletireváltás törli, mindkétchart azonos fizikaiirányt ad; régi útvonaltesztekPASS.
LocalMap/raszter/checkpointtesztek ésreleasebuildPASS. A teljes autonóm folyosó-
bejárást még nem igazoltuk. A déli végpontból további rövid játék következik.

## Élő fejlődés és kapuig jutás — 20:18

201830-7ee43267-play/0–2: önálló1220őrharc,2 **Savage Fang22,
168→176damage,20m0s**. FelszerelveBat13/Venom18marad.6friss7060sajátHP.
4–12: folyamatos nyugatiA*haladás, a korábbi sátorhurkot elhagyta.
12képen **Dusty Gulch – 2** kapu, narancs/zöldhatár, saját7,06K.
Ez új stratégiai helyzet, nem puszta mozgásszám: elértük azIsland2átjárót.
A teljes belépést a következőfrissképnek kell igazolnia; a kapuszélen ne
állítsunk már biztos Island2belsőpozíciót. Jelenlegi képichart62, V2poz
−32,81975/3,07742, cél−50,34131/−1,04509; akadályél119nem nőtt ezen a szakaszon.
Ez a déliudvarból autonóm nyugati megközelítés sikere, nem a most importált
E/S/SWfolyosó egészének automatikus bejárása. Következő20sátjáróellenőrzés.

## Island2-belépés igazolva — 20:21

202055-150b4715-play/0–3 átjutás a kapun.3képen már a narancsudvarban,
barna ház és fehérponyvásszekér mellett, a kapu mögöttünk/jobb oldalt;
saját7,06K. **Island2/DustyGulch belsőpozíció képpel igazolt.**
4–12a nyugati magas sziklafalat nem járja át; északi kerülés a ház és
szikla közötti zsebbe vitt.12: saját7060,chart62világ−1122,551/−90,253,
V2−50,5148/−4,0614, élőnarancsfej−14,60/−0,083minimapeltolás.
A közelitérképi fej nem igazol azonos magassági réteget vagy közvetlen támadási utat.
Nincs új harc/győzelem ezen a20smeneten. A következő friss kezdőképből előbb
a házzsebből a déli nyílt udvar felé kell kijutni, majd a szikla járható
megkerülését/rampáját megkeresni. VáltozatlanW/Nfalnyomás ne folytatódjon.
A zöldIsland1sátorhoz vagyDeepMineskapuhoz ne forduljunk vissza céltalanul.
