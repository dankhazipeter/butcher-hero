# Kapuőr-Unstuck a kamerafüggő biomjeltől függetlenül

## Élő anomália

A `docs/runs/20260829-074055-play/frame-00300` képen a bizonyított helyi 192/1,927K
fegyveres elit a játékos jobb oldalán, 311 pixelen látszott. A bot helyesen bossként
menekült tőle, de nem indította el a korábban erre a kapuzsebre megtanított azonnali
Unstuck-helyreállítást.

Az ok egy forráskódban maradt régi feltétel volt: a kapuőr csak akkor számított
Unstuck-azonosítónak, ha `orangeRockBiomeVisible=false`. A jelenlegi kameraállásban a
bal oldali narancsszikla látszott, noha az elit és a játékos ugyanabban a híd–sátor
zsebben állt.

**Biztos tény:** a biomjel kamerafüggő, nem a kapuőr elérhetőségének bizonyítéka. A
jobb oldali elérhetőséget már külön geometriai feltétel védi: az elit x-koordinátája
a képszélesség legalább 36%-a. A 90–199 HP-s, ismeretlen szintű, jutalomikon nélküli,
nem-fa bossaláírás további szűrői változatlanok.

## Döntés

A `!orangeRockBiomeVisible` vétót eltávolítottuk az azonnali kapuzseb-Unstuckból.
Ezentúl a lezárt Island 4 HUD + jobb oldali, bizonyított 92/192-es elit + teljes HP
együtt közvetlenül megnyitja a Settings panelt. A bal 36%-ban lévő, fal túloldali
ellenfél továbbra sem válthatja ki ezt az ágat.

Az Unstuck kimenetét az eltűnő Settings-X vagy HUD-esés igazolja. Aktív időzárnál öt
megmaradó X-es döntés után biztos bezárás és 900 döntéses hűtés következik.

## Ellenőrzés

- Célzott kép: `074055-play/frame-00300`.
- Elvárt első döntés: Settings megnyitása a kapuzseb saját Unstuck helyreállításához.
- Élő buildben ellenőrizendő: eltűnő X/HUD-eséses siker vagy szabályos cooldown-bezárás.

A `docs/runs/20260829-074759-replay` célzott visszajátszása teljesítette az első
elvárást: a döntés `(38, 66)` Settings-tap lett, pontosan a kapuzseb saját Unstuck
indokával. Az ezt tartalmazó első élő build: `docs/runs/20260829-074813-play`.

## Élő eredmény

A `074813-play` teljesen igazolta a változtatást:

- 41. esemény: bossmenekülés a kapuőr első felismerésekor;
- 48. esemény: az új, biomfüggetlen kapuőrág megnyitotta a Settings panelt;
- 49. esemény: egyszeri Unstuck-tap;
- `frame-00052`: explicit `YOU DIED`;
- `frame-00056`: üres zöld medence az átmenetben;
- `frame-00058`: a karakter újra megjelent a medencénél;
- `frame-00060→00066`: 310→747 gyógyulás;
- 79. esemény: a harminc inputmentes döntés után friss 747 OCR-rel újratervezés;
- `frame-00090`: a karakter már kijutott a medencéből, a Titan-portál felé haladt.

A javítás tehát nemcsak a Settings-döntést, hanem a teljes zseb→halál→medence→teljes
HP→újratervezés láncot élőben teljesítette.
