# Island 4 zöld kapuzseb: teljes iránypróba

## Biztos élő megfigyelés

A `20260829-063020-play` futásban az ötödik boss-találkozás után a bot a jobb
oldali 92/192 HP-ként olvasott elitet üldözte. A 43–201. esemény között a játékos
747/747 HP-n maradt, sebzés és HUD-átmenet nélkül. A cél távolsága 155–237 pixel
között ingadozott, de a mentett képeken a híd, a kapuoszlopok, az `UNLOCKS AT
ISLAND 4` felirat és a közelségi láda helyzete változatlan maradt. Maga a fegyveres
elit közben jól láthatóan járőrözött.

Ez megcáfolta azt a feltételezést, hogy a csökkenő cél–képközép-távolság minden
esetben a játékos sikeres közelítése. Ebben a nézetben a távolságváltozást az elit
saját mozgása is előállítja. A lefelé-jobbra, majd felfelé-jobbra ötös kerülő és az
1,10 másodperces sprint sem mozdította ki bizonyíthatóan a hátteret.

## Értelmezés

A karakter az Island 4 feliratos zöld kapu/híd környezetében egy ütközési zsebben
áll. Még ellenőrizendő, hogy az elit ténylegesen a zárhatár túloldalán van-e, vagy
ugyanazon az oldalon járőrözik; a biztos állítás csak az, hogy az eddigi közvetlen
és kétoldalas közelítés nem adott kameramozgást vagy harcot.

## Kísérleti döntés és eredménye

Ebben a pontos helyi aláírásban – lezárt Island 4 HUD, zöld nézet, jobb oldali,
szint/jutalomikon nélküli 90–199 HP-s bossjel – a bot nem indít újabb közvetlen
respawn-üldözést. Ehelyett hat végrehajtott swipe-onként végigpróbálja:

1. le;
2. fel;
3. balra;
4. jobbra;
5. balra-le;
6. balra-fel;
7. jobbra-fel;
8. jobbra-le.

Az élő `063545`, `063920`, `064506`, `064648`, `064840` és `065133` próbákból csak
a bal irány adott érdemi kameramozgást, de az is a lezárt híd/bossoldal felé vitte
a karaktert. A tiszta jobbra, le, fel, két jobboldali átló, valamint a megszakítás
nélküli hosszú jobbra-le átló teljesen statikus maradt. Az iránypróba így lezárt
diagnosztika, nem végleges helyreállítási stratégia.

A végleges megoldás a játék Settings menüjének bizonyított `Unstuck` gombja; lásd
[Settings / Unstuck és gyógyító medence](101-settings-unstuck-es-gyogyito-medence.md).

## Élő ellenőrzés

Az első iránypróba futása `docs/runs/20260829-063545-play`, az összes irányt és
hosszú átlót lezáró utolsó futás `docs/runs/20260829-065133-play`.
