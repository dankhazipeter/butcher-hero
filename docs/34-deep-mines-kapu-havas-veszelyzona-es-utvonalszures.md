# Deep Mines-kapu, havas veszélyzóna és útvonalszűrés

## Biztos képi megfigyelések

- A türkiz sín a zöld területről egy fehér–türkiz, lila köves kapuhoz vezet, majd a
  havas területen folytatódik.
- A kapu közepének ismételt északi swipe nem viszi át a karaktert. A jobb és bal oldalon
  szikla, illetve kapuoszlop látszik; oldalirányú kerülés szükséges.
- A történeti tízlépéses jobb oldali kerülővel a karakter ténylegesen bejutott a havas
  oldalra, de a későbbi bányatetős anomália miatt ezt a hosszúságot elvetettük.
- A havas oldalon több `1.92K` és legalább egy `7.15K` HP-s ellenfél látszott. A bot
  400-ról 51 HP-ig sérült, majd a bossőrrel kijutott és regenerálódott.
- A kapuhoz visszatérve a sín továbbra is észak felé mutatott. A minimap lila ikonja
  külön portál/oltár is lehet; nem tekintjük bizonyított Deep Mines-bejáratnak.

## Felismerési regresszió és javítás

A korábbi egyszerű türkiz-pixelszámláló a lila szikla türkiz peremét, a hidat és a
20-as szívfa környezetét is útvonalnak hitte. A regressziót a
`20260829-002956-play/frame-00066.png` és a `000913-play/frame-00020.png` bizonyítja.

Az új szabály csak olyan türkiz komponenst enged át, amely:

- legalább 100 képpont kiterjedésű és legalább 80 színilleszkedő pixelt tartalmaz;
- a befoglaló téglalapjával 175 képponton belül ér a játékoshoz;
- legalább 24 mintát és 0,24-es iránykoncentrációt ad.

Replay-eredmény:

- valódi sín (`003743-play/frame-00086`): felismerve, északi vektor;
- lila szikladísz (`002956-play/frame-00066`): elutasítva;
- húszas szívfa/híd (`000913-play/frame-00020`): elutasítva.

## Akadálykezelés

Hat statikus navigációs swipe után a bot nem vak égtájat, hanem a kívánt irányra
merőleges falmenti irányt választ. Legfeljebb tíz swipe futhat, de minden képen előbb
érvényesül a HP-/bossőr, és 180 px-es biztonságos cél megszakítja. A következő elakadás
az ellenkező oldalt próbálja; 800+ HP-s/boss cél 360 px-en belül mindig megelőzi.

## Bizonyosság

- **Biztos:** a sín kapuhoz/havas zónába vezet, a közép zárt, jobb oldali kerüléssel
  be lehet jutni, és a havas ellenfelek jelenleg rendkívül veszélyesek.
- **Nyitott:** a főzet pontos helye, felvételi módja és az, hogy a veszélyzónán át lehet-e
  harc nélkül, tartósan a sínt követni.
