# Helyi farm elsőbbsége és K-kijelzés — 2026-09-19

## Hipotézis és javítás

A `120300-play` 28–31. képén biztonságos, közeli cél látszott, mégis a távoli
koponya irányába mozgott a bot. A koponyaág túl korán futott. Most az ablak
szélességének 62%-án belüli kiválasztott farmcél és háromdöntéses célmemóriája
elsőbbséget kap. Ismert, fejlődésig tiltott boss elérése 120 döntésre némítja
a koponyaágat. A HP-/harci biztonsági őrök változatlanul előbb futnak.

Az alsó aréna felé vezető sziklafal-kitérőt korábban csak hosszú (óra+perc)
időzítő indította. Négy statikus döntés azonos térképi és biomfeltételekkel
most szintén indíthatja; a hetek múlva lejárt időzítő nem lehet kötelező landmark.

**Elvetve ugyanebben a ciklusban:** a fenti statikus belépőfeltétel túl tág.
A `120928-play/32–47` a kaktusz melletti háztetőbe hajtotta a karaktert.
A módosítást visszavontuk; narancs biom + koponyairány nem egyedi helyazonosító.
Az eredeti órás-időzítős makró sem általános útvonalbizonyíték.

## Élő ellenőrzés

`docs/runs/20260919-120502-play`: az első döntés valóban a 632 HP-s helyi célhoz
indul, majd 136/253 HP-s célokat közelít, támadási távolságnál vár. Az izolált
`120502-replay` nem állította elő ugyanazt a temporális célfelismerést, ezért
önmagában nem sikeres regressziós bizonyíték; az élő szakasz igazolja az ágat.
A futás végén vizuális 4,49K és elfogadott 4490 maximum. Ez kerekített kijelzés,
nem a rejtett pontos egész HP bizonyítása. A 765 HP-s kaktuszt kerítés választja
el; a közelítés 104 px-nél stagnál, faljárás indul. Ez navigációs hiányosság,
nem harci vereség. Következő ellenőrzés: `120746-play`.

## HP-kerekítés javítása — ellenőrzés alatt

A korábbi ±60-as, +40 alatti visszakerekítés a 4450 → 4,46K → 4,47K növekedést
elnyelte. Egy tizedes K-alaknál ±50, két tizedesnél ±5 a megtartási tolerancia.
Így a bizonyított 1299 megmaradhat 1,3K mellett, de 4450 nem azonos 4,46K-val.
K-alakból kis maximumnövekedéshez öt friss, egyező OCR kell. A +31…+60 rés
is az ötképes nagyobb-növekedési konszenzushoz kerül. Replay és élő ellenőrzés
eredményét a következő szakaszban rögzítjük; addig ez nem lezárt mérés.

## További élő eredmények

- `120746-play/33` már Venom Shard 13-at mutat az alsó aktív helyen; a pontos
  adó ellenfél nincs izolálva. Bat Cleaver 11 maradt. A 428-as őr eltűnését
  35. képtől látható állapot követi; a feliratra a bot hibásan 1-et olvasott.
- `120927-replay` a teljes 48 képes 120746-sorozaton lefutott; HP 4490 stabil,
  közeli célok elsőbbsége és akadálykerülés megmaradt. Az új HP-növekedési ág
  nem kapott új növekedést ebben a sorban, tehát ez csak stabilállapot-regresszió.
- `120928-play/3–19` a tartós akadálytérkép nyugati kerülője után a 765-ös
  kaktusz 87 px-re került. `20`: eltűnt, a helyén 6m0s kör, +1 és 1,03K
  zöld nyilas effektus. A kerítés mögötti cél legyőzése bizonyított; a jutalom
  nem szív, hanem piercing stat. Saját HP továbbra is 4,49K.
- `120928-play` felügyelten megszakítva a rossz helyen elindult déli makró
  miatt. `121038-nudge`: négy félmásodperces nyugati swipe, következő kép kell.
