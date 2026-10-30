# Bat13 build:1,43K→1,49K DPS — 2026-09-19

## Új győzelem és panelmérés

190843-71032638-play/26: a499HPőr legyőzve, **Bat Cleaver13,600→650**,
30m0s.27–30a helyén29m58s→29m54s. Saját6,54K. Előtte18–24közeli
fenyegetés-kapu miatt várakozás,25az őr107px-re közeledett,26jutalom.
A várakozás részben fölösleges lehet, de itt tényleges győzelem történt.

191006-c5f52fe9-observe/0előtte statpanel:
- DPS1,43K,HP6,54K,regen73,5;
- cutting164, piercing111+1,03K+1%; harmadik támadási típus0;
- mindhárom védelem0;
- Phantom Edge4+Venom Shard18felszerelés, Bat13/Steel26/Fang20tartalék.

191059-e1429b38-observe/0Batpanel: aktuális650damage,1,2s cooldown,
cutting,13példány. Zöld700 a következő példány előnézete, nem aktuális.
WOOD TRIBUTE zárva,EVOLVE13/130nem használva.

## Döntés és végrehajtás

Bat várhatóDPS `(164+650)/1,2≈678,3`; aPhantom4 korábban mért400damage,
0,84s és aktuális111piercing alapján `(111+400)×1,01/0,84≈614,4`.
A Venom18becslése `(111+630)×1,01/0,92≈813,5`, ezért nem azt cseréljük.
A teljes becslés1491,8, ami az1,49Kpanellel egyezik.

191145tapEQUIP→191146/0explicitSELECT SLOT TO EQUIP.191224tapelsőslot.
191225-39c975a6-observe/0utána: **DPS1,49K**,HP6,54Késregen73,5változatlan;
cut164+650,piercing111+630+1%. Felszerelve**Bat13+Venom18**;
Phantom4tartalék. Kijelzett nyereség körülbelül4,2%, költés/példányfogyás nélkül.
Ellenségtípusonkénti ölési időt ez nem helyettesíti; nagy bossok automatikus
újrapróbáját nem engedélyezi önmagában.

## Korábbi zöld+0,5jutalom pontosítása

A korábbi jegyzetek„pajzsjutalomnak”nevezték a kisőr zöld+0,5ikonját,
de konkrét védelmi növekedést nem mértünk. Most mindhárom védelem továbbra0,
míg a regen a korábbi68-ról73,5-re nőtt. **Hipotézis:** a zöld+0,5ikon
regenerációjutalom, nem védelem. Egyetlen őr előtte/utána statmérésével még
igazolandó; a korábbi„pajzs”megnevezés nem használható bizonyított mechanikaként.

## Következő stratégia

Az500szívfa várható19:16körüli újraéledése közel van. Friss timer/célkép
alapján ellenőrizzük, nem korlátlan farmként. +500kijelzettHP esetén mindkét
korábbi nagy boss20%-os újrapróba-heurisztikája átléphető lehet, de ez még
nem győzelemígéret vagy automatikus új próbajog. Külön dokumentált kísérlet kell.

## Élő buildellenőrzés — 19:14–19:15

191403/0inventorybezárva,500szívfa2m16s;191427/1ugyanott1m51s.
A179HPfa748piercingtalálattal elpusztul.18aDeep MinesNPCmelletti174HPfa
ugyanilyen748találat és **6h45m** hosszú hűtés.21–22friss **6,55K** sajátHP.
Bat13/Venom18aHUD-on megmaradt. Ez normál farmműködés bizonyítéka,
nem önmagában a4,2%DPS külön harci sebességmérése.

18–22a258-as `frontier-astar` először élőben is láthatóan aktiválódott:
elfogyott közeli cél után nem vár, hanem helyi felderítési célt követ.
22képen Deep MinesNPC-től nyugatra, a kék sátor/északi palánk közelében;
alul1,22Kőr részlete látszik, nincs új győzelem. V2chart54,−64,98/−58,41.
Következő nagyhozamú prioritás a most lejáró500szívfa friss visszakeresése
keletre a szélmalom mögött, nem kimerült kisfa ismétlése. A jelenlegi
nyugati kezdőpontból új képi visszamérés kell, régi vak keleti makró nincs.
