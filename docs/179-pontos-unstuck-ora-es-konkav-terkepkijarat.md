# Pontos Unstuck-óra és konkáv térképkijárat

## Az egyszeri magaslati hely értelmezése

A különleges magaslati ládahely nem farmkör: a láda egyszer vehető át, utána a
hely közvetlen visszalátogatásának nincs hozama. A tartós szemantikus térkép ezért
a biztosan kifosztott bejárati képaláírást és irányt végleges, nem eviktálható
állapotként kezeli. A tágabb magaslati hálózatot ettől még hosszú távon fel kell
deríteni, de csak új láda-, ellenfél-, küldetés- vagy ismeretlen ág bizonyítéka
indokol visszatérést; a régi láda önmagában nem.

A hely járhatósága magassági réteghez kötött. Képen közelinek látszó objektumhoz
nem feltétlenül vezet közvetlen út: híd, palló vagy rámpa válthat réteget. A
`193422-play` végén a karakter teljes 1940 HP-val ugyanazon narancssziklás
határzsebben maradt több irányfázison át. Ez nem mozgó ellenfél, hanem helyi
topológiai korlátozás volt.

## Pontos Unstuck-visszaszámlálás

A `193049-play/frame-00054.png` Settings-képén a gomb `06:25` értéket mutatott.
Az új, kizárólag a Settings alsó gombjára korlátozott OCR ezt replayben pontosan
385 másodpercként adta vissza. A karaktert a tényleges lejárat után végrehajtott
Unstuck 0 HP-s átmenettel a zöld központi medencéhez helyezte, ahol 426-ról
visszagyógyult a bizonyított 1940-es maximumra.

Az időzár most nem becsült tíz perc, hanem az olvasott `mm:ss` plusz öt másodperc,
abszolút lejáratként a `navigation-state.json` fájlban. Ismeretlen feliratnál
marad csak a konzervatív tartalék.

## Késleltetett teleport felismerése

A `195052-play` 47–55. döntése új versenyhelyzetet mutatott. A bot megnyomta az
elérhető Unstuckot, de a Settings még öt képen át látszott. Az ötödik képes őr
ezt tévesen aktív időzárnak minősítette és bezárta a panelt; egy képpel később a
karakter már a zöld medencénél volt. Az áthelyezés tehát sikeres volt, csak a
panel eltűnése késett.

Javítás: olvasható számlálónál öt kép továbbra is elég a biztos lezáráshoz.
Számláló nélküli, még látható panelnél tizennégy képig várunk, hogy a megkésett
teleport ne legyen hamis sikertelen próbának minősítve.

## Zárt Deep Mines-kapu: valódi területelhagyás

A `194114-play` 44–67. döntése 1940 maximumnál is újra elvégezte a kétoldali
1,92K-s kapupróbát. Kontaktus nem történt, majd a bot helyesen zárt kapuként
délnek fordult. A javítandó rész ezután jelent meg: amikor a `0/1` buborék egy
képre eltűnt, a piros minimapjel visszavitte a falhoz. Ez több mint száz további
döntéses kapukörnyéki hurkot okozott.

A kapu lezárása most 36 döntéses, buborékfüggetlen déli területelhagyási állapotot
indít. Ez törli a piros, lila és türkiz célmemóriát; helyi kerítést a geometriai
térkép kerülhet, de északi kapucélt a szakasz alatt nem építhet újra.

## Konkáv zseb és 180 fokos kerülő

A `194735-play` narancssziklás házzsebében a piros cél bal-fent volt, az egyetlen
járható kijárat viszont lefelé/jobbra nyílt. A korábbi tartós térkép csak a
javasolt iránytól legfeljebb 90 fokra keresett alternatívát, ezért bal, bal-fel,
fel és jobb-fel között fogyasztotta az időt.

Két bizonyított blokkolás után most mind a hét másik iránybin versenyezhet. A
célhoz igazodás továbbra is előny, ezért nyílt terepen nem fordul meg önkényesen;
konkáv zsákban viszont képes ideiglenesen 135–180 fokkal eltávolodni a cél
érdekében. Az élő futásban a lefelé-balra irány már tényleges kameramozgást adott.

## Következő ellenőrzések

- A 36 döntéses Deep Mines-kijutás elviszi-e a karaktert a kapu minimapkörén kívülre.
- A konkáv teljes iránykészlet megtalálja-e a ház–sziklafal zseb stabil kijáratát.
- Az egyszeri ládahely másik megközelítési aláírását is lezárja-e a szemantikus
  térkép; ha nem, a pontszerű ládamemóriát több-aláírásos helyszínné kell bővíteni.
- A 18,8K-s őrhöz vezető valódi rétegváltó út az alsó kőív vagy a felső palló-e.
