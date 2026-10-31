# Új verzió megfigyelései — 2026-10-29

## Lejárt DiamondLeague két képernyője — 2026-10-31 (317)

Felhasználói képi tény: a Time is over / DIAMOND LEAGUE panel alján
NO,THANKS, fölötte két zöld, pénzáras időhosszabbítás. A következő külön
EVENT ENDS! / DIAMOND LEAGUE összesítő alján aranyCONTINUE; ez hoz vissza
a játékba a felhasználó szerint. A CRYSTAL REWARDS és az összesítőn látszó
statok nem Free-átvételek. Képes tesztben az offer régiHUDheurisztikája
true: saját pinkgomb+zöldprogresszió megtévesztő, ezért az eventfelismerő
megelőzi ezt. Ezekből nem általánosítunk más league-re, eladási/vásárlási
gombokra vagy mindenCONTINUE-ra. Éles átmenet ebben a körben még nincs
igazolva; az átmenetileg hiányzó játékablak újra elérhető, de ez a popup
már nincs nyitva. Forrásképek és tesztek317-ben.

## No Ads és a feladatok megjelenése — 2026-10-31 (315)

Felhasználói pontosítás: No Ads nélkül egyáltalán nem jelenik meg aFree-
feladat. Így a közösfigyelő Freeága nem talál kattintható kártyát, miközben
a kristálynyitás önállóan elérhető maradhat. Nincs szükség külön kristály-only
kapcsolóra ehhez a játékműködéshez. Kódtény: a figyelő ténylegesen felismert
Freekártyára reagál, nem vásárlási nyugtát ellenőriz; nincs automatikus No Ads
vétel, reklámkezelés vagy fizetős fallback. A No Ads nélküli játékállapot
jelentése most felhasználói közlés, nem ezen a vásárolt fiókon megismételt
kísérlet. A telepítési segítségkérés nem oldja fel a314-es STOP-ot.

## Kristálynyitás — 2026-10-31 (313, felülírja312 ismeretlen képernyősorát)

Felhasználói négykép: főpanel aranyx1Open, kezdeti geodelap, változó színű/
szintű/statú kristály Continue-gombbal, majd szürkeOpen+főpanelX. Élőben
külön új közteskép: elsőütés után a barna lap eltűnik, a repedt lila kő és
TAP TO OPEN GEODE marad. Két további igazolt ütés után kék40-es kristály,
PierceDefense+291K és SellCost1.41K látszott. SellCost nem végrehajtott
eladás, és a kristály statja nem igazolt karakterstat-növekedés. Continue
után főpanel, bezárás után eltűnt a HUD-kristályikon piros pontja. Időzítő
~45perc, ezért a következőnyitás idejét nem a felhasználói6perces képből
égetjük be. Számláló0/9OCR-je0/S is lehet: ezt nem könyveljük számként.

## Következő: kristálytörés — 2026-10-31 (312)

Felhasználói közlés: a jobb oldali kék kristályikon piros jelzése azt
jelenti, hogy kristály törhető. A csatolt képen kék kristályok és fehér
szegélyű piros pötty látszanak; a funkciót most nem nyitottuk meg.
Minta: references/2026-10-31/crystal-red-dot-user.png.
A további képernyők, költségek, jutalom és a siker feltétele még ismeretlen.
Ez nem általános bolti vagy pénzköltési engedély, hanem a következő tervezett
automatizáció megfigyelése. A jelenlegi gyűjtő továbbra csak a bal oldaliFree.

## Free-jutalmak — 2026-10-30

Felhasználói képekkel azonosított8típus:Health,HealthRegen,Pierce/Cut/Smash
DamageésPierce/Cut/SmashDefense. A védelem pajzsos, nem azonos az azonos
színű támadóikonnal. A statlista százalékos sorai nem új Free-kategóriák.
Élő képileg igazolt+680SmashDamageés több további átvétel:282.
A kijelzett jutalom összegét naplózzuk, a teljes karakterstat szorzói különiek.

Forrás: `runs/20261029-223657-10037739-observe/frame-00000.png`.

- A játékablak elérhető, a karakter egy portál közelében áll.
- A portál fölött BOSS TOWERfelirat és0/9számláló látható.
- A karakter zöld csíkjánál473Mfelirat látható.
- A kezelőfelület és az alsó felszereléssor megváltozott.

Ezek vizuális tények. Az új ikonok funkciója, a Boss Tower szabálya és a
pontos harci statok még ismeretlenek. A473M-et nem írtuk régi HP-memóriába.
A régi mechanikai összefoglaló az archívumban maradt.
