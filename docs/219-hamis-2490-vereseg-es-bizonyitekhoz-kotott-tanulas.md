# A 2,49K-s őr hamis vereségsávja — 2026-09-19

## Visszamenőleges audit

`docs/runs/20260919-123241-5a5f5eb3-play/41–45`: a saját szám folyamatosan
5,23K. A 42. képen a 3m59s respawnkör a saját csíkra fed; a pixelmérés 21%-ot
ad, miközben a képen a zöld csík teljes. A legközelebbi cél ekkor egy 672-es őr.
A kód mégis a korábban látott 2,49K-s őrt társította a kritikus HP-hoz, és
`2250:5230` tartós vereségsávot írt. A 44. kép hibás `5:23` → 5 HP olvasatát
már a 213-as javítás kezelte; a hamis tudásadat azonban megmaradt.
A 45. kép ismét friss 5230, halálképernyő nem volt. A 49. képen maximum5240.

Ez nem igazolt harci kudarc. Emiatt a mai 124302 és 125151/125213/125244
döntései indokolatlanul kerülték a 2,49K-s őröket.

## Javítás és adatkorrekció

- Alacsony HP-ból csak **friss numerikus** mérés írhat tartós vereségsávot.
  A külön YOU DIED ág továbbra is elsődleges bizonyíték. Pixeles veszélynél
  visszavonulás megengedett, de az nem automatikus tartós harci tudás.
- Kizárólag a cáfolt `2250:5230` bejegyzést töröltük; a többi történeti
  sáv és a bizonyított két nagy bossvereség változatlan.
- A kisebb őröket most friss, kontrollált kontaktussal kell felmérni.
  Nem állítjuk pusztán a korrekcióból, hogy könnyűek.

A release build és a teljes regressziós tesztsor sikeres. A YOU DIED közvetlen
ága kódellenőrzéssel változatlan; a csonkolt 5:23 regresszió is továbbra zöld.
