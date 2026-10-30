# Bossba vezető minimapirány hűtése

## Ismétlődő hurok

A `011133-play`, `011302-play` és `011525-play` futásokban a 360 px-es bossőr és a
hatsöpréses távolodási memória sérülés nélkül működött. A memória után azonban a
legközelebbi piros minimappont ismét ugyanabba a falrészbe vezetett, majd egy statikus
faljárás újra 1.22K körüli páncélost tett láthatóvá. A bot biztonságban maradt, de nem
jutott vissza a gyors, +4-es bányatábori farmhoz.

## Meglévő mechanizmus új felhasználása

A programban már volt 120 döntéses `blockedRouteCooldown` a bizonyítottan lezárt
kerítésekhez. Bossészleléskor most:

1. elindul az aktuálissal együtt hat swipe-os biztos távolodás;
2. a legutóbbi minimapirány kerül a lezárt vektorba (ha nincs, a boss felé mutató
   geometriai vektor);
3. a kerülő oldala vált, hogy ismételt bossnál ne mindig ugyanazt az oldalt próbálja;
4. a memória lejárta után az azonos irányú minimapjavaslat helyett oldalirányú
   felderítés indul;
5. legalább kb. 63°-kal eltérő új navigációs irány feloldhatja a hűtést.

## Elfogadási feltétel

Boss után ne jelenjen meg azonnal újra a „Minimap alapján...” döntés az előző lezárt
vektorral. Az első azonos irányú javaslat `Hűtőlistás lezárt minimap-irány` döntést
adjon. Élő ellenőrzés: `20260829-011737-play`.

## Élő eredmény

Az elfogadási feltétel teljesült. A 112. esemény bossészlelése után a 114–122. döntések
azonos `(-0,79; +0,62)` vektorral fejezték be a hatsöpréses menekülést. A 124. eseménytől
az azonos minimapjavaslat helyett `Hűtőlistás lezárt minimap-irány; oldalirányú
felderítés` futott `(-0,45; +0,89)` iránnyal. A HP végig 424 maradt.

## Kerülőrendszerek ütközése és javítása

A 124–136. esemény hűtött oldalmozgása alatt a háttér statikus maradt. A külön
háttér-ujjlenyomat-őr a 138. eseménynél ezért saját faljárást indított `(+0,22; -0,97)`
iránnyal, és felülírta a még aktív délnyugati hűtést. A 152. eseménynél ismét boss
jelent meg. Aktív `blockedRouteCooldown` alatt ezért a statikus faljárás indítása
tiltott; a hűtő saját 12 lépéses oldalváltása az egyetlen akadálykezelő.

Élő ellenőrzés: `20260829-012105-play`.

## Tiszta merőleges elakadás és kifelé kevert vektor

A `012105-play` 42–64. eseménye 12 tisztán déli `(0; +1)` hűtőmozdulatot adott, de
a karakter a sziklán maradt. A 66–86. esemény északra váltott, majd a 88. eseménynél
ismét boss jelent meg. A puszta merőleges ezért nem elég összetett sziklasarokban.

Az aktuális hűtővektor a merőleges falmenti komponenshez 0,55 súllyal hozzáadja a
lezárt iránnyal ellentétes, faltól kifelé mutató komponenst, majd normalizál. Balra
lezárt minimapiránynál az első déli kerülő így délkelet: lelép a szikláról, miközben
dél felé keresi a fal végét. Élő futás: `20260829-012333-play`.

## Sikeres szakasz után újratervezés

A `012333-play/frame-00056.png` igazolta, hogy a `(0,48; 0,88)` délkeleti hűtő lehozta
a karaktert a szikláról a patak/kapuszerkezet melletti nyílt zöld területre. A régi
szabály ennek ellenére a 66. eseménynél északkeletre váltott és további szakaszt futott.

Most a 12. hűtőlépés után:

- ha a szakasz bármely pontján mozgott a háttér, a lezárt irány törlődik, és a következő
  kép friss útvonalat számít;
- csak továbbra is statikus háttérnél vált a hűtő a másik oldalra.

Az első `012533-play` kísérlet csak a 12. kép pillanatnyi statikusságát nézte, ezért a
korábbi mozgást elfelejtette és mégis oldalt váltott. Külön szakaszszintű
`blockedRouteBypassSawMovement` jelző őrzi az egész tizenkét lépés eredményét.
Az új jelző a `012743-play` 72. eseményénél feloldotta a hűtést, de a korábban felgyűlt
statikus számláló miatt a 74. esemény rögtön új faljárást indított. Sikeres feloldáskor
most a `consecutiveStaticSceneDecisions` is nullázódik. Ezután legalább hat friss
eredménytelen próbának kell megelőznie új faljárást. Élő ellenőrzés:
`20260829-012951-play`.

## Minden régi navigációs állapot törlése

A `012951-play` 98. eseménye egy 136 HP-s célhoz nyolclépéses `persistentDetour` kerülőt
indított. A 106. esemény bossmenekülése után a 118–124. események mégis folytatták ezt
a régi célkerülőt. A boss/visszavonulás most már a statikus és minimap-kerülők mellett
a `persistentDetour` és `blockedAreaEscape` állapotokat is törli. Élő futás:
`20260829-013258-play`.
