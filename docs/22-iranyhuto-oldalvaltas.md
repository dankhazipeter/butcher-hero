# Irányhűtő-oldalváltás és pályaszéli elakadás

Ez a folyamat a `20260828-225843-play` élő felügyeletéből született. Az előző javítás
helyesen megakadályozta a visszafordulást az Island 4 kerítése mögötti célhoz, de a
hosszú hűtési idő alatt ugyanaz a merőleges irány maga is akadállyá vált.

## Bizonyíték

- 112–146. esemény: a második stagnáló megközelítés után teljes 18 swipe-os kiszakadás.
- 148–168: az új irányhűtő `(-0,80; -0,60)` oldalirányú lépései ténylegesen eltérítették
  a botot a blokkolt északi/északkeleti iránytól.
- `frame-00150.png`: a karakter már más, nyitottabb kerítésszakaszon van.
- `frame-00200.png`: megérkezett a nyugati szikla–víz pályaszélhez.
- `frame-00245.png`: a terep és a karakter helyzete lényegében azonos, csak a timer
  változott `2h 58m`-ről `2h 57m`-re. Közben a konzol több mint húsz azonos hűtőswipe-ot
  naplózott. Ez biztos vizuális stagnálás.

## Cáfolt hipotézis

Az a feltevés, hogy a blokkolt célirányra merőleges egyetlen oldal 120 döntésig
biztonságosan használható, hamis. A merőleges út is véget érhet pályaszélen vagy más
hosszú falon, és a hűtőlogika korábban nem tartalmazott saját elakadáskezelést.

## Programdöntés

- A `blockedRouteBypassPhaseSteps` csak a ténylegesen végrehajtott, hűtőlistás
  oldalirányú döntéseket számolja.
- 12 ilyen swipe után a `blockedRouteBypassSign` előjele megfordul és a következő fázis
  az ellenkező merőleges irányt használja.
- Új kiszakadás kezdetén és valóban eltérő cél elfogadásakor a fázisszámláló nullázódik.
- Felhasználói aktivitás miatti `VÁR` és minimapjel nélküli tartalék járőr nem fogyasztja
  a 12-es fázist.

## Miért 12 lépés

A `225843` futásban 12 merőleges lépés már nagy pályaszakaszt járt be, de az első
sziklafalig még nem tartotta ott indokolatlanul sokáig a karaktert. Rövidebb fázis túl
gyors oldalirányú oszcillációt okozhat; hosszabb fázis ismét jelentős holtidőt adna a
pályaszélen. Ez kezdeti, élőben tovább mérendő érték.

## Elfogadási feltételek

1. Az első 12 hűtőswipe után a konzolban az oldalirány előjele megfordul.
2. Az ellenkező fázis képen is elmozdítja a karaktert a nyugati sziklafaltól.
3. Más irányú elérhető cél azonnal feloldhatja a hűtést.
4. A bot nem tér vissza tartós 200 HP-s kerítéscél-hurokba.

## Élő elfogadás — `231840-play`

A 183–217. eseményen lefutott a teljes déli kiszakadás. A hűtő első fázisa 219-től
12 tényleges `(-1,00; -0,07)` swipe-ot gyűjtött össze; a köztes minimap nélküli
spirállépések helyesen nem fogyasztották a fázisszámlálót. A 12. hűtőswipe 245-nél
zárta a fázist. A következő érvényes minimap-jel 255-nél már ellenkező,
`(+1,00; +0,07)` hűtőswipe-ot adott, majd ezt 257–265 között megtartotta.

A képi eredmény is pozitív: `frame-00245.png` még a szűk sátor–szikla ékben mutatja a
karaktert; `frame-00260.png` már attól jobbra, nyílt füves részen és a függőleges út
mellett. Ezzel az első három elfogadási feltétel élőben teljesült: a fázis pontosan váltott,
az ellenkező oldal kivezette a pályaszéli ékből, és a lezárt északi irány továbbra sem
kapott közvetlen engedélyt.
