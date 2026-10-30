# Butcher Hero — új kezdet, 2026-10-29

## Verziókezelés

GitHub: [dankhazipeter/butcher-hero](https://github.com/dankhazipeter/butcher-hero).
Egyelőre amainágat használjuk; minden lezárt változtatási kör után
automatikus commit és `git push origin main` készül, külön kérés nélkül.
Nyers futások, naplók és buildfájlok helyben maradnak; a kód, tesztek és
dokumentáció követve vannak. [Bekötési jegyzet](docs/290-github-main-elso-feltoltes.md).

## Free-jutalom figyelő — 2026-10-30

Fejlesztési ellenőrzés: `./scripts/check-rewards.sh` (macOS14+, Swift5.9+,
Python3.10+, Node18+). Új klón után egyszer: `./scripts/install-git-hooks.sh`.
Ezután commit ÉS push előtt automatikus tesztkapu fut; bármely hiba megállítja
a műveletet. A kapu az index/feltöltendő commit külön másolatát ellenőrzi,
nem a futó játékot. A27valódi mintakép elvárt eredménye:
[`tests/reward-reading-corpus.json`](tests/reward-reading-corpus.json).
[Mintabővítés és működés](docs/297-kepi-regresszios-korpusz-es-tesztkapu.md).

Élő statisztika: [helyi jutalomnézet](http://127.0.0.1:8765/).
Indítása: `./scripts/start-reward-dashboard.sh` (Python3.10+, külön csomag nélkül).
Látható lapon2s-onként frissül a helyi naplóból. Alapból csak a mostani
gyűjtőfutást mutatja; kézi oldalfrissítés nem kell. Részletek: [292](docs/292-elo-jutalomstatisztika.md).
Közös darabszámgrafikon is összehasonlítja a nyolc jutalomtípus gyakoriságát,
darabbal és aránnyal, a statértékek nagyságától függetlenül: [295](docs/295-kozos-darabszamgrafikon.md).

Az első automatizáció elkészült: másodpercenként figyeli a bal oldali event
alattiFree-jutalmat, átveszi és naplózza a8jutalomtípus egyikeként.
Most csak ez fut; a korábbi teljes játékbot nem aktív.

Kézi húzás közben várakozik. Elengedés után ellenőrzi újra aFreejutalmat;
ha kattintás után megmaradt a kártya,1másodperc múlva újrapróbálja.
Csak a két friss játékképen eltűnt kártyát könyveli, claimenként egyszer.
[Húzásvédelem és újrapróba részletei](docs/286-kezi-huzasvedelem-es-free-ujraproba.md).

Indítás: `./scripts/start-free-rewards.sh`, leállítás: `./scripts/stop-free-rewards.sh`.
Terminálban közvetlenül: `.build/release/ButcherHeroAutomation watch-free --interval 1`.
Összesítés: `.build/release/ButcherHeroAutomation stats --from <ISO8601> --to <ISO8601>`.
Napló: `data/free-rewards/events.jsonl`, státusz: `data/free-rewards/state.json`.
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
