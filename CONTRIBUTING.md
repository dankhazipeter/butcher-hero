# Közreműködés és kötelező tesztek

A regressziós tesztek a már igazolt működést védik a nyilvános repóban:
a beküldött PR-ból látszódjon, ha egy korábbi helyes felismerés, átvételi
szabály vagy statisztikai eredmény elromlik. A PR saját, friss ellenőrzését
kell sikeresen teljesíteni, nem elegendő a main egy korábbi zöld futása.

macOS14+, Swift5.9+, Python3.10+, Node18+ szükséges. A felismerés Apple
képi keretrendszereit használja, ezért ez a csomag nem Linuxon fut. Nem kell hozzá elindítani
a játékot, és a tesztek soha nem kattintanak vagy írnak éles jutalomnaplóba.
Az aktívFreefelismerés nem AppleVisionOCR: képiFREEsablon az elsődleges,
Tesseract5szigorú tartalék, a számokat verziózott játékbeli számjegyminták
olvassák. A jelvénykalibráció forrásait és a külön ellenőrző képeket
őrizzük meg; automatikus teszt nem írhat új maszkot vagy elvárt címkét. Függőség:
`brew install tesseract` (angol modell is szükséges; a Homebrewcsomag része).

Klónozás után egyszer:

```sh
make setup
```

Ez bekapcsolja a commit ÉS push előtt futó helyi tesztkapukat. A Git biztonsági
működése miatt a hook nem aktiválódik magától klónozáskor. Eltérő, már beállított
hookrendszert a telepítő nem ír felül; azzal előbb össze kell integrálni.

Teljes teszt egyetlen paranccsal, amely a hookokat is bekapcsolja:

```sh
make test
```

Gyors, csak képi ellenőrzés fejlesztés közben: `make test-vision`.
A teljes kör ettől még kötelező; a commit/push kapu mindig azt futtatja.
Közvetlenül, Make nélkül is elérhető: `./scripts/check-rewards.sh`.

## Képfelismerő változtatása

Az54valódi minta elvárásai: `tests/reward-reading-corpus.json`.
Mind a8jutalomtípusból legalább két külön kép maradjon. Új esethez
vizuálisan ellenőrzött valódi kép és rögzített címke kell. Nem írjuk át
az elvárt eredményt az aktuális programválaszhoz. Hibajavításnál előbb
piros, utána zöld teszt; a negatív és takart esetek is megmaradnak.
[Részletes munkamód](docs/297-kepi-regresszios-korpusz-es-tesztkapu.md).

## Pull request

- PR előtt `make test` sikeresen lefutott. A hookokat ne kerüld meg.
- Kód, releváns teszt és magyar tudásbázis együtt frissüljön az AGENTS.md szerint.
- Nyers napló, összes képfelvétel, build, jelszó vagy egyéb titok ne kerüljön Gitbe.
- A GitHub `Reward regression` workflow minden pushnál és PR-nál ugyanazt
  a tesztparancsot futtatja, `Reward tests (macOS)` ellenőrzésnéven.
  Akkor is jelez, ha a beküldő nem telepített helyi hookot.
- Forkból érkező első PR futásához GitHub-karbantartói jóváhagyás kellhet;
  ez nem sikeres teszt. A zöld ellenőrzésig ne tekintsük ellenőrzöttnek a PR-t.

A workflow önmagában nem tiltja a merge-et. Ehhez a repó Rulesets/branch
protection beállításában kötelező ellenőrzésként kell kijelölni a
`Reward tests (macOS)` checket. Ez külön tulajdonosi repóbeállítás;
nem kapcsoljuk be hallgatólagosan, mert a mostani közvetlen main-push
munkarendet is érintheti. A jelenlegi projektgazdai munkamód továbbra is
automatikus commit és push azAGENTS.md szerint.
