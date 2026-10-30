# Titan-portál, célzár és jutalom-OCR

Ez a lap három, ugyanazon pályaszakaszon összefüggő hatékonysági hibát rögzít: egy
feltételes objektum téves farmolását, a célok közti oszcillációt és az ikonból képzett
hamis jutalomszámot.

## A 200 HP-s lila objektum

A `220154-play/frame-00500.png` közepén lila energiával körbevett kőportál látszik. A
bot a vörösnek felismert 200-as csík miatt humanoidként kezelte, közvetlenül ráállt, majd
274–706. esemény között számos támadási kivárást és finom megközelítést végzett. A HP
egyszer sem csökkent.

A csík alatti 88×76 px-es testmintában a magenta arány:

- Titan-portál: 0,202;
- 4-szíves humanoid: 0,000;
- ismert fenyőkontroll: 0,000;
- 5-ös, 64 HP-s kontrollcél: 0,000.

Az aktuális szabály 0,06 fölött `objectiveStructureConfidence`-ként kizárja a testet a
`safeTargets`, a `nearestThreat` és a csoportfenyegetés forrásai közül. Erős, de még
nem teljesen bizonyított következtetés, hogy a portál a `0/7` gemküldetés után aktiválódik.

A `072159-play/frame-00302` a jutalomhiányos Island 4-területelhagyás közben újra
ugyanide hozta a karaktert. A `Collect all gems to unleash the Titan's power`, `0/7`
buborék puszta közelségre, koppintás nélkül jelent meg. Ez nem új gemforrás, hanem a
korábban dokumentált portál és feltétel új helymegerősítése; a bot nem próbált interakciót.

## Háromdöntéses célzár

A 72–85. eseményben a pontozó 64 HP-s közeli, illetve 179/200 HP-s távoli cél között
váltott. A kamera mozgása minden képen átírta a költséget, az ellentétes swipe-ok pedig
részben kioltották egymást.

Az új hiszterézis:

1. azonos, 85 px-en belüli képernyőhely biztosan ugyanaz a cél;
2. azonos testosztály és legfeljebb 40 HP eltérés nagy kameraelmozdulásnál is ugyanaz
   lehet;
3. eltérő új jelölt három tényleges stratégiai döntésig nem írja felül a régi üldözési
   irányt;
4. felhasználói aktivitás miatt kihagyott kép nem fogyasztja a célzárat.

## `+1` helyett `+12`

A `221123-play/frame-00000.png` egy 1-es kékfejszés, 128 HP-s humanoidot mutat. A
`frame-00010.png` ölés után vizuálisan `+1` zöld számot és kék fejszeikont ábrázol.
A Vision a kettőt `+12` szöveggé ragasztotta.

Az elemző ezért 40 képig megőrzi a legutóbbi, biztos ikonnal rendelkező cél statértékét.
Ha a nyers jutalom ettől eltér, de a száma az ismert értékkel kezdődik (`1→12`), az
ismert célérték győz. Ez nem általános számlevágás: célérték nélkül továbbra is csak
explicit pluszjeles `+N` jutalom fogadható el.

Az esemény új játékismeretet is ad: kékfejszés jutalom nem csak fenyőn, hanem humanoidon
is előfordul. A következő tiszta találati képen mérendő, hogy a korábbi 33-as normál
sebzés 34-re nőtt-e.
