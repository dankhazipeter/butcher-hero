# A tábori ösvény topológiai bekötése — 2026-09-19

## Kalibrációs bizonyíték

259végpont184048-observe/0és184143-play/0azonosságát offline optikai
áramlással ellenőriztük:116konszenzuspont,0maradékhiba,0/0eltolódás.
Utóbbi LocalWorldMap-pontja chart51,1176,677672/251,026064. Ez a horgony
a259-es mért−6,651367/−452,023394utat ugyanabba a térképrészbe helyezi.

V2pontok0,045léptékkel:53,249807/31,637226 →53,240807/21,626076 →
52,950495/11,296173. Csak az igazolt északi irány; nincs kitalált fordított él.
A kép szerinti kezdőhely és végpont megvan, az automatikus ismétlés tesztelendő.

## Programváltozás

A folyosóadat immár saját koordinátateret nevez meg. Importkor az élek
helyes térbe kerülnek; narancs-koponyás régi folyosók alapértelmezése megmarad.
Aktiválás csakterrain-chart-51és a torony keleti megközelítési tartománya
(x40..65,y15..50), északi cél esetén. A távoliNWcélhoz előbb kelet/északkelet
az ösvény bejáratához, utána észak a mért pontokon; nem közvetlen nyugati falirány.
Az aktuális hely→bejárat összekötés képi hipotézis, nem utólag igazoltnak
nyilvánított szabad él. A mozgás visszamérésből tanul tovább.

Két eredménytelen tényleges folyosólépés a konkrét irányított út bizonyítékát
5percre hűti és megszakítja a folyosót. Régi útadat nem jogosít végtelen falnyomásra.
Más chart azonos koordinátái nem aktiválhatják ezt az utat.

## Kísérlet

185036-observe/0:6,51K, szikla keleti oldala. A régi automatikusNWfutást
nem ismételtük; előbb a fenti bekötés és célzott teszt készült.

Build/V2tesztPASS, beleértve charttévesztés tilalmát és a sikertelen folyosó
hűtését. Quick-farm/HP-takarás replayPASS.

## Élő siker — 18:53

185320-f2487515-play/0–1az ösvény bejáratát célozzaNE,2–8a mért északi
ponton halad.9a torony felső oldala,14már a kerítés mögötti192HPőr mellett.
**16:Steel Splitter26,300→312,19m59s.**19a174HPfa516találata,
32saját6,52K ésúj3m52s. **A korrigált út önálló végrehajtása és jutalomig
vezető használata igazolt.** FelszerelésPhantom4/Venom18változatlan.

20–32várakozás már nem navigációs fal: aHP-sorOCR-je„152s16.52K”,
a percbetű hiányzik. Biztonsági megfigyelési kapu ezt eddig nem ismerte fel;
szűk javítás262-ben. A6,52K friss tiszta numerikus megerősítése még szükséges.
