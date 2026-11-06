# Kristálynyitások naplója és statisztikája

2026-11-04/05, natív app. Felhasználói kérés: minden kristálynyitásnál
rögzítsük, milyen kristály volt (szín, fajta) és hányas szintű, időponttal,
és legyen belőle statisztika. Kikötés: a gyűjtés a legfontosabb, éjszaka
felügyelet nélkül fut, a program csak minimális időre álljon le.

## Mit mutat az eredményképernyő (vizuális tény, 76 kép)

A CRYSTAL STATS eredménynél középen egy négyzetes csempe:

- **csempe háttérszíne = ritkaság**: szürke, zöld, kék, lila, narancs (egy
  régi képen). Az eladási ár ezzel nő (szürke 347–361, zöld 777–810,
  kék 1.4K, lila 2.37–2.43K);
- **a kristály színe**: kék, zöld vagy piros. Mind a 76 képen a statcsoportot
  követi: kék = védelem (Cut/Smash/Pierce Defense), zöld = élet (Health,
  Health Regen, Lifesteal), piros = sebzés (Cut/Smash/Pierce Damage);
- **szint**: a csempe jobb alsó sarkában (40 vagy 41);
- **stat**: a CRYSTAL STATS első sora, pl. „Cut Defense +148K”.

## Megoldás: külön, utólagos olvasás, nem a gyűjtési úton

- `CrystalResultReader` (RewardAutomationCore) a már elmentett `result`
  képből olvas. A geometria az ablakmagassággal skálázódik: csempe teteje
  0.352 H, oldala 0.1135 H, vízszintesen középen (623×863, 637×882,
  642×951, 788×1083 képeken mérve). Ritkaság a csempe kitöltésének
  színéből, a kristály színe a középső telített pixelekből, a szint és a
  statsor helyi Tesseracttal három különböző képelőkészítéssel. Érték csak
  akkor kerül be, ha legalább kettő egyezik. A statnév legfeljebb 2 betű
  OCR-hibát tűr az ismert 9 név közül, és csak akkor fogadjuk el, ha a
  kristály színével egyező csoportba esik.
- Az eladási árat nem rögzítjük: két előkészítés egyezően 2.97K-t olvasott
  egy ellenőrzött 2.37K helyett.
- `CrystalResultLog`: a kristálynaplóból (`events.jsonl`) kiválogatja az
  új kristályokat. Egy tranzakción belül a következő `result` képernyő csak
  akkor számít új kristálynak, ha közben ütés ment ki. Így az időtúllépés
  után újra látott eredmény (3184274F) egy kristály, a Continue utáni új
  geode (DC8756F5, C1F57DA9) pedig kettő. Kimenet: `crystal-rewards/results.jsonl`,
  soronként `crystal_result_read`: `openedAt`, `claimID`, `evidence`,
  `source` (app/cli), `reader`, `readAt`, `result` (rarity, gem, level,
  stat, amount, rawAmount, statLine). Flock + O_APPEND + fsync, ismételhető,
  a gyűjtőnaplót nem írja. Ha a kép már törlődött (24 órás megőrzés), és a
  kristály 10 percnél régebbi, akkor `evidenceMissing: true` és üres eredmény
  kerül be: a nyitás számít, a fajta ismeretlen.
- Az app egy háttérben (utility queue, 5 s késleltetéssel) frissít
  induláskor, minden `result` képernyő és `crystal_completed_ui` után. Hiba
  esetén csak az adott kristály marad olvasatlan; a gyűjtő kódja és
  ütemezése nem változott.
- Új „Kristályok” oldal: ritkaság- és színmegoszlás, szintek, statonként
  darab/összeg/átlag és ritkaság, valamint a nyitások listája időrendben.
  Ugyanazt az időszakszűrőt használja, mint a többi oldal.
- CLI: `ButcherHeroAutomation crystal-results [--root] [--out] [--source]`.
  Ezzel egyszer importáltuk a régi parancssoros gyűjtő 55 kristályát
  (`source: cli`) az app eredményfájljába.

## Ellenőrzés

- Mind a 76 mentett eredményképet vizuálisan összevetettük az olvasással:
  ritkaság, szín, szint és stat 76/76 helyes; összeg 65 esetben helyes,
  11 esetben üres (főleg „M”-es Health), hibás szám 0.
- Új tesztek (`CrystalResultTests`, a kötelező kapuban): 8 ellenőrzött kép,
  mind az 5 háttérszín, mind a 3 kristályszín és mind a 4 ablakméret; a
  tesztek az ismételt eredményképernyőt és az új ütést, az idempotens
  hozzáfűzést és a hiányzó képet is lefedik.
- Átlagosan kb. 1 s/kép háttérben (9 Tesseract-hívás).

## v2 — 2026-11-05: „#12.7K” és utólagos újraolvasás

A felhasználó jelezte: a 09:41-es Health Regen kristály összege „?” lett. A képen
„+12.7K”, de a három előkészítésből kettő „#12.7K”-t olvasott, és a parser
„+” jelet követelt. A javítás:

- Az előjel nem kötelező (OCR-ban „+”, „#”, „«” vagy „*”), a mértékegység viszont igen:
  minden kristálystat K/M/B/T-vel jelenik meg. Így a „Health +1.574” (rosszul
  olvasott 1.57M) továbbra is elutasított. Számhoz tapadó betű vagy számjegy
  (2S1K, G26K) sem lehet összeg. A statnév az első számjegyig vagy előjelig tart.
- A 77 kép (76 korábban ellenőrzött + az új) mind olvasott, 0 hibás érték;
  3 új összeg (20.2K, 12.5K, 12.7K), 9 marad üres (főleg „M”-es Health).
- `crystal-result-v2`. Egy újabb olvasó a hiányos bejegyzéseket egyszer
  újraolvassa (ha a kép még megvan), és új sort fűz hozzá. Betöltéskor
  ugyanarra a képre a legutolsó sor érvényes, a korábban kiolvasott mezők
  nem vesznek el. Ez a 353-as állandó szabály kristályokra alkalmazott
  változata.

## v3 — 2026-11-06: az „M” egység alakból

A felhasználó kérte, hogy az „M”-es (millió) összegek is olvashatók legyenek.
Ebben a fontban az M úgy néz ki, mint egy H, ezért a Tesseract h-nak, 4-nek,
8-nak vagy idézőjelnek olvassa. Egy karakterkészlet-korlátozással (whitelist)
végzett újraolvasást kipróbáltunk, de rontott: 8/4 lett belőle, és a számjegyek
is sérültek (153K→133K). Elvetettük.

A megoldás az egység alakja. A statsor utolsó glyphjének jobb negyede a
középső sorokban: az M-nél teljes magasságú jobb szár (lefedettség 1,00), a
K-nál csak a két kar, középen üres (0,00), mind a 77 képen 200-as
fényességküszöbnél. A számjegyeket továbbra is az OCR adja 2/3 szavazással. Ha az
OCR kiír egységet, annak egyeznie kell az alakkal. Ha nem ír ki: tizedespontos
számnál a negyedik számjegy (a játék legfeljebb hármat ír) vagy egyetlen
odatapadt betű maga a félreolvasott egység. Tizedespont nélkül nem találgatunk.

Eredmény 77 képen: 74 helyes összeg, 0 hibás, 3 üres (a 291K, ahol az OCR a
9-et S-nek olvassa). `crystal-result-v3`, a hiányos bejegyzések egyszer
újraolvasódnak. Új tesztek: alakalapú egységolvasás 4 képen, 1.57M fixture,
egységgel paraméterezett parser-esetek.
