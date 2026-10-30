# Stratégiai respawn: zöld nézeti újracélzás és oldalkerülés

## Első teljes élő megközelítési mérés

A `20260829-061234-play` futásban a helyi 92/192 elitazonosító öt találkozás után,
a 83. eseménynél sikeresen elindította a stratégiai újraéledést. A karakter az elit
irányába haladt, a távolság 258-ról 165 pixelre csökkent. Ez igazolja, hogy a jobb
oldali elit fizikailag elérhető, nem a lezárt fal túloldalán áll.

Ezután két új probléma jelent meg:

- a kamera zöld területre mozdulásakor az `orangeRockBiomeVisible` hamis lett, noha
  a lezárt Island 4 HUD és ugyanaz a 192-es elit megmaradt;
- bossjel nélkül a respawnmód a régi `(0,99; -0,11)` irányt tartotta, miközben az
  elit ténylegesen jobbra-felfelé került. A láda/korlát mellett 165–203 pixel között
  ingázott, sérülés nélkül.

## Javítás

A dokumentált helyi elitazonosítóhoz a lezárt Island 4 HUD elég; a változó háttér
narancsszikla-jelzője többé nem feltétel. Így a látható 92/192 elit minden képen
frissíti a közelítési vektort.

A respawnmód külön távolságmemóriát kapott. Ha hat végrehajtott közelítés alatt
nincs legalább 6 pixeles javulás, öt lépésnyi, a cél függőleges oldala felé erősített
oldalkerülést indít, majd eldobja a régi távolságot és újraméri a célt. 95 pixelen
belül vagy friss sebzésnél továbbra is helyben várja az automata harcot.

## Ellenőrizendő élő sorrend

1. öt helyi elit-találkozás;
2. pontosan újracélzott közelítés a zöld nézetben;
3. szükség esetén oldalkerülés;
4. első sebzés, halál/HUD-átmenet;
5. teljes HP-s Meadowlands-újraéledés és új biztonságos farmcél.
