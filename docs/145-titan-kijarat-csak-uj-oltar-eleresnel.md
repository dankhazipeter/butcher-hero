# Titan-kijárat csak új oltárelérésnél

## Az újratöltési hiba

A `20260829-125921-play` első 28 kijárati swipe-ja helyesen lezárult az 58. eseményen,
és az 59. esemény visszatért a szabad 0/7 gemkereséshez. A 72–75. eseményen azonban
a karakter még egyszer a feladatbuborék látótávolságába került. A 28-as keret ekkor
már nulla volt, ezért a korábbi feltétel újratöltötte, noha a 600 döntéses oltárhűtés
folyamatosan aktív maradt.

Ez egyetlen oltárlátogatáson belül második, fölösleges kijárati menetet okozott. A
78–117. eseményben a bot az új keretet használta el, köztes akadálykerülésekkel.

## Javított él

A kijárati keret most kizárólag a Titan-oltár állapotának `nincs hűtés → 600 döntéses
hűtés` átmenetén töltődik 28-ra. Aktív hűtés közben:

- a feladatmondat és a `0/7` továbbra is biztos HUD-/HP-takarásjel;
- a hűtés frissülhet 600-ra;
- a kijárati keret nem tölthető újra;
- az ismét felvillanó lila ikont a bot továbbra sem követi célként;
- a már lezárt kijárat után normál gemfelderítés fut.

## Célzott regresszió

A `20260829-130350-replay` egy biztos Titan-feladatképpel indult, 28 külön mozgó,
lila ikonos képen kimerítette a kijárati keretet, majd újra beadta a `0/7` buborékot
és egy lila ikonos képet. Az utolsó két döntés mindkettőn normál `Titan 0/7 gemkeresés`
maradt; új ellenirányú kijárat nem indult.

Az új release build élő futása `20260829-130403-play`. Ez a változat megtartja az
egyszeri fizikai eltávolodást, de ugyanazon oltárhűtési ciklus alatt nem enged újabb
28-as menetet.
