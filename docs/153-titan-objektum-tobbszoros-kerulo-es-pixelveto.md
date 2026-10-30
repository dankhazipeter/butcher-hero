# Titan-objektum: többszörös kerülő és a takart pixelcsík vétója

## Új élő bizonyíték

A `docs/runs/20260829-134633-play` 26. képén új 4.31K kontrollált próba indult.
A 200 HP-s Titan-objektum ismét a karakter és a boss közé került. Az első
hétlépéses kerülő átmenetileg növelte a távolságot, de a közvetlen visszaközelítés
a 39–42. képen ugyanabba a vonalba vitte vissza a karaktert.

A 42. képen közvetlenül látható:

- a boss továbbra is `4.31K` és `500` szívikonos;
- az útban álló objektum továbbra is 200 HP;
- két piros fejsze melletti `0` jelzi a sikertelen automatikus ütéseket;
- a karakter és a zöld csík nagy részét az objektum takarja;
- az Analyzer pixeles tartaléka emiatt 30%-ot becsült, a 43–44. képen azonban
  azonnal 96%, majd friss numerikus 778 jelent meg.

Ez ismét biztosan képi takarás, nem 70%-nyi valódi bosssebzés. A cél HP-ja sem
csökkent, ezért nem volt sikeres támadási ablak.

## Programdöntés

- Az objektumkerülés nem egyszeri többé. Ugyanazon kontrollált próbán belül
  legfeljebb három, kilencképes, váltott oldalú tangenciális kerülő indulhat, ha a
  200-as struktúra ismét a bossvonalba kerül.
- Aktív próba, változatlan bossminimum, 140 pixelen belüli objektív struktúra és
  kizárólag pixeles, 55% alatti HP együtt takarási aláírás. Ilyenkor a taktika az
  utolsó hiteles saját HP-t tartja, nem állít sebzésemléket, és tovább kerüli az
  objektumot.
- Friss numerikus HP-esés vagy tényleges boss-HP-csökkenés ezt a vétót nem kapja;
  valódi sebzésnél a 82%-os burst-megszakítás továbbra is azonnali.

## Regresszió

A `docs/runs/20260829-135021-replay` ugyanazon képsoron:

- a 41. képen elindította a második, váltott oldalú struktúrakerülőt;
- a 42. képen a nyers elemzés 30%-os pixelt látott, de a taktika nem menekült,
  hanem `4310→4310` mellett folytatta a kerülőt;
- a következő képeken 778 HP maradt, kritikus állapot nem keletkezett.

Az élő ellenőrző folyamat: `docs/runs/20260829-135053-play`.
