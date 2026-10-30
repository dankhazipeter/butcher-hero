# Island 4 bal fali `2531`: első képes és egyedül maradó csoporttag

## Két élő alak

A `20260829-055702-play` 234. eseményén egy cél nyers és simított HP-ja is 2531
lett, miközben 150 pixelen belül két normál társ 253 HP-n állt. A külön képes
replayben az egyik társ 255-re ingadozott, ezért a puszta pontosérték-számlálás
nem adott konszenzust.

A következő `20260829-060209-play` 107. eseményén már csak egyetlen cél maradt
látható a fal bal oldalán. A célmemória 253-at tartott, a nyers OCR `2531` volt,
de ismert szint nélkül az általános szintfolytonossági toldalékőr nem működött.
Mindkét eset hamis bossmenekülést indított.

## Biztonságosan szűk helyi szabály

- a 253/255 közti ±3 HP eltérés azonos közeli csoportnak számít;
- ha a nagy HP már a simított értékbe is bekerült, két 150 pixelen belüli normál
  társ és a lezárt Island 4 bal oldali, narancssziklás pozíció együtt kell;
- ha a simított 253 még megvan, ugyanezen védett faloldalon annak 1–2 jegyű
  toldaléka egyetlen látható tagnál is eldobható;
- a fal bal oldalán a cél közvetlen farmként eleve elérhetetlen, így a felmentés
  nem indít támadást; csak a hamis menekülési ciklust szünteti meg.

## Regresszió

A `060433-replay` a 234. képet normál Island 4-kifelé átlóvá tette. A jobb oldali
`1192`/192 elit nem kapja meg a helyi felmentést, a 4.31K/501 és 923 bossképek
továbbra is menekülést adnak.
