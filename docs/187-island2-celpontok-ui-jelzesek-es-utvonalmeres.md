# Island 2 célpontok, UI-jelzések és útvonalmérés

## Miért készült ez a fejezet?

A felhasználói prioritás egyértelmű: nem az Island 1 általános farmján kell
maradni, hanem az Island 2 nagy térképén jelzett ellenfeleket kell felkutatni,
és a jelzéssel ellátott UI-ikonokat rendszeresen ellenőrizni kell. A munkaciklus
kézi méréseket, felügyelt botfutásokat, forrásjavításokat és élő visszaellenőrzést
tartalmazott.

## UI-jelzések

- A bal felső boríték kétlépcsős: az első tap a HUD-ikont változtatja meg, a
  második nyitja meg a `MAILBOX` panelt.
- A Mailbox jelenlegi tartalma: `You have no Mails yet.` Nincs átvehető levél.
- A jobb oldali jelzett Shop egy tapra nyílik. A jelenlegi állapot
  `FREE IN 23h 53m`; nincs azonnal átvehető ingyenes jutalom.
- Az inventory korábbi kézi összehasonlítása szerint a megtartandó build
  `693 DPS`, `2.47K` körüli HP, Bat Cleaver 10 + Steel Splitter 14. A másik
  összeállítás csak `434 DPS`; automatikus gyengébb váltás tilos.
- A bot ezentúl célhiányos, teljes HP-s biztonságos pillanatban automatikusan
  ellenőrzi a Mailboxot és a Shopot. Nem vásárol, nem indít reklámot, az ismert
  X-szel bezár, majd 2572 döntéses (körülbelül harmincperces) hűtést alkalmaz.

## Nagy térkép és Island 2

A kibontott térképen két releváns koponya látszik:

- egy narancs koponya az Island 2 belső, északi részén;
- egy rózsaszín koponya ettől északnyugatra.

A lila jel nem Island 2-ellenfél, hanem a zöld Titan-oltár/portál. A
`014420-play/0` képen egyetlen lila jel felé adott északnyugati swipe azonnal
visszavitte a karaktert a zöld területre, miközben az Island 2 18,8K-s őre már
látható volt. Emiatt narancs biomon a lila jel teljesen némított, és a normál
piros térképvektor is megelőzi a lila jel navigációját.

## Bizonyított célok és eredmények

- `20260830-004826-play`: az 1,28K-s, 2-es szintű kaktusz elesett, közvetlen
  `+10` jutalom jelent meg.
- Ugyanez a futás járható Island 2-síkon 18,8K-s, 25-ös statikonú páncélost és
  27,7K-s páncélost is mutatott.
- `20260830-012335-play`: a havas felső csoport egyik 1,16K-s csíkja
  `1160→1100→1000` értékre csökkent. A szintkülönbség ellenére sebzés történt;
  helyben tartott automata harc külön vizsgálandó.
- `20260830-013227-play`: a bot az Island 2 4,4K-s DOC-őrét megtalálta. A
  `4.4K` OCR egy képen `4`-re csonkolódott; a minimum-HP most ugyanazt a
  kanonikus 4400-at használja, ezért nem keletkezik hamis `4400→4` siker.
- `20260830-015923-play`: a piros prioritásjavítás után a bot ismét közvetlenül
  megtalálta a 4,4K-s őrt. A DOC keleti–északi útján több kis helyi cél elesett,
  `+296`, `+130`, majd több `+10` jutalom látszott. A kijelzett saját maximum
  közben 2,47K-ról 2,48K-ra, majd 2,49K/2,51K/2,54K környékére nőtt; a pontos
  tartós maximumhoz a botállapot és következő tiszta OCR-képek egyeztetendők.

## Útvonalmérések

- A központi zöld útkereszteződéstől 15 tiszta nyugati swipe korábban közvetlenül
  `Dusty Gulch - 2` területre vitt.
- A zöld hajóroncsos/csonttáborból 20 nyugati swipe ismét bizonyítottan az
  Island 2 belső házzsebébe vitt (`015012-nudge`).
- A 18,8K-s házzsebnél a 14 dél + 10 nyugat + 16 észak útvonal teljes hurkot
  zár és ugyanoda tér vissza (`015140`–`015257`). Ez a vak út törölve.
- A DOC-őrnél a szekértől balra–északra–jobbra futó U-út ugyancsak ugyanahhoz a
  zárt kapuhoz tér vissza (`013227/74–105`).
- A szekértől délre, majd keletre futó próba a zöld oldalra visz; ez Island 2
  őrkerülőként tilos.
- A külső narancs síkról a keleti falvég, majd északi haladás valóban helyi kis
  ellenfelekhez és jutalmakhoz vezetett, de a további keleti átjáró zöld területre
  vitt. Az út szigetazonosító őrt igényel; nem tekinthető kész 4,4K-s bejáratnak.

## Botjavítások

- Új `nudge` mód: mérhető, irányonkénti swipe-sorozatok, saját kurzor- és
  fókusz-visszaállítással.
- A `Enemy weapon` világfelirat nem lehet célcsík.
- A kontrollált kísérleti plafon explicit tizedes-K feliratnál 30K, így a
  18,8K és 27,7K egyszer mérhető.
- A 4,4K OCR minimuma kanonikus; a csonkolt 4 nem sebzés.
- A piros belső/peremcél és a normál piros minimapvektor megelőzi a lila portált.
- Narancs biomon a lila portál teljesen tiltott.
- Az egyszeri kontrollált bosspróba legfeljebb két közeli fenyegetés mellett
  büntetésmentes halálig is folytatható, hogy tényleges sebzéscsere mérhető legyen.
- A vak 18,8K-s dél–nyugat–észak hurok törölve; stagnáláskor képi faljárás dönt.

## Következő kísérletek

1. Island 2-re visszatérés után a 4,4K-s őr keleti falvégét úgy kell bejárni,
   hogy a zöld határ felismerése azonnal visszafordítsa a karaktert.
2. A 18,8K-s őrnél teljes HP-ról tényleges kontaktust kell tartani, és külön
   naplózni a saját HP, az ellenfél HP és az automata ütési ciklus változását.
3. A rózsaszín második koponyát a narancs cél lezárása után külön küldetésállapot
   kapja; lila portál ezt nem írhatja felül.
4. A Mailbox/Shop automatikus megnyitás–felismerés–bezárás ciklust élő botfutásban
   ellenőrizni kell.

