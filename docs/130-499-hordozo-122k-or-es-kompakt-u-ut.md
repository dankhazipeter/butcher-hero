# A 499 HP-s hordozó 1.22K-s őre és a kompakt U-út

## Élő hordozó-találat — `20260829-103900-play`

Az adaptív védett felderítés a 273. eseménynél először élőben hajtotta végre a
három statikus swipe utáni negyedfordulatot. A kamera ezután továbbmozdult, és a
299. eseménynél újra megjelent a zöld fegyverkártyával igazolt `499 HP`-s
Bat Cleaver-hordozó. A közvetlen követés `263→191` pixelre közelített, majd a
vízszintes kerítésnél 200–229 pixelen stagnált.

A korábbi 12–12–12 U-út 322-nél indult. A képek pontosabb pályageometriát adtak:

- `frame-00322`: a játékos a vízszintes kerítés alatt, a hordozó fölötte;
- `frame-00330`: a bal szakasz hetedik végrehajtott swipe-ja már a kerítés bal alsó
  sarkánál van;
- `frame-00340`: a tizenkettedik bal swipe már túlhaladt a sarkon; a bal felső
  képszélen az `1.22K` HP-s őr részben látszik;
- `frame-00342`: az első felfelé mozgás után az őr még képszéli, ezért a
  célfelismerő nem választja ki;
- `frame-00348`: a negyedik felfelé döntés előtt az 1.22K-s őr teljesen látható,
  és a bossőr helyesen megszakítja az útvonalat.

A harmadik, jobbra visszatérő láb így el sem indult. A megszakítás helyes volt; az
útvonal függőleges szakasza volt túl hosszú.

## Történeti döntés: 8–3–8 — élőben megcáfolva

A hordozó kompakt, biztonságosabb U-útja:

1. nyolc bal swipe — a hetedik már eléri, a nyolcadik biztosan meghaladja a sarkot;
2. három felfelé swipe — éppen a bizonyított negyedik, őrt aktiváló lépés előtt áll meg;
3. nyolc jobbra swipe — kelet felé, a hordozó bekerített területe irányába tér vissza;
4. boss, friss sérülés vagy visszavonulás továbbra is bármely szakaszt megszakíthat.

Ez lerövidíti a rögzített mozgást 36-ról 19 swipe-ra, csökkenti a túlfutást, és a
visszatérő lábat még az 1.22K-s őr aggrója előtt kezdi el.

## Regresszió

A `20260829-104720-replay` a friss binárissal a hordozóképsoron az alábbi relatív
döntéseket adta:

- 8–15: nyolc bal swipe;
- 16–18: három felfelé swipe;
- 19–26: nyolc jobbra swipe;
- 27: csak ezután tért vissza a minimaphoz.

A döntési sorrend és darabszám regresszióban igazolt volt, de a harmadik láb élő
fizikai eredményét a `20260829-104751-play` **megcáfolta**: három felfelé swipe után
a karakter még a hosszú függőleges palánk nyugati oldalán állt, a nyolc jobbra
swipe pedig statikusan a kerítésnek ment. A jelenlegi, hosszabb és őrtől ferdén
távolodó munkahipotézist a [131. fejezet](131-499-hordozo-8-3-8-cafolat-es-orfolyoso.md)
rögzíti.
