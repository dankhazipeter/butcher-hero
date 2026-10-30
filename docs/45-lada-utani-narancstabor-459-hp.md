# Láda utáni narancstábor és 459 maximális HP

## Közvetlenül látott fejlődés — `20260829-020221-play`

- A világláda átvétele után a hiteles maximum 438 volt.
- A `frame-00078.png` zöld `+4` szívet és 442-es teljes HP-t mutat.
- A `frame-00130.png` újabb zöld `+4` szívet és 446-os teljes HP-t mutat.
- Mindkét ölés az Island 4 felirat közelében lévő narancs tábor elérhető oldalán történt.
  A felirat tehát nem jelenti azt, hogy a teljes narancs terület zárt; csak a perspektivikus
  sziklafal túloldalát és az oda vezető irányt kell kizárni.

## Következő élő kör — `20260829-020635-play`

- A futás első képe 450-es teljes HP-val indult. A `446→450` közti +4 lépcsőre nincs
  elmentett jutalomfelirat, de a közvetlenül előtte ugyanott zajló farm és a korábbi
  ismételt +4-ek alapján **erős következtetés**, hogy még egy 4-szíves humanoid halt meg.
- A sűrű csoport a 450-es maximum mellett 392 pillanatnyi HP-ig sebezte a karaktert.
  A frisssebzéses visszavonulás működött: a bot eltávolodott, majd harcon kívül
  visszagyógyult.
- A `frame-00016.png` közvetlen zöld `+4` szívfeliratot mutat 435 pillanatnyi HP mellett;
  a `frame-00018.png` már teljes 454 HP-t igazol. Ez biztos `450→454` maximumnövekedés.
- A 20. eseménynél egy 1-es szintű kaktusz 76 HP-n látszik, utána eltűnik; a 23. esemény
  és a `frame-00022.png` teljes 459 HP-t mutat. A köztes jutalomfelirat nem került a
  kétképenkénti mentésbe, ezért a `454→459` **erős következtetéssel** a kaktusz +5
  szívjutalma, miközben maga az új 459-es maximum biztos.
- A `docs/bot-state.json` tartós értéke 459-re frissült.

## Taktikai következmény

A tábor kiemelkedően jó fejlődési hely, de nem veszélytelen: több közeli cél össztüze
egy rövid megközelítés alatt a HP kb. 13%-át elviheti. Az aktuális stratégia ezért
megtartja a 95%-os frisssebzéses menekülést, majd teljes gyógyulás után térhet vissza.
Az elérhető oldalon lévő 136 HP-s kaktusz és 253 HP-s, 4-szíves humanoid továbbra is
farmcél; a bal 36%-os Island 4-szűrés csak a ténylegesen fal mögötti célokat zárja ki.

## Következő mérés

- Egy új kaktuszölésnél a `+5` felirat közvetlen mentése és OCR-je.
- A világláda `+2` kék fejsze jutalma utáni tiszta normál találati szám.
- A táborban szerzett HP/perc és a sérülés/ölés arány automatikus összesítése.

Utólagos folytatás: ugyanennek a futásnak a `frame-00376.png` képe újabb közvetlen
`+4` szívet és 463 HP-t igazolt; lásd a 46. tudáslapot.
