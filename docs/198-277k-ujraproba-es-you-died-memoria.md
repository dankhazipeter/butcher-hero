# 27,7K-s újrapróba és YOU DIED memória

## Élő harci eredmény

- A `084413-play/238` 4,41K saját maximumnál kontrollált próbát indított a
  27,7K-s lovag ellen. Ez a korábbi 3,43K-s vereség óta több mint 20% fejlődés,
  ezért a próba szabályosan nyílt újra.
- A `247` képen már tényleges közelharc és 320-as saját sérülés látszott; a boss
  25K-n, a karakter 2,77K-n állt.
- A `253` képen a karakter saját csíkja 0 volt, a boss 20,1K-n maradt; a `254`
  képen biztos `YOU DIED` overlay jelent meg.
- A próbában a boss körülbelül 7,6K HP-t vesztett. A jelenlegi build tehát
  érdemben sebzi, de 4,41K saját maximum nem elég a teljes harc túléléséhez.
- A halál után a játék automatikusan a Meadowlands 1 Titan-medencéjénél
  élesztett újra. Bat Cleaver 11 és Steel Splitter 22 megmaradt.

## Felismert programhiba

A halálképen a Vision pontosan felismerte a `YOU DIED` szöveget, de a régi
numerikus HP-memória és a háttér zöld komponensei 100%-os saját HP-t adtak. Emiatt
a normál `health < 35%` ág nem írta felül a 27,5K-s vereségsáv régi, 3430-as
erőszintjét.

## Javítás

- Minden nem passzív kontrollált bosspróba rövid ideig külön őrzi a kezdő HP-t.
- Biztos `YOU DIED` OCR esetén a bot ettől a HP-tól tartósítja a vereségsávot,
  függetlenül a pillanatnyi, takart saját HP-méréstől.
- A 27,5K-s sáv most 4410-es erőszinthez kötött. Következő újrapróba legkorábban
  `4410 × 1,20 = 5292` hiteles maximumnál engedélyezett.
- A halálképen a bot input nélkül várja az automatikus újraéledést.

## Nyitott következtetés

A körülbelül 7,6K kiosztott sebzés alapján a fegyver-DPS megfelelő, de a saját
túlélési idő rövid. A következő próbát HP-farm és/vagy új védekező stat után kell
megismételni; puszta agresszívebb mozgás 5292 HP alatt nem indokolt.

