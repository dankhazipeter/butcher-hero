# A lila sziklazóna első felügyelt elérése

## Képi bizonyíték

A `081746-play/frame-00406` a korábbi zöld–vörös Island 4-kapuhuroktól eltérő
környezetet mutat:

- nagy, sötétlila sziklatömb és lila talaj a kép felső-jobb részén;
- a szikla mellett kis, csuklyás alak sárga arccal;
- a minimap jobb oldalán összefüggő lila zóna;
- a hős nyílt zöld sávban, teljes 768 HP-val;
- nincs látható HP-csíkos cél, jutalomablak vagy közvetlen sebzés.

Az állapotot a 361–405. döntések hosszú jutalomhiányos területelhagyása érte el. A
407. döntésnél a bot a visszahúzó minimapjel helyett növekvő szabad felderítésre
váltott. Ez az első közvetlen bizonyíték arra, hogy a zárfal körüli hurokból swipe-pal
is elérhető egy másik világzóna, nem kizárólag Unstuckkal.

## Munkahipotézis

A csuklyás alak lehet NPC, kapuőr vagy dekoráció. Amíg nincs HP-csík, interakciós
felirat vagy küldetésjel, nem koppintunk rá és nem minősítjük ellenfélnek. A lila zóna
értéke egyelőre az útvonal-diverzitás: távol van a csonkolt 1,927K kapuelittől, ezért
esélyt ad új farmcélok és tereppontok találására.

## Következő mérés

1. A szabad felderítés közben marad-e a lila zóna a minimapon, vagy ez csak keskeny
   határsáv?
2. Megjelenik-e biztonságos HP-csíkos cél, láda, quest-sín vagy interakciós felirat?
3. Milyen irányú swipe visz be ténylegesen a lila talajra, és melyik irány ütközik a
   sziklába?
4. Az első jutalom esetén az új maximum-/jutalomszekvencia helyesen lezárja-e a
   jutalomhiányos állapotot?

## Új eredmény: belső barlangzseb

A `100443-play/frame-00163.png` már nem csak a lila zóna szélét, hanem egy sín,
sziklafal és csontív közti belső barlangzsebet mutatott. Tizenegy statikus
kiszabadítási fázis sem mozdította el a karaktert. A biomfüggetlen, hatfázisú
Unstuck-javítást a [126. fejezet](126-lila-barlang-hatfazisu-biomefüggetlen-unstuck.md)
rögzíti.
