# Island 4 zárfal mögötti 17.5K, +30 növényi cél

## Élő megfigyelés

A `20260829-130403-play` 88. eseménye új, közvetlenül olvasható céladatot adott:

- kijelzett HP: `17.5K`;
- statikon: vörös szív `30`;
- célcsík közepe kb. 268 pixelre volt;
- a képi növény-/fakonfidencia 0,295;
- saját HP 778/778, sérülés nem történt.

A mentett `frame-00088.png` fontos térképi kontextust mutat. A karakter a zöld oldalon,
egy magas fa–fém kapuoszlop mellett áll, a 17.5K-s növényi cél pedig a narancsszínű
terület jobb oldalán látszik. A bal HUD-on közben `UNLOCKS AT ISLAND 4` szerepel.

## Következtetés

A cél jelenleg nem egyszerűen „túl erős”, hanem a lezárt Island 4-oldalon áll. A
közvetlen megközelítés ezért nem adna tiszta harci kísérletet: a fal távolságplatót,
elakadást vagy a képszélen torz célazonosságot okozna. A bot helyesen a céllal ellentétes
irányba távolodott, majd hat menekülési swipe után újratervezett; a saját HP végig 778.

A `+30` szívikon alapján a cél potenciálisan nagyon értékes max-HP forrás. A 17.5K
névleges HP miatt nyers 693 DPS-sel kb. 25 másodperc lenne a védelem nélküli elméleti
ölési idő, de a támadás, armor és elérhetőség ismeretlen. Ezért az Island 4 valódi
feloldása után külön, teljes HP-s kontrollált mérési sávként kell kezelni, nem a zárfalon
keresztül próbálni.

## Nyitott kérdések

- A `30` minden öléskor +30 max HP-t ad-e, vagy más szívmechanika?
- A növényi cél passzív fa, távolsági ellenfél vagy közelharci boss?
- Island 4 feloldása melyik fejlődési küszöbhöz kötött?
- A 17.5K azonos-e a korábban látott 67.5K-s alsó képszéli növényi boss egy gyengébb
  változatával, vagy külön célosztály?
