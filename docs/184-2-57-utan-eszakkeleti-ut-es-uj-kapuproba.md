# 2/57 után: északkeleti út és új kapupróba

## A ládaszámláló gépi igazolása

A `224235-replay` a `222821-play/82` egyetlen képét elemezte újra. A középső OCR
stabilan kiolvasta a `You found 2/57` és `chests` sorokat, a strukturált
`discoveredChestCount` mező pedig pontosan `2` lett. Ez bizonyítja, hogy az új
detektor nemcsak kézi megfigyelésre, hanem automatikus tartós tanulásra is alkalmas.

## Tartós ágcsere

A `223939-play` első döntése már nem a déli 2/57-es platformágat indította, hanem
az északkeleti zöld ellenfél felé fordult. Az általános akadálytérkép először még
felülírta a konkrét útvonalat; az elsőbbségi kivétel után a `224147-play` 0–55.
döntése megszakítás nélkül tartotta az északkeleti vektort. A korábbi fali zsebből
ez nem mozdított, ezért Unstuck után a zöld medence lett a kanonikus kezdőcsomópont.

## 4,31K-s szívfa és Titan-objektum

A `224547-play` 21–35. képe a zöld út északi részén egy 4,31K HP-s, `500` szív
jutalmú nagy fát mutatott. A játékos és a fa között egy 200 HP-s, lila láncos
Titan-kőobjektum és középső sziklatömb állt.

- Első biztos távolság: 412 pixel.
- Legjobb biztos távolság: 291 pixel.
- Fa HP-változás: 4310→4310.
- Játékos sérülés: nem volt.
- Következtetés: ez ismét útvonalpróba, nem harci vereség.

A képsor végén a karakter már a középső szikla jobb oldalán állt. Innen a vízszintes
tangens visszavitte a kapu elé, ezért a következő kontrollált próba külön gráfélt
kapott: 13 tiszta északi lépés a jobb oldali völgyben, majd 8 nyugati ráfordulás a
szikla felső vége mögött.

## Deep Mines anti-stone kapu

A `225035-play` 12–33. képe a havas Deep Mines-réteg alsó oldalát mutatta. A
fehér–türkiz, lila kristályos híd/kapu fölött több 1,92K HP-s, 20 szívjutalmas
ellenfél és egy 7,15K-s fegyverhordozó állt. A játékos alatt az explicit feladat:

`Find a magic anti-stone potion in Deep Mines – 0/1`

A 1,92K-s cél kontrollált megközelítése több oldalról sem adott sebzést. Amikor a
bot két teljes kerülő után visszaért a 0/1 buborékhoz, helyesen zárt kapunak
minősítette, tartós hűtést írt és 36 döntéses déli kijárást indított.

## Aktuális stratégia

1. A 2/57-es déli platformhoz nem térünk vissza.
2. A Deep Mines 0/1 kapunál nem farmolunk vetületben közeli havas ellenfelet.
3. Anti-stone potion forrást kell keresni a járható zöld/narancs rétegen,
   különösen új világ-ládákban, ellenfélcsoportoknál és feladatjelzőknél.
4. A nagy térképen messze északon látott arany láda elsőrangú, még fel nem derített
   jelölt; nem azonos a már lezárt 2/57-es platformmal.
5. A 4,31K-s szívfát az új észak→nyugat völgykerülővel újra meg kell próbálni,
   mert a 500-as szívjutalom jelentős maximum-HP növekedést ígér.

## Mellékmegfigyelés

A fali zseb élő képén a bal oldali HUD-ban egy fejszeikon, `7` és `2x Reward`
jelzés jelent meg. Ez valószínűleg időszakos fegyver-/jutalombónusz vagy feladat,
de még nincs elég bizonyíték arra, hogy kattintható, automatikus vagy fizetős elem.
