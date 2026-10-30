# Magaslati egyszeri ág és visszatérési zár

## Biztos játékszabály

A különleges magaslati ládahely egyszeri hozamú. A láda begyűjtése után ugyanoda
pusztán a régi térképjel miatt visszatérni időveszteség. Ettől a magaslati hálózat
nem kerül végleg tiltólistára: később új láda, új küldetés, új ellenfél vagy eddig
ismeretlen járható ág bizonyítéka indokolhat célzott visszatérést.

A terület külön magassági rétegen van. A képen közelinek tűnő palló, őr vagy
tereptárgy nem bizonyít közvetlen járhatóságot; az alsó és felső szint között csak
meghatározott rámpákon és átjárókon lehet váltani.

## Élő bizonyíték

- A `201120-play` narancssziklás szakaszáról a hosszú délkeleti
  `(0,79; 0,61)` kiszakadás ténylegesen visszavitte a karaktert a zöld területre.
- A `201915-play` több, egymástól erősen eltérő swipe-ja a ház–sziklafal zsebben
  kameramozgást adott, de a karakter ugyanazon a magaslati rétegen maradt. A
  mozgó háttér tehát önmagában nem kijáratbizonyíték.
- A `202055-play` automatikus gear-koppintása nem nyitotta meg a Settings panelt.
  Ugyanaz a pont friss képernyőállapot után közvetlen kattintással működött; ez
  ablakaktiválási versenyhelyzetet valószínűsít, nem hibás képi koordinátát.
- A kézzel elindított Unstuck 0 HP-s átmenet után ismét a zöld medencéhez tette a
  karaktert, és a `202322-play` első képe már teljes 1940 HP-t mutatott.
- A `202322-play` 0–64. döntéseiben a piros, északnyugati minimapjel kevesebb mint
  másfél perc alatt visszahúzta a botot ugyanabba a magaslati házzsebbe. A
  65–81. döntés hosszú délkeleti kiszakadása ismét visszaért a zöld mezőre.

## Megvalósított stratégia

1. A 18,8K-s jelzéshez tartozó magaslati útvonal kimerítése külön tartós
   `elevatedBossRouteBand` és abszolút lejárat állapotot kap.
2. A magaslati útvonal utolsó szakasza nem fordul vissza a felső réteghez, hanem
   húsz délkeleti lépéssel a bizonyított zöld kijáratot tartja.
3. A lezárás után a 18,8K-s sáv fél órán át nem indíthat új kontrollált próbát.
   Ez nem harci vereség: helyszínhozam- és útvonalhűtés.
4. Zöld terepen ugyanezen hűtés alatt az északnyugati piros minimapirányt a bot
   nem követi, mert az élőben az egyszeri magaslati ágra vitte vissza. Közvetlenül
   látható, biztonságos farmcél továbbra is elsőbbséget kap.
5. Ha a karakter mégis cél nélkül, teljes HP-val a narancssziklás felső rétegen
   marad, a bot az Unstuckot az ág determinisztikus lezárásaként kezeli, nem vár
   további álmozgásos statikus fázisokra.
6. A ritka globális koppintások az ablak aktiválása után további 160 ms türelmi
   időt kapnak; ez a folyamatos swipe-ok sebességét nem csökkenti.

## Szemantikus térkép

A kifosztott ág zöld határáról származó második, 33 elemű képaláírás bekerült a
`semantic-map.json` fájlba. A helyi irányjelölés nem évül ki a 400 csomópontos
geometriai térképpel együtt. A hűtés a jelenlegi futásban gyors védőkorlát, a
szemantikus ládamemória pedig a hosszú távú tudás.

## Nyitott ellenőrzések

- A zöld mezőn elnémított északnyugati piros jel mellett talál-e a bot új farmcélt
  vagy új területet anélkül, hogy a magaslati zsebbe visszafordulna.
- A hosszabb aktiválási türelmi idővel az automatikus Settings-koppintás biztosan
  megnyitja-e a panelt a következő valódi Unstuck-helyzetben.
- Mely magaslati pontok egyszeri ládák, és mely `5hxxm` körök ismételhető
  ellenfél-/erőforrás-időzítők; a két állapotot csak jutalomátmenet igazolhatja.

## 21:33–21:43 élő pontosítás

- A `213307-play` nem egyszerű zöldről visszatérési hurok volt: a futás már a
  város fölötti, egyszeri ládaplatón indult. A 49., 68., 109. és 123. kép végig
  ugyanazt a külön felső réteget mutatta; a 4,4K-s DOC-őr alul látszott.
- A bot a 123. döntésben önállóan felismerte a kimerített statikus réteget és
  megnyitotta a Settings panelt. A munkamenet megszakítása után ugyanennek a már
  nyitott panelnek az Unstuck gombja a zöld medencéhez teleportált; 690 HP-ról
  a karakter ismét 1940-ig gyógyult.
- A `214244-play` első élő képei már normál zöld járószintet mutatnak. Ezért ott
  nem kellett újabb Unstuck; az ismételt teleport csak elvesztegette volna a
  játékoldali időzárat.
- A korábbi 30 perces, `18,8K` HP-s útvonalhűtés tévesen összekapcsolta a boss
  erősségét az egyszeri láda szemantikájával. Most külön tartós
  `exhaustedOneShotHighlandBranch` állapot rögzíti a kifosztott platót.
- A gyors platóazonosítás legalább 75% narancssziklát és középen látható órás
  időzítőt kér, továbbá egy friss `OPEN` vagy biztos magaslati lezárás által
  beállított kijutási szándékot. A kifosztottság önmagában nem elég: a
  `214244-play` alsó útja is 87% narancsszínt és több órás kört mutatott.
- Az automatikus UI-koppintás a `205232-play` későbbi szakaszában már teljes
  Settings→Unstuck→zöld medence láncot hajtott végre. A 160 ms aktiválási türelem
  segít, de a panel képi visszaellenőrzése továbbra is kötelező.
- A `214244-play` 80. képén a régi „minden narancsszikla három fázis” szabály
  tévesen Settingset nyitott az alsó úton; az Unstuckon `02:43` időzár volt. A
  program bezárta a panelt, és nem teleportált. Ez bizonyítja, hogy az alsó és
  felső réteget nem lehet pusztán narancsszínnel és órás körökkel szétválasztani.
- A javított állapot két külön bitet vezet: a tartós kifosztottság megakadályozza
  a hozamcélként való visszatérést, a rövid életű `pendingOneShotHighlandExit`
  pedig csak biztos OPEN/lezárás után jogosít gyors Unstuckra. Sikertelen,
  időzáras és sikeres Unstuck egyaránt törli a függő kijutási szándékot.

## 22:08–22:16 ismételt feljutás és pontosabb rétegjel

- A `220802-play` 237–256. képe újra a már kifosztott magaslati réteget mutatta.
  A narancsszikla-fedettség 77–94% között mozgott, cél nem volt, de az általános
  útkeresés a kameramozgás miatt tovább próbálkozott.
- A 256. képen a karakterhez közeli `3h44m` kör a célzott
  `nearbyRespawnTimer` jellel felismerhetővé vált. Ez a jel a `214244-play`
  normál alsó narancs útján végig hamis volt.
- A kézzel végrehajtott Settings→Unstuck ismét a zöld Meadowlands medencéhez
  vitt, teljes 1940 HP-val.
- A gyors kijutás ezért friss OPEN nélkül is engedélyezett, ha a magaslati ág már
  tartósan kifosztott, legalább 75% narancsszikla látszik és a közeli hosszú
  visszatöltési kör detektálható. Az elszórt középső timer-OCR önmagában továbbra
  sem elég, így az alsó út ellenpéldája védett marad.
