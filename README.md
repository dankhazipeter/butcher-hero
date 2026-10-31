# Butcher Hero — új kezdet, 2026-10-29

## Setup / Getting started

Full English installation and usage instructions, including prerequisites,
permissions, build/start/stop commands, the dashboard, logs and troubleshooting,
are in [AGENTS.md](AGENTS.md#setup-and-usage--for-users-contributors-and-their-ai-assistants-315).
You can ask an AI coding assistant to read that guide and walk you through
setup and what the tool does. Reading the guide does not start the program.

After setup and the release build, run both services in your own Terminal:

```sh
make start
```

Leave that Terminal open. It shows the collector/dashboard output and
progress; **Ctrl+C stops both**. From another terminal: `make status` or
`make stop`. Existing statistics continue by default. The dashboard is at
http://127.0.0.1:8765/; this does not launch the game automatically.

For a short command from **any directory**, run `make install-cli` once,
then `butcher-hero start`, `butcher-hero status` or `butcher-hero stop`.
The command is a user-local symlink into this checkout. If `~/.local/bin`
is not on PATH, use `~/.local/bin/butcher-hero start`; the installer prints
an optional PATH command and never edits your shell configuration.
Alternatively, without installation: `make -C /path/to/checkout start`
(quote paths containing spaces). Use `make start PORT=8766` for another
port. A separately running collector or occupied port must be stopped by
its owner first; the launcher does not take over unrelated processes.
Details: [Terminal launcher](docs/326-kozos-terminal-indito.md).

FREE rewards require the game's **No Ads** purchase. According to the
maintainer, those tasks do not appear without it, so the FREE branch stays
idle while geode opening can still work in the same watcher. No separate
crystal-only flag or purchase-receipt detector is needed for that behaviour.

## Verziókezelés

GitHub: [dankhazipeter/butcher-hero](https://github.com/dankhazipeter/butcher-hero).
Egyelőre amainágat használjuk; minden lezárt változtatási kör után
automatikus commit és `git push origin main` készül, külön kérés nélkül.
Nyers futások, naplók és buildfájlok helyben maradnak; a kód, tesztek és
dokumentáció követve vannak. [Bekötési jegyzet](docs/290-github-main-elso-feltoltes.md).

## Free-jutalom figyelő — 2026-10-31

Fejlesztési ellenőrzés: `make test` (macOS14+, Swift5.9+,
Python3.10+, Node18+). Új klón után egyszer: `make setup`.
Szükséges OCR-függőség: Tesseract5 + angol modell (`brew install tesseract`).
Ezután commit ÉS push előtt automatikus tesztkapu fut; bármely hiba megállítja
a műveletet. A kapu az index/feltöltendő commit külön másolatát ellenőrzi,
nem a futó játékot. Az54valódi mintakép elvárt eredménye:
[`tests/reward-reading-corpus.json`](tests/reward-reading-corpus.json).
[Mintabővítés és működés](docs/297-kepi-regresszios-korpusz-es-tesztkapu.md).
Minden push és PR ugyanazt a tesztet futtatja GitHubon is.
[Közreműködői útmutató](CONTRIBUTING.md).

Élő statisztika: [helyi jutalomnézet](http://127.0.0.1:8765/).
A játék külön állapotsávot kapott: „A játék nem fut”, nem található,
ablaka nem látható, fut vagy nem ellenőrizhető. Biztosan telepített, leállt
játékhoz **Játék indítása** gomb jelenik meg. Csak kattintásra nyitja meg
a játékot; a gyűjtőt nem indítja el és a statisztikát nem nullázza.
A napló továbbra csak olvasható. [Játékállapot és indítás](docs/320-jatekallapot-es-inditogomb.md).
A tetején külön színes állapotsáv mutatja, hogy a gyűjtő fut, leállt vagy
várakozik, az utolsó sikeres képolvasás idejével. Elavult adat vagy kapcsolat-
hiba nem jelenhet meg működő gyűjtésként. [Állapotjelzés részletei](docs/304-lathato-gyujtoallapot.md).
Indítása: `./scripts/start-reward-dashboard.sh` (Python3.10+, külön csomag nélkül).
Látható lapon2s-onként frissül a helyi naplóból. Alapból csak a mostani
gyűjtőfutást mutatja; kézi oldalfrissítés nem kell. Részletek: [292](docs/292-elo-jutalomstatisztika.md).
Közös darabszámgrafikon is összehasonlítja a nyolc jutalomtípus gyakoriságát,
darabbal és aránnyal, a statértékek nagyságától függetlenül: [295](docs/295-kozos-darabszamgrafikon.md).

Az első automatizáció elkészült: másodpercenként figyeli a bal oldali event
alattiFree-jutalmat, átveszi és naplózza a8jutalomtípus egyikeként.
Ugyanez a figyelő a piros ponttal jelzett kristályt is megnyitja az engedélyezett
x1 → feltörés → Continue → bezárás sorrendben, friss képi ellenőrzésekkel.
A korábbi teljes játékbot nem aktív. [Kristályfolyamat és korlátok](docs/313-kristalygyujtes-es-kozos-vezerles.md).
A pöttyöt összefüggő piros körként, fehér gyűrűvel vizsgálja, nem külön
piros/fehér konfettipixelekből. A saját megnyitású, ismert üres kristálypanelt
bezárja jutalomkönyvelés nélkül; ismeretlen vagy kézi panelt nem vesz át.
[Konfetti és beragadás javítása](docs/322-kristaly-konfetti-es-ures-panel.md).
Az ismert DiamondLeague eseményzáráskor aNO,THANKS, majd az összesítő
CONTINUEgombját kezeli; áras ajánlatokra nem kattint. Két frissHUD-kép
után folytatja a gyűjtést. [Eseményzáró képernyők](docs/317-event-vege-kepernyok.md).
Külön napló: `data/crystal-rewards/events.jsonl` és `evidence/`; a kristály
nem növeli a bal oldali Free-statisztikát. A `CrystalTests` valódi képei és
állapotsortesztjei ugyanabban a `make test` / commit / push / PR-kapuban futnak.

Kézi húzás közben várakozik. Elengedés után ellenőrzi újra aFreejutalmat;
ha kattintás után megmaradt a kártya,1másodperc múlva újrapróbálja.
Csak a két friss játékképen eltűnt kártyát könyveli, claimenként egyszer.
[Húzásvédelem és újrapróba részletei](docs/286-kezi-huzasvedelem-es-free-ujraproba.md).

Több kijelzőn a friss Quartz-ablakkeretet és a kurzor tényleges célbaérését
is ellenőrzi; alvó/hiányzó kijelző vagy elmozdult ablak mellett nem kattint.
A külsőmonitoros teljes élő ellenőrzés még nyitott; [koordinátavédelem és napló](docs/321-kulso-kijelzo-inputgeometria.md).

Indítás: `./scripts/start-free-rewards.sh`, leállítás: `./scripts/stop-free-rewards.sh`.
Az indítót tartós terminálmunkamenetben hagyjuk futni: felügyeli és elakadáskor
újraindítja a saját gyűjtőjét. Technikai folytatás: `--resume-run`.
A tesztek közben nem állítjuk le; a kéziSTOPa felügyelőt is leállítja.
[Felügyelet és kiesések tanulságai](docs/300-gyujtes-helyreallitasa-es-felugyelete.md).
Az aktív képolvasó elsőként képiFREEsablonokat használ, aTesseract
szűkített tartalék; a számokat saját játékbeli glyphmintákból olvassa.
Friss, korlátozott újrapróba és végsőképből könyvelés védi a Health-átvételt.
[A kimaradások javítása és bizonyítékai](docs/311-free-kepi-felismeres-es-ujraproba.md).
Nincs AppleVisionOCRhívás ebben a körben.
[A fagyó képolvasó kiváltása](docs/303-vision-kivaltasa-es-szamjegymintak.md).
Terminálban közvetlenül: `.build/release/ButcherHeroAutomation watch-free --interval 1`.
Összesítés: `.build/release/ButcherHeroAutomation stats --from <ISO8601> --to <ISO8601>`.
Napló: `data/free-rewards/events.jsonl`, státusz: `data/free-rewards/state.json`.
Eseményablakok külön naplója: `data/event-dismissals/events.jsonl`.
[Részletes leírás és élő teszt](docs/282-nyolc-free-jutalom-es-naplozas.md).

Az alábbi első napi előkészítés már történeti.

A frissített játékhoz új taktikát építünk a felhasználó lépéseiből és a kért
képernyőképekből. Most nincs automatikus játék vagy folyamatos megfigyelés;
az első lépésre várunk.

- [Aktív projektutasítások](AGENTS.md)
- [Újrakezdés és első kért kép](docs/280-frissitett-jatek-tiszta-kezdet.md)
- [Tudásbázis](docs/README.md)
- [Munkamenet állapota](docs/session-state.json)
- [Visszaállítható archívum](docs/archive/2026-10-29-before-restart/README.md)

A korábbi kód, tesztek és felvételek megmaradtak. A régi felismerés és vezérlés
új játékverziós ellenőrzésre szorul.
