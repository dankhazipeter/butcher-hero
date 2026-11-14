# 363 — A bizalmi réteg: mi történik a mentéssel a lokális hash-ellenőrzés után (2026-11-14)

## Kérés

A 362 után a felhasználással folytattuk: a lokális integritás-hash receptje
ismert, de a nyitott kérdés az, hogy **egy hash-szel konzisztensen módosított
mentéssel mi történik a játék betöltésekor** — elfogadja-e a játék, vagy a
felhő/bizalmi réteg visszaállítja. Ez a kör tisztán statikus elemzés: konténerbe
nem nyúltunk, játékot nem indítottunk, nem teszteltünk élő szerkesztést.

## A teljes lánc betöltéskor

A `Codebase.Core.MainSceneInitializer.Start` állapotgépe (Assembly-CSharp,
`<Start>d__28`, 0x2E6F700 környéke) így hozza össze a rétegeket:

```
TryLoadAndSaveRepairingFiles()          # 362-ben leírva: main → backup → pre_cloud
    sikeres fájl → CommittedSaveHash = a betöltött fájl hash mezője
    minden fájl rossz → IsCommittedSaveRejected = true
CheckLocalSave(gameData.CommittedSaveHash)
if (gameData.IsCommittedSaveRejected) DistrustLocalSave()
```

A `CloudSavesService.CheckLocalSave(hash)` (0x381F3A0) közvetlen tail-hívás a
`CloudSaveLocalTrust.Check`-be (0x381F444):

```
Check(fileHash):                                   # fileHash = CommittedSaveHash
    IsChecked = true
    if (_state.IsUntrusted) return true            # már distrustált: nincs új döntés
    remembered = _state.LocalSaveHash              # PlayerPrefs: cloud_save_local_hash
    if (remembered üres):
        if (fileHash üres) return true
        _state.Write(fileHash, ...)                # első alkalom: megjegyzi
        return true
    if (String.Equals(remembered, fileHash, Ordinal)) return true
    Distrust()                                     # eltérés!
```

`Distrust()` (0x381F654): `Debug.LogWarning` + `_state.Write(régi hash,
isUntrusted: true)` — a PlayerPrefs-ben a `cloud_save_local_hash` megmarad, de a
`PlayerPrefsLocalState` +0x18 `IsUntrusted` mező (és a hozzá tartozó
PlayerPrefs-kulcs) igaz lesz. `IsTrusted => !IsUntrusted` (0x381FE84, `eor w0,#1`).

`Remember(hash)` (0x381F848): csak ha nincs distrust és a hash nem üres —
`_state.Write(hash, isUntrusted: false)`. `Forget` a `CloudSaveSession.ApplyCloud`-ból
hívódik (a felhői mentés alkalmazása után elfelejti a lokálisan megjegyzett hash-t).

## A felhői szinkron döntése (CloudSaveSync.Sync)

A `<Sync>d__21` állapotgép (0x382B640 környéke) a 362-ben azonosított
**SHA256-os** `CloudSaveHash.Compute`-tal számolja a lokális mentés hash-ét,
 majd:

```
if (AreEqual(felhői Sha256 (CloudSaveMetadata), lokálisan számolt SHA256))
    → Remember + NothingToDo                       # 0x382B698–0x382B704
else
    → időbélyeg-összehasonlítás                    # 0x382B724–0x382B748
    → ha a felhői újabb: CloudSaveSync.Download → Apply → HandleOverwritten
      (a lokális fájlt felülírja a felhői mentés)  # 0x382B71C
    → különben a feltöltés ága                     # 0x382AFD8 (nem fejtettük teljesen)
```

Az `Apply`/`ResolveConflict` útvonalak `HandleOverwritten`-et (0x3826FE0) hívnak;
a konfliktus-felület a `DevourCloudSavePrompt`/`ProfileSavesConflictView`.
A bizalmat a `CloudSaveSession.Resumed`, `<Boot>d__21` és `<Resume>d__22`
hívott `Trust()` (0x3826524) állítja helyre — a felhői művelet sikere után.

## Következtetés a gyakorlatra — mit jelent egy konzisztens lokális szerkesztés

1. **A fájl saját MD5-ellenőrzése átmegy** (362 receptje: data + kulcs +
   optimális salt-kódolás) — nincs „SAVE DATA ERROR", a módosított állapot
   betöltődik és játszható.
2. **A bizalmi réteg viszont eltérést lát**: a `CommittedSaveHash` (a módosított
   fájl hash-e) nem egyezik a PlayerPrefs `cloud_save_local_hash` értékével (a
   felhővel utoljára szinkronizált állapotéval) → `Distrust`, IsUntrusted=true.
3. **Ha a felhő-szinkron aktív**, a Sync a lokális SHA256 és a felhői Sha256
   eltérését látja; a megfigyelt szerkezet szerint időbélyeg-döntés: felhői
   újabb → letöltés és lokális felülírás (a módosítás elvész), lokális újabb →
   feltöltés (a módosítás a felhőre kerül — ezt az ágát csak szerkezetből
   következtetjük, nem fejtettük végig). Konfliktus esetén prompt is előfordulhat.
4. A tartós lokális módosítás feltétele tehát a 362-es recepten felül a
   `cloud_save_local_hash` PlayerPrefs-kulcs összehangolása (és/vagy a szinkron
   helyzet rendezése). **Ezt nem próbáltuk ki** — a plist TCC-védelem alatt áll
   ehhez a folyamathoz, és mentésírás-próba külön, explicit felhasználói kérésre
   történhet csak.

## Bizonyított és következtetett állítások

- Bizonyított (disassembly + hívási gráf): a Check/Distrust/Remember/Forget/Trust
  logika, az IsUntrusted-alapú IsTrusted, a PlayerPrefs `cloud_save_local_hash`
  olvasása/írása (`PlayerPrefsLocalState`, +0x10 hash, +0x18 untrusted), a Sync
  SHA256-összehasonlítása és a Download-ág, a HandleOverwritten hívói, a
  MainSceneInitializer.Start döntési sorrendje.
- Következtetett (szerkezetből, nem lépésről lépésre fejtve): a feltöltési ág
  feltételei (időbélyeg-alapú irány), és hogy a módosított mentés pontosan így
  viselkedik élőben — élő próba nélkül marad.
- A szerver oldali ETag/SHA-ellenőrzés külön mechanizmus, ahhoz nem nyúltunk.

## Főbb címek (kiegészítés a 362 listájához)

| Funkció | Cím |
|---|---|
| `MainSceneInitializer.<Start>d__28` CheckLocalSave/Distrust döntés | 0x2E6F818–0x2E6F858 |
| `CloudSavesService.CheckLocalSave` | 0x381F3A0 |
| `CloudSavesService.DistrustLocalSave` | 0x381F63C |
| `CloudSaveLocalTrust.Check/Distrust/Remember/Forget/Trust` | 0x381F444 / 0x381F654 / 0x381F848 / 0x3826368 / 0x3826524 |
| `CloudSaveLocalTrust.get_IsTrusted` | 0x381FE84 |
| `PlayerPrefsLocalState` get/set_LocalSaveHash, get/set_IsUntrusted, Write | 0x3826270–0x3826290 |
| `CloudSaveSync.Sync` SHA-compare + Download ág | 0x382B640–0x382B71C |
| `CloudSaveSession.HandleOverwritten` | 0x3826FE0 |
| `GameDataService.get/set_IsCommittedSaveRejected` | 0x2E78D1C / 0x2E78D24 (mező +0x68) |
| `GameDataService.get_CommittedSaveHash` | 0x2E71374 (mező +0x48, a CommitSave írja) |

## Amit nem csináltunk

- Nem írtunk a konténerbe, nem módosítottunk mentést vagy plist-et (a plist
  e folyamat számára nem is olvasható: TCC).
- Nem indítottunk játékot, nem végeztünk élő mentés-szerkesztési próbát.
- A gyűjtőt, supervisort, dashboardot nem érintettük; a naplók változatlanok.
