# Cursed Girl és a Deep Mines ellenszérum-küldetés

## Felfedezés

A `docs/runs/20260829-000247-play` zöld minimap-landmark navigációja a Cursed Girl NPC-hez
vezetett. A `frame-00224.png` normál HUD-on mutatja a kőbe szorult lányt és a közelébe
érkező játékost. Ez közvetlenül igazolja, hogy a zöld minimapjel nem dekoráció: új NPC-t
és fejlődési feladatot jelölt.

## Párbeszéd

A következő képek teljes képernyős párbeszédet mutatnak, a játékmenet HUD-ja eltűnik:

- `frame-00228.png`: „Please... help me... I'm turning to stone...”;
- `frame-00230.png`: a lány szerint a bányában van egy mágikus főzet, amely visszafordítja
  az átkot;
- `frame-00232.png`: kéri, hogy hozzuk vissza, mielőtt teljesen kővé válik;
- `frame-00234.png`: szöveg nélküli átvezető kép, a lány már szürke kőszobor.

Minden szöveges panelen látható a `Tap to continue` jelzés. Az átvezető automatikusan
visszaadta a normál játékot; nem volt game over vagy fizetős művelet.

## Új feladat és útvonal

A `docs/runs/20260829-000750-observe/frame-00000.png` normál HUD-ján ez olvasható:

`Find a magic anti-stone potion in Deep Mines` — `0/1`

A terepen világoskék, szaggatott útvonal jelent meg a lánytól egy kapu irányába. A bot
piros minimap-navigációja az új célterületet kezdi követni. A főzet helye, a Deep Mines
bejárata, ellenfelei és a visszavitel jutalma még nyitott kutatás.

## Felismerési incidens és javítás

A lány két piros hajdísze 46×40 körüli pink komponensként átment a régi geometriai
popup-X szűrőn. A bot ezért véletlenül a hajára koppintott; a tapok ugyan léptették a
történetet, de a képernyőállapot értelmezése hibás volt. A szöveg nélküli kővé válásnál
hat alacsony HUD-bizalmú kép után a folyamat leállt.

A javított szabályok:

1. külön OCR-régió keresi a `Tap to continue` vagy `Cursed Girl` szöveget;
2. csak biztos felismeréskor koppint a dialógusmező jobb alsó részére;
3. az általános pink bezárót csak a kép jobb 40%-ában fogadja el;
4. HUD nélküli, szöveg nélküli átvezetőn input nélkül tovább figyel, és explicit
   felhasználói leállításig nem fejezi be magától a folyamatot.

A `000903-replay` mindhárom párbeszédképen szándékos dialógusléptetést, a kőszobros
képen passzív várakozást adott. Az élő folytatás: `20260829-000913-play`.
