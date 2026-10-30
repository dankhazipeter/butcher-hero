# Egyszámjegyű 1.22K-csonkolás és szélescsík-őr

## Bizonyított hiba — `20260829-011302-play/frame-00002.png`

A kép jobb felső részén egy páncélos fölött jól olvasható `1.22K` HP áll. Az elemző
ugyanennek a 57 px széles piros csíknak mindössze `7` HP-t adott, nem ismert fel
szintet és nem jelölte bossnak. A döntő ezért 309 px-ről kétszer közvetlenül felé
indult. A későbbi bossőr kimenekített, a játékos HP-ja 424 maradt, de a korai célválasztás
veszélyes volt.

## Ok

A cél-HP OCR-régió mindössze 6 pixellel kezdődött a piros csík fölött. A magasabb
számjegyek és a `K` felső része kilóghatott; a Vision így egyetlen téves számjegyet
adott vissza. Ez a korábbi `1.22K→221` hibától külön eset: itt nem maradt háromjegyű,
gyanúsan nagy érték, ezért a 150-es őr nem segített.

## Javítás

- A HP-régió 76×(csík+15) helyett 84×(csík+36), és 18 pixellel a csík fölött indul.
- Ismeretlen szintű, nem-fa cél legalább 45 px széles csíkján a 20 alatti OCR-HP
  csonkolásnak számít és tiltott.
- Az OCR nélküli széles csík régi tiltása változatlan.
- Ismert 1–2. szintű célok külön ágon továbbra is támadhatók; a szabály nem tiltja a
  bizonyított kis kaktuszokat.

## Regresszió

A `20260829-011508-replay` ugyanazon képen már `cél nincs biztonságos` döntést adott.
Az 1.22K száma nem lett stabil numerikus mérés, ezért a nagyobb OCR-régió önmagában nem
elég, de a szélescsík-őr megbízhatóan kizárta a közvetlen üldözést.

Élő ellenőrzés: `20260829-011525-play`.
