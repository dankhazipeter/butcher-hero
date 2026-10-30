# Újratermelődési időzítő mint harcvégi bizonyíték

A passzív cél halálakor a helyén kör alakú, többnyire `4m 0s` körüli visszaszámláló
jelenik meg. Ez nem puszta környezeti UI: közvetlen bizonyíték arra, hogy az adott cél
elpusztult és újratermelődésre vár.

## Megfigyelt eseménysorok

Az első nagy fenyő a `215627-play` futásban:

1. 291 HP-ról indult, a 55. eseménynél 258 HP látszott;
2. a `frame-00070.png` még 43 HP-t és 33-as találati sebzést mutatott;
3. a 75. eseménynél `4m 0s`, a 80.-nál `3m 57s`, a `frame-00090.png` képen `3m 52s`
   kör maradt a cél helyén;
4. a bot jutalomfelirat híján még a 92. eseményig várt.

A második, 357 HP-ról sebzett nagy fenyőnél az időzítő 145-nél jelent meg, de a régi
memória csak 155-nél oldott le. Mindkét sor bizonyítja, hogy a timer korábbi és stabilabb
harcvégi jel, mint a becsült kivárási plafon.

Egy 10-szíves, 174 HP-s fenyő 361. eseményénél egyszerre jelent meg `3m 59s`, a
`310→320` max-HP lépés és egy `•10`-nek, később `€10`-nek olvasott lebegő felirat. Ez a
jutalom-OCR torzulásától függetlenül megerősíti a kör harcvégi jelentését.

A `222253-play/frame-00110.png` ugyanezt ismét közvetlenebbül mutatta: `320→330`, zöld
`+10` szív és `3m 59s` kör egy képen. A következő események ugyanakkor bizonyították,
hogy a timer a HP-OCR-t is beszennyezheti; ezért időegységes sor harcvégi bizonyíték
lehet, numerikus HP-forrás viszont nem.

A következő `224139-play` fenyőölésnél a program már maga is elfogadta a `+10`
jutalomeseményt és `330→340` maximumlépést. Ez megerősíti, hogy a javított harcvégi és
jutalomlánc egymással konzisztens.

## Végrehajtott szabály

- Az elemző a játékos közvetlen OCR-régiójában `m` betűt és legalább két számjegyet
  tartalmazó sort `nearbyRespawnTimer=true` mezővel naplóz. Ez akkor is működik, ha a
  Vision a másodperc `s` betűjét 5-nek olvassa.
- Ha a bot már számszerű/csíkalapú sebzést bizonyított egy passzív célon, és annak csíkja
  eltűnt, a timer azonnal lezárja a harci memóriát.
- A sorszámozott `+N` jutalom továbbra is ugyanilyen erős bizonyíték.
- Ha egyik sem olvasható, a HP/ütésszám alapján becsült, 8–36 döntéses kivárás marad.

## Nyitott regressziós kockázat

A ritkított, minden ötödik PNG-t tartalmazó replay elveszítheti a folyamatos célazonosságot:
egy távoli másik csíkot új célként láthat, mielőtt a mentett timerkép következik. Emiatt a
timeres lezárás elfogadási feltétele az élő, minden képet elemző `220154-play` futásban
ellenőrzendő. Külön mérendő, hogy más közeli, korábban megölt fa timerje okozhat-e hamis
lezárást; a közvetlen játékos-ROI ezt várhatóan ritkává teszi.
