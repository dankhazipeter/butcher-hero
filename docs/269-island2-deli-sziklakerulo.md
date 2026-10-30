# Island 2: a házzsebtől a DOC nyugati oldaláig — 2026-09-19

## Kérdés és biztos kiindulás

A felhasználó a narancssárga fejekkel jelzett gólemek legyőzését kérte.
A keleti 4,31K-s cél győzelme és +500 szíve már igazolt (265); a nyugati
18,8K-s célhoz most járható megközelítést keresünk. Saját maximum7060,
Bat13/Venom18, utolsó statpanel1,49KDPS/73,5regen. Új nagy bosspróba még nincs.

## Felügyelt bejárás, nem autonóm siker

202501-6c3e2d1b-observe/0: barna ház és nyugati szikla közötti zseb.
Azonos a202055-play/12 végponttal:104képi egyezőpont,0elmozdulás,
0,077maradékhiba. A chart62 kiinduló világpozíció−1122,551/−90,253.

- 202536:3×0,40sS →202540/0, a házzseb elhagyva, balra18,8K-s test/HP.
- 202636:3×0,40sS →202640/0, vízszintes természetes kőív északi oldala.
- 202709:3×0,40sSE →202713/0, a karaktert a kőív takarja.
- 203133:3×0,40sS →203137/0, az ív ALATT átjutottunk a déli folyosóba.
- 203155,203224,203247:három külön3×0,40sSW; képenként ellenőrzött
  délnyugati út,203251/0a nagy sziklatömb déli oldala.
- 203319,203346,203408:három külön3×0,40sW,203412/0szabad délnyugati udvar.
  203323/0a DOC4,4K-s őre látható, de még a fal túlsó oldalán.
- 203458:3×0,40sNW,203503/0a szélmalom nyugati oldala.
- 203532:3×0,40sN,203536/0a malomszikla mellett; északra rövid kerítés,
  annak nyugati végét külön kell kerülni. Nem indul közvetlenNEikonhajsza.

Minden felsorolt input után tényleges frissPNG készült. Az observe által
kiírt SWIPE csak javaslat, nem végrehajtott művelet. Új ölés/jutalom eddig nincs.
Az időnként7,0K-ra kerekített HUD nem bizonyított sérülés: a csík tele,
következőképen7,06K, ezért ebből nem tanulunk vereséget.

## Képi útmérés

A teljes köztes nudgePNG-lánc 202501→203412 optikai mérése érvényes;
nem csak a távoli végpontokat hasonlítottuk össze. Relatív (x,y) képpixel:
202640:(−3,805;358,562),202713:(144,811;478,141),
203137:(146,692;668,047),203251:(−328,490;1089,816),
203412:(−968,168;1088,964). Mozgási mérés, nem swipe-időből becsült út.
Ez irányított, ténylegesen bejárt kerülő; visszafelé és autonóm bejárása
még nem igazolt. A gólem magaslati elérését önmagában nem bizonyítja.

## Következő döntés

A nyugati rövid kerítést megkerülve északra, majd friss képből a DOC északi
bejárata / gólem járható útja. DOC már bizonyítottan legyőzhető, értékes
mellékcél; a18,8K-hoz külön azonosított kontaktus és kontrollált próba kell.
Ne forduljunk vissza a keleti házzsebbe vagy Island1-re új cél nélkül.

## A 18,8K-s cél valódi megközelítése — 20:39

203600:2W;203658:3NNW;203721:3N (minden0,40s): a rövid kerítés
nyugati végét megkerültük.203725/0nyílt északi udvar, szekér/hordó északon.
203747:3ENE;203814:3E;203839:3ENE (0,40s),203910:2ENE (0,35s).
**203913/0a18,8K-s,25zöldszíves láncos gólem teljes testtel látható**,
saját7,06K, nyugatról nyílt talajon közelítünk; délről háztető/szikla szűkít.
A DOC-ot egyelőre nem támadtuk, az elsődleges gólemcélhoz jutottunk.

Döntés: egyetlen rövid, külön `--kite-boss` kísérlet. Előző5840→7060HP
(+20,9%),1,30K→1,49KDPS(+14,6%); korábbi vezérlési hibák javítva232-ben.
Friss kiting-unit: kezdőHP, korai kitérés, bossHP-reset, halál/ismétlés tiltása
PASS. Hipotézis: rövid kontaktus után nyugati nyílt térben regenerálódva
folytatható-e a sebzés? Ez még nem győzelem és nem általános bossengedély.
