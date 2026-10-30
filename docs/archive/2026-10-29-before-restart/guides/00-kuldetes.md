# A projekt küldetése

## Alapfeladat

Olyan, teljesen helyben futó botot építünk a Butcher Hero egyjátékos iPad-játékhoz, amely:

- a játék képernyőit önállóan elemzi;
- a látottakból következteti ki a szabályokat és a vezérlést;
- érintést utánzó, kitartott swipe-okkal mozgatja; a húzás bármely nem takart
  játéktérpontról indulhat, nem kötelező a kirajzolt alsó kör közepéről;
- játszik, fejlődik, és egyre jobb, mérhető stratégiákat keres;
- minden fontos megfigyelést, döntést, taktikát és eredményt ebben a `docs` mappában rögzít.

## Nem felejthető működési elv

**A programot nem hagyjuk változatlanul, magában futni.** A projekt lényege az elemző és
fejlesztő visszacsatolás: a bot korlátozott idejű játékmeneteit a modell visszanézi,
értelmezi, majd a tapasztalat alapján módosítja a program felismerését, döntési logikáját
vagy taktikáját. Ezután új kísérlet következik.

Kötelező fejlesztési ciklus:

1. **Megfigyelés:** kiinduló képernyő és korábbi futási napló értelmezése.
2. **Hipotézis:** egy konkrét játékmechanikai vagy taktikai feltevés megfogalmazása.
3. **Korlátozott kísérlet:** rövid, visszafordítható és naplózott botfutás.
4. **Kiértékelés:** képkockák, HP-változás, helyzetváltozás, jutalom és hibák elemzése.
5. **Programjavítás:** felismerő, állapotgép, vezérlés vagy stratégia módosítása.
6. **Dokumentálás:** biztos tény, elvetett hipotézis, új döntés és következő mérés leírása.
7. **Újrateszt:** az új verzió összehasonlítása az előzővel.

Hosszabb önálló farmolás csak akkor indokolt, ha az aktuális viselkedés több rövid futásban
stabilnak és biztonságosnak bizonyult; annak eredményét is utólag elemezni kell.

## Sikerkritérium

Nem önmagában az számít sikernek, hogy a bot mozog. Akkor haladunk, ha futásról futásra
egyre pontosabban érzékeli a játék állapotát, kevesebb hibás döntést hoz, jobb a túlélési
és fejlődési eredménye, és ezek oka a naplóból visszakövethető.

A játékos megerősítése szerint a halál után a karakter automatikusan, külön játékbeli
veszteség nélkül újraéled. Emiatt a túlélés nem merev korlát: egy kontrollált halál
elfogadható felfedezési eredmény, ha új ellenfélről, sebzésről vagy jutalomról tanítja a
modellt. Az elsődleges cél a tartós fejlődés üteme és az új mechanikák feltárása.
