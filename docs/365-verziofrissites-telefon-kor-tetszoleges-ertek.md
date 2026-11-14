# 365 — Verziófrissítés, telefon-kör és tetszőleges érték: a mentésszerkesztés teljes láncban (2026-11-14)

## Kérés

A 364-es sikeres Jar 360→361 próba után a felhasználó frissítette a játékot,
letöltötte a telefonán játszott frissebb állapotot, és azt kérte, hogy a
szerkesztés bármilyen Jar-értéken és az új játékverzión is működjön — a végső
céllal, hogy a módosítás a felhőn át a **telefonra is átkerüljön**.

## Megállapítás 1 — a hash-recept túlélte a verziófrissítést

A frissített játék a telefones állapot letöltése után saját maga írt új mentést
(119 167 bájt, salt −388851964). Ez a fájl a **362-es, 2.1-es recepttel és
`5b5496vn7456oodw976d95mo` kulccsal validál** — vagyis az új verzió ugyanazt az
MD5-alapú lokális hash-receptet és ugyanazt a beégetett kulcsot használja.
A recept tehát **verziófüggetlennek bizonyult**; nem kellett `--secret` felülírás.

A letöltés folyama a fájlokból leolvasható: a `game_data_pre_cloud.bin`
(144 340 bájt, a letöltés előtti Mac-állapot, Jar=361 — a 364-es módosítás
pillanatképként itt megőrződött) 22:35:16-kor készült, majd az új
`game_data.bin` a telefon progressziója lett (Jar=7). A trust-réteg zöld maradt:
`cloud_save_local_hash` = az aktuális fájl hash-e, `cloud_save_local_untrusted` = 0.

## Megállapítás 2 — tetszőleges érték, mindkét kódolási út élesben

A próbaszkript (`jar_experiment.py`, session temp) kibővült: `--to N`
(tetszőleges érték), `--secret KULCS` (új verziós kulcs felülírása, végül nem
kellett), `--go` (+1 kompatibilitás), `--check`, `--revert`. A számláló helye
továbbra is dinamikusan keresett. Két eltérő MessagePack-kódolási átmenet ment
élesben:

1. **7 → 10** (telefones állapot): mindkettő egybájtos fixnum (`0x07`→`0x0A`),
   helyben cserélve, a fájl mérete változatlan (119 167 bájt). Új hash
   `18-38-9C-A5-…`, a patchelt fájl a recept szerint érvényes; a biztonsági
   mentés `20261114-223919-jar-361-consistent` (SHA-256 manifesttel).
2. **10 → 350**: fixnum (1 bájt) → uint16 (3 bájt) — **kódolásváltás, a fájl
   újraépítési útja**: a mentés 2 bájttal hosszabb, a számláló utáni bájtok
   eltolódnak, a hash-mező pozíciója változik; a szkript újraparse-ol és a
   teljes data szekcióra újraszámolja a hash-t. Ez az út offline már három
   forgatókönyvben validálva volt (235→999, 360→65 536, 360→100) a repó
   `scripts/butcher-save-hash.py` eszközével keresztkontrollálva; élesben
   hibátlanul működött.

Mindkét esetben: a játék hibátlanul betöltött (nincs „SAVE DATA ERROR"), a
Crystal Jar a módosított értéket mutatta, és a módosítás a játék saját
mentési ciklusán át persistálódott.

## Megállapítás 3 — a teljes felhői kör: Mac → felhő → telefon

A 10-es módosítás után a játék feltöltötte az állapotot, a felhasználó a
telefonon szinkronizált, és **a telefonon is 10-et mutatott a Jar** — a
szerkesztés tehát a teljes láncon átterjedt:

```
Mac: konzisztens fájl-szerkesztés (362 recept)
  → játék elfogadja és saját maga ment újra (hash-szel)
  → feltöltés a felhőre (SHA256-os meta-hash, 363)
  → telefon: letöltés → ugyanaz az érték
```

Ezzel a 361-es kísérlet óta nyitott kérdés véglegesen lezárult: a mentés
lokálisan bármikor konzisztensen módosítható, és a módosítás a felhői
szinkronon át minden eszközre átviszik.

## Megjegyzések

- A felhő-mentés **egész fájl**, nem összefésülés: a feltöltés előtt fel nem
  töltött telefonos haladás felülíródhatna — a próba alatt ez nem állt fenn.
- A CLAIM gomb a tárolt lelkeket a normál játék-folyamat szerint váltja be;
  teszteléshez nem kell megnyomni.
- Az `event_analytics.event_mobs_killed` és a Jar-számláló közötti játékbeli
  kereszt-ellenőrzést nem láttuk; a gyakorlat szerint a szám önmagában él (a
  350-as érték hibátlanul betöltött és persistálódott).

## Amit nem csináltunk

- A repó kódjába nem nyúltunk (a próbaszkript a session temp mappában maradt,
  a 364-es doksiban rögzített módon); a gyűjtő/supervisor/dashboard nem futott.
- A konténer-írás kizárólag a felhasználó által kért próbakörökben, előzetes
  SHA-256 manifestes biztonsági mentéssel történt; bármelyik állapot
  visszaállítható a `save-backups` mappából (`--revert`).
- A felhői API-t közvetlenül nem érintettük; a felhői viselkedést a játék
  saját szinkronján keresztül figyeltük.
