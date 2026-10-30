# Átfedő közelharci HP-csík — 2026-09-19

## Megfigyelés és diagnózis

Friss193600-d4e90045-observe/0: saját7060, Bat13/Venom18, szélmalomtólN/NE,
az északi sziklafal déli oldalán. Nincs közeli cél. A265-ben legyőzött
fa-gólem többórás hűtése miatt ugyanezt a harcot most nem ismételjük.

192612-5b181452-play/0 régi harci képen a valós piros csík325..337×402..410,
103 piros képpont; fölötte részben a saját zöld HP-csík. A régi piroscsík-
ellenőrzés két párhuzamos fekete keretet követelt, de a felsőt a zöld csík
takarta. Emiatt `redBars=[]`, `visibleTargets=[]`, és V2frontier indult.
Második hiba: a cél származtatott középpontja csak20,49px-re van a játékostól,
amit az általános45px alsó távolsághatár külön is kizárt volna.

## Szűk javítás

Az `isOverlappingContactBar` csak sajátHUD-közeli,8..24px széles,
4..10px magas,legalább45piros pixeles csíkra enged kivételt. Kell legalább
28px hosszú alsó keret85%fekete ponttal, és fölötte egy sorban legalább
10élénkzöld pixel. Kizárólag ugyanennek a mintának enged45px-nél közelebbi célt.
Nem általános pirosszín- vagy harcierő-kapulazítás.

193829-f4e1cf97-replay/0 eredmény: a2740HPellenfél,20,49px távolság,
0,393fekete keretbizonyosság és0,068szívjel felismerve;nearbyThreatCount=1.
A normál élőV2ág kizáró feltétele emiatt már tiltja az általános felderítést.
A replay maga csak a stratégiát futtatja, nem az élőV2végső kapuját: ezért
az ott kiírt régi Island2swipe nem végrehajtott mozdulat vagy élő navigációs siker.

Ez felismerés és célfolytonossági védelem, **nem teljes autonóm sérültgólem-
harcigazolás**. A500jutalomszám ezen az átfedő képen még nem olvasható a
célhoz rendelt mezőből, ezért az eredetiKnownHeartGuardianpróbakezdés külön
nem aktiválódik. Nem oldjuk fel találomra minden2740HPellenfél támadását.

## Ellenőrzés

- ReleasebuildPASS.
- Új `overlapping-contact-regression.sh`:2740HP/30pxkontaktusPASS;
  friss7060normál képen nincs hamis közeli veszély.
- Piroscsizma negatív és sérültDOCcsík pozitív regresszióPASS.
- Ismert4310/500gólem próba, quickfarm, passzív923fa, kis1220őr és
  automatikusDOCpróba tiltása: mindPASS.
- Élő új harci kontaktus ezen ciklusban még nem történt; a gólem kimerült.

## Következő stratégia

A keleti500gólem helyett a nyugati út/Island2következő élő céljaihoz indulunk,
friss képpel a nyílt fűsávon. A bot nem kap vak, teljes szigetmakrót.
Mindkét nagy boss korábbiHPheurisztikája teljesül7060maximumon; a konkrét
ellenfél helyének azonosítása és külön próbahipotézis továbbra szükséges.

## Élő visszaút — 19:40–19:44

Minden szakasz után külön frissobservekép, mindegyik3×0,40s:
194048W→194053út/sín;194117W→194122NPCkeleti oldala;
194148SW→194152NPCdéli oldala;194220W→194224kéksátor keleti oldala.
Innen **nem továbbW a sátorba**, hanem194308SE→194313nyíltfű,
194348SW→194353sátor délkeleti sarka. Az1,22Kőr balra/délre látható,
nyílt kontaktusoldalról; saját képen7,06K,OCRkerekített7000.
Következő25s normál próba a már engedélyezett kisőrrel; nem új nagybosspróba.
Ez felügyelői képi visszaút, nem a teljes út autonóm navigációs igazolása.

## Élő eredmény és következő navigációs hiba — 19:44

194412-8d483e48-play/1–3 önálló1220őrkontaktus,4 **Savage Fang21,
Damage160→168,20m0s**.7,06KsajátHP, Bat13/Venom18marad felszerelve;
Fangtartalék. Következő várhatókb.20:04:20, friss képpel ellenőrizendő.
A4-es képen a jutalom lezárja a harci visszakeresést: ez élő regressziós siker.
Az átfedőgólem-újratesztet ez nem helyettesíti.

5–14 a cél nélküli frontier visszavitt a sátor keleti falához.14: saját7,06K,
NPCészakkeletre, üres/kimerült farmkörök; nincs ok változatlanul folytatni.
Képi térképrész **chart62**, pozíció84,27/−156,38; aV2 ugyanakkor még
**orange-skull**,64,10/−2,92,109akadályél. A nyugati élő és keleti korábban
élő fej azonos sablonja miatt ez a koordinátatér nem általánosan megbízható.
Következő: a már képi visszaazonosítással igazolt terrainchart legyen elsődleges
akkor is, ha van narancsikontalálat; tesztelni kell két azonos ikon és chartváltás
esetén. A jelenlegi szabály csak ikonhiánynál/vagy márterrainmódban választja azt.
Ez diagnózis/javítási terv, ebben a ciklusban még nem implementáltuk.
Nyugati bossmegközelítés még nem sikerült; ne nevezzük ezt Island2-átjutásnak.
