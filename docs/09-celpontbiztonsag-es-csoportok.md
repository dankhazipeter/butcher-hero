# Célpontbiztonság és ellenségcsoportok

Ez a lap a képernyőn látható célok környezeti kockázatát és az „izolált humanoid”
fogalmának fejlődését rögzíti. Egy cél alacsony HP-ja önmagában nem jelent jó célpontot,
ha megközelítése több támadót aktivál.

## Jelenlegi szabály

- A fa a türkizzöld lombarány alapján nem visszaütő célként kezelhető.
- A cél fölötti szív vagy fejsze a jutalomtípust jelzi, nem a visszaütést. Szíves fenyő
  és szíves humanoid is létezik; a fenyegetést továbbra is a testforma alapján számoljuk.
- Humanoidot csak legalább 85% játékos-HP mellett választunk.
- Humanoid csak akkor izolált, ha 150 képponton belül nincs más felismert humanoid.
- Ugyanez a 150 px-es sugár számít a célpont klaszterbüntetésében és a játékos körüli
  túlerő mérésében.
- Az érték képernyőtávolság, nem világkoordináta; a kamera nagyításának változásakor újra
  kell mérni.

## Miért 150 px

A `docs/runs/20260828-203027-play/frame-00010.png` képen három 3-as, 41 HP-s humanoid
látható egy harci csoportban. Az alsó és a következő tag becsült entitásközéppontja
110–120 px-re volt egymástól, ezért a régi 105 px-es sugár az alsót hibásan izoláltnak
minősítette. A bot a közeli 1-es fák helyett ezt választotta és 243-ról 198 HP-ig sérült,
mielőtt visszavonult.

A 150 px-es regresszióban (`docs/runs/20260828-203209-replay`) ugyanazon a 10. mentett
képen a 41 HP-s humanoid helyett a 234 HP-s közeli fa lett a választás. Ez a statikus
képi döntést igazolja; az eltérő új mozgássor élő ellenőrzése külön szükséges.

## Közelharci takarás és passzív célmemória

A `210934` futásban a játékos teste a fenyő lombját és HP-csíkját részben eltakarva a
fa-bizalmat 0,51-ről 0,21–0,24-re vitte. Ugyanazon, korábban fának bizonyult cél 100 px-en
belül ezért legalább 0,30 értéket őriz. Ha a fa már sebződött, a csík eltűnése nem indít
azonnal felderítő swipe-ot: a bot a legutóbbi HP-ból becsült ideig kivár. Humanoidnál
marad a rövid háromképes memória, mert ott a vak várakozás harci kockázat.

## Következő finomítások

- Megfigyelni, hogy 150 px mellett marad-e valóban izolált, vállalható humanoid.
- Külön kockázatot adni annak a fának is, amely 150 px-en belül humanoid mellett áll.
- Időbeli veszélytérképet készíteni, hogy a képszélről röviden eltűnő csoport se váljon
  azonnal „biztonságossá”.
