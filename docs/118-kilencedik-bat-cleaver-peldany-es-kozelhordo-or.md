# Kilencedik Bat Cleaver-példány és közelhordozó-őr

## Élő esemény

Az `084349-play/frame-00196.png` képen a karakter egy teljes 499 HP-s humanoid mellett
áll. A HP-csík bal felső részén külön élénkzöld, fegyverkártyaszerű statikon látható.
A bot korábbi kockázati szabálya nem választotta célként, de a közeli automata támadás
így is befejezte.

A `frame-00198.png` közvetlen jutalomképe:

- zöld Bat Cleaver kártya;
- `LEVEL UP`;
- példányszám `9` (előtte az alsó sorban `8`);
- `Damage 400 > 450`;
- `29m 59s` újratermelődési idő;
- a játékos HP-ja változatlanul 778.

Ez megismétli a korábbi 499 HP-s hordozó bizonyítékát: minden ilyen ölés egy Bat
Cleaver-példányt és pontosan +50 fegyversebzést ad. Nyolc példánynál a fegyver 400,
kilencnél 450 sebzést ad.

## Felismerés

A kék fejsze- és piros szívikon detektora a zöld kártyaikont nem látta, mert az ikon
a csík közepétől balra helyezkedik el. Új, szűk régió méri a csík `minX−4…minX+22`,
`minY−28…minY−5` területén az élénk, telített zöld pixeleket.

## Biztonsági korlát

A cél távolról gyakran a tábor kerítése mögött látszik. Emiatt a jel nem általános
üldözési felmentés. Csak akkor lesz biztonságos farmcél, ha egyszerre teljesül:

- a tanult max-HP legalább 600;
- a cél legfeljebb 150 pixelre van;
- nincs 150 pixeles körben más ellenséges társ;
- a csík teljes, 45–65 pixel széles;
- az élénkzöld ikonbizonyíték eléri a mért küszöböt.

A normál képszél-, boss-, klaszter- és HP-arányőrök ezután is előtte futnak.

## Visszajátszás

A `085353-replay` a kritikus `frame-00196` képen 99 pixeles, ismeretlen HP-jú célként
helyesen kiválasztotta és tovább közelítette a hordozót. Ugyanebben a visszajátszásban
a 281–349 pixeles, kerítés-túloldali 499-es képek egyikét sem választotta célként.

## Következő mérés

A kilencpéldányos Bat Cleaver elméleti nyers normál találata a korábban bizonyított
33-as alapstáttal `33 + 450 = 483`. A következő teljes HP-s, védelem nélküli célon a
lebegő találati számot és a cél HP-csökkenését kell összevetni ezzel.

## Következő állapot — teljesítve

A `104751-play/frame-00867` közvetlenül igazolta a tizedik példányt és a
`Damage 450 > 500` lépcsőt. A korábbi 483-as becslés már történeti, mert közben az
alap támadóstatot adó jutalmak és a második aktív fegyver is változhattak. Az új
összetevőket inventory-Stats audittal és boss-HP csökkenéssel kell szétválasztani;
részletek a 132. fejezetben.
