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

## Crystal Jar: tárolt event-lelkek (kiegészítés, 2026-11-14 délután)

A felhasználó képén a Crystal Jar (Mythic accessory, „Soul Jar” képesség)
CLAIM gombja mellett 360 áll. Ez a mentésben itt van:

```
data.player.items[] → key: "crystal_jar"
  ability_counters["accessory_crystal_jar_ability_1"] = 360
```

- **Egyetlen egész szám**, nincs külön piros/kék bontás. A gomb melletti
  piros+kék kristálykép az Event Crystals ikonja; hogy beváltáskor milyen
  arányban és milyen event-valutára vált, az a mentésből nem derül ki
  (a `events.currencies` most üres, az event nem aktív).
- Időbeli alakulás a három mentésben: 235 (11-13 09:04Z) → 360 (11-14
  09:53Z) → 360 (11-14 12:25Z). A +125 pontosan egyezik az
  `event_analytics.event_mobs_killed` = 125 értékkel. Ez erős egybeesés, de
  nem bizonyítja, hogy minden event-mob egy lelket ad.
- A tárgy most **nincs felszerelve**: az accessory-slotokban `gem_ring` és
  `soul_essence` van, a harmadik VIP-slot zárt. A tárgy szintje 1,
  `accessory_experience` 3500 (a képen 3.5K/1.5K, LEVEL UP elérhető).
- A játék erőforrásai (`Data/data.unity3d`, Addressables-bundle-ök)
  tömörítettek, sima szövegkereséssel nem található bennük a tárgy
  definíciója; ehhez Unity-bundle-olvasó kellene, ezt nem telepítettük.

## Próba: Crystal Jar 360 → 361 (felhasználói kérésre, 2026-11-14)

A felhasználó kifejezetten kérte, hogy próbaként írjuk át a 360-at 361-re,
majd ő elindítja a játékot. Előtte:

- A játék nem futott (folyamatellenőrzés).
- Mentés: `~/Library/Application Support/Butcher Hero/save-backups/20261114-before-jar-361/`
  (`game_data.bin`, `game_data_backup.bin`, `game_data_pre_cloud.bin`,
  `com.multicastgames.butcher.plist`, SHA-256 egyezés ellenőrizve).

Integritásmező: a gyökér `hash` egy 16 bájtos érték `XX-XX-…` alakban, és
minden mentéskor új véletlen `salt` kerül mellé. A prefs `cloud_save_local_hash`
ugyanezt az értéket tárolja. MD5/SHA1/SHA256 a `data`-ra, a teljes térképre,
salttal elöl/hátul és HMAC-kel sem reprodukálható, tehát valószínűleg a
programba fordított kulcs is része. Ezt nem fejtettük vissza és nem
hamisítottuk.

Módosítás: kizárólag a `game_data.bin` egyetlen bájtja (offset 10197,
`0x68` → `0x69`, uint16 360 → 361). A `hash`, a `salt`, a `backup`, a
`pre_cloud` és a prefs változatlan. Ezért a próba egyben azt is méri, hogy a
játék észleli-e a hash-eltérést (például a backup betöltésével, felhőből
visszatöltéssel vagy a mentés elvetésével).

### Eredmény: a játék észlelte és elvetette a módosítást

A felhasználó kérésére 14:04-kor (helyi idő) `open -b`-vel indítottuk a
játékot. A Terms/Privacy ablak Continue gombját nem tudtuk megnyomni, mert a
Mac zárolva volt (előtérben a `loginwindow`). A feloldás jelszót igényel,
ezért azt nem csináltuk meg. Az eredmény viszont a fájlokból kiolvasható:

- A játék már a betöltéskor (14:04:22) ellenőrizte a mentést. A módosított
  fájlt `game_data_corrupted.bin` néven félretette; ez bájtra azonos a mi
  egybájtos módosításunkkal.
- A `game_data.bin` helyére a `game_data_backup.bin` tartalma került
  (SHA-256 egyezik, belső idő 12:23:54Z, hash `97-73-…`). A Crystal Jar
  értéke ebben **360**.
- Ez 2 perccel régebbi állapot, mint az utolsó valódi mentés (12:26:10Z).
  A különbség csak a geode-egyenleg (4 a 6 helyett) és a karakter pozíciója;
  statok, tárgyak, kristályok és ölések azonosak.

A felhasználó által feloldott gépen a betöltéskor a játék „SAVE DATA ERROR
— damaged or modified … will try to restore your progress from the Cloud
Save” üzenetet mutatott. A 19:24-es (helyi idő) mentés szerint a haladás
ép: a statok, gemek, kristályok és ölések egyeznek a 12:26:10Z-s utolsó jó
mentéssel, a Jar 360, a geode 9 (azóta újratöltődött), és csak 2 perc
játékidő veszett el.

Következtetés: a `hash` mező valódi integritás-ellenőrzés. Hash nélküli
kézi módosítást a játék nem fogad el, hanem a backupra áll vissza. A hash
hamisítását nem vállaltuk. Az eredeti, érvényes 12:26:10Z-s mentés a
`save-backups/20261114-before-jar-361/game_data.bin` fájlban megmaradt.

## Külső forrás: S3M4RiL YouTube-videó (2026-10-27)

A felhasználó küldte: „Butcher Hero: How to Edit Your Save & Fix Broken
Timers”. A videó Androidon, a 2.0.4-es verzión mutatja be, hogyan lehet a
`game_data.bin`-t (MessagePack) JSON-ná alakítani és visszaalakítani, hogy
az óraállítás után a jövőbe került időbélyegeket javítsák. A mi
megállapításainkat megerősíti:

- Ugyanaz a formátum. Az időmezők: Unix-másodperc (`last_tickets_restore_timestamp`,
  `daily_chest_cooldown_timestamp`), .NET ticks (`last_geode_timestamp`,
  `last_stones_reset_day`), olvasható dátum (`next_free_claim_reset`,
  `free_chest_claim_reset`).
- A szerző kitűzött megjegyzése szerint a módszer a **2.1-es verzióban már nem
  működik**. Egy hozzászóló szerint a 2.1 hash-ellenőrzést kapott, egy másik
  pontosan a mi eredményünket írja le (a játék visszaáll a backupra). A mi
  iPad-es mentésünkben `user.app_version` = `2.1`, tehát ez nem a régi verzió.
- Egy hozzászóló azt állítja, hogy reprodukálta a hash-t, és felajánlja, hogy
  idegenek mentését átszerkeszti. Ezt nem használjuk és nem ajánljuk
  (fiók- és adatbiztonsági kockázat).

## Memóriaszerkesztés megvalósíthatósága macOS-en (felmérés, 2026-11-14)

A felhasználó a futásidejű memóriaszerkesztés lehetőségére kíváncsi, mert
akkor a játék maga mentené a helyes hash-sel. Csak olvasó ellenőrzéseket
végeztünk, a memóriába nem írtunk.

- SIP: bekapcsolva. Developer mode: kikapcsolva.
- A játék aláírása: `flags=0x0`, vagyis nincs hardened runtime és nincs
  `get-task-allow`. A jogosultságai csak Game Center és associated domains.
- Titkosítás: a fő stub (`ButcherherohooknchewRPG`, 4 KB) `cryptid 1`, de a
  valódi kódot tartalmazó `UnityFramework` (90 MB) `cryptid 0`, tehát nem
  titkosított. A `Data/Managed/Metadata/global-metadata.dat` olvasható, benne
  vannak az osztály- és metódusnevek (például `LocalSaveHash`,
  `CommittedSaveHash`, `CloudSaveHash`, `ComputeHash`). A statikus elemzés
  tehát könnyebb, mint elsőre gondoltuk.
- Nincs Code Stage Anti-Cheat Toolkit nyoma (`Obscured*`, `CodeStage`,
  `*CheatingDetector`: mind 0 találat). A memóriabeli értékek valószínűleg
  nincsenek külön kódolva.
- Memóriahozzáférés: saját, aláíratlan teszttel `task_for_pid` a játékra
  normál felhasználóként `KERN_FAILURE`. Rootként (sudo) nem próbáltuk, mert
  az a felhasználó jelszavát igényli. Hogy SIP mellett rootként engedélyezi-e
  a rendszer ennél az iOS-appnál, az nyitott.

## Amit nem csináltunk

- Nem írtunk a játék konténerébe, nem módosítottunk mentést, plist-et vagy
  felhőmentés-hasht.
- A dekódoláshoz használt kis MessagePack-olvasó nem került a repóba; ha
  később a gyűjtő vagy a dashboard használná ezt a forrást, az új, külön
  jóváhagyandó bemenet lenne (TCC-függés, formátumváltozás kockázata).
- A gyűjtőt nem állítottuk le és nem indítottuk újra.
