# Elvetett erőfüggő 151–250 HP-s próbacél

> **Történeti, elvetett kísérlet.** Az első élő próba bizonyította, hogy a 192-nek
> látszó cél valójában 1,927K-s elit volt. A lazítás kikerült a kódból; részletes
> ellenbizonyíték: `87-jobb-kepszeli-192-bol-1-927k-es-probacel-visszavonas.md`.

## A régi korlát elavulása

A humanoid célkapu történetileg minden ismeretlen szintű, 150 HP fölötti célpontot
kizárt, mert az `1.22K` elit OCR-je korábban `221` vagy akár `7` értékre csonkolódott.
Ez helyes volt 400 körüli játékos-HP és jóval kisebb sebzés mellett, de 747 maximális
HP-n és 442-es mért fejszeértéknél túl sok valódi, együtéses fejlődési célt hagy ki.

A `20260829-050324-play/frame-00022→00114` ismételten ugyanazt az izolált humanoidot
mutatta:

- fekete keretes, 57 pixeles célcsík;
- stabil, tiszta `192` HP OCR;
- nincs K-jel, bossbizonyíték vagy statikonból származó 100+ veszélyjel;
- nincs 150 pixelen belüli társa;
- a játékos friss OCR-rel végig 747/747 HP-n állt;
- a cél 176–228 pixeles távolságon többször elérhető oldalon látszott.

A régi kapu ezt mégsem választotta, ezért a bot hosszú fal- és minimapkerülésbe ment
ahelyett, hogy kipróbálta volna az együtéses ellenfelet.

## Új, skálázott próbaág

Ismeretlen szintű, 151–250 HP-s humanoid csak akkor lehet biztonságos próbacél, ha:

- a tartósan megtanult maximum legalább 700;
- a játékos aktuális HP-ja legalább 98%;
- a cél izolált (`companions == 0`);
- nincs nyers 800+ HP, K-rövidítés vagy más bossbizonyíték;
- a korábbi képszéli, zárfal- és részleges testőrök mind átengedik.

A már meglévő döntő ezután is 95% alatti friss sebzésnél visszavonul, a bossőr pedig
minden próbacél fölött fut. A szabály tehát nem tesz általánosan biztonságossá közepes
humanoidokat; a jelenlegi erőszinthez kötött, kontrollált feltárási ablakot nyit.

## Regresszió és élő állapot

- `050324/frame-00022`: a javított replay 219 pixelen a 192 HP-s cél felé indul;
- `050324/frame-00068`: 176 pixelen ismét ugyanazt a célt közelíti;
- `011302/frame-00002`: a történeti csonkolt 1.22K elit továbbra sem biztonságos;
- `033954/frame-00002`: a másik történeti veszélyes kép szintén cél nélkül marad.

A build sikeresen elkészült, a folyamatos élő ellenőrzés `20260829-050827-play`
néven indult. A 192 HP-s cél első tényleges harca, sebzése és jutalma még mérendő.

## Élő cáfolat és visszavonás

A cél 160 pixelig közeledett, majd a `050827/frame-00058` képen 1927 HP-ra állt
helyre és bossbizonyítékot adott. A bot sérülés nélkül menekült. A 151–250-es ág így
nem valódi közepes célra, hanem egy újabb K-csonkolási hibára nyitott utat. A kód
visszaállt a 150-es ismeretlenszint-kapura; az itt leírt szabály nem aktuális taktika.
