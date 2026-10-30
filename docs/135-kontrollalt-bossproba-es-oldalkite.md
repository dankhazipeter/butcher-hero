# Kontrollált bosspróba és oldalkite

## Miért változott a szabály

A régi stratégia minden 800+ HP-s ellenféltől automatikusan elmenekült. Ez helyes volt
340 max-HP és jóval kisebb sebzés mellett, de a jelenlegi állapot már 778 max-HP és
500 Bat Cleaver Damage. A puszta ellenfél-HP nem dönti el a harcot: számít a saját
találati sebzés, cooldown, az ellenfél ütésének nagysága és ritmusa, valamint az, hogy
mozgás közben is működik az automata támadás.

## Külön kutatási mód

A `--controlled-boss-trials` kapcsoló folyamatonként egyetlen próbát enged minden
250-es ellenfél-HP sávban, 800 és 8 000 között. Indítási feltétel:

- legalább 750 kijelzett saját HP és legalább 95%-os aktuális HP;
- nincs friss sebzés;
- teljes bossbizonyíték és legfeljebb 420 pixeles távolság.

A bot 112 pixel fölött közelít. Több látható bossnál a kiválasztott cél felé tartó
vektorhoz hozzáadja a többi ellenféltől elfelé mutató komponenst, így megpróbálja
szétválasztani őket. Támadási közelben érintőirányban köröz, 68 pixel alatt kifelé,
94 pixel fölött enyhén befelé korrigál. 65% saját HP alatt erősebb kifelé komponens
lép be, 45% alatt pedig a normál visszavonulás visszakapja az elsőbbséget.

Egy rövid OCR-takarásnál három lépésig a legutóbbi bossirányt tartja, majd egy képet
jutalomra/halálátmenetre vár. Legfeljebb 90 tényleges döntés után lezárja a próbát.

## Regresszió

- `20260829-112030-replay`: az 1.92K-s képen normál módban változatlan azonnali
  menekülés;
- `20260829-112041-replay`: a hosszú régi képsorban az 1.22K-s sáv egyszer indult,
  tartós ismétlést nem okozott;
- `20260829-112356-replay`: a 7.15K-s képsor 7150 HP-ról indította a próbát, majd a
  felismerési résben a legutóbbi iránnyal folytatta a visszakeresést;
- `20260829-112255-replay`: ugyanazon, két 1.92K-s csíkot tartalmazó képen a kutatási
  mód szabályosan elindította a célzott mérést.

## Élő mérési terv

Minden próbánál rögzítjük az ellenfél kezdő és legalacsonyabb HP-ját, a saját HP-esés
lépcsőit, az ütések közti időt, a mozgás közbeni találatokat, a halált és a jutalmat.
Az első siker vagy vereség után az adott ellenfélsáv modellje frissül; nem a régi
„nagyobb HP = biztos vereség” feltételezéshez térünk vissza.

## Kísérlet előtti buildfrissítés

Az élő próba előtt a Savage Fang 1 helyére Steel Splitter 14 került. A kijelzett DPS
517-ről 693-ra nőtt, ezért a bossok nyers, defense nélküli időbecslése rendre kb.
1,8 s (1.22K), 2,8 s (1.92K), 6,2 s (4.31K) és 10,3 s (7.15K). Ezek csak előzetes
becslések; a bot továbbra is a tényleges HP-csökkenést és saját túlélést méri.

## Első élő győzelem

A `20260829-121101-play` 76–86. eseménye az 1.22K-s páncélost teljes 778 HP-ról
kontrolláltan megtámadta és legyőzte. Támadási távolságban a saját HP 754, majd 751
volt; a cél eltűnése után 768→778-ra regenerálódott. A `frame-00086` közvetlen
`LEVEL UP`, Savage Fang `1→2`, Damage `8→16` jutalmat és `19m 58s` cooldownkört
mutat. Az 1.22K-s sáv ezért a jelenlegi 693 DPS builddel bizonyítottan nyerhető,
nem automatikus menekülési kategória. Részletes képaudit: a 138. fejezet.
