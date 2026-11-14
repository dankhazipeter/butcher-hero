# 362 — A mentés-hash visszafejtése a binárisból (2026-11-14)

## Kérés

A felhasználó telepítette a REA toolt (https://rea.tools), és azt kérte: keressük
meg a Butcher Hero binárisát, és fejtsük vissza, hogyan készül a 361-ben
azonosított integritás-ellenőrző `hash` a `game_data.bin` gyökerében. A 361-es
kör megállapította, hogy a hash valódi integritásvédelem (egy bájtos módosításra
a játék elvetette a mentést és a backupból töltött), de a receptjét nem ismertük:
MD5/SHA1/SHA256 a `data`-ra, sóval elöl/hátul és HMAC-kel sem reprodukálható volt.

**A recept most teljesen vissza van fejtve és három valódi mentésen validálva.**

## Az algoritmus (a lényeg)

A gyökér hash mezője így készül (íráskor) és így ellenőrizhető (olvasáskor):

```
hash = BitConverter.ToString(                                  # "XX-XX-…-XX" nagybetűs, kötőjeles
    MD5(
        data_msgpack_bájtok                                     # a fájlbeli 'data' érték NYERS bájtjai
        + msgpack_str("5b5496vn7456oodw976d95mo")               # fixstr: 0xB8 + 24 bájt kulcs
        + msgpack_write_int(salt)                               # optimális int kódolás (lásd lent)
    )
)
```

- **A titkos kulcs** egy 24 karakteres, a játékba fordított konstans:
  `5b5496vn7456oodw976d95mo`. A `global-metadata.dat` string-literálja; a
  hivatkozó kód a metaadat-usage slot `0x5EFFC38`-ból tölti be (IL2CPP
  metadata-usage kódolás: `kind = (v & 0xE0000000) >> 29` — 5 = StringLiteral,
  `index = (v & 0x1FFFFFFE) >> 1`).
- **A salt** íráskor `UnityEngine.Random.Range(int.MinValue, int.MaxValue)`
  (nem kriptografikus RNG!). A fájlba `WriteInt64`-ként kerül (`0xD3` + 8 bájt),
  de **a hash-be az optimális int kódolású alakja** megy bele — ez volt a 361-ben
  hiányzó darab. A MessagePack-CSharp `MessagePackWriter.Write(int)` kódolása:

  | Salt tartomány | Kódolás a hash-bemenetben |
  |---|---|
  | 0…127 | 1 bájt (positive fixnum) |
  | 128…255 | `0xCC` + u8 |
  | 256…65535 | `0xCD` + u16 BE |
  | **> 65535 (pozitív)** | **`0xCE` + u32 BE** |
  | −32…−1 | 1 bájt (negative fixnum) |
  | −128…−33 | `0xD0` + i8 |
  | −32768…−129 | `0xD1` + i16 |
  | **< −32768 (negatív)** | **`0xD2` + i32 BE** |

- A `version` (2) és a `time` (DateTime.UtcNow, fixext8 típus −1) **nem** része a
  hash-nek; csak a `data` bájtjai, a kulcs és a salt.
- Az ellenőrzés a fájl nyers `data` bájtjait hash-eli újra (nem újraszerializál),
  majd `String.Equals(tárolt, számolt, StringComparison.Ordinal)` módon hasonlítja
  össze. Eltérésnél `InvalidDataException("UdRoot - Hash mismatch")` keletkezik —
  ez váltja ki a „SAVE DATA ERROR" felületet és a karantén–visszaállítási láncot.

## Validáció

A `~/Library/Application Support/Butcher Hero/save-backups/20261114-before-jar-361/`
három fájlján a recept bájtra pontosan visszatermelődik:

| Fájl | Salt | Tárolt hash | Eredmény |
|---|---:|---|---|
| `game_data.bin` | −853994833 (negatív → `0xD2`) | `77-03-2B-50-…` | egyezik |
| `game_data_backup.bin` | 530690136 (pozitív → `0xCE`) | `97-73-B3-FD-…` | egyezik |
| `game_data_pre_cloud.bin` | −1004654814 (negatív → `0xD2`) | `91-54-9C-AE-…` | egyezik |

A 361-es próba (Crystal Jar 360→361 egy bájt átírása) így teljesen értelmezhető:
a módosítás önmagában érvényes MessagePack maradt, de a `data` bájtjai
megváltoztak, a `hash` mező nem — az ellenőrzés eltérést talált, a játék a fájlt
`game_data_corrupted.bin`-be tette és a backupból töltött. **A backup fájl hash-e
érvényes volt** (a 361-es ideiglenes kétely tisztázódott): a pozitív salt miatt
`0xCE`-es kódolás kell hozzá, a negatív saltokhoz `0xD2`-es.

## Hol él a kódban

A játék Unity 6 (IL2CPP metadata v39), a kód a nem FairPlay-titkosított
`UnityFramework` arm64 binárisban, Mach-O chained fixups (`DYLD_CHAINED_PTR_64_OFFSET`)
kódolással. A REA MCP-folyamata ebben a sessionben nem volt elérhető (Node-verziókapu),
ezért a metaadat-leltárat a REA npx-cache-ben lévő könyvtárából futtattuk, a
bináris oldalt pedig saját Mach-O + fixup-dekóderrel oldottuk meg (832 333 fixup).

Főbb címek (vmaddr, `__TEXT,il2cpp`):

| Funkció | Cím | Megjegyzés |
|---|---|---|
| `Multicast.UserData.UdRoot<T>`Serialize (hash-író) | `0x32C1470` környéke | salt generálás → MD5 → BitConverter.ToString |
| `UdRoot<T>` ellenőrző ága (Deserialize) | `0x32C1D04…0x32C2188` | ReadRaw(data) + kulcs + salt → MD5 → Ordinal összehasonlítás |
| `MD5.Create` | `0x35DEB9C` | |
| `HashAlgorithm.TryComputeHash` | `0x35D9048` | |
| `BitConverter.ToString(byte[])` | `0x36BF3F8` | a `XX-XX` formátum forrása |
| `UnityEngine.Random.Range` (salt) | hívás a `0x32C15AC`-on | int32 teljes tartomány |
| `GameDataService.TryLoadFromFile` | `0x2E7A644` | ReadAllBytes → betöltés → ellenőrzés |
| `GameDataService.TryLoadAndSaveRepairingFiles` | `0x2E7111C` | main → backup → pre_cloud sorrend; sikertelennél „[GameDataService] Corrupted save" log + `QuarantineFile` (`0x2E7AB7C`) |
| `GameDataService.CreateBackup` | `0x2E7AECC` | sima `File.Copy` (a fő mentésről) |
| `GameDataService.RestoreSaveFile` | `0x2E7B1CC` | nem-első jelölt visszamásolása a fő fájlba |
| `Multicast.CloudSave.CloudSaveHash.Compute` | `0x38256C0` | **másik** hash: SHA256, kisbetűs, kötőjel nélküli — a felhős mentés-metaadathoz (`CloudSaveMetadata.Sha256`) |
| `Multicast.CloudSave.CloudSaveLocalTrust.Check` | `0x381F444` | lokális bizalmi réteg; eltérésnél `Distrust`-ba tail-callol |

A használt string-literálok (metaadat-index): `'salt'` 17607, `'hash'` 15659,
`'version'` 18761, `'time'` 18292, `'data'` 14484, `'cloud_save_local_hash'`
14043, `'UdRoot - Failed to calculate MD5'` 11218, `'UdRoot - Hash mismatch'`
11219, `'UdRoot - No hash in input stream'` 11221, kulcs: `5b5496vn7456oodw976d95mo`.

## Mit jelent ez

- **A lokális integritás-ellenőrzés megkerülhető az algoritmus ismeretében**:
  egy konzisztens (data, salt, hash) hármas bármelyik szerkesztett mentéshez
  legyártható, mert a kulcs a binárisban/metaadatban van. Ez nem titkosítás,
  hanem kulcsozott ellenőrzőösszeg.
- A 361-es próba most utólag is elvégezhető lenne helyes hash-szel — de **ebbe a
  körbe nem csináltunk mentésírás-próbát**: a konténerbe nem írtunk, a játékot
  nem indítottuk, a gyűjtést nem állítottuk le és nem indítottuk újra.
- A **felhő oldalát nem fejtettük vissza és nem is teszteltük**: a
  `CloudSaveHash.Compute` egy másik, SHA256-alapú hash (kisbetűs, kötőjel
  nélküli, 64 karakter) a felhő-feltöltés metaadataihoz; a
  `CloudSaveLocalTrust`/`PlayerPrefs cloud_save_local_hash` bizalmi réteg
  szerkezete ismert (Compare/Distrust), de egy módosított-yet-konzisztens mentés
  erre a rétegre gyakorolt hatását nem mérjük ki állítás nélkül. A szerver oldali
  SHA/ETag-ellenőrzés ehhez teljesen külön.

## Eszköz a repóban

- `scripts/butcher-save-hash.py` — offline, csak olvasó eszköz:
  `verify` (fájl hash-ének ellenőrzése, kilépési kód 0/2), `hash` (a fájl
  data+salt hash-e), `hash-data` (adott bájtokra és salt-ra). Saját minimális
  MessagePack gyökérelemzőt tartalmaz, külső függőség nincs.
- `tests/test_save_hash.py` — 9 offline teszt: az int-kódolás összes ága,
  kanonikus (előre, függetlenül kiszámolt) hash-vektorok, szintetikus mentés
  round-trip, egybájtos módosítás észlelése, `verify` kilépési kódjai.
  **Csak szintetikus adat** — személyes mentés nem kerül a repóba.
- A hosszú elemzési szkriptek (Mach-O/fixup-dekóder, metaadat-parser, BL-szkenner,
  annotált disassembler) a session ideiglenes mappájában maradtak, nem repó-tartalom.

## Amit nem csináltunk

- Nem írtunk a játék konténerébe, nem módosítottunk mentést, plist-et vagy
  felhőmentést; a `game_data_corrupted.bin`-t és a biztonsági mentéseket nem
  nyúltuk.
- Nem indítottunk játékot és nem végeztünk élő mentéspróbát.
- A gyűjtőt, supervisort, dashboardot nem állítottuk le és nem indítottuk újra.
- Nem módosítottunk felismerési küszöböt vagy más futó komponenst.

## Módszertani jegyzet (reprodukálhatóság)

1. `global-metadata.dat` v39: 380 bájtos fejléc, szekcióbejegyzésenként
   (offset, size, count) 12 bájt; methods-rekord 30 bájt, token a +18-nál;
   a tokenből `row = token & 0xFFFFFF`, a modul `methodPointers[(row−1)*8]`
   adja a függvénycímet.
2. A codeGenModule megtalálása: az image-név C stringjére mutató pointer a
   `__DATA`-ban, mögötte `methodPointerCount` (= az image metódusszáma) és a
   `methodPointers` tömb címe.
3. Metadata-usage slot dekódolás: a slot nyers 64 bites értékéből
   `kind = (v & 0xE0000000) >> 29` (1: típus, 5: string-literál, 6: metódus-ref),
   `index = (v & 0x1FFFFFFE) >> 1`; a slotok a `__DATA` szegmensben élnek.
4. A generikus (`UdRoot<T>`) kód nem szerepel a methodPointers-ben; a hívó
   EL-feloldásával és a slot-hivatkozások (adrp+add) szkennelésével találtuk meg
   a `0x32C1xxx` régióban.
