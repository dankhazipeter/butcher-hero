# Lila zóna felől elérhető +10 fa és 778 HP

## Élő bizonyíték

Az `084349-play` új binárissal és a kijavított 768-as tartós maximummal indult. A bot
kijutott az Island 4 bal zsebéből, a lila sziklafal külső oldalára ért, majd boss- és
lezártiránnyal szembeni kerülés után másik oldalról tért vissza a központi táborhoz.

Az eseménysor:

- 158: a 174 HP-s, 10-szíves fa 208 pixelre megjelenik;
- 160: 166 pixel;
- 161: 127 pixel;
- 163: a fa eltűnik a rövid célmemória után;
- 164: friss 778-as teljes HP és új maximumszekvencia;
- a `frame-00164.png` képen a karakter mellett közvetlenül látszik a `+10` piros
  szívjutalom.

A tartós `maximumDisplayedHP` 768-ról 778-ra frissült.

## Új útvonal-ismeret

Ugyanez a fa korábban a szikla–fenyő–sátor tömb másik oldaláról 284/285 pixelen
megállította a közvetlen üldözést. A mostani, lila zóna felől érkező délkeleti ív
akadály nélkül 127 pixelre zárt. A probléma tehát nem a fa általános
elérhetetlensége, hanem a megközelítés oldala.

## Stratégiai következmény

A lila zóna felé végzett hosszabb kiszakadás farmútvonal része lehet: nemcsak új
területet tár fel, hanem bizonyítottan hozzáférhető oldalt ad ehhez a +10 HP-s fához.
Ha a közvetlen oldal ismét 285 pixelen platózik, a botnak érdemes nagyobb zónakört
tennie és délkelet felől visszatérnie.

## Biztosság

- **Biztos:** a jutalom +10 max-HP, a változás 768→778.
- **Biztos:** a fa 127 pixelről eltűnt, automatikus támadással kivágódott.
- **Biztos:** a korábbi plató nem általános elérhetetlenség.
- **Még mérendő:** a zónakör tudatosan, ismételhetően ugyanarra a kedvező oldalra
  vezethető-e a következő újratermelődés után.
