# Aktuális statforrások és 693 DPS build

## Közvetlen inventory-audit

A jogi Continue után újratöltött világban a jobb oldali inventory láda a jelenlegi
állapotot mutatta:

- DPS `517`;
- HP `778`;
- Health Regen `22.5`;
- Cut Damage `92 +500`;
- Pierce Damage `16 +8`;
- Smash és a három lapos defense mező `0`.

A képlet közvetlenül összeállt a két felszerelt fegyverből:

- Bat Cleaver: `(92 + 500) / 1,2 = 493,3 DPS`;
- Savage Fang: `(16 + 8) / 1,0 = 24 DPS`;
- összesen kerekítve `517 DPS`.

## Fegyveradatok

### Bat Cleaver

- Uncommon, Cutting;
- 10 példány, 50 Damage/példány;
- aktuális Damage 500, következő előnézet 550;
- cooldown 1,2 s;
- `WOOD TRIBUTE` special ability 130 példánynál;
- `EVOLVE 10/130` csak progressziójelző, jelenleg nem teljesíthető.

### Savage Fang

- Common, Piercing;
- az inventory-auditkor 1 példány, az első 1.22K bossgyőzelem után 2, a második után
  3 példány;
- 8 Damage/példány, jelenlegi saját Damage 24;
- cooldown 1,0 s;
- `STAB DEVOUR` 100 példánynál.

### Steel Splitter

- Common, Cutting;
- 14 példány, 12 Damage/példány;
- aktuális Damage 168, következő előnézet 180;
- cooldown 1,3 s;
- `CUT DEVOUR` 100 példánynál.

## Ingyenes buildoptimalizálás

A Steel Splittert a második, Savage Fang helyére szereltük. A játék explicit
`SELECT SLOT TO EQUIP` választót adott, ezért a Bat Cleaver biztosan megmaradt.
Az eredmény:

- Equipped: Bat Cleaver 10 + Steel Splitter 14;
- Savage Fang az inventoryba került; későbbi bossjutalmakkal jelenleg 3 példányos;
- Cut sor `92 +668`;
- Pierce sor `16`, felszerelésbónusz nélkül;
- DPS `517→693`, HP és regen változatlan.

Ez `(92+500)/1,2 + (92+168)/1,3 = 693,3`, tehát a kijelzés kerekítése és a
fegyverenként, támadástípusonként számolt DPS modell közvetlenül igazolt. A csere
kb. 34%-os DPS-növekedés, fizetős valuta vagy példány felhasználása nélkül.

A későbbi két 1.22K bossjutalom Savage Fang `1→2→3`, Damage `8→16→24` fejlődést
adott. Mivel a Fang nincs felszerelve, ez nem módosította a jelenlegi 693 DPS buildet.

## Statforrások

A kék info panel statonként megmutatta a forrásokat:

- Movement Speed: Flat +9 = Base +1 + Enemy +8; effektív érték `5.92`;
- Health: Flat 770 = Base 100 + Enemy 660 + Secret Chest 10;
- Health Percent: Secret Chest ×1,01; `770 × 1,01 = 778`;
- Health Regen: Base 0,5 + Enemy 22 = 22,5;
- Cut Damage: Enemy 90 + Secret Chest 2 = 92;
- Pierce Damage: Enemy 16 = 16;
- Pierce/Cut/Smash Damage% és a látható Pierce/Cut Defense% alapértéke 100%.

Ez bizonyítja, hogy az ellenségek nemcsak max-HP-t, hanem külön mozgás-, regen-,
Cut- és Pierce-statokat is építettek. A Secret Chest +10 HP, +1% HP és +2 Cut Damage
hatása a panelen forrás szerint is megmaradt.
