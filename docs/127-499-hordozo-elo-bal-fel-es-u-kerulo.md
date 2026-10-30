# A 499 HP-s hordozó élő bal–fel útja és U-kerülője

## Élő bizonyíték — `20260829-101003-play`

A javított hordozófelismerő az 556. eseménynél ismét megtalálta a teljesen zöld
fegyverkártyával igazolt, `499 HP`-s Bat Cleaver-hordozót. A közvetlen közelítés
`266→212` pixelre zárt, majd 212 pixelen hat végrehajtott swipe-on át statikus
maradt. Ez ugyanaz a vízszintes tábori kerítés, amelyet a korábbi futások mutattak.

A 572–594. események végrehajtották a tizenkét bal oldali swipe-ot. A mentett képek
fizikai pályamozgást bizonyítanak:

- `frame-00556`: a játékos a hosszú vízszintes kerítés alatt, a hordozó fölötte;
- `frame-00572`: a cél még 212 pixelen, közvetlenül a kerülő indulása előtt;
- `frame-00584`: a játékos elérte a kerítés bal alsó sarkát, a hordozó a jobb
  képszélen még látható;
- `frame-00594`: a teljes bal szakasz után a karakter a kerítésen kívüli
  útkereszteződésnél áll.

Ez élőben megerősíti, hogy a jobb oldali torony–hordó zsebbel szemben a bal oldal
járható, és a háttérváltozás nem a hordozó járőrözéséből származik.

## A kétszakaszos út hibája

A 596–618. események tizenkét felfelé swipe-pal végigmentek a kerítés külső
oldalán. A karakter közben valóban észak felé mozgott, elérte a Deep Mines
sínpályáját és a havas kaput. A hordozó azonban takarásban maradt. A második
szakasz végén a régi döntő átadta a vezérlést a minimapnak; a 620. eseménytől az
balra fordított. A 642. képen több `1.92K` és `7.15K` HP-s őr jelent meg, ezért a
bossőr helyesen megszakította a próbát és menekült.

Következtetés: a bal → fel L-alak nem elég. A kerítés körbejárásához harmadik láb
kell, amely északon jobbra visszatér a bekerített terület felé. A veszély nem a
biztonsági őr hibája volt, hanem a hiányzó pályageometriai szakasz.

## Első U-munkahipotézis — később rövidítve

A hordozóspecifikus út első U-alakú változata:

1. tizenkét swipe balra a vízszintes kerítés mentén;
2. tizenkét swipe felfelé a kerítés külső oldalán;
3. tizenkét swipe jobbra, vissza a hordozó bekerített területe felé;
4. csak ezután kaphat újra vezérlést a célkövetés vagy a minimap.

A boss-, friss sérülés-, visszavonulás- és UI-őrök mindhárom rögzített szakaszt
megelőzik, ezért a harmadik láb sem írhatja felül a biztonsági menekülést.

## Ellenőrizendő

- A jobbra visszatérő harmadik láb ténylegesen bevisz-e a hordozó oldalára.
- Újra megjelenik-e a 499-es cél a harmadik szakasz közben vagy után.
- Az út elkerüli-e a Deep Mines 1.92K/7.15K őreit.
- A hordozó legyőzése után a Bat Cleaver-példányszám `9→10`, a sebzés pedig
  várhatóan `450→500` lesz-e.

Az U-út élő fizikai sikere ezért jelenleg **munkahipotézis**; az első két szakasz
járhatósága viszont képpel igazolt tény.

## Későbbi élő korrekció

A `103900-play` megmutatta, hogy a sarok már 7–8 bal swipe után elérhető, a
tizenkét felfelé szakaszt pedig az 1.22K-s őr a negyedik lépésnél megszakítja.
Az ezután bevezetett **8 bal → 3 fel → 8 jobb** változatot a
`104751-play` élőben szintén megcáfolta: a jobbra láb még a függőleges palánknak
ment. A teljes negatív bizonyíték és a hosszabb, őr mellett jobbra-felfelé futó
munkahipotézis a [131. fejezetben](131-499-hordozo-8-3-8-cafolat-es-orfolyoso.md)
található. A 12–12–12 és 8–3–8 változat egyaránt történeti.

## Döntési regresszió

A `20260829-102622-replay` a `frame-00556→00642` mentett képsoron az új binárissal
végigfuttatta a döntőt. A 11–22. relatív döntés tizenkét bal swipe-ot, a 23–34.
tizenkét felfelé swipe-ot, a 35–46. pedig tizenkét jobbra swipe-ot adott. A 47.
döntésnél tért vissza először a minimaphoz. Ez igazolja a szakaszok sorrendjét és
darabszámát; az élő fizikai harmadik láb eredményét továbbra is külön kell mérni.
