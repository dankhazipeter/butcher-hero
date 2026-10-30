# Oldalsó küldetésbuborékok és magaslati helyállapot

## Két új, egyedi küldetésjel

A `185715-play` 143. képe a Deep Mines lila kőkapujánál bal oldali buborékban
mutatta a `Find a magic anti-stone potion in Deep Mines 0/1` feladatot. A
`190457-play` 152. képén a Titan-oltár szövege a jobb képszélre tolódott:
`Collect all gems to unleash Titan's ...`. A korábbi, csak középső és bal felső
OCR-területek ezeket nem fedték le, ezért a döntő nem tudta biztosan, hogy már
elérte a helyszínt.

A képelemző most külön bal és jobb oldali karakterközeli OCR-területet is olvas.
A `191141-replay` a Deep Mines-képen kizárólag a potion-feladatot, a
`191112-replay` a Titan-képen kizárólag a gemfeladatot jelölte igaznak. Ez két
független, visszajátszással ellenőrzött állapot, nem általános HUD-találat.

## Nem minden visszatérési pont azonos

Három helytípust külön kell kezelni:

1. A különleges világ-láda egyszeri. A `worldChestDirection` után megjelenő
   `TAP TO CLAIM`, `CONTINUE` vagy biztos jutalom végleg lezárja az adott képi
   csomópont adott irányát (`collectedChestDirections`).
2. A köríves időzárat mutató kaktusz vagy más farmpont újratermelődik. A timer
   a siker bizonyítéka és egyben a legkorábbi értelmes visszatérés feltétele.
3. A Titan-oltár és a Deep Mines-kapu küldetéshely. Elérésük hosszú navigációs
   hűtést indít, de nem végleges törlést: gem- vagy potion-progressz után újra
   értelmessé válhatnak.

A szemantikus térkép csak a már kifosztott láda pontos visszairányát kerüli el.
A magaslati biom többi, még ismeretlen csomópontja továbbra is felderítendő.

## A magaslat külön járható réteg

A magaslati helyen a képernyőn közelinek látszó cél nem feltétlenül érhető el
közvetlen swipe-pal. A járható felület keskeny párkányokból, hidakból és
rámpákból áll. Ha közelítés közben a háttér statikus, és az átfedő cél valamint
a játékos HP-ja sem változik, az nem harci vereség, hanem helyi szintkülönbség.

Ilyenkor a rendszer az adott topológiai csomópont közvetlen irányát lezárja,
falmenti bejáratot keres, majd a bizonyított irányok kimerülése után Unstuckkal
tér vissza a központi gyógyító medencéhez. A `190457-play` 307–338. döntése ezt
már teljesen automatikusan végrehajtotta: Settings, Unstuck, áthelyezés,
gyógyulás, majd helyi kijutás.

## Aktuális stratégiai következmény

- Kifosztott magaslati ládáért nincs visszaút.
- Ismeretlen magaslati ágat később továbbra is fel kell deríteni.
- A magassági rétegen belül csak bizonyított rámpa/híd vagy tanult sikerirány
  számít járható élnek.
- A Titan-oltárhoz gemprogressz, a Deep Mines-kapuhoz potionprogressz ad új
  visszatérési okot.
- Az Unstuck nem alapértelmezett utazás, hanem a lokális topológia többirányú,
  mérhető kimerítése utáni helyreállítás.

## Élő ellenőrzés és két új korrekció

A `191302-play` 247–278. szakaszában a bot követte a türkiz sínt, majd az 1,92K-s
havas célhoz két ellentétes oldalkerülőt végzett. Kontaktus nem történt, a `0/1`
potion-buborék ismét megjelent, ezért a döntő helyesen lezárta a kaput és délnek
távozott. Egy korábban indított peremcél-sín kerülő azonban a hűtés alatt még
nyers sínirányt olvasott. A kapuhűtés most ezt a memóriát és a kapu lila
minimapjelét is törli.

A `192249-play` 60–62. képein a karakter biztosan a kapu alatt, a havas célok a
felső rétegen álltak. Két távoli csíkot az OCR átmenetileg `2` és `20` HP-nak
olvasott, ezért a régi döntő még két swipe-ot tett feléjük. Most a látható
potion-feladat + aktív kapuhűtés minden távoli célbecslésnél erősebb, és azonnali
déli területelhagyást indít. A biztos `1/1` szöveg feloldja ezt a szabályt.

A `191302-play` 109. képén a 18,8K-s őr bal-fent, külön sziklarétegen állt, a
járható palló pedig a céloldal felé, de meredekebben felfelé vezetett. A próba
most már az első képtől tíz döntésig tartja ezt a rámpavektort. A
`192300-replay` 109–118. döntése igazolta, hogy a boss képről való eltűnése nem
szakítja meg idő előtt a pallóívet.

## Nyitott mérések

- A Titan-feladat számlálója mikor vált `0/7`-ről `1/7`-re, és mi ad gemet.
- A Deep Mines anti-stone potion vizuális alakja, forrása és a kapunyitás pontos
  visszajelzése.
- Hány különleges egyszeri láda van a magaslati hálózat további ágain.
- A topológiai csomópont-aláírás mennyire stabil napszak- és effektváltozáskor.
