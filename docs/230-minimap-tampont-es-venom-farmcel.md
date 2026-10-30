# Minimap-támpont és Venom-farmcél — 2026-09-19

## Hipotézis

A helyi optikai térkép önmagában nem választ jó farmcélt. Az általános külső
piros fegyvermutató ismételten északnyugati kerítéshez küldte a botot, miközben
a korábban legyőzött3,06K-s őr máshol volt. A30perces ciklus alapján ennek
ellenőrzése indokoltabb, mint a kimerültDOCvagy a két változatlanul vesztes boss.

## Támpontok és skála

`140122-71600bcd-play/21`: narancs koponya középpont(540;73,5), a zöldVenom-
fegyverjel(544,5;139),637×882es képen. A zöld ikon és az őr helyének megfelelése
képi munkahipotézis a fegyverzsákmány és a közelség alapján; az új visszatérés
eredménye külön igazolja vagy cáfolja. A háromszög a játékos.

Új sablonfelismerő két szín+alak mintát kezel: koponya és zöld fegyverikon.
Az arc sötét szemrészlete/kerete, illetve a kártya belső nyila is számít;
egy sárga vagy zöld folt önmagában nem találat.27alatti átlageltérés és a
következő különböző helyű találattól8nyi előny kell. A sötétMailboxképen nincs
elfogadott találat. A pozíció minimappixelben van, nem swipe-számban.

## Vezérlés

Elsőbbségi, durva farmirány a Venomikonhoz; ha az nem látszik, a koponyához
viszonyított(4,5;65,5)eltolás. Ez **nem járhatósági bizonyíték**. Az új helyi
térkép méri az elmozdulást és kerülheti a falat. Hatminimappixelen belül csak
megérkezést jelölünk, majd180sellenőrzési hűtés; nem automatikus győzelmet.
Harc, visszavonulás, közeli cél ésUImegelőzi ezt. Mentés:`docs/landmark-goals.json`.

A koponya nem geodéziai fixpont: ellenségmozgás, takarás és térképszél
torzíthatja. Ezért durva céliránynak használjuk, nem kapcsolunk össze pusztán
ebből két külön magasságú vagy bizonytalan helyi térképrészt.

## Nyitott élő ellenőrzés

Valóban a3,06K-s őrhöz érkezik-e? Újratermelődött-e? Mi lesz a következő
cooldown és jutalom? A teljes bejárt út irányított gráfként megmaradjon;
gyorsító mellett is az aktuális képi/minihelyzet szabja meg a haladást.

## Élő siker — 144057-cee913bb-play

0–13: tizennégy friss minimapmérésből vezetett,0,62s-os input a nyugati
kerítéstől keletre.14: a3,06K-s őr valóban megjelent a megjósolt környéken,
a harci stratégia átvette a vezérlést.18: **Venom Shard16 LEVEL UP,
Damage525→560**, alatta29m58s. SajátHP5840, csak a16képen5830.
A zöld fegyverikon→Venom-őr megfelelést ez a külön visszatérés igazolta.

A korábbi~30perces újratermelődés most újra30percet adott, szemben aDOC hosszú
napi időzítőjével. A következő célidő nagyjából15:12helyi idő, nem3perc múlva.
Ezt külön tartós cooldownként kell kezelni; a180s érkezési hűtés csak
bizonytalan célhiányra való, nem igazolt győzelemre.
