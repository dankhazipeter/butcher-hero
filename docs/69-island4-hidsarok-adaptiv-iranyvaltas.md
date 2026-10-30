# Island 4 hídsarok: adaptív irányváltás

## Élő anomália — `20260829-033954-play`

A második +10 után a karakter az Island 4 hídja, a szikla és a lezárt faépítmény közötti
sarokba ékelődött. A `frame-00362.png` képen a játékos a híd jobb oldali tartója alatt
áll; jobbra nyílt zöld terület látszik, a tartott balra-le jellegű falmenti vektor mégsem
mozdította meg.

A 351–363. eseményben a kvantált háttér teljesen azonos maradt. A bot felismerte az
elakadást, de az ismert navigációs vektorhoz tartozó kerülőt vakon tíz swipe-ig őrizte.
Ez hosszú, járható fal mellett hasznos, fizikai sarokban viszont bizonyítottan elvesztegeti
az időt.

## Döntés

Aktív statikus faljárás közben is mérjük tovább a háttér mozgását:

- ha a kamera mozog, a legfeljebb tízlépéses falmenti szakasz változatlanul lefuthat;
- ha három egymást követő végrehajtott swipe után is statikus a kép, az aktuális átló
  bizonyítottan rossz;
- ilyenkor ugyanazon döntésben a következő négyátlós fázis indul, nem várunk még hét
  sikertelen mozdulatot és újabb hat alapirányú próbát;
- boss, sebzés és közeli biztonságos cél továbbra is minden faljárást megelőz.

## Ellenőrzési feltétel

Az új build akkor tekinthető élőben igazoltnak, ha a következő teljesen statikus
háromswipe-os szakasz után a napló azonnal új `akadálykerülés indul` döntést mutat eltérő
vektorral, majd a háttér ujjlenyomata megváltozik.

## Replay-ellenőrzés — `20260829-034857-replay`

A teljes `033954-play` újraelemzése a javított builddel teljesítette az irányváltási
feltételt. Például a 312→314→316 képeken tartott `(1,00; 0,00)` vektor után a 318.
képen rögtön `(-0,54; 0,84)` indult; ugyanez a háromswipe-os ritmus több további
teljesen statikus fázison is megismétlődött. Ahol a háttér közben változott, a bot nem
kényszerített korai oldalváltást. A regressziós feltétel teljesült; az élő build fut.
