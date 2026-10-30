# Titan-kijárat 28 lépéses korlátozása

## Élő cáfolat

A `20260829-125610-play` 51. eseményétől az ellenirányú kijárat élőben helyesen
eltávolította a karaktert az oltártól. A lila minimapjel azonban 90 döntés után sem
tűnt el: iránytűként a minimap peremén maradt. Emiatt a korlátlan kijárati szabály a
91. esemény környékére egy új, több ezer HP-s boss-területhez, majd a déli térképszél
akadályához tolta a karaktert.

A bossőr elsőbbsége működött és sérülés nélkül eltávolodott a veszélytől, de utána az
oltár elleniránya ismét átvette a vezérlést. Ez bizonyítja, hogy a lila jel eltűnésére
várni nem megfelelő lezárási feltétel.

## Új korlát

A Titan-feladat felismerése most 28 tényleges kijárati swipe-ot enged. Csak olyan
döntés fogyasztja a keretet, amely valóban az oltár ellenirányába indul; közeli cél,
boss, sérülés vagy statikus akadálykerülés nem égeti el. A 28 lépés után:

- az oltár 600 döntéses hűtése tovább él;
- a lila ikont továbbra sem követjük vissza;
- a kijárati ellenirány megszűnik;
- a bot ismét piros/zöld célokat, küldetésutat és szabad gemfelderítést használ.

Ha a karakter később fizikailag újra az oltárhoz ér és a teljes Titan-feladat ismét
látszik, új 28 lépéses kijárat indulhat. Ez a visszatérésből való kiszabadulást megőrzi,
de a globális lila iránytű nem uralhatja a teljes térképezést.

## Ellenőrzés

A release build sikeresen elkészült. Az azonos képekből álló `125857-replay` a
statikussági őr elsőbbségét is megmutatta: ismételt mozdulatlan képen a bot nem vakon
fogyasztotta tovább a kijárati lépéseket, hanem akadálykerülést és később Unstuck-
helyreállítást választott. A tényleges 28 mozgó kijárati lépés élő ellenőrzése
`20260829-125921-play` néven indult.

## Élő igazolás

A `125921-play` pontosan a tervezett állapotgépet adta. A 23–37. esemény 15 kijárati
swipe-ot hajtott végre, a 38–41. esemény statikus akadálykerülést futtatott keretfogyás
nélkül, a 42–53. esemény további 12 kijárati swipe-ot, az 58. pedig az utolsó, 28.
lépést adta. Az 59. esemény már automatikusan visszatért a `Titan 0/7 gemkeresés`
szabad felderítéséhez. A korlát és a megszakítható számlálás élőben igazolt.

Pontosítás: a 72–75. esemény ismét látható feladatbuboréka a keretet tévesen
újratöltötte. A 145. fejezet javítása szerint 28-as keret csak új, korábban nem
lehűtött oltáreléréskor indulhat; aktív 600-as hűtés alatt nem.
