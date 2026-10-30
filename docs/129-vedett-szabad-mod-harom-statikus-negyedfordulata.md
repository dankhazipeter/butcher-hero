# Védett szabad mód: három statikus swipe utáni negyedfordulat

## Élő anomália — `20260829-102651-play`

Az Unstuck utáni 120 döntéses védett szabad felderítés a 217. eseménynél indult.
A mód helyesen nem engedte, hogy a régi minimapjel vagy a teljes statikus faljárás
azonnal visszavigye a karaktert a zárútba. A növekvő négyzetspirál nagyobb területet
járt be: a medencétől a lila sziklafalig, az útig, majd az őrtorony és a tábor
környezetéig jutott.

A `frame-00300`, `frame-00360` és `frame-00395` azonban megmutatta a korlátját. A
spirál egyre hosszabb oldalai közül az egyik ismét a sátor–kerítés zsebébe vitte a
karaktert. Mivel a védett mód szándékosan kizárta a teljes statikus kiszabadítót,
a bot a hosszú spirálszár hátralevő mozdulatait ugyanannak a falnak adta. A 449.
eseménynél, közvetlenül a védett mód lejárta után már hat változatlan háttérkép
bizonyította az újabb elakadást.

Következtetés: a védett mód elsőbbsége helyes, de a primitív végrehajtója nem lehet
vak a statikus háttérre. A teljes faljárás visszakapcsolása helyett könnyebb,
helyi korrekció kell.

## Döntés

Aktív `protectedFreeExploreFrames` alatt (a történeti kódban:
`island4DroughtFreeExploreFrames`):

1. farmcél, quest-sín vagy világ-láda továbbra is azonnal megszakítja a módot;
2. három egymást követő, végrehajtott swipe után változatlan háttér esetén a bot
   90 fokkal a következő égtájra fordul;
3. az új oldal hossza 4–12 swipe között marad, nem örökli vakon a már 20–48
   lépésesre nőtt spirálszár hátralevő részét;
4. a védett mód és annak hátralévő ideje megmarad, tehát a régi minimap- és
   statikusútvonal-memória nem veheti át újra a vezérlést.

Ez az őr az Unstuck utáni 120-as, a drought utáni 40/80-as és a zöld landmarkot
helyettesítő 160-as szabad módra egyaránt érvényes.

## Regresszió

A `20260829-103816-replay` 260 azonos sátor–kerítés képen futott. Miután a döntő
elérte a védett szabad módot, a 224., 227., 230., 233. és további döntéseken minden
harmadik statikus swipe után sorrendben le, jobb, fel, bal irányba fordult. A napló
külön `negyedfordulatos oldalkitérés` okot adott.

Ez igazolja, hogy változatlan képnél nincs több hosszú falnak húzás. Az élő fizikai
hatást a `20260829-103900-play` felügyelete méri tovább.

## Élő igazolás

A `103900-play` 273. eseménye valódi statikus szakasz után jobbra fordult. A kamera
ezután továbbmozdult, és a 299. eseménynél megtalálta a 499 HP-s Bat Cleaver-
hordozót. A negyedfordulat tehát élőben is megszakította a falnak húzást, és közvetlen
hasznos farmcélhoz vezetett.
