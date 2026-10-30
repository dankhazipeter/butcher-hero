# +20 szívből +21 HP és maximumnövekedéses progress-reset

## Közvetlen élő bizonyíték

A `docs/runs/20260829-074813-play` futásban a bot másodszor is megközelítette a
20-szíves, 431 HP-s fát:

- `frame-00260`: a fa még teljes 431 HP-n, a játékos maximuma 747;
- `frame-00266`: támadási közelítés;
- `frame-00276`: a fa eltűnt, közvetlen zöld `+20` és piros szívikon látszik;
- `frame-00278`: friss numerikus 768 HP;
- `frame-00280`: a 768 ismét stabil.

**Biztos tény:** a közvetlen +20 szívjutalom 747→768, azaz +21 tényleges maximális
HP-t adott. A játékban korábban megszerzett világláda `+1%` szívbónusza ezért nem
pusztán egyszeri +1 volt: a későbbi lapos szívjutalmakat is százalékosan növeli vagy
felfelé kerekíti. Ez összhangban áll a korábbi 553→564 változással egy +10-es jutalom
után.

A hiteles aktuális maximum e mérési ponttól **768 HP**.

## Felügyeleti anomália

A `+20` vizuálisan tiszta volt, de a `rewardOCRStrings` üres maradt, és nem keletkezett
`recentRewardSequence`. A 150 döntéses jutalomhiányos területelhagyás már futott, ezért
a bot a valódi fejlődés után is tovább tartotta a hosszú kiszakadást. A maximumőr
ugyanakkor két egymást követő friss 768 OCR-ből helyesen elfogadta az új maximumot.

**Döntés:** az Analyzer tartós maximumőre által elfogadott új maximum önálló fejlődési
esemény. A `+21`-hez két azonos mérés kell, az ismert elemi lépcsők gyorsútja változatlan.
Megerősítése mostantól külön szekvenciát ad a stratégiának, amely:

- nullázza a `decisionsSinceProgress` számlálót;
- leállítja a hosszú jutalomhiányos kiszakadást és a szabad felderítést;
- törli a jutalomhiányból gyűlt statikus fázisbizonyítékot;
- változatlanul lezárja a stratégiai respawn okát.

Így a láthatatlan vagy OCR-ből kimaradó jutalom sem engedi, hogy a bot egy sikeres
farm után tévesen „nincs progresszió” állapotban maradjon.

## Ellenőrzési terv

1. A következő, a tartós `bot-state.json` maximum fölé növő jutalom külön
   maximumszekvenciát adjon, és a döntés többé ne legyen `Tartós jutalomhiány...`.
2. A normál, változatlan teljes HP ne generáljon ismételt progress-resetet.
3. Élőben az első új max-HP lépcső után legalább 150 új tényleges döntés kelljen a
   következő jutalomhiányos módhoz.

Megjegyzés: a `075542-play` az előző, szívfa-memóriás binárissal indult el, mielőtt
ez a reset elkészült. Emiatt a javítás élő igazolása csak az ezt követő futásban
kezdődik; a két build bizonyítékát nem keverjük össze. A történeti `074813` replay a
jelenlegi 768-as tartós maximumból indul, ezért ugyanazt a régi lépcsőt már nem tudja
új maximumként újra kibocsátani; ez helyes, írásmentes replay-viselkedés.
