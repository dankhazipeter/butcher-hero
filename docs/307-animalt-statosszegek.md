# Animált statösszegek — 2026-10-30

## Kérés és könyvtárválasztás

A „Növekedés, statonként” nagy számai ne csak átíródjanak, hanem finoman
animálódjanak. A felhasználó külön kérte könyvtár keresését.

A [CountUp.js](https://github.com/inorganik/countUp.js) erre készült:
egyedi formattingFn, új célérték és mindkét irányú számlálás támogatott.
A2.10.1 npm-kiadás eredeti UMD-fájlja helyben szerepel, MIT-licenccel;
forrás, gitHead, tarballintegritás és fájlhash: dashboard/vendor/README.md.
Nincs futás közbeni CDN-/internetes függőség vagy új telepítési lépés.

## UX és pontosság

- A statkártya korábbi összegéről az újra0,65s easing-átmenet fut.
- Azonos adatfrissítés nem indít új animációt. Gyors változásnál a korábbi
  animáció leáll, az éppen látható képkocka számától folytatódik.
- Első betöltés és időszakváltás azonnali: nem mutatunk hamis „új bevételt”.
- prefers-reduced-motion vagy háttérlap esetén azonnali végérték; a futó
  animáció is lezárható a következő frissítéskor.
- A K/M/B/T formázó közös marad. Végén mindig az eredeti szöveges
  naplóösszegből formázunk; a title és aria-label azonnal a pontos célt jelzi.
- Nem biztonságos számábrázolás, hatnál több tizedes, hiányzó könyvtár
  vagy könyvtárhiba esetén azonnali végérték, nem hamisított nulla.
- Csak kijelzés: napló, API, darabszámgrafikon és könyvelés nem változik.

## Teszt és üzemeltetés

Öt új Node-teszt a valódi vendorkönyvtárat futtatja vm-ben vezérelhető
requestAnimationFrame órával. Köztes képkocka, végérték, azonos poll,
gyors célváltás, csökkenés, tizedes, szűrőváltás, háttérlap, reduced-motion,
nagy/hibás szám, hiányzó lib és scriptbetöltési sorrend ellenőrzött.
A HTTPteszt az új két JS-útvonalat is vizsgálja; engedélylista és self-only
CSP megmaradt. Teljes23Swift+15statisztika+3Gitkapu+9felügyelet+19Node
és4JS-szintaxisellenőrzésPASS. A commit/push/PR-kapu ugyanígy futtatja.

A Sites készség helyi-only munkamenete szerint nincs felhős publikálás.
A read-only szerver az új útvonalakhoz77612-ről89001-re indult újra,
tartós session10556. A gyűjtő66095 végig futott,21:02:05Zfrissképidővel.
A helyi HTTP-n a vendorhash és az adapter/betöltési sorrend ellenőrizve.
A böngészőkapcsolat „browser.user is unavailable” hibája miatt új vizuális
ellenőrzés nem sikerült; nem állítunk vizuális PASS-t. A meglévő oldalt
újra kell tölteni az animáció bekapcsolásához.
