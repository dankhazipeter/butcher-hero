# Dusty Gulch – 2 és a fegyverhely HUD helyes értelmezése

## A döntő képi bizonyíték

A `docs/runs/20260829-140735-play/frame-00242.png` közepén a játék kiírja:
`Dusty Gulch – 2`. A karakter a narancssziklás terület normál bejáratánál áll,
balra és a minimapon is ellenfelek látszanak. Ugyanezen a képen továbbra is ott
van az `UNLOCKS AT ISLAND 4` lakat.

Ez közvetlenül cáfolja, hogy a felirat a narancssziklás területet lezáró kapu
lenne. A lakat a bal oldali, még üres fegyverhelyhez tartozó globális HUD-elem:
azt jelzi, hogy a következő felszerelési slot Island 4-nél nyílik meg.

## Hogyan jutottunk be

- A piros vektor első közvetlen követése helyi szikla–víz–kerítés akadályhoz ért.
- A hatirányú próbát követő Unstuck a zöld Titan-medencéhez tett
  (`frame-00109`); nem közvetlenül a narancsszikla belsejébe teleportált.
- A védett helyi felderítés később más útvonalon elérte a `Dusty Gulch – 2`
  bejáratát (`frame-00242`).
- Ettől kezdve a karakter normálisan járt és harcolt a narancssziklás területen.

## Azonnali fejlődési eredmény

A Dusty Gulch – 2 sűrűn tartalmaz 253 HP-s, 4-es szívikonnal jelölt humanoidokat.
A képen megjelenő `+4` szív és a tartós saját HP-sor együtt bizonyítja a jutalmat:

- `140735-play/frame-00305`: 778→782 és látható `+4`;
- `frame-00317`: 782→786 és `+4`;
- `frame-00324`: 786→790;
- `frame-00328`: 790→794 és `+4`;
- `frame-00340`: 794→798;
- `142259-play/frame-00073`: újabb tartós 798→802.

**Biztos:** legalább hat, egyenként +4 maximális HP-t adó cél esett el; a hiteles
maximum 778-ról 802-re nőtt. Ez rövid idő alatt +24 tartós HP, ezért a Dusty
Gulch – 2 jelenleg kiemelt farmterület.

## További célok a területen

- 632 HP-s, `1`-es zöld ikonos kaktusz/élő növényi cél: a `140735-play` 328–333.
  képein 632→206 sebzést kapott, de biztos jutalom vagy ölés még nincs.
- 765 HP-s hasonló cél többször elérhető közelségbe került; jutalma még nincs
  azonosítva.
- Az ismert 1.22K-s páncélos itt is előfordul; egy új próbában 1220→731 HP-ig
  sérült, de a harmadik biztos Savage Fang-jutalom még nem látszott.
- A `141620-play/frame-00022` egy 4.4K HP-s, távoli ellenfelet mutat egy helyi
  szikla/építmény mögött. Az első kerülő nem hozott harci kontaktust; külön
  útvonalkísérlet kell.

## Programjavítás

- A képi mező neve `island4WeaponSlotLockVisible`; szemantikája most explicit.
- Ez a HUD-jel többé nem vesz részt navigációban, célpontbiztonságban, stratégiai
  respawnban, elakadásbizonyítékban vagy földrajzi bal/jobb céltiltásban.
- A korábbi fix jobbra-le „Island 4-kijárat” megszűnt.
- A 150 jutalommentes döntés után erősen balra mutató piros céltől automatikusan
  eltávolító szabály megszűnt. Valódi akadályt a képi statikusság, faljárás és
  cél-aláírásos hűtés kezel.
- A Dusty Gulch narancsszín-mérése megmarad, de csak helyi OCR-hibamintákhoz és
  akadálykerülő geometriához; nem jelent lezárt területet.
- A Meadowlandsban hasznos, öt eredménytelen boss-találkozás utáni stratégiai
  respawn Dusty Gulchban nem indulhat el: a sűrű nagyellenfél-jelenlét mellett is
  értékes +4 farm működik, ezért ott a bosskerülés és a kis szíves cél az elsődleges.
- A Dusty Gulchon belüli zöld oázisfolt egy képre elrejtheti a narancs biomot.
  A narancsmérés ezért 8%-os küszöböt és 12 döntéses memóriát használ; enélkül a
  `142613-play/frame-00140` 67.5K-s növénye tévesen stratégiai respawnt indított.
- A Deep Mines-kapuhűtés kizárólag az `anti-stone potion 0/1` küldetés és a
  tényleges kétoldali stagnálás bizonyítékára épül.

Release build és teljes regresszió: `docs/runs/20260829-142308-replay`.
Az új szabály élő folytatása: `docs/runs/20260829-142613-play`.
