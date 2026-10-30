# Hatfázisú zsákutca és újraélesztési kiszabadítás

## Élő helyzet

A `20260829-053247-play` és `053646-play` futásokban a karakter a lezárt Island 4
sziklafal jobb oldalának keskeny párkányán maradt. A képen látható 253/632 HP-s
célok a bal, átjárhatatlan oldalon álltak. A bot a jobbra-le határátlót, négy
forgatott átlót, az ellenirányt és a hűtött oldaljárást is végrehajtotta, mégis
ugyanabba a képi helyzetbe tért vissza, fejlődés és sebzés nélkül.

Ez eltér a korábbi sátor–kerítés saroktól: ott két fázis után tényleges
kameramozgás és nyílt mező következett. Itt több teljes fázis minden végrehajtott
swipe-ja statikus maradt, ezért a további körbeforgás várható hozama nulla.

## Döntés

A stratégia külön számlálja a teljesen sikertelen statikus kiszabadítási fázisokat.
Nagyobb kamera-ujjlenyomat-változás vagy egy fázison belüli igazolt mozgás törli a
számlálót. A fázisszám a döntési szövegben is megjelenik, így élőben auditálható.

Hat sikertelen fázis után, csak akkor, ha:

- Island 4-zár és narancsszikla-biombizonyíték is látszik;
- a játékos legalább 90%-os HP-n van;
- nincs közeli, kiemelt 5+ szíves fa;
- korábban láttunk a fal elérhető, jobb oldalán támadót;

a bot a legutóbbi elérhető támadó irányában stratégiai újraéledést indít. A fal bal
36%-ában álló cél soha nem lehet ehhez irány. A támadó rövid takarása nem törli a
jobb oldali utolsó irányt; jutalom, új maximum, halál–HUD-átmenet vagy 120 döntéses
időkorlát továbbra is lezárja a módot.

## Replay és élő ellenőrzés

A `20260829-054307-replay` a `053247-play` teljes képsorán a 103. döntésnél aktiválta
a mentést, majd `(0,99; 0,16)` irányban tartotta a legutóbbi jobb oldali támadót.
A korábbi változat ugyanitt újabb faljáró fázist kezdett.

Az új élő build `20260829-054356-play` néven indult. Következő bizonyítandó sor:
megközelítés → sebzés → automatikus halál/HUD-átmenet → friss teljes HP-s
Meadowlands → első biztonságos fejlődési cél.

## Első élő eredmény

A `054356-play` 100–122. eseménye között nagy képi elmozdulás történt, ezért a
sikertelenfázis-számláló helyesen nullázódott és a respawnmentés nem aktiválódott.
A `frame-00122` már a híd jobb oldalán, a fehér `1/57` láda mellett mutatta a
karaktert, a jobb oldali 192-es elittel együtt. A természetes kiszabadítás tehát
ebben a körben végül sikerült; a hatfázisú respawnág továbbra is csak tartalék.
