# A 499 HP-s hordozó 8–3–8 útjának élő cáfolata és az őrfolyosó

## Élő kísérlet — `20260829-104751-play`

A friss 8–3–8-as hordozóút először fizikailag is végigfutott. A 230–251. esemény
között a bot újra megtalálta a zöld fegyverkártyával igazolt `499 HP`-s hordozót,
`360→204` pixelre közelített, majd a vízszintes kerítésnél stagnált.

A rögzített út szakaszai:

- `frame-00252`: a játékos a vízszintes kerítés alatt, a hordozó fölötte; indul az
  első bal swipe;
- `frame-00263`: a nyolcadik bal swipe után a játékos a délnyugati
  útkereszteződésnél, a sátor kerítésének külső sarkánál áll;
- `frame-00265`, `00267`, `00269`: három felfelé swipe valódi északi
  kameramozgást ad a nyugati palánk külső oldalán;
- `frame-00271→00281`: a nyolc jobbra swipe alatt a karakter a függőleges
  palánknak nyomódik; a sátor, a palánkoszlop és a karakter egymáshoz képest
  változatlan marad;
- `frame-00283`: a statikus háttérőr helyesen felismeri a sikertelen visszatérést.

Ez élőben **megcáfolja** a 8–3–8-as munkahipotézist. A nyolclépéses bal szakasz jó,
de három északi lépés nem éri el a hosszú nyugati palánk felső végét. A jobbra láb
nem vitt be a táborba, így a Bat Cleaver számláló `9`, a Damage pedig `450` maradt.

## Pontosított pályageometria

A korábbi két futás együtt már elég a szűk folyosó leírásához:

1. a jobb oldali torony–hordó zseb tizenkét swipe-on át teljesen zárt;
2. a bal oldal nyolc swipe-pal eléri a délnyugati sarkot;
3. a saroktól északra hosszú, függőleges palánk fut;
4. a palánk nyugati oldalán, nagyjából a negyedik északi lépés környékén egy
   `1.22K HP`-s őr jelenik meg;
5. a hordozóhoz ezért csak a palánk felső vége felől, keletre visszafordulva lehet
   eljutni, miközben az őrtől jobbra kell távolodni.

## Új, kontrollált munkahipotézis

A következő hordozóút:

1. nyolc swipe balra a délnyugati sarokig;
2. legfeljebb nyolc swipe felfelé a nyugati palánk mentén;
3. ha a pontos `900...1500 HP` közötti nyugati őr `250...360` pixelen jelenik meg,
   a játékos legalább 90%-os HP-n van és nincs friss sebzés, az északi vektor
   jobbra-felfelé ferdül, vagyis egyszerre keresi a palánk végét és távolodik az
   őrtől;
4. ezután nyolc jobbra swipe tér vissza a tábor felé;
5. 250 pixel alatti őr, friss sebzés, 90% alatti HP, `1500+ HP` vagy más boss az
   általános menekülést indítja, és törli a próbát.

Ez nem általános bossfigyelmen kívül hagyás. Egyetlen, képekkel azonosított
őrfolyosóhoz tartozó, teljes HP-s és távoli áthaladási kísérlet. A halál továbbra
sem okoz felszerelés- vagy maximumvesztést, de a döntő elsődlegesen a sebzés előtti
jobbra-felfelé eltávolodást próbálja.

## Regresszió és ellenőrizendő állítások

A `20260829-105627-replay` a mentett 104751-es képsoron az új binárissal igazolta a
rögzített állapotgépet: nyolc bal, nyolc északi, nyolc jobbra döntés következik,
majd csak ezután kap újra vezérlést a normál navigáció. A képsorban az 1.22K-s őr
nem a megfelelő útvonalállapotban látszott, ezért a jobbra-felfelé élő ág még
**munkahipotézis**.

A célzott `20260829-110020-replay` feltárta, hogy a képen látható `1.22K` feliratot
az OCR belsőleg `122000`-ként tárolja (`ocrStrings: ["1:22K:"]`). Az első
`900...1500` numerikus kapu ezért nem ismerte fel a helyi őrt, és a normál
bossmenekülés futott. A javított azonosító csak aktív hordozóút közben fogadja el a
`120000...125000` belső értéket, ha legalább `0,04` fejszeikon-bizonyíték is van;
ez nem tesz más 122K-s ellenfelet általánosan átjárhatóvá.

A `20260829-110146-replay` azonos célzott sorozatán az új aláírás már öt képen
helyesen a `(0,86; -0,51)` jobbra-felfelé folyosófutást választotta. Az ötödik
képnél elfogyott az északi szakasz, és a mesterségesen változatlanul ismételt
őrképen a tiszta jobbra visszatérés első lépését a normál bossőr megszakította.
Ezért ugyanaz a szűk kapu a legfeljebb nyolc, közvetlenül az őrtől keletre távolodó
visszatérő lépésre is érvényes. Az út lejárta, közeledő őr, friss sebzés vagy HP-esés
azonnal megszünteti a kivételt.

A `20260829-110325-replay` már a teljes javított prioritást igazolta ugyanazon,
szándékosan változatlan őrképpel:

- 19–23: öt jobbra-felfelé swipe;
- 24–31: nyolc tisztán jobbra, tábor felé tartó swipe;
- 32: a rögzített út lejárta után az őr továbbra is látszott, ezért ismét az
  általános bossmenekülés futott.

A külön `20260829-110340-replay` az aktív hordozóút közepére a korábbi
`frame-00642` 1.92K/7.15K-s Deep Mines őrképét illesztette. A szűk helyi aláírás
nem nyílt ki: rögtön a „Többezer HP-s boss túl közel van” menekülés indult. Így a
helyi 1.22K-s kivétel és az erősebb bossok biztonsági regressziója egyaránt igazolt;
csak a fizikai pályán való élő áthaladás maradt nyitott.

A következő élő találkozásnál mérendő:

- hány északi/átlós swipe után tűnik el a függőleges palánk a jobb útból;
- az 1.22K-s őr távolsága nő-e a jobbra-felfelé futás alatt;
- újra megjelenik-e a 499-es hordozó a visszatérő lábon;
- a hordozó legyőzése után megtörténik-e a Bat Cleaver `9→10` és Damage
  `450→500` változása.

## Utólagos helyesbítés

A futás teljes, 861–877. eseményének későbbi auditja szerint a hordozó ugyanebben a
folyamatban mégis 59 pixelre került, majd elesett. A jutalom közvetlenül `9→10` és
`Damage 450→500` lett. Ez a fenti utolsó mérési kérdést megválaszolja, de nem teszi
sikeressé a korábban elakadt 8–3–8 részutat: a tényleges ölés csak későbbi általános
navigáció után történt. Részletek: `132-tizedik-bat-cleaver-es-500-sebzes.md`.
