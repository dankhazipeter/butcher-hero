# Titan–Deep Mines gráfél és Steel 20

## Megfigyelt hiba

A Titan gyógyítómedencétől a régi zöldterületi visszatérő makró több
perc alatt sem találta Island 2-t. Nyugati, északi, déli és keleti szakaszai
valóban mozgatták a karaktert, de minden ciklus a kék hajótest és a ferde
fahíd ugyanazon konkáv zsebébe tért vissza. A minimap nyugati koponyavektora
célhelyes, topológiailag azonban nem járható ebből a helyállapotból.

## Kimért útvonal

Az Unstuck utáni Titan-kőkörtől a következő szakaszok reprodukálhatóan a
Deep Mines `anti-stone potion 0/1` kapujához vittek:

1. 12 észak az oltár felső oldalához;
2. 14 nyugat a hajó felső kapuoszlopához;
3. 10 kelet, amely kiszabadít a hajótest konkáv oldalából;
4. 18 észak a havas Deep Mines-kapuig.

A látszólagos nyugat–kelet visszalépés nem fölösleges: a két szakasz más
akadályoldalon halad, és ettől nyílik meg az északi sínkapu. A képernyőn a
türkiz sín, a havas talaj és a lila kristályos kapu egyszerre igazolta az érkezést.

## Programdöntés

A friss Titan 0/7 overlay külön, négyszakaszos állapotgépet indít. A köztes
minimapjel, keskeny narancssáv és helyi cél nem szakítja meg. A Deep Mines 0/1
buborék lezárja ezt az élt, majd a már bizonyított
`13 dél → 20 nyugat → 12 észak → 8 nyugat` Island 2-él veszi át.

## Fejlődés

A hajózsebben megjelenő 192 HP-s kis ellenfél automatikusan elesett. Ezt követően
a felszerelt Steel Splitter 19-ről 20-as szintre nőtt; a Bat Cleaver 11 és a
3,43K saját maximum változatlan maradt. A következő felszerelésauditnál a
DPS- és támadóérték-változást is rögzíteni kell.
