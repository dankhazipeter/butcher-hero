# Titan-oltár aktív ellenirányú kijárata

## Miért nem elég az oltár figyelmen kívül hagyása

A `20260829-125042-play` helyesen felismerte és 600 döntésre lehűtötte a Titan-oltárt,
de az addigi stratégia ezután csak eldobta a lila minimapirányt. A növekvő
négyzetspirál terepakadályok között később visszakanyarodott az oltárhoz: a 110–116.
eseményen a `0/7` buborék ismét a karakter fölött volt. Ez nem új oltárfeladat és nem
gem, csak a geometriailag visszatérő felderítő út következménye.

Az ismert lila ikon azonban ilyenkor is hasznos információ. Már nem célirányként,
hanem az elhagyni kívánt hely vektoraként kell értelmezni.

## Új kijárati szabály

Aktív Titan-oltárhűtés alatt, ha a lila minimapikon látszik:

- a bot az ikon irányának pontos ellentettjét választja;
- ezt 0,54 másodperces, folyamatos swipe-pal tartja;
- az ikon pulzáló eltűnését hat tényleges döntéses külön kijárati memória hidalja át;
- közeli valódi cél, küldetésút, boss vagy sérülés továbbra is korábban dönthet;
- legfeljebb 28 tényleges kijárati swipe fut, mert az ikon távoli iránytűként a
  minimap peremén maradhat; ezután visszatér a normál gemfelderítés.

Így ugyanaz a lila jel két állapotban ellentétes jelentést kap: ismeretlen oltárnál
odavezet, felderített oltárnál kivezet.

## Regresszió

A `20260829-125549-replay` a 114–130. mentett képeket játszotta vissza. Amint a lila
irány a 126. képen felismerhető lett, a döntés `A felderített Titan-oltártól a lila
minimapjel ellenirányában távolodom` ágra váltott, majd a 128. és 130. képen is ugyanazt
a kifelé tartó irányt őrizte.

Az új release build élő futása `20260829-125610-play` néven indult. Ez később
megmutatta, hogy a jel távolról sem tűnik el, ezért a 144. fejezet 28 lépéses
korlátozása felülírja a korlátlan kijárat történeti változatát.
