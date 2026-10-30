# Gyorsabb fakontaktus — 2026-09-19

172137/2–8és172354/37–43: közel álló passzív fa HP-ja nem változik,
mégis hét megfigyelést vár a bot a0,18s érintkezési korrekció előtt.
A korrekció után172137/9és172354/44tényleges ölés. A távolságbecslés
nem jelent biztos fegyverkontaktust; az ismételt várakozás mérhető veszteség.

Új CloseContactPolicy: legalább0,25fatest-bizonyosság, biztos1–800HP,
nulla közeli fenyegetés éslegalább90%sajátHP mellett két megfigyelés után
ugyanaz a rövid0,18s korrekció. Észlelt sebzés továbbra azonnali várakozást
és számlálóresetet ad. Humanoid, nagy/hiányzóHP vagy rossz sajátHP: marad7.
Ez kontaktusgyorsítás, nem új vak megközelítés vagy nagyobb harci kockázat.

Friss172806-observe/0:5,87K sajátHP, Titan0/7kör mellett. Pontos maximum
panelből még nem ellenőrzött; a korábbi +2/+10szív jutalmak utáni kerekítettHUD.
Következő: célzott teszt,172137replayben korábbi korrekció, rövid élő aratás.

## Ellenőrzés és élő eredmény

Release build, hat CloseContactPolicy egységeset és172137replay: PASS.
A replay legkésőbb4képen korrigál a korábbi8helyett.
173013-play/26–27: élőben egy várókép után már0,18s korrekció;
29képen516találat,+5szív,új3m59s kör. SajátHUD5,89K, tartós kijelzett
maximum5890; ez kerekített érték, nem pontos statpanelmérés.
Az új szabály élő pozitív esete igazolt, nem csak replayeredmény.

Ugyanebben a futásban15és22képen még a régi„nyolclépéses falvégi kerülő”
írta felül a rövid megközelítést. Ok: obstacleMap.adapt a V2-ág előtt,
feltétel nélkül futott. A249„egyetlen tulajdonos” állítása ezért csak a
hosszú navigációra teljesült. Javítás: a régi adaptáló kizárólag explicit
kitingTrial-módban futhat; normál játékban sem közeli megközelítést, sem
biztonsági döntést nem ír át. A V2helyi akadálytérképe megmarad.
