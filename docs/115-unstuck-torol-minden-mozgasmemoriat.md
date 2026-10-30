# Unstuck után minden régi mozgásmemória törlődik

## Megfigyelés

A `083724-play` futásban az Unstuck sikeresen eltüntette a Settings panelt, a bot
kivárta a gyógyulást és beállította a 120 döntéses helyi szabad felderítést. Ennek
ellenére a következő döntéseket egy korábbról megmaradt statikus kiszabadítási fázis
kapta meg: a régi `(0.98, 0.21)` irányú terv elsőbbséget élvezett a friss spirállal
szemben.

## Következtetés

Az Unstuck nem egyszerű részlépés, hanem helyzetfolytonosságot megszakító teleport.
A régi képernyőhöz, falhoz, célhoz vagy kerülőhöz tartozó minden mozgásmemória ekkor
érvénytelen.

## Javítás

A sikeres, 30 képes helyreállítás végén a bot most törli:

- a statikus iránypróbát és mozgásbizonyítékát;
- a minimap- és célkerülőket;
- a blokkolt terület/útvonal terveit és hűtését;
- a hozzájuk tartozó irány- és fázisállapotokat.

Csak ezután indul a 120 döntéses helyi szabad felderítés. Így az új spawn valóban
új navigációs epizódként kezdődik.

## Visszajátszásos igazolás

A javított `084443-replay` 74. döntése lezárta az Unstuck-várakozást, a 75. döntés
pedig közvetlenül a helyi szabad felderítést választotta. A korábbi futásban itt
megjelent statikus falmenti swipe többé nem futott le.
