# Újratermelődött 499-es hordozó közepes megközelítése

## Biztos élő megfigyelés

A `091457-play` szabad területfelderítése újra megtalálta a korábban legyőzött,
499 HP-s Bat Cleaver-hordozót:

- `frame-00285`: 293 pixel, zöld fegyverkártya-bizonyíték `0,0309`;
- `frame-00286`: 260 pixel, bizonyíték `0,0293`;
- `frame-00287`: 252 pixel, bizonyíték `0,0386`;
- `frame-00288`: 313 pixel;
- `frame-00290`: 395 pixel, a teljes humanoid és a 499-es csík közvetlenül látható.

A 29m59s újratermelődési idő tehát letelt, a hordozó ismét jelen van. A 285–287.
döntés még az általános „ismeretlen szintű cél” kitérőjét használta: előbb közelebb
hozta, majd a négyirányú felderítés 395 pixelre eltávolította. Ez nem felismerési
hiba, hanem a közeli támadási kapu és a távoli navigáció közötti hiányzó stratégia.

## Döntés

A 150 pixelen belüli, izolált 499-es hordozó továbbra is biztos befejezhető cél.
Emellett külön közepes felderítő sávot kap 270 pixelig, csak akkor, ha:

- a saját bizonyított max-HP legalább 600;
- az olvasott HP pontosan 499;
- a zöld fegyverkártya pixeleinek aránya legalább `0,02`;
- a teljes csík 45–65 pixel széles;
- a cél legalább a kép szélességének 15%-án belülre került.

A 270-es felső kapu szándékos: a korábbi `085353-replay` kerítés-túloldali képei
281–349 pixelesek voltak, ezért továbbra sem válnak üldözhetővé. Ha a 260/252
pixeles megközelítés elakad, a meglévő célstagnálás két ellenoldali kerülő után
hosszú kiszakadással elengedi.

## Várt eredmény

A `091457` visszajátszásán a 286–287. képnek HP-csík-megközelítést kell adnia, a
293 és 281+ pixeles képeknek nem. Élőben a cél vagy 150 pixel alá kerül és a bot
begyűjti a tizedik Bat Cleaver-példányt, vagy a járhatatlan kerítés bizonyítéka után
automatikusan kiszakad.
