# Élő biome-szűrő és ismételt +10: 502 HP

## Élő telepítés — `20260829-030113-play`

A javított folyamat 492 HP-val indult a zöld Meadowlands területen. Bár az
`UNLOCKS AT ISLAND 4` HUD végig látható volt, a 0–155. eseményben egyszer sem jelent
meg a téves „Látható Island 4-zárfal” döntés. A bot normál minimap-, statikus
akadály- és célközelítési ágakat használt. Ez az `orangeRockBiomeVisible` kapu első
élő igazolása.

## Ismételt 10-szíves fenyő

- `frame-00054`: 10-szíves, 48 HP-s fenyő a játékostól balra-felfelé.
- `frame-00058`: a bot elérte a fát, még 48 HP.
- `frame-00060`: 248 és 24 találati szám, a cél eltűnik.
- `frame-00062`: közvetlen zöld `+10` szív, 3:58 respawnkör és teljes 502 HP.
- `frame-00064`: a `+10` továbbra is látható, a 502 stabil.

Ez a `025524-play` korábbi `475→485` példája után második közvetlen bizonyíték arra,
hogy a 10-szíves, 48 HP-s Meadowlands-fenyő +10 max HP-t ad. A jutalom
megismételhető célpéldányokon; az egyedi fa újratermelése a képen kb. négy percről
indul.

## Aktuális állapot

A fejezet mérési pontján a `docs/bot-state.json` hiteles maximuma 502 volt. A futás
későbbi +2/+3 humanoidjai 507-re emelték; lásd a 57. dokumentumot. A Meadowlands
szívfarm elsődleges marad.
