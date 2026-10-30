# Kis ablakos cél-HP és megfigyelési írásvédelem — 2026-09-19

## Hipotézis

A 637×882-es ablakban a széles cél-OCR néha csak a csík fölötti 1-es statot
olvassa, magát a csíkba írt 428/765 HP-t nem. Ez hamis könnyű célt és pontatlan
harci követést eredményez. A probléma nem indokol találgatott számot.

## Javítás és bizonyíték

Ha a széles régió legnagyobb száma legfeljebb 20, egy második, szűk,
háromszorosra nagyított csíksor-OCR egészíti ki. A felső statikon kívül marad.

- `120746-play/33`: vizuálisan 428, eredeti naplóban 1.
- `121157-replay`: ugyanaz a kép friss felismerővel 428.
- `121208-replay`: teljes 48 képes soron is 428 a 33. képnél; 4490 saját HP
  változatlan. A javítás nem teljes: az 5. képen a 765-ös növény továbbra is
  csak 1-et ad, a 6. kép 765-jét a régi temporális őr még 1-en tartja. Ezt
  nyitott hibaként tartjuk számon, nem tekintjük tökéletes felismerésnek.
- `121207-play`: élő ellenőrzés indul; az első hat döntésben két 632-es
  kaktusz megközelítése, majd cél eltűnése. Pontos jutalomszám még nincs igazolva.

## Observe nem tanulhat végrehajtás nélkül

Az audit feltárta, hogy observe alatt is íródhatott a tartós HP/navigáció,
noha a stratégiadöntés nem lett végrehajtva. Most az observe mindhárom tudástár
írását tiltja, de betölti az élő navigációs előzményt. A replay továbbra sem
tölti a navigációs előzményt, és semmilyen tudástárat nem ír. A log és PNG
mindkét módban szándékosan létrejön. Következő ellenőrzés: állományhashek
azonossága observe előtt és után, majd élő futás az új builddel.

Ellenőrzés kész: `121338-observe` két képénél a bot-state, navigation-state és
world-map SHA1 hash-e külön-külön változatlan maradt. Másik play közben nem futott.
Az observe tudástár-írásvédelme ezzel élőben is ellenőrzött.
