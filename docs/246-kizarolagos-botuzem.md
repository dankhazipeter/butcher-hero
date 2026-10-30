# Kizárólagos botüzem — 2026-09-19

Felhasználói utasítás: „nem kell rám várni. játsszon úgy a bot, mint ha csak
ő lenne a gépnél!” Ez felülírja a korábbi géphasználat-védelmi preferenciát.

Minden további play/nudge/scroll indítás `--min-user-idle 0` értékkel.
Az egér és a fókusz átvehető; a chatben kért stop változatlanul azonnali.
A háttérbemenet ettől nem lett működőképes: továbbra előtér-inputot használunk.
A0küszöb már támogatott, nem kell új inputmechanizmus vagy hosszú fejlesztés.

Mérés: előző60s kör95képből88aktivitás-várakozás,7swipe (245).
A következő körben az aktivitás-várakozásnak nullára kell csökkennie.
Ez a várakozási veszteséget oldja meg, az útvonaltervezés hibáit nem.

164311-play42képből0felhasználói aktivitás miatti várakozás. Beállítás igazolt.
A kör második feleHP-takarási hibával állt; külön247javítás, nem inputvédelmi késés.
