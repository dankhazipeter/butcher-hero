# Új taktika — 2026-10-29

## Aktív — 2026-10-30

305: képháttér-problémánál először különítjük el a PNG-alfa és a CSS
hatását. Most a képek átlátszók; csak a megjelenítés változik. UI-javítás
miatt nincs gyűjtőleállás vagy a felismerési sablonok újragenerálása.

304:az élő statisztikai kapcsolatot nem keverjük a gyűjtő működésével.
Külön szöveges/színes állapotsáv és utolsó sikeres képidő. A leállási,
elakadási és kapcsolathibás UIágakat tesztadatokkal vizsgáljuk, nem az élő
gyűjtő szándékos leállításával. A felület továbbra sem vezérli a játékot.

303:újraindítással tünetet kezelő natívOCRhelyett a hibázó függőséget
kiváltottuk aFree-körből. Előszörpixelbadge, utána célzottFREEellenőrzés;
számot nem találunk ki típusból vagy korábbiösszegből. Új bizonytalan fontot
képből címkézünk, regresszióval fedünk. Adatmodell frissíthető leállítás nélkül.

302:átmenetiOCRinfrastruktúrahibánál sincs tesztkapu-megkerülés. CPU-
feldolgozási kísérlet támogatott eszközökkel, képi elvárások változatlanok.
A felügyelt gyűjtő közben külön marad, betöltéshez is előre fordított bináris kell.

300:tesztfejlesztés nem jelentheti az engedélyezettFreegyűjtés elhanyagolását.
Aktív gyűjtést csak betöltésre állítunk meg, nem a teljes teszt/CI idejére.
Friss lastCheckedAt és átvételi utókép alapján mondunk működést, nem PIDből.
Kézi átvételt nem írunk a bot hozamához; STOPután a felügyelő sem indulhat vissza.

299:távoliCIpiros esetén a tényleges naplóból diagnosztizálunk. A runner-
kapacitásról szóló NOTICE nem magyarázta a hibát; konkrét fordítási hibák
voltak. Nem gyengítjük a tesztet vagy cseréljük le a képi elvárást emiatt.

298:közreműködőknél is helyi make test és PR-on látható GitHubellenőrzés.
A helyi siker nem helyettesíti a szerveroldali futást; jóváhagyásra váró
fork-ellenőrzés nemPASS. Merge-tilalmat nem ígérünk külön repószabály nélkül.

297:felismerési javítás csak rögzített képi elvárásokkal és a teljes
tesztkapu sikerével zárható. Nem módosítjuk az elvárt címkét azért, hogy
a hibás felismerő átmenjen. Új esethez külön kalibrációs/ellenőrző kép;
teszt nem vezérel játékot, régi jutalmakat nem könyvel. Az555CutDamage
hibát az új készlet fedezte fel, nem a felhasználó újabb jelzése.

296: smash-statisztika hiányánál a bizonytalan típusú, már igazolt tételek
képeit nézzük, nem könyvelünk új átvételt. Technikai javítás után --resume-run
őrzi meg az aktuális kör statisztikáját. Nincs összegből kitalált típus.

295:gyűjtési gyakoriságot a közös DARABvonalakon hasonlítunk össze,
nem aHealthésmás statok eltérő nagyságú összegeiből. Az ismeretlen típusok
külön maradnak, nem torzítunk kitalált besorolással. A gyűjtő nem változott.

294:a rövidített statkijelzés nem csökkentheti a napló pontosságát.
Összehasonlításhoz továbbra a teljes értéket használjuk; a UI-ikonok
háttéreltávolítása nem módosítja a gyűjtő felismerését vagy inputját.

293:felhasználói prioritás mostantól jó naplózott adatok, nem történeti
helyreállítás. Javított gyűjtő külön új futás; a292-es élő nézet ezt mutatja
alapból. Zöld fű nemFreekártya;18.3K=18300, teljes token kell.

291:új kifejezett folytatásra aFreegyűjtés ismét fut; kézi húzásvédelem
és a286-os újrapróba/könyvelés változatlan. CsakFree, nincs karaktermozgás,
harc, bolt vagy ismeretlen felugró képernyő automatikus átugrása.

286:kézi játékot lenyomott egérgomb mellett nem szakítjuk meg jutalominputtal.
Elengedés után frissFreeellenőrzés. Megmaradt kártya1s után újrapróba,
csak két hiánykép könyvel; ugyanazt a jutalmat többször nem számoljuk.

284:felhasználói18Kkézi átvétel nem bothozam. A kihagyott/takart számos
kártyák felismerése és az el nem küldött kattintás utáni újrapróba javítva.

A felhasználó a nyolcféleFree-jutalom felismerését, átvételét és időbélyeges
naplózását kérte; ez fut1másodperces ellenőrzéssel(282). Karaktermozgás,
harc és bolt nincs. Az alábbi teljesSTOPa tegnapi munkamenet története.

FelhasználóiSTOP(281):játék teljesen bezárva,automatizáció nem fut.
Új kérésig nincs megfigyelés vagy fejlesztési futás. AFreefigyelő félkész.

Még nincs kialakított taktika; a felhasználó első lépésére várunk.
Nincs mozgás, kattintás vagy automatikus játék. Képet a felhasználó jelzésére nézünk.

A korábbi farmcélok, bosspróbák, fegyverajánlások és útvonalak történetiek.
Az új verzióban friss ellenőrzést igényelnek. Az első kért kép:280.
