# Titan-oltár, 0/7 gem és a lila minimapcél

## A lila ikon jelentése

A `20260829-122455-play` élő futás bizonyította, hogy a minimap külön lila ikonja
nem ellenség és nem átjáró, hanem a Titan-oltár helyszínjelzője. Az ikon lila belső
komponense kb. 9×9 pixel, ezért különválasztható a piros harci pontoktól, a sárga
játékosjelölőtől és a zöld helyszínikonoktól.

A célzott navigáció 38–44. képkockán a kör alakú, kék közepű kőoltárhoz vitte a
karaktert. Közel érve a játék ezt a feladatot írta ki:

`Collect all gems to unleash the Titan's power`

Az aktuális számláló `0/7`. Biztos tény tehát, hogy hét gem összegyűjtése egy új
Titan-rendszert vagy erőt old fel. A gemek forrása és a feloldás pontos jutalma még
nyitott; a következő élő cél ezek felderítése.

## Pulzáló ikon és iránymemória

A lila ikon animál. Az első élő változatban minden második képen a színküszöb alá
esett, miközben a vele ellentétes oldalon piros cél maradt. A bot ezért felváltva
jobbra, majd balra swipe-olt. Öt döntéses különleges-landmark memória került a
stratégiába. A `20260829-122443-replay` a látható ikon után öt mentett felismerési
résen át ugyanazt az irányt tartotta; az új élő futás ezt a pulzáló képeken is
folyamatos mozgással igazolta.

Amint a Titan-feladat buboréka látható, a rendszer bizonyítottnak veszi az oltár
elérését és azonnal törli ezt az iránymemóriát. Így nem nyomja vissza a karaktert az
oltár közepébe, hanem továbbindulhat gemeket és ellenfeleket keresni.

## A feladatbuborék HP-takarása

Az oltár fekete buboréka pontosan a karakter HP-szövegére és részben a zöld csíkjára
kerül. A korábbi általános OCR a `0/7` és a takart 778 részeiből egyszer `7il0`→70
HP-t állított elő, majd téves 9%-os kritikus visszavonulást indított. Ez nem valódi
sebzés és nem újraéledés volt: az előtte és utána látható tiszta szám is 778.

A javított Analyzer külön, széles Titan-ROI-ban felismeri a `Titan/power/gems` és
`/7` kombinációt. Ebben az állapotban:

- a takart képből nem fogad új numerikus HP-t;
- a legutóbbi hiteles 778 marad érvényes;
- a Titan-buborék önálló játéktér-bizonyíték, ezért a HUD-őr nem állítja le a mozgást;
- a bot elhagyja az oltárt, és folytatja a térkép- és gemfelderítést.

A `20260829-122731-replay` ugyanazon, korábban 15%-os HUD-képet 95%-os biztos
játéktérként kezelte és normál felderítő swipe-ot adott, hamis 70 HP nélkül.

## Továbbhaladás az oltár után

A következő élő `20260829-123510-play` 48. eseménye új folyamatban is felismerte a
teljes 0/7 feladatot. A felismerés 600 tényleges döntésre lehűti az oltár irányát,
ezért a pulzáló lila ikon nem húzza vissza a karaktert. A lezárt Island 4 felé erősen
balra mutató piros irány ugyanekkor elnyomódik, helyette növekvő szabad felderítés fut.
A 109. eseményen az oltár már jobbra-lefelé, a karakter mögött volt, miközben a bot
balra kutatott tovább. A részletes stratégia és élő bizonyíték a 140. fejezetben van.

## Mozgó számlálósor

A `124335-play` megmutatta, hogy a buborék függőleges helyzete változhat: a teljes
feladatmondat olvasható maradt, miközben a `0/7` kicsúszott a régi OCR-régióból.
A Titan-mondat ezért számláló nélkül is állapotbizonyíték, a ROI pedig lefelé bővült.
A négyperces téves várakozás és regresszió részletei a 142. fejezetben vannak.
