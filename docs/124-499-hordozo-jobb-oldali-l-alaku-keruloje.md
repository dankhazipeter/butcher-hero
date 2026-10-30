# A 499 HP-s hordozó kerítéskerülője: jobb oldali próba, bal L-út

## Élő megfigyelés

A `094545-play` futásban a javított felismerő a Bat Cleaver-hordozót már helyesen
követte: a 162–180. esemény között a cél `499 HP` maradt, a távolság pedig
`233→182` pixelre csökkent. A korábbi `499→199` csonkolási hiba nem indított
bossmenekülést.

A `frame-00180.png` képen a helyzet egyértelmű:

- a hordozó a vízszintes tábori kerítés fölött áll;
- a játékos közvetlenül a kerítés alatt van;
- a cél felé mutató egyenes swipe ezért 182 pixelen platózik;
- a képen balra és jobbra is a kerítés mentén kell előbb oldalirányban haladni.

Az általános első kerülő balra indult. Nyolc végrehajtott swipe után a
`frame-00198.png` már a kerítés bal alsó sarkát mutatta, tehát az oldaljárás
tényleges kameramozgást és sarokelérést adott. A cél azonban kicsúszott a képből,
ezért a bot a minimapra váltott. A `frame-00234.png`-nél ez az út egy `1.22K HP`-s
fegyveres őrhöz vitt 316 pixelen belülre, mire a helyes bossőr menekülést indított.

## Első döntés és élő cáfolat

A `095752-play` 64–126. élő eseménye megcáfolta az első jobb oldali hipotézist.
A bot 263→185 pixelre közelített, majd a 79. eseménytől tizenkét jobbra swipe-ot
adott. A `frame-00102`, `frame-00108`, `frame-00120` és `frame-00126` képeken a
játékos, a kerítés, a torony és a hordó ugyanazon a helyen maradt. A cél 185–228
pixeles ingadozása csak a hordozó saját járőrözése volt, nem játékosmozgás. A jobb
oldalt a torony–hordó sarok teljesen lezárja.

Az első jobb oldali L-terv ezért elvetve. A javított döntés:

1. a bot a célirány képernyő szerinti bal oldali merőlegesére fordul;
2. tizenkét tényleges swipe-ig tartja ezt az irányt, hogy túlhaladjon a kerítés
   sarkán;
3. ezután a cél láthatóságától függetlenül tizenkét swipe-ig megtartja a korábbi
   célirányt, és befordul a tábor belseje felé;
4. látható boss, friss sebzés vagy visszavonulási szükség minden ponton korábban
   fut, tehát megszakíthatja a kerülőt.

Az útvonal hordozóspecifikus. Más céloknál megmarad a nyolclépéses, oldalváltó
általános akadálykövetés.

## Regressziós bizonyíték

A `100409-replay` strukturált naplója a problémás képsoron az alábbi döntést adta:

- 12–23: tizenkét `(-0.99, -0.14)` bal oldali akadálykövető swipe;
- 24–35: tizenkét `(0.14, -0.99)` kötelező beforduló swipe a hordozó utolsó irányába;
- a jutalomhiányos Island 4-ág csak ezután kaphatott vezérlést;
- a 499-es cél mindvégig farmcél maradt, bossmenekülés nem indult.

A replay a döntési prioritást igazolta. A `101003-play` később élőben is bizonyította,
hogy a tizenkét bal swipe eléri a kerítés végét, a tizenkét felfelé swipe pedig
végigmegy annak külső oldalán. A puszta L-alak azonban a Deep Mines őreihez vezetett,
ezért harmadik, jobbra visszatérő szakasz került a döntőbe. A képi bizonyítékot és az
új U-alakú munkahipotézist a [127. fejezet](127-499-hordozo-elo-bal-fel-es-u-kerulo.md)
rögzíti.

A következő élő próba az 1.22K-s őr miatt ezt 8–3–8-as kompakt U-ra rövidítette,
majd a `104751-play` azt is megcáfolta: három északi lépés után a visszatérés még
a függőleges palánknak ment. Lásd a [130. fejezetet](130-499-hordozo-122k-or-es-kompakt-u-ut.md)
és a jelenlegi [131. fejezetet](131-499-hordozo-8-3-8-cafolat-es-orfolyoso.md).
