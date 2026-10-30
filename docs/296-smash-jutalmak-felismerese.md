# Smash jutalmak felismerése — 2026-10-30

## Hibajelzés és bizonyíték

A felhasználó látott Smash Damage jutalmat, de a statisztikában nem jelent
meg. Az aktuális futás naplójában a négy 688-as kalapács és három 809-es
pajzsos kalapács átvétele igazolt volt, a típusuk azonban `unknown` maradt.
Így az összes igazolt darabszámban szerepeltek, a smash sorokban nem.

Az asszisztens a mentett eredeti képeket ellenőrizte. A lila kalapács
pajzs nélkül Smash Damage; barna pajzson Smash Defense. Nem a 688/809
összegekből találjuk ki a típust. Tartós, valódi képi referenciák:

- `references/2026-10-30/free-smash-688-green-a.png`
- `references/2026-10-30/free-smash-688-green-b.png`
- `references/2026-10-30/free-smash-688-green-c.png`
- `references/2026-10-30/free-smash-defense-809-green.png`

A régi alak/szín-illesztési hiba 0,488–0,568 között volt, az engedélyezett
maximum pedig 0,48. A zöld pályaháttér kiszűrését külön kipróbáltuk, de
önmagában nem oldotta meg a hibát; ez a kísérlet NEM került a végső kódba.
Biztos következtetés: a régi minták nem fedték le jól ezt az aktuális HUD-ot.

## Javítás

A felismerő két új, eredeti játékképből kalibrált sablont is betölt:
`smash_damage_current.png`, `smash_defense_current.png`. A kalibrálás a
naplózott Free-jelzés geometriai adataiból ugyanazt a kivágást használja,
mint a `RewardVision`. Reprodukálható parancs:
`swift tools/build-reward-icon-templates.swift --current-smash-only`.

A korábbi nyolc statminta és élő referenciák megmaradtak. Az illesztési
maximum és a különbségi küszöb változatlan; nincs általános lazítás vagy
összeg szerinti besorolás. A külön UI-képekhez sem nyúltunk.

## Az aktuális gyűjtés megőrzése

`watch-free --resume-run` technikai újraindításkor `watcher_resumed` eseményt
ír a már megkezdett gyűjtéshez. Első indításkor vagy e kapcsoló nélkül
továbbra is `watcher_started` keletkezik. Így a javítás nem nullázza az élő
nézet „Mostani futás” szűrését: a kezdete továbbra is16:50:44.381Z.

`reconcile --current-run` csak a legutóbbi `watcher_started` utáni, még
bizonytalan tételek eredeti képeit vizsgálja újra. ClaimID-nként az utolsó
kattintási próbát használja, a már korrigált tételeket kihagyja. Eredményként
kizárólag `reward_corrected` sort fűz hozzá, sosem átvételi visszaigazolást.
Az eredeti naplósorok megmaradnak; a korábbi futásokhoz nem nyúltunk.

A fizikai folyamat újraindításakor az előző folyamat megfigyelési hibája
nem marad aktív figyelmeztetésként az oldalon. Ez a státusz elválik a
folytatólagos gyűjtési időszaktól; új valódi hiba továbbra is megjelenik.

## Teszt és élő eredmény

15 Swift-teszt PASS: a három 688-as mintából két külön képen is ellenőrzött
általánosítás; a pajzsos 809-es külön típusként megmarad; minden korábbi
8ikon/18K/18.3K/húzás/elszámolási regresszió sikeres. A CLI-integrációs
teszt igazolja az aktuális körre szűkítést, a régi sorok bájtpontos megőrzését,
a már korrigált elemek kihagyását és a kitalált igazolások hiányát.
13 Python- és5 Node-teszt szintén PASS; releasebuild sikeres.

A2444-es figyelő szabályosan leállt; a stop pillanatában nem volt függő
claim az állapotában. Az új figyelőPID29305, execsession9371,
17:46:41.978Z `watcher_resumed`. Az új folyamatban friss HP- és pierce-
átvételek képi igazolást kaptak, a régi gyűjtés kezdete változatlan maradt.

17:47:28Z körül7 bizonytalan típus pontosítva:4 Smash Damage és3 Smash
Defense. Az API következő pillanatképében Smash Damage4db/+2752,
Smash Defense4db/+3236 (1 korábban is felismert +3 pontosított).
92 igazolt átvétel,0 függő,0 ismeretlen. A közös darabvonal és a nyers
értéksor is magától frissül, az eredeti kattintási időpontra visszavetítve.

A statisztikaszerver execsession72899 alatt fut, ugyanazon helyi címen.
Minden régebbi történeti tétel változatlan. A program futva marad;
új, javítás utáni élő Smash-jutalmat csak konkrét naplósorból állítunk,
a most felsorolt négy a mentett képekből biztosan pontosított átvétel.
