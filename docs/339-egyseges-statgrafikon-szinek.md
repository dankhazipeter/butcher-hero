# Egységes típusszínek a statonkénti grafikonokon

2026-11-01. A felhasználó a Növekedés, statonként grafikonjain is az
összesített darabszámdiagram típusonként eltérő színeit kéri.

## Megoldás

A statkártya a meglévő `frequency-{kind}` palettaosztályt kapja. Pontosan
ugyanaz a CSS-színforrás, mint az összesített görbénél és jelmagyarázatnál,
nem egy másolt paletta. A statgörbe stroke-ja, a végpont fill-je és az
alatta lévő terület fill-je a `--series-color` változóból jön. A kitöltés
12%átlátszatlanságú, így visszafogott marad. Hiányzó új típusszínnél a
meglévő chartfallback elérhető; a jelenlegi nyolc típus mind saját színű.

A meglévő világos és sötét témás paletták változatlanok: Health piros,
Regen zöld, PierceDamage cián, CutDefense narancsbarna, CutDamage arany,
SmashDefense rózsaszín, SmashDamage lila, PierceDefense kék. A tengelyek,
értékek és feliratok neutrálisak maradnak. A közös jelmagyarázat elrejtő
gombja továbbra csak a közös darabszámgörbét kapcsolja, nem a statkártyát.

## Ellenőrzés

2új Node-regresszió: valódi app.js DOM nyolc ténylegesen kirajzolt spark-
görbével és a közös diagrammal; azonos palettaosztály a kártya/legenda/
görbe hármasban, pont/terület/vonal megmarad, számérték változatlan,
legendaelrejtés nem tünteti el a statgörbét. A tesztharness új opt-in
statWidth-ja lehetővé teszi az SVG kirajzolását; a régi tesztek alapértéke
változatlan. Második teszt a közös CSS-változó vonal-/pont-/területhasználatát,
12%kitöltést és típusonként egyetlen sötét+világos palettadefiníciót ellenőriz.
Teljes kapu223teszt+7JS-szintaxis sikeres.

Élő, saját rejtett IAB-lapon a24órás nézetben mind a nyolc tényleges SVG
computed style-ját összevetettük: minden statvonal/végpont/kitöltés RGB
pontosan megegyezett a közös megfelelő görbével; fillOpacity0.12. Világos
témában vizuálisan is ellenőrzött. A sötét paletta közös öröklését a CSS-
regresszió védi; az operációs rendszer témáját nem változtattuk meg.
Helyi PNG-proof `.build/ui-proof/339-stat-colours.png`, nem Gitadat.
Saját tesztlap bezárva, userlapon egyszeri reload kell.

Nincs gyűjtő/backend/releaseváltozás, saját restart vagy sessionreset,
napló- vagy összegmódosítás. A gyűjtő a teszt- és Git-kapuk alatt futva marad.
