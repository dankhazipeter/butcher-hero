# Egyszerű tesztparancs, klónozói hook és PR-CI — 2026-10-30

A felhasználó kiegészítése: a tesztek könnyen futtathatók és AGENTS-ben
kötelezőek legyenek; a klónozók és PR-beküldők is még saját gépükön lássák
a hibát. A297-es valódi képi regresszió változatlanul megmaradt.

## Három használható parancs

- `make setup`: egyszeri hook-telepítés klónozás után.
- `make test`: hook-telepítés és teljes ellenőrzés egyben.
- `make test-vision`: hook-telepítés és gyors képi részellenőrzés. Nem teljes kapu.

A közvetlen `./scripts/check-rewards.sh` továbbra is működik. A tesztek
nem játszanak, nem indítanak megfigyelést és nem írnak éles jutalomnaplóba.
Az AGENTS.md kötelezőként rögzíti ezt, a CONTRIBUTING.md leírja új
közreműködőknek is, a PR-sablon ellenőrzőlistát ad.

## GitHubon is ugyanaz a teszt

`.github/workflows/reward-tests.yml`: minden push, minden PR és kézi
workflowindítás. macos-15környezet (AppleVision miatt), Python3.13, Node24;
parancs `make test`. A check neve stabil: `Reward tests (macOS)`.
Nincs útvonal szerinti kihagyás vagy továbbengedő hibaelnyelés.

Az actions/checkout, setup-python, setup-node hivatalos v7verzióit
ellenőriztük, majd a tényleges commitSHA-t rögzítettük. Csak contents:read
jogosultság, checkoutpersist-credentials:false; nincs titokhasználat,
publikálás, játékfuttatás vagy privilegizált pull_request_target.

Hivatalos actionforrások: [checkout](https://github.com/actions/checkout),
[setup-python](https://github.com/actions/setup-python),
[setup-node](https://github.com/actions/setup-node).

## Amit a repófájl önmagában nem tud kikényszeríteni

A helyi hookok nem aktiválódnak klónozáskor: a közreműködő futtassa a
setupot vagy a tesztet. Ezt nem próbáljuk Git-biztonságot megkerülve megoldani.
A CI helyi hook nélkül is jelez a PR-on; forkból az első futás kézi
jóváhagyásra várhat. Ez nem tesztsiker.
[GitHub fork-jóváhagyás](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/approve-runs-from-forks).

Hibás ellenőrzés melletti merge tényleges tiltásához a tulajdonosnak a
Rulesets/branchprotection alatt requiredcheckként kell megadnia a
`Reward tests (macOS)` ellenőrzést. Ezt nem módosítottuk hallgatólagosan,
mert a korábban kért közvetlenmain-push lehetőségét is érintheti.
Nem állítjuk, hogy már létezik aktív szerveroldali merge-tilalom.
[GitHub required checks](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches#require-status-checks-before-merging).

A helyi PASS, a workflow szintaktikai ellenőrzése és a tényleges GitHubCI
eredménye külön bizonyíték. A GitHub-futás sikerét csak a távoli ellenőrzés
alapján tekintjük igazoltnak; korábbi helyi eredményből nem következtetjük ki.

Helyi ellenőrzés: a workflowYAML sikeresen beolvasható, a közös `make test`
parancs és read-only jogosultság ellenőrizve. A tényleges `make test` is
sikeres:17Swift (27képes korpusz),13statisztika,3Gitkapu,5Node és két
JSszintaxisellenőrzés. A commit/push külön izolált ellenőrzése ugyanezt futtatja.
