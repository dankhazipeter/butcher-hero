# Nagy szívkaktusz prioritása kis célok között — 2026-09-19

## Hipotézis és friss bizonyíték

A `122904-159dcbb0-observe/0–1` képen egyszerre négy 765-ös kis növény és
a 300-szíves, 11,4K-s kaktusz látszik. A nagy cél 371 px, fa-bizonyíték 0,291,
szív-bizonyíték 0,719, explicit `300` és `11.4K` OCR. A bot mégis a 102 px-re
álló kis növényt választotta. Ez nem hiányzó képértelmezés, hanem prioritási hiba.

## Két programhiba

1. A stratégiai bossjelölt kiválasztása minden szívfát befogadott. A legközelebbi
   765-ös nyert, majd a későbbi 800-as minimumon kiesett; a valódi nagy célhoz
   már nem tért vissza. A szívfa-bossjelöltek most ugyanazt a 800…30000 sávot
   kérik, mint a fogyasztó ág.
2. A piros minimapjel irányegyezését a már vizuálisan igazolt passzív szívfától
   is kérte. A szívfa ezért másik piros pont mellett kimaradt. Igazolt növény és
   szívikon esetén a saját képi célirány elegendő; humanoidokra a régi kapu marad.

Build után ugyanazon két kép replaye, majd innen induló élő automatikus
kaktuszpróba következik. Csak a tényleges +300/HP-változás igazolja a győzelmet.

`123047-fd6cf85b-replay`: mindkét képen a nagy 11400-as cél kapja a délkeleti
irányt. `123048-e5c8fd86-play`: ugyaninnen automatikusan három közelítő swipe,
majd helyben támadás. A 8. képen 11400→7570 boss-HP, saját 99%; a környező
kis célok nem szakították meg. A képpár bekerült az automatikus regresszióba.

## Teljes automatikus győzelem

Ugyanez a futás a 17. képen új respawn-körből lezárta a harcot, a 19. képen
vizuálisan **+300 szív és 5,18K** látszik. A gépi maximum 4880→5180,
majd közeli 10-szíves farm után 5190. Emberi mozgás vagy kézi javítás a harc
közben nem történt. Időbélyegek: első döntés 12:30:49, közeli álló támadás
12:30:53, győzelem 12:31:01; teljes közelítés+harc kb. 12 s, álló szakasz kb. 8 s.
A pixelcsík rövid 25%-os takarása nem vitte el a botot a nyerhető célról.
