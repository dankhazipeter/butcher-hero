# Respawn-oldalkerülés oldalváltással

## Élő ellenpélda az egyoldalas kerülőre

A `20260829-062633-play` stratégiai közelítésében a hosszú sprint sem oldotta fel
minden helyzetben az akadályt: a 83–86. eseményeken a cél 150 pixelen, azonos képi
koordinátán maradt több 1,10 másodperces swipe ellenére. Ez nem kite-olás, hanem
statikus környezeti ütközés.

Az első felfelé-jobbra oldalkerülés lefutott, de a következő stagnálás ugyanazt az
oldalt választotta újra. A bot így a híd/láda akadály ugyanazon oldalát ismételte,
és a geometriai zsákutca fennmaradt.

## Döntés

A stratégiai respawn oldalkerülési előjele minden ciklus után vált:

1. lefelé-jobbra kerülés;
2. felfelé-jobbra kerülés;
3. ismét lefelé, és így tovább.

Az `x` komponens továbbra is a boss felé mutat, csak a függőleges kerülőoldal vált.
Új stratégiai mód kezdetén az előjel alaphelyzetbe áll. A sprint-, távolság- és
95 pixeles harci kapuk változatlanok.
