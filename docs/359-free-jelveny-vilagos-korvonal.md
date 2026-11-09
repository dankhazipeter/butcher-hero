# FREE-jelvény világos háttéren: elutasított kártyák

2026-11-09 reggel. A felhasználó jelezte, hogy az átlagos felszedési idő 33 s-ról
42 s-ra nőtt. Képernyőképen egy ott maradt kártya: FREE, Cut Defense, 867, homokos
háttéren.

## Tények

- Napló: `5B8FD345` / `386ACCCA` 05:37:14Z-től többször `reward_detected`
  cutting_defense 867, majd `click_failed` „Free preclick rejected:
  badge_shape_missing”. A kártyát csak 05:39:11Z-kor vette fel, 117 s után.
- A `badge_shape_missing` azt jelenti, hogy a `freeBadgeRects` egyetlen jelöltet sem
  talált. A teljes naplóban 212 ilyen sor van. Az elmentett 68 diagnosztikai
  képből 58-on jól látható kártya van (579, 646, 658, 740, 839, 867, 881), homokon,
  világos fűn és világos kövön.
- Az elbukó feltétel a jelvény sötét körvonala. A régi kód legalább ⌈w·h·0.000025⌉
  = 15 pixelt kért, amelynek legnagyobb csatornája 100 (vivid) vagy 90 alatt van.
  A körvonal áttetsző, ezért világos háttéren csak közepesen sötét (max ≈125–150).
  A hibás képeken 7–14 ilyen pixel volt. A jól olvasott előképeken is csak 11–15
  volt, ezért ugyanaz az álló kártya egyik képkockán átment, a következőn nem. A
  „két stabil kép” kapu emiatt újra és újra kezdődött.

## Javítás

`darkLimit` mindkét ágban 140. A fehér szöveg, a méret és arány, a kártyaszegély
és a FREE pixelegyezés (vagy OCR) feltétele változatlan. A 140-es küszöbnél a
hibás képeken legalább 44 sötét pixel van, a szükséges 15 felett.

## Ellenőrzés

- Visszajátszás 4819 képen (az app összes elmentett before/validated/after/
  diagnostic képe és a korpusz). A régi és az új kód eredménye csak 58
  diagnosztikai képen tér el: `badge_shape_missing` helyett mindegyiken a claimjének
  megfelelő típus és összeg. Az 1552 felvétel utáni kép és a korpusz egyetlen
  eredménye sem változott, nem lett új hamis kártyajelenlét. A megmaradt 10
  „nincs jelvény” diagnosztikai képen vizuálisan sincs kártya.
- A 120-as küszöb ugyanezt adta, de csak 17 vs 15 tartalékkal. Ezért 140.
- Korpusz +5 kép (`docs/references/2026-11-09/`): 4 pozitív (homok 658/867,
  világos fű 839, kő 881), ezeket a régi kód mind elutasította, és 1 homokos
  negatív.
- Ez nem összegolvasási javítás. A kártyák nem „?” összeggel lettek felvéve,
  hanem késve. A 353-as reconcile dry-run eredménye lent.

## Telepítés és utólagos javítás

- Teljes kapu PASS. Az app 07:33Z-kor települt. A gyűjtést a felhasználó 05:44:56Z-kor
  leállította (`watcher_stopped`), és az újraindítás után is kikapcsolva maradt.
  Élő megerősítés a következő gyűjtésnél.
- `reconcile --dry-run`: 0 javítható, 105 nem javítható. Ezek a 2026-11-07-i
  „?” piercing_damage tételek, képük a 24 órás megőrzés miatt már nincs meg.
  Nem kapcsolódnak ehhez a hibához, éles reconcile nem futott.
