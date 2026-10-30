# Piros minimapcél és az Island 4 zárfala

> **Helyesbítés:** ez a fejezet az első megközelítés után született, és a
> „lezárt Island 4-régió” következtetése még ugyanabban a felügyelt ciklusban
> megdőlt. A `frame-00242` normál bejáraton elérte a **Dusty Gulch – 2** területet,
> ahol a piros célok farmolhatók. Az `UNLOCKS AT ISLAND 4` a következő fegyverhely
> HUD-felirata, nem világkapu. Az aktuális tudás és programdöntés a
> [158-as fejezetben](158-dusty-gulch-2-es-a-fegyverhely-hud.md) van; az alábbi
> szöveg a hibás hipotézis felismerésének történeti naplója.

## Kiinduló anomália

A `docs/runs/20260829-140322-play/frame-00083.png` képén a Titan-oltár `0/7`
feladata mellett a minimap bal oldalán piros célterület maradt. A bot mégsem indult
közvetlenül oda: a Titan-hűtés alatt minden erősen balra mutató piros irányt a
globális `UNLOCKS AT ISLAND 4` HUD alapján lezártnak tekintett, és a Titan-kijárati
vektor felülírhatta a piros jelet.

Ez hibás általánosítás volt. Az `UNLOCKS` felirat globális HUD-elem; puszta
jelenléte nem bizonyítja, hogy minden piros térképcél a fal túloldalán van.

## Programdöntés

- Élő piros minimapvektor elsőbbséget kap a Titan kijárati memóriájával szemben.
- A Titan kijárati vektor csak akkor futhat, ha nincs érzékelt piros cél.
- Piros irányt csak a már két oldalról fizikailag zártnak bizonyított Deep Mines-kapu
  aktív hűtése némíthat el.
- A konkrét Island 4-fal kerülője a helyszíni narancsszikla-bizonyítékhoz kötött;
  ezt a Titan-hűtés önmagában többé nem tiltja le.

A `docs/runs/20260829-140704-replay` 18–24. képein a módosított döntő hat egymást
követő, balra mutató swipe-pal követte a piros célt.

## Élő expedíció eredménye

A release builddel indított `docs/runs/20260829-140735-play` már az első képen a
piros cél felé indult. A 0–5. képen közvetlenül balra haladt. A szikla–kerítés sarok
miatt ezután mind a hat akadálykerülő fázist kipróbálta:

- a 12. és 59. képen a palánk helyileg elzárta a közvetlen irányt;
- a 60–72. képen a bot ismét a piros vektort tartotta, és elérte a bal oldali
  narancsszikla–víz határt;
- a 72. képen a karakter közvetlenül a zárt átkelőnél áll, miközben balra a nagy
  narancsszikla, alatta víz, mellette kerítés, a HUD-on pedig az
  `UNLOCKS AT ISLAND 4` lakat látszik;
- hat eltérő kerülőfázis egyikével sem jött létre átjárás vagy harci kontaktus;
  a 78–109. képen a bizonyított Unstuck helyreállítás vitte vissza a karaktert.

**Biztos:** a bot elment a térképen jelzett irányba és fizikailag megvizsgálta a
határt; a célhoz nem alakult ki harci kontaktus.

**Elvetett következtetés:** a bal oldali piros cél nem egy feloldásra váró Island
4-régióban van. Csak az első, közvetlen út futott helyi szikla–víz akadályba;
a `frame-00242` másik irányból bejutott a Dusty Gulch – 2-be.

**Nyitott:** a Dusty Gulch – 2 teljes útvonalgráfja, és hogy a minimap egyes piros
pontjai a 253 / +4, 632, 765, 1.22K és 4.4K célok közül melyikhez tartoznak.

## Taktikai következmény

A piros térképcélt nem szabad puszta HUD-felirat alapján kihagyni. Helyi akadálynál
az általános faljárás másik bejáratot keres; csak konkrét cél-aláírás és ismételt
stagnálás indíthat ideiglenes útvonalhűtést.
