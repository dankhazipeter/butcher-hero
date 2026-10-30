# Havas fennsík és 3.06K-s fegyverhordozó-győzelem

## A piros minimapjel útvonala

A `20260829-150906-play` új release futásban a piros minimapjel a 79. döntéstől
elsőbbséget kapott. A Dusty Gulch narancssziklás részén át először egy havas fennsík
alatti peremhez vezetett. A 123. képen sok, egymásra fedő `1.16K` cél állt a sziklafal
túloldalán.

## Távoli csoport: két félrevezető jel

- A képenként kiválasztott legközelebbi csoporttag miatt a mért távolság 307–361 px
  között ugrált, miközben a karakter nem jutott át a falon.
- A fennsíki célokon 30 és 120 sebzések jelentek meg akkor is, amikor a karakter
  biztosan támadási távolságon kívül volt. Az `1.16K→1.13K→1.00K` ezért nem a bot
  sebzésének bizonyítéka.

A közelítés mostantól a teljes próba eddigi legjobb távolságához mér. Csak legalább
8 px-es új rekord nullázza a stagnálást. Három távoli, eredménytelen oldalláb után
a bot a direkt üldözést hűti és a fal mentén keres bejáratot.

## A járható út és a 3.06K-s ellenfél

A régi bináris végül déli irányban kijutott a szikla alól, majd a piros jel egy
kerítésekkel tagolt Dusty Gulch-udvarba vezette. A 234. képen két fontos cél látszott:

- egy 765 HP-s, 1-es szintű kaktusz;
- egy külön, 3.06K HP-s páncélos fegyverhordozó.

A bot a 3.06K-s ellenfelet 378 px-ről kezdte követni, a 240. képen 65 px-re zárt és
megkezdődött a tényleges automata harc. A 243. képen a hordozó csíkja már 1.72K-t
mutatott. A játékos hiteles numerikus sora `802→748→720→591→566`; a köztes 30–34%-os
pixeles értékeket a felek és overlayek takarása okozta. A 254. képre a játékos újra
802 HP-ra regenerált.

## Jutalom

A 247. képen zöld `LEVEL UP` kártya jelent meg:

- példányszám: `2`;
- `Damage 35→70`;
- új, zöld fegyverikon.

Az alsó felszerelt ikonok Bat Cleaver 10 + Steel Splitter 14 maradtak, tehát a jutalom
nem szerelte fel automatikusan az új fegyvert. A tárgy neve, típusa és cooldownja
még inventory-auditra vár. A hordozó helyén a 251. képen `29m 54s` cooldown látszott.

## Stratégiai következtetés

A 3.06K-s hordozó teljes HP-ról a jelenlegi 693 DPS builddel bizonyítottan nyerhető,
és új fegyverfejlődést ad. A saját veszteség 236 HP volt, amit a regen gyorsan
visszatöltött. A kb. harmincperces respawn miatt értékes, de nem rövid farmkör; az
inventory-audit után a fegyver DPS-e dönti el, hogy felülmúlja-e a Steel Splittert.
