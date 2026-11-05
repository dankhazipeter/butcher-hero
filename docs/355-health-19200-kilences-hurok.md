# „?” Health: 19.2K a 623×863 ablakban

2026-11-05 reggel. A felhasználó újraindította a gyűjtést, és a Naplóban
a Health átvételek összege „?” lett.

## Tények

- 12 Health claim 07:16–07:52Z között, mind 623×863 ablak, 15 px számjegyek.
  Kártyán „19.2K”, három független claim utóképén „+19.2K” szívikonnal.
- Olvasó: az 1 jó, a 9 = 0.111, a 8 = 0.136, a különbség 0.025 < 0.035, ezért
  helyesen nem tippelt.

## Elvetett első javítás

A korábbi módszer, az egy új „9” glyph felvétele, a 19.2K-t megoldotta. A teljes
visszajátszás (6480 ismert összegű kép) viszont 293 korábban helyes képet
nil-re rontott (636, 630, 633), mert a 15 px-es 9 jobban hasonlít azok 3-asára,
mint a meglévő 3-mintáik. Visszavontuk, a digits.json változatlan.

## Javítás: zárt hurok mint döntő jel

A font alakja: a 3-nak nincs zárt belső hurka, a 9-nek egy, a 8-nak kettő
(ellenőrizve 598, 591, 549, 633, 636, 630 és 19.2K képeken). Az
`RewardNumberReader.counters` a 24×32-es glyphmaszk szegélyt nem érintő
háttérrégióit számolja. Csak akkor dönt, ha a két legjobb jelölt 3/8/9 közül
való, a 0.035-ös margó miatt amúgy is ismeretlen maradna, és pontosan az
egyik jelölt hurokszáma egyezik (hibája < 0.30). Tiszta egyezést soha nem
változtat meg, küszöb és minták változatlanok.

## Ellenőrzés

- Visszajátszás a 6480 ismert összegű képen: 6479 egyező, 1 régi ismert
  naplóhiba, 0 nil, ugyanaz, mint javítás előtt. A 12 Health kép mind 19.2K.
- Új teszt (`testSmallFontNineIsToldFromThreeAndEightByItsCounter`): három
  19.2K claim, valamint a 598/633 glyphek hurokszáma (0,1,2 / 1,0,0).
- A „?” sorokat a 353-as állandó szabály szerint utólag `reconcile`
  javítja; az eredmény itt alább.
