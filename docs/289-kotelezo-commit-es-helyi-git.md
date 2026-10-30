# Kötelező commit és helyi Git — 2026-10-30

291FELÜLÍRÁS:az új állandó felhasználói utasítás szerint minden lezárt
változtatási kör után automatikus commit ÉS main-push kell, külön kérés nélkül.
[291 — automatikus feltöltés és folytatás](291-automatikus-commit-push-es-free-ujrainditas.md).

Frissebb állapot: a felhasználó megadta aGitHub-célt, a remote és az első
main-push elkészült. [290 — GitHub main](290-github-main-elso-feltoltes.md).
Az alábbi„nincs remote/push”a helyi tároló létrehozásának akkori állapota.

## Felhasználói kérés

Minden változtatási kör után commit készüljön. A felhasználó hamarosan
távoli repót hoz létre, később oda pusholhatunk. A játék leállítva marad.

## Döntés és hatókör

Ellenőrzéskor a projekt nem voltGit-tároló. A kért helyi commitolás
előfeltételeként helyi tárolót hozunk létre, kezdeti állapotmentéssel.
Az első commit a már meglévő forrásokat, teszteket, eszközöket és tudásbázist
is összefogja; nem rekonstruálunk utólag mesterséges fejlesztési történetet.
A meglévőGit-szerzői beállítás használható, nem változtatjuk meg.

`.gitignore`:44GBnyi `docs/runs` és297MBnyi `data` futási anyag, továbbá
`outputs`, `.build` és helyi titokfájlok kimaradnak. Nem töröltünk adatot.
A két aktív teszthez szükséges régi képernyőkép célzott kivétellel bekerül;
a többi címkézett referencia a `docs/references` alatt eleve követhető.
A történeti/archív szöveges tudásbázist nem dobjuk el.

## Állandó munkaszabály

Minden logikailag lezárt változtatási kör: releváns teszt/ellenőrzés,
naprakészMD-dokumentáció, diff-ellenőrzés, célzott staging, egy beszédes
commit, majd végső státuszellenőrzés. Olvasás miatt nincs üres commit.
Más felhasználói változtatást nem keverünk a saját körünkbe. Sikertelen
commitot blokkoló ténnyel jelentünk. Külső repó/létrehozás/push most nincs.

Az eredményt a helyiGit-napló igazolja. Az első commit saját hashét nem
írjuk ugyanabba a commitba, mert az önhivatkozó lenne.

## Ellenőrzés az induló commit előtt

453követésre jelölt fájl, kb.19MB; a két célzott kép kivételével nincs
`docs/runs`állomány, és nincs `data`, `outputs` vagy `.build` a stagingben.
A gyakori privátkulcs-/tokenminták ellenőrzése nem jelzett találatot;
ez célzott ellenőrzés, nem teljes titokmentességi garancia.
`swift test --filter RewardTests`:11tesztPASS, kb.1s tesztidő.

A teljes kezdeti diff néhány régiMD-fájl végén fölösleges üres sort jelez;
ezek történeti formázását nem módosítottuk. E meglévő blank-at-eof
figyelmeztetések kivételével a staged whitespace-ellenőrzés tiszta.
TávoliGit-cím nincs beállítva; push nem történt. A játék leállítva maradt.
