# Tartós akadálytérkép, befejezendő kaktuszfarm és magaslati ládazóna

## Miért maradt félbe a 11,4K-s kaktusz

A `20260829-165856-play` élő futása egyértelmű hibát tárt fel. A passzív,
300-szíves kaktusz HP-ja 11,4K-ról 11,1K-ra, 10,1K-ra, 9,68K-ra, majd 2,44K-ra
és 1,57K-ra csökkent. A játékos HP-ja közben 953 maradt. A cél tehát nyerhető és
nagy hozamú, de a 48 képes takarási memória pontosan a befejezés előtt lejárt.
A bot elmozdult, a növény pedig később 10,1K-ra regenerálódott.

Javítás:

- a közeli, már igazolt 8K+ passzív szívkaktusz csíktakarási őre 120 képre nőtt;
- helyben tartott kaktuszharc közben a statikus háttér nem gyűjt elakadási pontot;
- az egymásra rajzolt karakter, fegyvereffektus és célcsík egyszer 14%-os hamis
  saját HP-t adott. Nagy passzív kaktusz kontaktusában egy kizárólag pixeles esés
  nem szakítja meg a harcot; friss numerikus HP-esés továbbra is azonnali veszély;
- a passzív nagy cél kontrollált időkerete 90-ről 180 döntésre nőtt.

## Piros minimapcél stabilizálása

Több közeli piros pontnál a legközelebbi pont képenként a játékos két oldalára
ugrott. A régi döntő emiatt majdnem pontosan észak és dél között váltogatott,
tehát sok input mellett sem haladt. Az új szabály a közel ellentétes piros
irányváltást csak három egymást követő, egymással egyező képen fogadja el. Egy
valódi célon való áthaladás továbbra is gyorsan, három mérés után átfordítja az
irányt.

## A tartós topologikus akadálytérkép

A pálya akadályai fixek, de egy abszolút koordináta könnyen elcsúszna kamera,
teleport és kézi mozgás után. Ezért a bot helyi, képi topologikus térképet épít:

- a HUD-ot és a karaktert kerülő háttéraláírás azonosít egy helyi csomópontot;
- csomópontonként nyolc irányban számlálja a végrehajtott, sikeres és blokkolt
  swipe-okat;
- ugyanazon irány két bizonyított blokkolása után legfeljebb 90 fokos, jobb
  pontszámú oldalirányt választ;
- a választott kerülőt nyolc swipe-ig tartja, hogy a minimap ne fordítsa vissza;
- négy blokk és nulla siker után az irány tartós zsákutca, amelyet csak későbbi
  bizonyított siker oldhat fel;
- a sikeres irány csökkenti a későbbi blokkolási büntetést;
- legfeljebb 400 helyi csomópont marad meg, a legrégebbi cserélődik;
- a tudás a `docs/world-map.json` fájlba kerül, ezért fejlesztési újraindítás után
  sem vész el;
- emberi aktivitás alatt nem tanul a kimaradt vagy kézzel megváltoztatott
  mozgásból.

A `20260829-170847-play` futásban a rendszer már élőben is többször a
`Tartós akadálytérkép` döntést adta, amikor a korábbi irány ugyanazon képi helyen
ismét statikus maradt.

## Magaslati egyszeri ládazóna

A narancssziklás magaslat különleges, egyszer megszerezhető ládákat tartalmaz.
Nem sík, szabad terület: keskeny hidak, párkányok és sziklafalak szabják meg a
járható gráfot. A ládák összeszedése után nincs ismételhető farmértéke, ezért a
helyet később „felderített egyszeri helyszínként” kell kezelni, nem visszatérő
landmarkként.

A közelben egy 25-ös statikonú, 18,8K HP-s páncélos is mozog. Egy élő kontaktus
984-ről 94 HP-ra vitte a karaktert, majd automatikus újraéledés következett. A
magaslat geometriája közben több közvetlen és két oldali megközelítést blokkolt;
ez egyszerre veszély- és útvonalprobléma, nem gyors farm.

A felhasználó kérésére kézzel végrehajtott Unstuck bizonyítottan áthelyezte a
karaktert a zöld gyógyítómedencéhez. Az új kép 984/984 HP-t mutatott. A tartós
állapot maximuma ezért most **984 HP**.

## Megvalósított szemantikus térképréteg

A geometriai akadálytérkép mellett a helyek ládaállapota is megmarad:
`ismeretlen → láda látható → láda begyűjtve → egyszeri irány lezárva`. A láda
irányát követő `OPEN`, `TAP TO CLAIM`, `CONTINUE` vagy közeli jutalom igazolja a
begyűjtést. Friss céljel nélkül a lezárt hely oldalirányú, nyolclépéses eltávolodást
vált ki. A részletes állapotgép, a tartós 18,8K-s vereségsáv és az Unstuck időzár
tanulsága: `171-egyszeri-ladamemoria-veresegsav-es-unstuck-idozar.md`.
