# Első élő stratégiai respawn és a sebzésemlék javítása

## Első valódi aktiválás — `20260829-044928-play`

A stratégiai újraélesztés az ötödik, fejlődés nélküli boss-találkozás után először
élő játékban is aktiválódott. A 132. eseménytől a bot a legutóbb látott boss irányát
tartotta. A 139. esemény pixeles HP-mérése 95%-ot jelzett, majd a 140. esemény tiszta
OCR-je ismét teljes 727 HP-t mutatott. A közelben közben megjelent egy 431 HP-s,
20-szíves fa, de az aktív stratégiai mód helyesen nem váltott át normál farmra.

## Feltárt hiba

Az első találat után a program a `strategicRespawnSawDamage` történeti jelzőt úgy
használta, mintha minden további képen még mindig friss sebzés történne. Emiatt a
143. eseménytől a 120 döntéses időkorlátig helyben várt a „támadó takart” indokkal.
A jelző helyesen bizonyította, hogy a boss egyszer már eltalálta a karaktert, de nem
volt alkalmas annak eldöntésére, hogy éppen most is támadási távolságban áll-e.

Biztos következtetés: az egyszer látott sebzés nem lehet korlátlan helyben várási
feltétel. A boss rövid kitakarása és a játékos gyors regenerációja mellett ezzel a
program végül pont a tervezett útvonal-rövidítést hiúsította meg.

## Javított döntés

- A helyben kivárás csak addig él, amíg a normál `recentDamageFrames` memória tényleg
  friss sebzést jelez.
- Ha ez lejár, a stratégiai mód nem szakad meg: tovább tartja a legutóbbi bossirányt.
- A `strategicRespawnSawDamage` továbbra is történeti bizonyíték marad a mód belső
  állapotához, de önmagában nem blokkol mozgást.
- A jutalom, két tiszta új maximum, biztos újraéledés és a 120 döntéses időkorlát
  változatlan megszakítófeltétel.

## Ellenőrzés

A javított build a teljes `044928-play` képsor visszajátszásán a 142. képtől nem
ragadt helyben: a rövid frisssebzéses ablak után minden végrehajtható döntésben a
legutóbbi bossirányt tartotta. Az új élő build `20260829-045414-play` néven indult.
Ebben a korai +20 fejlődés lenullázta a boss-hurok számlálóját, ezért a teljes
halál–Meadowlands ciklus élő időmérése továbbra is nyitott; a konkrét végtelen várási
hiba azonban megszűnt.

A futás későbbi, második aktiválása valóban folyamatosan mozgott, tehát ezt a javítást
élőben is igazolta. Külön elérhetőségi hibát tárt fel: a cél a lezárt Island 4-fal
túloldalán állt. Ennek javítása és regressziója a
`84-strategiai-respawn-es-island4-elerhetosegi-or.md` dokumentumban található.
