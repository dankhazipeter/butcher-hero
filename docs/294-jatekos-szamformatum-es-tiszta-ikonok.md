# Játékos számformátum és tiszta ikonok — 2026-10-30

## Kérés és választott kijelzési szabály

A felhasználó a statgrafikonok fölött isK/Mrövidítést kért, és barna
négyszög nélküli, fehér hátteren megjelenő ikonokat. Példái:
73200→73,2K;2360000→2,3M;100M alatt99,8M, fölötte egész szám.

**Következtetés, nem bizonyított játékbelső szabály:** tizedeslevágás,
nem felfelé kerekítés; a skálázott érték100alatt egy tizedesjegy,
100-tól egész szám. Egységek:K=1000,M=1000000,B=1000000000,T=1000000000000.
Ezért999999→999K,1000000→1M,100900000→100M. A konkrét játék minden
határon alkalmazott algoritmusát nem állítjuk ismertnek; új példára
a közös formázó és teszt módosítható.

`dashboard/format.js`:közös, tiszta formázó a felső statértékekhez és
tengelyekhez. A pontos tizedesszövegeket nem alakítja lebegőpontos számmá.
Alapadat, aggregáció, napló, APIés gyűjtő nem változott. A táblázat,
tooltipés képernyőolvasó továbbra a teljes pontos naplóértéket kapja.

## Ikonok és eszközhasználat

A helyi Sites munkafolyamatban módosult a meglévő nézet. Nyolc külön
háttéreltávolító szerkesztés készült a beépített image_gentoollal,
transparent_background=truebeállítással, az előzőleg megtekintett eredeti
statképekkel. Nincs CLI/API-kulcsos generálás, nincs új külső függőség.

Az új, csak megjelenítésre szántRGBA PNG-k tartós helye:
`dashboard/icons/`:hp.png,regeneration.png,piercing_damage.png,
cutting_damage.png,smash_damage.png,piercing_defense.png,
cutting_defense.png,smash_defense.png.

Az eredeti generált kimenetek a generátor saját mappájában megmaradtak.
A projektpéldányok csak szokásos, aránytartó96px-es exportméretezést kaptak
macOSsips-szel. Alfacsatorna megmaradt; a felület CSS-e fehér hátteret ad.
A forrásalakhoz hasonló UI-változatok, nem állítunk pixelazonos kivágást.
A pajzs saját barna színe nem háttér, megmaradhat. A gyűjtő eredeti képei
`Sources/RewardAutomationCore/Resources/RewardIcons/` alatt változatlanok;
ezeknek nincs köze az új UI-képekhez. Ikonok böngészőcache-e1óra,
APIadat továbbra no-store; nem töltünk újra nagy képet2s-onként.

### Végső promptkészlet

Minden `NAME` helyére sorban a fenti8fájlnév kiterjesztés nélküli része
került, a hozzá tartozó eredetiPNGvolt az egyetlen edit target:

> Use case: background-extraction. Edit target: the supplied tiny Butcher Hero stat icon (NAME). Remove ONLY the flat brown square background and make that background fully transparent. Preserve exactly the original icon shape, internal colour fills, thick black outlines, proportions, orientation and small highlights. Do not reinterpret, embellish, recolour or redesign the symbol. No text, shadow, border, frame, extra object or white halo. Center the isolated original symbol with a narrow transparent margin; it will be displayed at 28 pixels on a white UI background. Output actual RGBA transparency.

## Ellenőrzés és működés

`node --test tests/reward_format.test.cjs`:5tesztPASS,példák/határértékek,
kis/tizedes értékek, nagy pontos számok, hibás/hiányzó adatok, mind a8
PNG8bitRGBA/≤96px/átlátszó első sarok.9Pythonstatisztikai tesztPASS;
JS-szintaxis és Gitdiff-ellenőrzésPASS. A gyűjtő forrásához nem nyúltunk,
nem állítottuk le vagy fordítottuk újra;PID2444tovább futott.

Csak a helyi statisztikakiszolgáló indult újra az új statikus útvonalhoz:
execsession2939,ugyanaz a http://127.0.0.1:8765/ cím.
A korábbi böngészőlap átvétele `browser.user is unavailable`hibát adott;
dokumentált API-val új saját ellenőrzőlap nyílt, azon a friss nézet elérhető.
Nincs külső publikálás, új credential vagy globális beállítás.

Böngészőben:8ikon betöltött,96px-es forrás és mindegyik alatt
rgb(255,255,255)háttér; nincs konzolhiba vagy vízszintes túlcsordulás.
ÉlőHealth201300érték+201K-ként jelent meg, pontos tooltip+201300;
Pierce3780→+3,7K,Cut1665→+1,6K. Az ikonok vizuálisan ellenőrizve,
barna négyzet nélkül. Képernyőkép helyben:
`outputs/reward-dashboard/dashboard-compact-icons.jpg`.

E kör egy commit és automatikus main-push; a Git-napló adja az azonosítót.
