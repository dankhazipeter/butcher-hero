# Kristály-eredményképernyő nagy ablakban: HUD-nak olvasva

2026-11-09 délelőtt. A játék a nagy (külső) kijelzőn fut, ablakmérete 1024×1398. A
felhasználó képernyőképe szerint a gyűjtő a CRYSTAL STATS eredményképernyőn (Pierce
Defense +305K, CONTINUE) állt, és a kristálynyitás nem ment tovább.

## Tények

- Két tranzakció akadt el ugyanígy: `9CA4791B` (10:37Z) és `2F16399C` (11:29Z). Az
  ütések után mindkettőnél `crystal_screen hud; ["ringDot=absent;blue=0.0"]` került a
  naplóba. A hozzá tartozó kép valójában az eredményképernyő (zöld csempe, CONTINUE).
- A folyamat ezért nem nyomott Continue-t: `transaction_timeout`, majd
  `crystal_finished_no_reward`. A második esetnél a képernyő ott maradt, amíg a
  felhasználó kézzel tovább nem nyomta. A Free-gyűjtő ez alatt `HUD=true`-t látott, de
  kártyát nem, tehát kattintás nem történt.
- Ok: a `CrystalVision.observe` előbb a HUD-ágat vizsgálta, csak utána az eredményt. A HUD
  heurisztika (`RewardVision.hudVisible`) alsó sávjában a Continue gomb narancs pereme
  piros pixelnek, középen a zöld ritkaságú csempe zöldnek számít. Ezen az ablakon így
  az eredményképernyő is HUD lett.

## Javítás

- Az eredményképernyő vizsgálata (sárga CONTINUE-sáv, pontos „CONTINUE” és „CRYSTAL
  STATS” szöveg) most a HUD-ág előtt fut. A HUD-heurisztika és a küszöbök nem változtak.
- Kristálynapló: a `CrystalResultLog` az ütések utáni első „hud” képet is jelöltként
  veszi. Csak akkor kerül be, ha a mentett kép most eredményképernyőnek olvasódik. Puszta
  naplósorból nem lesz kristály, hiányzó képből sem.

## Ellenőrzés

- Visszajátszás 1685 képen (az app és a régi CLI összes kristály-bizonyítékképe, és
  minden hatodik Free-kép): régi és új besorolás csak 8 képen tér el, mind a beragadt
  eredményképernyő, `hud` → `result`. Minden más (789 hud, 369 geode, 144
  inventoryReady, 139 result, 134 inventoryUnavailable, 100 unknown, 2 inventoryEmpty)
  változatlan.
- Új teszt a nagy ablakos képpel (`docs/references/2026-11-09/crystal-result-green-tile-large.png`):
  a régi kódon piros, az újon zöld. Rögzíti azt is, hogy a HUD-heurisztika erre a képre
  igazat ad, és hogy a Continue fix pontja a gombra esik.
- Új naplóteszt: a HUD-nak naplózott eredménykép bekerül, egy valódi HUD-kép ütés után
  nem. Ismételt futás nem ír új sort.
- Az élő napló másolatán futtatva pontosan a két kimaradt kristály jön: 10:37:34Z zöld
  csempe/zöld kristály L47 Lifesteal +9.14K, 11:29:38Z zöld/kék L50 Pierce Defense
  +305K. Mindkettőt a képről vizuálisan ellenőriztük. Az eredeti napló bájtra
  változatlan előtagként megmarad.
