# Felületi fordítások

- `hu.js`: magyar, alapértelmezett; `en.js`: angol.
- A fejléc választása `butcher-dashboard-language` néven a böngésző
  localStorage tárolójába kerül. Tiltott tároló esetén is működik a váltás,
  csak az újratöltésen át történő megjegyzés nem garantált.
- Minden nyelv saját `language`, `name`, `locale` és `messages` adatokkal
  rendelkezik. A `name` a nyelv saját neve; a `locale` a dátum-/számformátum.
- A `{count}`, `{time}` stb. helyőrzőket pontosan meg kell tartani.
- UI-kódba ne kerüljön új felhasználói szöveg: új kulcs mindkét fájlba,
  majd `t("kulcs", {helyorzo: ertek})` vagy HTML `data-i18n="kulcs"`.
  A behelyettesítés textContenttel történik, nem HTML-ként.
- Az eredeti gyűjtőnapló diagnosztikai üzeneteit szándékosan változatlanul
  idézzük; ez nem a napló vagy a játék nyelvének átállítása.
- A nyolc játékbeli stat `kind.*` neve minden nyelven az angol eredeti:
  Health, Health Regen, Pierce Damage, Cut Damage, Smash Damage,
  Pierce Defense, Cut Defense, Smash Defense. Ezeket ne fordítsd le.
  A `kind.unknown` továbbra lefordítandó, mert felületi diagnosztikai címke.
- A locale a szám-/dátumformátumot adja, nem az időzónát. Az időzóna a
  böngésző aktuális IANA zónája; nyelvváltáskor nem változik.

## Új nyelv hozzáadása

1. Másold az `en.js` szerkezetét például `fr.js` néven.
2. Állítsd át a `language` értékét `fr`-re, `name` értékét `Français`-re,
   `locale` értékét `fr-FR`-re és a böngészős regisztrációt `.fr=catalog`-ra.
3. Fordítsd le a `messages` értékeket a fenti nyolc statnév kivételével;
   a kulcsokat/helyőrzőket ne módosítsd.
4. Az index.htmlben az i18n.js elé kerüljön egy helyi, defer script:
   `<script src="/locales/fr.js" defer></script>`.
5. Futtasd: `make test`. A nyelvi fájlokat a teszt automatikusan felfedezi;
   kulcs- és helyőrzőeltérés, üres fordítás vagy hiányzó scriptbetöltés hibát ad.

A választó automatikusan felveszi a betöltött új nyelvet, nem kell külön
options listát szerkeszteni. A szerver a kéttagú nyelvkódokat és az opcionális
nagybetűs régiót engedi (`fr.js`, `pt-BR.js`); régiós kódnál a regisztráció
szögletes zárójeles, például `RewardLocales["pt-BR"]=catalog`.
A szövegek helyi fájlok, nincs fordítási szolgáltatás vagy CDN.
