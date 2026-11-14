# 361 — A játék helyi mentése: statértékek és forrásaik (2026-11-14)

## Kérés

A felhasználó megadta a Teljes lemezhozzáférést, és azt kérte, nézzük át a
macOS-en futó iPad-játék helyi fájljait. Olyan adatot keresett, amelyből
kiderülnek a játékbeli statértékei. Kifejezetten **csak olvasást és
értelmezést** kért, módosítást nem. Semmit nem írtunk a játék konténerébe:
a fájlokat a session ideiglenes mappájába másoltuk, és ott dekódoltuk.

## Hol vannak az adatok

- Alkalmazáscsomag: `/Applications/Butcher hero: hook'n'chew RPG.app/Wrapper/ButcherherohooknchewRPG.app`.
  Unity-játék, az erőforrások a `Data/` mappában vannak; a bináris FairPlay-jel titkosított.
- Adatkonténer (TCC-védett, Teljes lemezhozzáférés kell):
  `~/Library/Containers/com.multicastgames.butcher/Data/`.

A releváns fájlok a `Documents/` mappában:

| Fájl | Tartalom |
|---|---|
| `game_data.bin` | a teljes játékmentés, **MessagePack** (bináris JSON) |
| `game_data_backup.bin` | az előző írás másolata, azonos szerkezet |
| `game_data_pre_cloud.bin` | a felhőszinkron előtti helyi mentés (2026-11-13) |
| `RemoteConfigCache.json` | szerveroldali A/B-teszt- és játékbeállítások, sima JSON |

A `Library/Preferences/com.multicastgames.butcher.plist` (Unity PlayerPrefs)
főleg hirdetési SDK-, consent- és felhőmentés-metaadatot tartalmaz, statot nem.
A többi fájl reklám-, analitika- és WebKit-gyorsítótár.

## A mentés szerkezete

A gyökér: `version` (2), `salt`, `time` (MessagePack-időbélyeg), `hash`
(16 bájtos ellenőrzőösszeg) és `data`. A `data` 32 szekciót tartalmaz, a
fontosabbak:

- `player.stats`: statonként `stat_type`, `base_value` és `modifiers` lista.
  Minden módosító neve a **forrást** jelöli (`map.normal_mob`, `map.tree`,
  `map.elite`, `vip.cashback`, `vip.chest`, `event.prize`, `shop`, `ads`,
  `no_ads`, `secret_chest`, `quest.*`, tárgyképességek stb.).
- `player.items`, `loadout`: fegyverek, szint, példányszám.
- `crystals`: minden kristály `base_stat_type`, `base_stat_value`, `rarity`,
  `level`, bekapcsolt slot; `geodes_opened_count`.
- `amulet`: amulettfa fejlesztési szintjei (például `health_percent`).
- `currency`: geode, lélek, varázspor, toronyjegy egyenlegek.
- `cashback`, `baked_rewards`, `boss_tower`, `quests`, `achievements`,
  `player_statistics` (összes ölés, legnagyobb krit).
- `user`: játékidő, eszköz, reklámstatisztika. Ebben személyes azonosító is
  van, ezért a dokumentáció nem idéz belőle azonosítót.

## A `stat_type` kódok jelentése — bizonyítottan

Két független egyezés igazolja.

1. **Kristálynapló.** A mentés tíz legújabb kristálya (id 1991–2000) típus,
   ritkaság és érték szerint pontosan egyezik a
   `crystal-rewards/results.jsonl` tíz utolsó eredményével (például 1.23M
   Smash Damage narancs, 11.9K Lifesteal zöld, 17.4K Health Regen szürke).
2. **FREE-napló.** A két mentés közti `no_ads` növekmény mind a nyolc
   típusnál ugyanabban az irányban és nagyságrendben nő, mint a gyűjtőnapló
   igazolt FREE-összege (lásd lent).

| Kód | Stat | Kód | Stat |
|---|---|---|---|
| 1 | Health | 14 | Pierce Defense |
| 2 | Health Regen | 16 | Cut Defense |
| 6 | Pierce Damage | 20 | Smash Defense |
| 8 | Cut Damage | 22 | Lifesteal |
| 12 | Smash Damage | | |

Ritkaság (`rarity`): 0 szürke, 1 zöld, 3 lila, 4 narancs; a 2 valószínűleg
kék, de ezt itt nem igazoltuk. A többi kódot (0, 3–5, 7, 9, 13, 15, 17, 21,
23–25, 33, 34) nem azonosítottuk; ezek százalékos vagy krit/blokk jellegű
értékek lehetnek, de ez csak hipotézis.

## A FREE-jutalmak forrásneve: `no_ads`

A FREE-feladat a No Ads vásárlás után jelenik meg; a mentésben ennek a
forrásnak `no_ads` a neve (`source` 5, ugyanaz, mint a reklámos `ads`-é).
A 2026-11-14 09:53Z-s mentés szerint (nyers összegek, a módosítótípus 0
tagjai):

| Stat | Összes gyűjtött | Ebből FREE (`no_ads`) | Arány |
|---|---:|---:|---:|
| Health | 318 011 648 | 170 899 168 | 53,7% |
| Health Regen | 1 375 374 | 290 011 | 21,1% |
| Pierce Damage | 10 644 226 | 4 897 359 | 46,0% |
| Cut Damage | 7 030 294 | 981 058 | 14,0% |
| Smash Damage | 8 765 390 | 1 236 281 | 14,1% |
| Pierce Defense | 4 862 998 | 1 045 604 | 21,5% |
| Cut Defense | 8 950 574 | 3 945 816 | 44,1% |
| Smash Defense | 6 711 602 | 1 400 709 | 20,9% |
| Lifesteal | 348 666 | 0 | 0% |

**Fontos korlát:** ezek a mentett nyers statgyűjtések. A játékban kijelzett
végső érték ennél nagyobb lehet, mert az amulettfa százalékos bónuszai, a
felszerelt kristályok és a tárgyak futás közben számolódnak hozzá; ezek
végeredménye nincs elmentve. A kristályok értéke külön a `crystals`
szekcióban van, nem a `player.stats`-ban.

## Összevetés a gyűjtőnaplóval — nyitott 20%-os eltérés

Ablak: a `pre_cloud` mentés belső ideje (2026-11-13 09:04:36Z) és az aktuális
mentés ideje (2026-11-14 09:53:36Z) között. A naplóban 0 ismeretlen vagy
összeg nélküli igazolt claim esett ide.

| Stat | Napló: db / összeg | Mentés: `no_ads` növekmény | Arány |
|---|---:|---:|---:|
| Health | 413 / 8 136 100 | 9 783 424 | 1,202 |
| Health Regen | 146 / 12 556 | 15 383 | 1,225 |
| Pierce Damage | 439 / 266 868 | 316 444 | 1,186 |
| Cut Damage | 72 / 42 120 | 50 400 | 1,197 |
| Smash Damage | 73 / 54 385 | 68 703 | 1,263 |
| Pierce Defense | 66 / 42 900 | 52 038 | 1,213 |
| Cut Defense | 261 / 231 507 | 271 491 | 1,173 |
| Smash Defense | 71 / 60 066 | 70 221 | 1,169 |

A mentés mind a nyolc típusnál következetesen kb. 17–26%-kal többet
könyvelt, mint amennyit a kártyán látott értékekből a napló összead.
**Az ok nincs bizonyítva.** Lehetséges magyarázatok:

- A játék a kártyán mutatott értéknél többet ír jóvá (rejtett szorzó). A
  `RemoteConfigCache.json` tartalmaz `common_reward_multipliers` A/B-tesztet,
  de a mentés `ab_tests` listájában ez nincs hozzárendelve a fiókhoz, így
  ebből nem következik szorzó.
- Időablak-eltérés: 09:04Z és 16:26Z között (2026-11-13) a napló nem
  tartalmaz claimet, és a `pre_cloud` fájl 16:26Z-kor, a felhőszinkronnál
  keletkezett. Ha a belső `time` nem pontosan a tartalom állapotát jelöli,
  az ablak eltolódik. Egy korábbi kezdettel (07:00Z) a Health-arány 1,04
  lenne, de a típusok közti egyenletes ~1,2-es arány inkább szorzóra utal.
- Kézi átvétel a gyűjtő nélkül ugyanebben az ablakban.

A gyűjtő naplóját és statisztikáját ebből **nem módosítjuk**: a napló a
kártyán látott értéket rögzíti, és ez továbbra is így marad.

## Amit nem csináltunk

- Nem írtunk a játék konténerébe, nem módosítottunk mentést, plist-et vagy
  felhőmentés-hasht.
- A dekódoláshoz használt kis MessagePack-olvasó nem került a repóba; ha
  később a gyűjtő vagy a dashboard használná ezt a forrást, az új, külön
  jóváhagyandó bemenet lenne (TCC-függés, formátumváltozás kockázata).
- A gyűjtőt nem állítottuk le és nem indítottuk újra.
