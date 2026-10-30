# Island 4 HUD-felirat biome-szűrése és 492 HP

## Megfigyelt értelmezési hiba

A `20260829-025524-play/frame-00074→00132` zöld Meadowlands-képein ugyanúgy látható
az `UNLOCKS AT ISLAND 4` felirat, mint a narancs sziklafalnál. Tehát ez globális
feloldási HUD, nem önmagában helyi zárfal-bizonyíték.

A régi szabály emiatt 116–132. esemény között ismételten jobbra-le küldte a karaktert,
és a bal 36%-ban látható elérhető célokat is kizárta. Ez történeti hiba; a feliratot
önmagában többé nem szabad geometriai kapuként használni.

## Javítás

Az analizátor ritka képpontmintákból `orangeRockBiomeVisible` állapotot számít. A
narancsszikla-osztályhoz legalább 16% nagy vörösfölényű, narancs/barna terepminta
kell. Az Island 4-specifikus szabályok csak a HUD-felirat **és** e biomjel együttese
esetén aktívak:

- bal 36%-os célkizárás;
- balra mutató minimap helyett azonnali `(0,48; 0,88)` zárfalátló;
- narancssziklára hangolt négyátlós statikus kiszabadulás.

## Regresszió

- `20260829-030044-replay`, Meadowlands `frame-00126`: `nem narancsszikla`, normál
  minimap-felderítés `(-0,78; -0,62)`.
- Ugyanez a replay-időbélyeg, narancs `024202/frame-00020`: `narancsszikla`, a
  67,5K boss továbbra is tiszta felfelé menekülést vált ki.
- Narancs `025524/frame-00054`: `narancsszikla`; a biome-kapu működik akkor is, ha
  a helyi jelenetet karakterek és effektek takarják.

A javított élő folyamat `20260829-030113-play`; biztos kezdő maximuma 492.

