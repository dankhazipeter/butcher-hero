# Stratégiai respawn és az Island 4 elérhetőségi őre

## Második élő aktiválás — `20260829-045414-play`

A 727→747 fejlődés helyesen lenullázta a boss-számlálót. Később öt újabb,
fejlődés nélküli bossészlelés gyűlt össze, ezért a stratégiai respawn a 317.
eseménynél ismét aktiválódott. Ezúttal nem jelent meg a korábbi, végtelen helyben
várási hiba: a bot a javításnak megfelelően folyamatosan a megjegyzett vagy frissen
látott fenyegetés felé swipe-olt.

A képi audit mégis új hibát tárt fel. A kiválasztott, 632 HP-s és bossbizonyítékú cél
a narancs Island 4 területén, a lezárt sziklafal bal oldalán állt, míg a játékos a
zöld, elérhető oldalon volt (`frame-00316→00336`). A farmcélválasztó ugyanezt a bal
36%-os régiót már kizárja, a stratégiai respawn azonban csak a veszélyességet nézte.
A 317–395. esemény között a játékos teljes 747 HP-n maradt, a háttér lényegében nem
mozdult, és a fal túloldali cél természetesen nem tudta eltalálni.

Biztos következtetés: egy objektum lehet valódi bossveszély a képen, miközben ezen a
megközelítési oldalon nem használható szándékos halál célpontjaként. A bossőrnek azért
látnia kell, hogy ne menjünk bele; a stratégiai respawnnak viszont elérhetőségi kapu
is kell.

## Javítás

- Látható Island 4-zár és narancsszikla-biombizonyíték mellett a kép bal 36%-ában
  álló fenyegetés nem indíthat stratégiai respawnt.
- Ha egy már aktív stratégiai mód közben válik biztossá ugyanez a helyzet, a mód
  azonnal megszakad, a boss-számláló nullázódik, és a bizonyított `(0,48; 0,88)`
  kifelé tartó átló indul.
- A cél veszélyként megmarad. A normál bossmenekülés továbbra is észleli és távolodik
  tőle; csak a szándékos közelítés tiltott.
- Elérhető oldalon álló bossra az ötös küszöb, a frisssebzéses kivárás és a többi
  megszakítófeltétel változatlan.

## Regresszió és új élő futás

A teljes `045414-play` visszajátszása a javított builddel az ötödik és további
fal-túloldali bossképeken sem indított stratégiai respawnt. A releváns képeken a
normál, a veszélytől kifelé mutató bossmenekülés futott; a 214., 232., 266., 344.,
370. és 384. mentett kép is ezt igazolta. A build sikeresen elkészült, majd a
folyamatos játék `20260829-050324-play` néven azonnal újraindult 747 hiteles
maximummal.

