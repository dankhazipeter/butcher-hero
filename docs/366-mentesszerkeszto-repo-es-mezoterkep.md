# 366 — Mentésszerkesztő a repóban és a mentés teljes mezőtere (2026-11-14)

## Kérés

A 364–365 sikerek után a felhasználó kérte, hogy a próbaszkript kerüljön a
repóba, és legyen képes a **crystal_jar példányszámot (`copies`) pontosan
eggyel növelni** (a tárgy fejlesztéséhez kell példány: 2 fejlesztés + 1 vásárlás
= 3 megszerzett példány, mind elfogyott; a mentésben `copies: 0`).
Ugyanitt lezárta a korábbi nyitott szálakat: a ~20%-os naplóeltérés (361) és a
REA MCP bekötése — ezekkel nem kíván foglalkozni.

## Új eszköz: `scripts/butcher-save-edit.py`

A 364–365 session-temp próbaszkriptje átkerült a repóba, `copies` móddal és
relatív értékkezeléssel bővítve. A hash-receptet és a SECRET kulcsot a
`scripts/butcher-save-hash.py` modulból tölti be (a kulcs egy helyen él).

```
butcher-save-edit.py --check             # állapot: hash érvényessége, Jar, copies, plist
butcher-save-edit.py --jar N             # Jar-számláló (tárolt lelkek); '+N'/'-N' relatív
butcher-save-edit.py --copies N          # crystal_jar példányszám; '+N'/'-N' relatív
butcher-save-edit.py --copies +1         # példányszám pontosan eggyel növelése
butcher-save-edit.py --revert            # utolsó biztonsági mentés visszaállítása
butcher-save-edit.py … --secret KULCS    # hash-kulcs felülírása (új játékverzió esetére)
```

Minden írás: játék-nem-fut ellenőrzés → a jelenlegi mentés hash-érvényességének
ellenőrzése → SHA-256 manifestes biztonsági mentés → mező cseréje minden
MessagePack-kódolási átmeneten (azonos hossznál helyben, változó hosszal
újraépítéssel) → hash újraszámolása (362 recept) → atomi fájlírás → a
PlayerPrefs `cloud_save_local_hash`/`cloud_save_local_untrusted` összehangolása
(363), hogy a trust-réteg elfogadja és a felhői szinkron vigye.

Tesztek: `tests/test_save_edit.py` — 12 offline teszt szintetikus mentéseken:
mezőkeresők, mindkét patch-út (helyben/újraépítés, növekvő és zsugorodó
kódolásváltás), a `resolve_value` relatív/abszolút/guard-esetei, a kész fájl
érvényessége a verify-recepttel. A valódi (59 tételes) mentésen végpont-
szimuláció is futott: copies 0→+1 (helyben) és 0→350 (újraépítés, +2 bájt),
mindkettő a `butcher-save-hash.py verify` eszközzel is érvényes.

## A mentés mezőtere — miben lehet gondolkozni

Gyökér: `version` (2), `salt`, `time` (DateTime, nem hash-elt), `data`, `hash`.
A `data` **32 szekciót** tartalmaz (a 2.1-es mentés szerint):

`player`, `user`, `vip`, `events`, `mails`, `shop`, `gates`, `cashback`,
`analytics`, `event_analytics`, `ab_tests`, `spawners`, `baked_rewards`,
`boss_tower`, `amulet`, `crystals`, `level_pass`, `island_mastery`,
`currency`, `daily_procs`, `meta_stats`, `secret_chests`, `quests`, `mines`,
`notifications`, `promo_codes`, `socials`, `blacksmith`, `limited_mode`,
`achievements`, `player_statistics`, `rescue_quest`.

`player` (26 mező): pozíciók/haladás (location-számok, `gems`), tutorial-jelzők,
`deaths_count`, **`items`** (59 tétel), `item_slots`, `stats` (a 361-ben
azonosított stat-gyűjtők forrásonként), `loadout`, `filter_loadouts`,
`last_position`, `unstack_cooldown_ts` (időbélyeg!).

Egy tárgy mezői (crystal_jar példa): `key`, `level`, **`copies`** (példányszám),
`evolved`, `accessory_level`, `accessory_experience` (float XP),
`inheritance_upgrades`, `ability_counters` (pl. a Jar lelk-számláló),
`accessory_cap_notice_level`.

**Amit az eddigi bizonyítékok alapján viszonylag biztonságos editelni:**
számlálók és készletek, amelyek egyszerű tárolt értékek — `copies`, a Jar
lelk-számláló, valószínűleg a `currency` egyenlegek és a `crystals` mezői
(`base_stat_value`, `rarity`, `level`). Ezek a játék saját mentési ciklusán
át bizonyultan persistálódnak és a felhőn át eszközök között eljutnak.

**Amit kerüljünk vagy nagyon óvatosan:**
- **időbélyegek** (`*_ts`, cooldown-mezők, `time`): előre állítva a S3M4RiL
  által javított „jövőbe zárt időzítő" hiba, hátra állítva a játék saját
  logikájával ütközhet;
- `version` és séma-mezők: a migráció bemenetei;
- event/quest állapotgépek: a szerver oldali eseményállapottal szinkronban
  élhetnek, elcsúsztatásuk konfliktust okozhat;
- a felhő **egész fájlt** cserél, nem fésül: a feltöltés előtt fel nem töltött
  másik-eszközi haladás felülíródik (365).

A felhasználó elve: **minimális, célzott módosítások** (pl. `--copies +1`
fejlesztéshez), nem „mindent maxra" — a 366-os eszköz ezt támogatja.

## Lezárt szálak (felhasználói döntés)

- A 361-ben nyitott **~20%-os eltérés** (mentés `no_ads` növekménye vs.
  gyűjtőnapló) — a felhasználó nem kíván foglalkozni vele; a napló/gyűjtő
  értékei érintetlenül maradnak.
- A **REA MCP** OpenCode-ba való bekötése — szintén elvetve; a jövőbeli
  bináris-elemzés a 362-ben rögzített saját módszertannal megismételhető.

## Amit nem csináltunk

- A gyűjtő/supervisor/dashboard nem futott és nem is érintettük.
- Konténer-írás e körben nem történt (csak az eszköz készült és offline
  validálódott); a felhasználó saját termináljából futtatja majd.
