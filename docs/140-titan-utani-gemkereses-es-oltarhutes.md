# Titan utáni gemkeresés és oltárhűtés

## Élő visszaigazolás

A `20260829-123510-play` új folyamatként ismét megközelítette a lila minimapikont.
A 48. esemény teljesen felismerte a `Collect all gems to unleash the Titan's power`
feliratot és a `0/7` számlálót. Ezután a bot már nem követte vissza a pulzáló lila
ikont: a 109. eseményen az oltár iránya a karakter mögött, jobbra-lefelé volt, a bot
pedig balra haladt tovább szabad területet felderíteni.

Ez bizonyítja, hogy a felismerés nem csak mentett képen működik. Egy frissen indított
élő folyamat is eléri az oltárt, megjegyzi az aktuális Titan-feladatot, kijut a környező
kőgyűrűből, majd gemkereső módra vált.

## Döntési oltárhűtés

Az oltár elérésekor 600 tényleges döntéses hűtés indul. Ez alatt:

- a lila Titan-ikont a bot nem tekinti új úticélnak, akkor sem, ha az animáció miatt
  ismét felvillan;
- a `0/7` feladatbuborék újbóli megjelenése meghosszabbítja/megerősíti a hűtést;
- ellenfél, jutalom, küldetés és veszély továbbra is azonnal felülírhatja a puszta
  felderítő mozgást;
- a hűtés csak a döntési állapotban él, ezért folyamat-újraindítás után az oltár egyszer
  ismét felkereshető. Ennek tartós állapotba emelése nyitott fejlesztési feladat.

## Lezárt piros irány elnyomása

A Titan után a minimap erős balra mutató piros célja ugyanarra a `UNLOCKS AT ISLAND 4`
határra vezetett, amely korábban sok útvonalhurkot okozott. Amíg a 0/7-es oltárhűtés
aktív, ezt az irányt nem érdemes újra követni: nem gemhez, hanem bizonyított zárfalhoz
visz.

Ilyenkor a bot növekvő négyzetspirál-felderítést használ. Az eseménynapló ezt külön
indokkal jelzi: `Titan 0/7 gemkeresés: a lezárt bal piros irány helyett növekvő szabad
felderítés`. A `123455-replay` minden oltár utáni mentett képen ezt az ágat választotta,
az élő `123510-play` 109. eseménye pedig a fizikai mozgást is igazolta.

## Kameranézet és narancsszikla-memória

A zöld és narancssziklás tereprész közötti keskeny átmenetnél a kamera egy-egy swipe
hatására felváltva mutathatja vagy takarhatja a narancs biome-jegyet. Ez nem valódi
területváltás. A bot ezért tizenkét döntésig megőrzi a friss narancsszikla-bizonyítékot,
így a zárfal melletti kifelé tartó irány nem oszcillál a kamera minden rezdülésére.

## Következő mérés

A következő biztos Titan-adat egy gem megszerzésének képsora lesz: cél típusa, az
`0/7→1/7` változás időpontja, az esetleges külön jutalomképernyő, valamint az, hogy a
számláló halál vagy Unstuck után megmarad-e. Addig a gemforrás ismeretlen, ezért a bot
ellenséget, világobjektumot és új landmarkot egyaránt vizsgál.

A későbbi `124335-play` alapján a teljes Titan-feladatmondat számláló-OCR nélkül is
elindítja ugyanezt a hűtést; a mozgó `0/7` hiánya nem állíthatja le a gemkeresést.

A `125042-play` alapján a hűtés alatt látható lila ikont aktív kijárati vektorként
használjuk: a bot az ellenirányába halad, amíg az oltár eltűnik a minimapról. Így a
szabad spirál nem kanyarodik vissza ugyanahhoz a 0/7 buborékhoz.

Pontosítás a `125610-play` alapján: a jel nem feltétlenül tűnik el, ezért az aktív
kijárat 28 végrehajtott swipe után lezárul. Az oltárhűtés ettől még megmarad.
