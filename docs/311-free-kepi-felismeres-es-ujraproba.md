# Free-kimaradások: képi felismerés és friss újrapróba — 2026-10-31

## Kérés és hatókör

A felhasználó jóváhagyta a Health-átvétel javítását, majd többperces
kimaradást és aránytalanul kevés Health-et jelzett. A teljes felismerés,
stabilitás, kattintás előtti ellenőrzés, utóellenőrzés és statkönyvelés
láncát vizsgáltuk. A kézzel felvett ajándék nem botjutalom. A háttérablak
általános kezelését nem bővítjük, a fókusz-/egérvédelem megmarad.

Ez a309/310-es nyitott diagnózist a következő bizonyítékokkal írja felül.

## Biztos hibák és bizonyítékok

1. **FREE szó tévesztése.** UTC08:22:56.476kor a9B1012ED…Health18300
   próbához friss elutasítási kép került a naplóba. A szív18.3KésFREE
   jól látható, mégis `FRE` és `ms` lett az OCR. A pontos ok
   `free_text_missing`, nem egérvárakozás, ablakváltás vagy összegváltozás.
   Referencia: `health18300-preclick-fre.png`.
2. **A stabilitás újraindult.** A későbbi Regen81képeken `*`+`REE` jött,
   a következő képen megint jó olvasás. Ez a régi két-egymás-utáni kaput
   újra és újra nullázta. Referencia: `regen81-ree-heldout.png`.
3. **Túl magas OCR-keret.** Két593CutDefenseképen a szókeret magassága
   kb0.023 lett a szokásos0.011helyett. Ettől az ikonvágás lejjebb ment,
   és ugyanazon ajándék típusa a kattintásig unknown lett. A küszöb nem
   lett lazítva; a horgony volt hibás. Referenciák: kétocr-heightkép.
4. **Fű mint megmaradt kártya.** Egy valódi ajándék nélküli képen a zöld
   fűfolt card=true értéket adott. Ez akadályozhatja az eltűnés igazolását.
   Referencia: `absent-grass-leaf-badge.png`; a képen nincs Freekártya.
5. **Új érték/ablakméret.** A felhasználó623×863képe18.1KHealth-et mutat,
   nem18.3K-t. Kézi átvétel volt. Saját fixture18100elvárással, nem
   korábbi összegből kitalálva. A Regen-kép értéke81, nem83.

A teljes helyi napló lekérdezéskori click_failed eseményei:869Health,
303Regen,160CutDefense (további más típusok is). Ezek **próbálkozások**,
nem ennyi külön elveszett ajándék. Minden régi hiba pontos oka nem
állapítható meg visszamenőleg frisskép nélkül. A jutalomtípusok valódi
megjelenési valószínűségét nem vezetjük le a már torzult sikerstatisztikából.

## Javítás

### Kép az első, OCR csak tartalék

A FreeBadgeMatcher a fixFREEgrafikát hasonlítja három kézzel ellenőrzött
forrásból képzett48×24maszkkal. Fehér/zöld/egyéb kategóriák, fehérglyphDice
és zöldegyezés,±1pixeles környezet. FehérDice>=0.82és0.85/0.15súlyozott
pont>=0.82kell. Ez nem82%valószínűség. A Regen81ellenőrzőkép nem része
a jelvénykalibrációnak. Források és kézi kalibráció menete a ResourceREADMEban.

Bizonytalan képnél szigorú TesseractFREEellenőrzés marad: először belső
kivágás, amely nem veszi be a fehér keretet/közeli időzítőt, csak utána a
régi kivágás. FRE/REEelfogadás nincs. Az ikon vágási horgonya a zöld
jelvény alja, nem az OCRszókeret. A kártyajelenléthez a jelvény alatt
magas sötét jobb kártyaszegély is kell, hogy a fű ne blokkolja az igazolást.

### Rövid kiesés nem végleges elakadás

Legfeljebb2.5s szövegkiesés áthidalható, kizárólag láthatóHUDéskártya
mellett. Olvashatatlan aktuális képre ettől még nem megy input. Kattintás
előtt max3új képből, összesen1.2s-en belül kell ugyanazt az ajánlatot
teljesen felismerni. Más összeg, más ablak, STOP vagy időtúllépés elutasítás.
Az egérgombot minden olvasás előtt és az input előtt is ellenőrizzük.

### Végső képből könyvelés

A click_validated elmenti a tényleges végső képet és felismerést. A
click_sent ezeket használja, nem egy korábbi, esetleg már unknown
besorolású képkockát. Sikert továbbra csak két, kártya nélküli játékHUDkép
igazol. A diagnosztika és a click_validated önmagában nem átvétel.
Újraszámolás/kézi jutalom utólagos botnak könyvelése nem történt.

### Új diagnosztika

Startup, candidate_lost, preclick_rejected és35snéma szakasz utáni idle
képek konkrét indokkal kerülnek a helyi evidencekönyvtárba. A sor tartalmazza
a HUD/card/fingerprintadatot és a látott szavakat. Max40extra kép/process,
nem korlátlan másodpercenkénti képmentés. A normál kattintási bizonyíték
és végső utókép ettől külön marad. Többperces kihagyás után már nem csak
egy félrevezető „jutalom megváltozott” szöveg marad.

## Ellenőrzés és éles állapot

35rögzített, képből címkézett eset:27pozitív/8negatív. A három jelvény-
kalibráció mellett24további pozitív eset; a számjegyolvasó korábbi
kalibrációs átfedése ettől független, nem állítunk teljesen független adatot.
Az új képek6valódi PNG-t jelentenek, nem mesterségesen generált variánsokat.
A régi29elvárás változatlan maradt.

Tesztek: képi út kényszerített ellenőrzése a hibásHealth/Regenképeken;
változott ablak/ajánlat/STOP/időkeret; három sikertelen olvasás vége;
stabilitási TTL; diagnosztikai okok; maszkforrások; nem átvételt jelentő
események statisztikai kizárása. Teljes29Swift+16statisztika+3Gitkapu+
9felügyelet+31Node=88teszt és7JSszintaxisPASS. A kapu commit/push/PR-ra is fut.

Éles program: supervisor36813/worker36820, tartós session21801,
UTC08:35:01indulás,1smintavétel,resume-run. Backend:
`pixel-free+pixel-digits-v2; tesseract fallback`.

UTC08:35:19.057click_sent /08:35:21.297claim_confirmed_ui Health18100,
A38872DB…claim; az utóképen kifejezett+18.1Kszív látszik. A végső
validált PNGofflineinspectje pixelolvasást mutat. Az első3perc6igazolt,
ebből3Health. UTC08:42:54ig15igazolt/4Health/0click_failed az új workerben.
Ez több egymást követő siker, nem örökhibamentesség-bizonyíték.

Fordítás/teszt közben a gyűjtő futott. Az első diagnosztikai betöltés30s
szünetet okozott; a következő két előre fordított csere~1–2s alatt történt.
A végső betöltéskor az új resourcekönyvtár is átkerült, nem csak a bináris.
Nincs mozgatás, harc, bolt, vásárlás, reklám vagy ismeretlen panel kezelése.
Folyamatos valódi állapot: data/free-rewards/state.json. Távoli CI külön
ellenőrizendő, hosszú távon új ablak-/font-/pulzálási eset új fixturet igényel.
