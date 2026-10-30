# Kite-oló elit és közelharci sprint

## Élő mozgásminta

A `20260829-062107-play` javított újracélzása és oldalkerülése működött: a bot a
192-es elitet többször 124–137 pixelre közelítette. Az ellenfél ezután egyetlen
képpár alatt rendszeresen 180–206 pixelre nyitotta a távolságot. Példák:

- 110–114. esemény: 131 pixel, majd a 116. esemény 204;
- 130–134. esemény: 148 pixel, majd a 136. esemény 170;
- 196–197. esemény: 126/124 pixel, majd a 199. esemény 185.

A cél teljes HP-n maradt, a játékos sem kapott sebzést. Ez erős bizonyíték arra,
hogy az elit mozgó/kite-oló ellenfél, és a 0,56 másodperces közelítések között ki tud
lépni a közelharci tartományból.

## Döntés

Stratégiai respawn közben:

- 165 pixelen kívül 0,72 másodperces folyamatos célkövetés;
- 165 pixelen belül 1,10 másodperces sprint;
- 95 pixelen belül vagy friss sebzésnél továbbra is input nélküli automata harc.

A hosszabb swipe csak a már explicit respawnmódban él; normál farmnál és a felhasználó
aktivitási őrénél semmit nem változtat. A cél a 124 pixeles távolságplató átlépése,
nem az általános mozgás felgyorsítása.
