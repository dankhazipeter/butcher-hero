# Saját térkép és sebességfüggetlen helyzetkövetés — 2026-09-19

## Felhasználói követelmény

Gyors, folyamatos farm, nem percekenként néhány kézi mozdulat. A járható utak,
falak és hozzávetőleges fix ellenfélhelyek kerüljenek saját térképre. A gyorsító
hatások miatt egy adott idejű swipe nem jelent állandó távolságot. Helyzetet
képi háttér- és minimap-támpontokból kell visszamérni, nem lépésszámból jósolni.

## Jelenlegi hiány és mérhető terv

A régi33értékű színaláírás és az irányonkénti blokkszámláló nem valódi pozíció.
A222/225helyi gráf első lépés, de túl pontos kezdőképhez és lépéskorláthoz kötött.

1. Több képi háttérrész elmozdulása → bizonytalansággal jelölt helyi pozíció.
2. Járható mozgásokból gráfélek; mozgás nélküli tényleges inputból akadály,
   de harc, emberi input és UI soha nem akadálybizonyíték.
3. Képi támpontok és minimap-aláírás visszaazonosítása → drift javítása;
   bizonytalan helyzetnél nincs vak útvonalkövetés vagy más térképszigettel összemosás.
4. Ellenfélhely, jutalomtípus, legyőzhetőség és mért újratermelődés csomóponthoz.
5. Aktuális elmozdulás/inputidő alapján mozgáshossz; gyorsulás nem rontja el a térképet.
6. Fejlődés/perc és falnak küldött input aránya mutassa a javulást, ne a mozgásszám.

## Első mérés — még nem kész navigátor

AppleVision SDK helyi fejlécei alapján többkivágásos transzláció és sűrű optikai
mozgás került összehasonlításra. `133246-nudge` nyugati lépései és
`133139-nudge` déli lépései a kalibrációs sorok. A transzláció40–150ms körüli,
de a perspektíva és homogén narancs talaj miatt több rész nem egyezik; hibás
egyezést nem fogadunk el. A sűrű mozgás első modellbetöltése20s volt, utána
36–70ms/képpár. Az elmozdulás skálája még külön mesterséges és terepi mérésre szorul.
Addig csak diagnosztikai prototípus, nem irányítja a karaktert.

Közben `140122-71600bcd-play`3,06K-s őrgyőzelmet (30perces kör) ésVenom14→15
fejlődést adott. A122–124képen a korábbi kerítéses765-ös kaktusz is biztos
újratermelődési kört és+1statjutalmat mutat. AHP5810; a járható farm tehát fut,
de az útvonalkeresés hatékonysága továbbra elégtelen, ezért készül ez a réteg.

## Kalibráció és első implementáció — 14:20 körül

Tény: Vision optical-flow rev2 még a mesterséges+60px eltolásból is35px körüli
értéket adott. Rev1 ugyanezen59,97px-et mért. Ezért rev1et használunk, minden
javasolt pontot7×7pixeles képrészillesztéssel ellenőrizve. A perspektívát robusztus
affin síkillesztés kezeli, a karakter központi régiója kizárt. Legalább8 egyezés,
45%konszenzus és térbeli kiterjedés kell. A hat ismert eltolásos teszt hibája<1px.
A133139déli öt szakasz mind érvényes, kb78–86px háttérmozgással; ez nem
világegység és a teljes sziget hosszú távú sodródása még nem mért.

`LocalWorldMap` külön helyi koordinátájú térképrészeket ment. Bizonytalan mozgás
után nincs összekötött kitalált út. Terepkép+minimap szigorú közös egyezése
visszaazonosíthat korábbi pontot. A mozgásból járható irányított élek, két
igazolt mozdulatlan inputból helyhez kötött blokkolt irány készül. A célpontok
hozzávetőleges helye, legnagyobb látottHP-ja, ideje és bizonyítéka mentődik.
Az ellenfélmozgás és a perspektíva miatt ezek becslések, nem pontos spawnpontok.
Harcot/UI-t/menekülést nem ír felül a térkép. Általános felderítésnél az első
vezérlési használat kevésbé bejárt oldalirányt választ, és150mért pixeles
elmozdulásig tartja, nem előírt számú swipe-ig. Élő mérés még szükséges.

Nyitott: teljes farmkör tervezése, célcooldown térképre kapcsolása, magassági
rétegek biztos elválasztása, hosszú távú koordinátasodródás. Nem kész globálisSLAM.
Közben141140-play/342ig5840-re nőtt a kijelzett maximum; a sok kerülő és
Island1-visszatérés miatt ez továbbra nem elég jó fejlődési ütem.

## Első élő eredmény és újabb célválasztási hiba

142009/0–18: a háttér valóban0px; a régi Island2-makró még kimaradt a
térképes akadályőrből. Ezt a hiányt javítottuk.142112/5–8: két mozdulatlan
input után a saját térkép oldalirányban kijutott,13képenDusty Gulch2felirat.
Ezután a közeli minimap-piros pont SEirányban visszavitteIsland1re. A pont körüli
zöld/narancs terepmintából ezért külön kizárjuk azIsland1célokat ezen fejlettségen.
A142112/13replay már nem fordul keletre. A teljes korábbi regresszió változatlanul átment.

Újabb helyvisszaazonosítás: nemcsak kis képleírók pontos egyezése, hanem a
mentett közeli kulcsképből ellenőrzött optikai elmozdulás is használható,
szigorú minimap-egyezéssel. A korai térképpontok `live-frame-N` hivatkozása
hiányos; az új pontok már teljes futás/kép hivatkozást kapnak. Régi bizonytalan
térképrészt nem nevezünk automatikusan ugyanannak a helynek.

## Sűrűbb mintavétel és útvonalkeresés — 14:30

142548futás teljes visszajátszása: a16pxmintarács kevés részletet talált néhány
sziklán;8pxrács mellett191elfogadott mozgás,0elutasított a vizsgált,UI-mentes
képpárokon. Az idő tipikusan30–45ms, tehát nem ez a játék tempójának fő korlátja.
Külön feltárt hiba: a régiSettings-Xszíndetektor vörös sziklát is talált;
a térképezés ezeken tévesen megszakadt. MostSettings/Unstuck szöveg is kell.

A régi színaláírásos kerülő és az új helyzetszabályozó nem rakódhat egymásra;
elfogadott képi mozgás esetén az új térképé az általános navigációs felügyelet.
Új irányított legrövidebbút-kereső csak ténylegesen bejárt éleken vezethet a
korábban legalábbkétszer látott,≤5K-sIsland2ellenfél környékére. Visszafordítható
magaslati él nem feltételezhető. Érkezés utáni célhiány nem győzelem,120s múlva
ellenőrizhető újra. A sebességbecslés a következő waypointig szükséges tartást
0,25–0,68s között módosítja. Ismeretlen csomópontközti résen nincs vak rövidítés.
Teszt: irányított út, ismeretlen visszaút, kapcsolat nélküli közeli pont és
blokkolt él külön ellenőrzött. Élő eredmény/perc javulása még NEM bizonyított.
