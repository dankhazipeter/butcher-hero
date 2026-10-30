# Venom Shard build és panelbiztonság — 2026-09-19

## Mért eredmény

A Steel Splitter 22 helyett Venom Shard 12 került a második helyre.
`20260919-115833-observe/1`: DPS 851 → 1,1K, HP 4,46K és regen 51,5 változatlan.
Bat Cleaver 11 megmaradt, Steel Splitter 22 tartalékba került. Nincs valuta-
vagy példányfogyasztás. Külön SELECT SLOT TO EQUIP panelen választottuk a második helyet.

| Fegyver | Példány | Aktuális sebzés | Cooldown | Típus |
|---|---:|---:|---:|---|
| Bat Cleaver | 11 | 550 | 1,2 s (korábbi audit) | cutting |
| Steel Splitter | 22 | 264 | 1,3 s | cutting |
| Venom Shard | 12 | 420 | 0,92 s | piercing |
| Savage Fang | 16 | 128 | 1 s | piercing |
| Phantom Edge | 1 | 100 | 0,84 s | piercing |

A statpanel típusonként 118 cutting és 74 piercing alapértéket, utóbbinál +1%-ot
mutat. A korábban igazolt képletből becslés:
`(118+550)/1,2 + ((74+420)×1,01)/0,92 ≈ 1099 DPS`.
Ez egyezik a kerekített 1,1K kijelzéssel, kb. 29%-os növekedés.
A valódi ellenfelen mért ölési idő és esetleges típusvédelem hatása még külön teszt.

## Miért maradt korábban rejtve?

A 193-as jegyzet csak a tartalékok példányszámát listázta; nem bizonyította,
hogy mind rosszabb. A mai teljes statfeltárás ezért szükséges volt. A zöld
következő sebzésérték nem aktuális érték; a példányszám önmagában sem rangsor.

## Bizonyítékok és javítás

- `115359-observe/1`: Venom Shard teljes panel.
- `115501-observe/1`: Savage Fang teljes panel.
- `115709-observe/1`: Steel Splitter teljes panel.
- `115739-observe/1`: Phantom Edge teljes panel.
- `115818-observe/1`: explicit slotválasztó.
- `115833-observe/1`: új felszerelés és 1,1K DPS.
- `115710-replay`: a régi Deep Mines jobb oldali buborék már 13S kijáratot ad.
- `115711-replay`: a Venom panel már bezárást ad, nem téves Bat-EQUIP-et.

A SPECIAL ABILITY szöveg általános fegyverpanel-szöveg, nem Bat Cleaver-azonosító.
Az automatika nem végez név nélküli felszerelést. Inventory és tárgymodal alatt
a harci HP-tanulás tiltott. Az audit és a csere felügyelt tapokkal történt.
