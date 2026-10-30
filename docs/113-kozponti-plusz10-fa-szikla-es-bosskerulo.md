# A központi +10 fa szikla- és bosskerülője

## Stabil helyi térképpont

A `081746-play/frame-00316→00328` és a következő `082820-play` futás 176–190.
döntése ugyanazt a célgeometriát mutatja:

- 10-es szintű, 174 HP-s, piros szívikonos fenyő a kép felső-bal részén;
- a hős a célhoz képest lent-jobbra;
- közvetlenül közöttük nagy szürke sziklatömb és több fenyő;
- balra kék sátor/kerítésszakasz, fent türkiz Deep Mines sín;
- az egyenes közelítés 290→284/285 pixelen megáll.

A bot első tartós kerülője balra-le indult. Röviddel ezután több ezres boss vált
láthatóvá, ezért a bossőr helyesen megszakította a farmot és jobbra-le menekített.
Ez nem a fa veszélyessége, hanem az első kerülőoldal kockázata.

## Döntés és következő próba

A meglévő oldalváltó algoritmus megőrizte a következő kerülőjelet, de a hibaciklust
is megőrizte; a `082820/259` emiatt ellenoldali próba nélkül hosszú kiszakadás lett.
Javítás: aktív kerülőt félbeszakító boss eggyel visszalépteti a hibaciklust, az
oldalváltó jelet viszont megtartja. A következő azonos fa-megközelítés így az
ellenkező, jobbra-fel kerülőt kapja.

Sikerkritérium:

1. a következő kerülő után a távolság 284 alá csökken;
2. 180 pixelen belül a szívfa-prioritás megtartja a célt;
3. 95 pixelen belül az automata támadás befejezi a 174 HP-t;
4. közvetlen +10 effektus után a tartós maximum 768 fölé nő, és a
   maximumszekvencia lenullázza a jutalomhiányos módot.

Ha a második oldal is bosst vagy változatlan 285 pixelt ad, a fa helyi
megközelíthetetlenségi aláírást kap, és a farmkör másik célra vált.
