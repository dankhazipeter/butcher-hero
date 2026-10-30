# Settings / Unstuck és gyógyító medence

## Menüfelderítés

A `20260829-065615-play` futásban a bot a teljesen statikus Island 4-kapuzsebnél
egyszer megnyitotta a bal felső fogaskereket, majd minden további inputot letiltott.
A Settings panelen az alábbi, játékmenet szempontjából lényeges elem látszott:

- sárga `Unstuck` gomb;
- alatta explicit leírás: `Press this button if your hero is stuck`.

A panelen hang, rezgés, minőség, értesítések, nyelv és promóciós kód is található,
de ezekhez a bot nem nyúlt. Az Unstuck a játék saját, célzott helyreállító funkciója,
ezért biztonságosabb a halál mesterséges kikényszerítésénél.

## Első élő Unstuck

A `20260829-065757-play` 0. eseménye egyszer megnyomta az Unstuck gombot. A képsor:

1. a menü bezárult, a kapuzseb eltűnt;
2. a kamera egy romos, zöld folyadékos gyógyító medencéhez ugrott;
3. a karakter a medencében 119 HP-val jelent meg;
4. a friss OCR 614, majd 672, végül 747 HP-t mért;
5. a maximális 747 HP és a hét fegyverpéldány megmaradt.

Az első mintából még csak a helyi áthelyezés és automatikus gyógyulás látszott. A
`072159-play` később explicit `YOU DIED` képpel bizonyította, hogy az Unstuck valójában
kontrollált halált és automatikus újraéledést indít. Nem jutalomvesztő új játék: a
maximum és a felszerelés megmarad. A HUD az átmenetben bizonytalan, ezért ilyenkor nem
szabad célpontot vagy normál sebzést értelmezni.

## Első teljesen automatikus siker

A `docs/runs/20260829-072159-play` 85. eseménye a 192-nek csonkolt helyi elit mellett
megnyitotta a Settingset, a 86. megnyomta az Unstuckot. A mentett képsor:

- `frame-00084`: teljes 747 HP, a 192-es elit a kerítés másik oldalán;
- `frame-00086`: Settings, aktív sárga Unstuck gomb;
- `frame-00088`: explicit `YOU DIED`;
- `frame-00100`: zöld medence, 134 HP;
- `frame-00110`: 717 HP;
- `frame-00116`: teljes 747 HP, hét fegyverpéldány.

A HUD-eséses állapotgép helyesen sikernek minősítette, harminc inputmentes ciklust várt,
majd csak a 116. eseménynél tervezett újra. Ez közvetlenül igazolja a megmaradó
maximumot/felszerelést és a teljes automatikus helyreállítási láncot.

## Beépített állapotgép

Az első megvalósítás három szakaszos volt: Settings megnyitása, egyszeri Unstuck-tap,
majd harminc inputmentes döntési ciklus. Az ismételt élő próba azonban megmutatta,
hogy az Unstucknak többperces időzára van. Emiatt a puszta időalapú várakozás elvetve;
a végleges állapotgép a HUD eltűnéséből ellenőrzi, hogy valóban elindult-e a teleport.

Felhasználói aktivitásos várakozás egyik számlálót sem fogyasztja. A részletes második
próba és a visszacsatolásos javítás: [Unstuck-időzár és HUD-visszacsatolás](102-unstuck-idozar-es-hud-visszacsatolas.md).

## Következő élő futás

Az automatizált állapotgéppel indított ellenőrzés: `docs/runs/20260829-070131-play`.
Ez bizonyította az Unstuck időzárát, ezért az ellenőrzött végleges változat a
`docs/runs/20260829-070657-play` felügyelt futásban dolgozik tovább.
