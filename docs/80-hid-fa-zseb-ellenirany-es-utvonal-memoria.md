# Híd–fa zseb: ellenirány és útvonal-memória

## Incidens — `20260829-042252-play` és `20260829-042722-play`

A 727 HP-s karakter az Island 4 feliratot mutató zöld udvarban egy rövid farámpa,
kerítés és nagy előtéri fenyő közé került. A minimap tartósan közel
`(-0,97; -0,25)` irányba mutatott. A korábbi négy, a navigációs vektorhoz képest
forgatott átló újra és újra ugyanazokat a közeli képi állapotokat járta be, de nem
jutott tovább a célhoz.

Biztos technikai megfigyelés: a képenként választott régi érintési pont túl alacsonyan,
az előtéri lombon feküdt. A szabadpont-kereső ezért felsőbb jelölteket is kapott
(`y=0,50–0,52`), és azonos vizuális pontszámnál enyhén a magasabbat részesíti előnyben.
Az élő futás ezután `(0,25; 0,52)` körüli, tisztább kezdőpontot választott. Ez önmagában
nem oldotta meg az útvonalhurkot, tehát a fő ok nem elvesző swipe volt.

## Hatfázisú próba — `20260829-043036-play`

A négy átló után ötödik fázisként bekerült a blokkolt vektor pontos ellentéte, majd
hatodik tartalékként az eredeti vektor. Az 54–66. esemény körüli ellenirány
`(0,98; 0,21)` ténylegesen lehozta a karaktert a rámpáról a sátor mellé. A következő
`(-0,97; -0,24)` szakasz viszont visszavitte a korábbi pályarészre. Következtetés:
az ellenirány jó kiszakadás volt, de a siker emléke nélkül a sorozat saját maga
visszafordította.

## Döntés: a kiszakadás után lezárt útvonal

Az ötödik, közvetlen ellenirány indításakor a bot most 120 döntésre hűtőlistára teszi
az eredeti minimap-/küldetésvektort. Az ellenirányú szakasz egy új akadálynál még
szabályosan befejeződhet, utána azonban nem a hatodik, visszafordító fázis következik.
A meglévő útvonalhűtő a lezárt irányra merőleges és attól 0,55 súllyal kifelé mutató
vektort használ. Új, érdemben eltérő minimapirány vagy a hűtőszakasz alatti
kameramozgás újratervezést enged.

## Élő igazolás — `20260829-043455-play`

- 52–68.: az ellenirány ismét elvitte a karaktert a rámpától a sátorig;
- 70–74.: a visszafordulás helyett három `(0,65; -0,76)` hűtőlistás oldalirányú
  swipe futott;
- 76-tól a minimapvektor `(-0,23; -0,97)` környékére fordult, majd észak felé
  folyamatosan változott; ez nem a korábbi zseb ismétlése;
- `frame-00076`–`frame-00088`: a karakter a sátor mögül nyílt udvaron át a következő
  fakerítésig haladt;
- 103-tól a helyesen azonosított 291 HP-s, 1-fejszés fenyő került képbe; a cél
  294→249→235 pixelre közeledett, majd a kőfalnál a külön célakadály-logika vette át
  a döntést és hosszú kiszakadást indított.

Ez közvetlenül igazolja, hogy a híd–fa zseb megszűnt, és a kiszakadás utáni
útvonal-memória második, önálló akadályig vitte tovább a játékost. Az új területen
egyelőre nem született jutalom; a 291 HP-s fa ismét kőfal mögötti, alacsony hozamú
célként viselkedett.

## Következő mérés

Figyelni kell, hogy a lezártirány-hűtés egymást követő kerítés- és sátorsarkoknál is
elkerüli-e a korábbi képi állapotokat, illetve mennyi döntés után talál elérhető
szívfát. Hosszabb távon a jelenlegi ujjlenyomatokból helyi állapotgráf készíthető,
amely nemcsak az utolsó rossz irányt, hanem a már bejárt képi hurkokat is bünteti.
