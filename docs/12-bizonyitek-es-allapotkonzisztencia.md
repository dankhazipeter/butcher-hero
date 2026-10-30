# Képi bizonyíték, OCR és tartós állapot egyeztetése

Ez a lap rögzíti, hogyan választjuk szét a közvetlen képi tényt, az OCR által javasolt
számot és a futások között megőrzött gépi állapotot. Erre azért van szükség, mert a
játék időzítői, találati számai és ikonokkal összeragadt feliratai gyakran ugyanabba a
képrégióba kerülnek, mint a játékos HP-ja.

## Bizonyítéki sorrend

1. A mentett PNG az elsődleges bizonyíték: rajta külön értékeljük a zöld csík teltségét,
   a ténylegesen látható számot és a takaró elemet.
2. A Vision nyers szövege mérési adat, nem automatikusan játékállapot. A timerből,
   találati számból vagy célpontból származó jelöltet a képi geometriával is egyeztetjük.
3. Az időbeli sorozat dönti el a nagy ugrásokat. Egyetlen képkocka nem írhatja felül a
   stabil előzményt, ha a pixelcsík ellentmond neki.
4. A `bot-state.json` csak hitelesített, többször látott maximumot őriz. Nem helyettesíti
   az aktuális képet, hanem fizikai korlátot és arányos összehasonlítási alapot ad.
5. Ha nincs megbízható számszerű HP, ezt hiányzó értékként naplózzuk. A döntő ilyenkor
   a zöld csík arányával működhet tovább; tilos egy timer-számot kényszerből HP-vá tenni.

## Első rögzített eset: `4h 57m` kontra 286 HP

- Forrás: `docs/runs/20260828-210202-play/frame-00000.png`.
- Kép: teljes zöld játékoscsík; a szám helyén/térségében hosszú időzítő takar.
- Nyers OCR: `4h 57m`.
- Következő tiszta kép: 286 HP és továbbra is teljes csík.
- Régi hiba: az 57 tartalék HP-jelöltként visszakerülhetett.
- Új döntés: a pixelcsíkkal összeegyeztethetetlen jelöltek teljesen kiesnek; üres jelöltlista
  esetén csak arányos HP van.
- Regresszió: `docs/runs/20260828-210417-replay`; az első eseményben nincs
  `playerDisplayedHP`, a `playerHealthFraction` 1, a következő eseménytől az érték 286.

## Dokumentációs következmény

Új maximumot, jutalmat vagy sebzésértéket csak képkocka és időbeli eseménysor együtt
emelhet biztos ténnyé. Ha egy későbbi ikon vagy sebzésmérés megcáfol egy régi oksági
magyarázatot, a konszolidált leírást javítjuk, a régi hipotézist pedig történeti,
cáfolt állításként őrizzük meg.
