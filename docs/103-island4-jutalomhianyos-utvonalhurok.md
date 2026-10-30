# Island 4 jutalomhiányos útvonalhurok

## A hiba nem fizikai beragadás

A `docs/runs/20260829-070657-play` futásban a karakter a 198→240., majd a
300→360→420→442. mentett képek között többször jelentősen elmozdult. A 747 HP stabil
maradt, a program nem fagyott le, mégsem szerzett jutalmat. A minimap piros iránya a
zöld Island 4-előtérből tartósan balra, a lezárt narancssárga oldal felé mutatott.

Az ismétlődő ciklus:

1. a minimap balra vezette a karaktert;
2. a zárfal-/statikusőr kifelé vagy a fal mentén terelte;
3. valódi kameramozgás miatt a rövid útvonalhűtés sikeresnek minősült és feloldódott;
4. a következő képen ugyanaz a balra mutató piros pont ismét átvette a vezérlést.

**Biztos tény:** a kameramozgás önmagában nem haladási mutató. A `070657` több mint
700 képkockájában nem volt tartós jutalom, miközben a karakter több terepszakaszt bejárt.

## Fejlődéshiányos területelhagyás

A stratégia külön `decisionsSinceProgress` számlálót kapott. Új jutalomszekvencia
nullázza; felhasználói aktivitás miatti külső várakozás nem növeli.

Az új ág csak akkor indul, ha egyszerre teljesül:

- legalább 150 tényleges döntés óta nincs jutalom;
- látszik az Island 4 lezárt HUD-ja;
- nincs látható biztonságos cél, világ-láda vagy türkiz küldetésút;
- a játékos legalább 90% HP-n van;
- a minimap iránya erősen balra mutat (`x < -0,75`);
- az epizód saját hűtése lejárt.

Ekkor legfeljebb 120 tényleges swipe-on át a lezárt vektorral ellentétes és oldalirányú
komponenst együtt tartja. Új cél, láda, quest-út vagy legalább kb. 70°-kal elforduló
minimapvektor azonnal megszakítja. Három statikus kép után oldalt vált; négy statikus
oldalváltás után visszaadja a vezérlést az általános faljárásnak/Unstucknak. Egy epizód
után 360 tényleges döntéses saját hűtés akadályozza a folyamatos újraindulást.

## Replay

A teljes `docs/runs/20260829-071841-replay` a 150. döntésnél (`frame-00298`) indította
az új ágat. Statikus szakasznál irányt váltott, később pedig változatlanul elsőbbséget
adott a 10-es szintű 174 HP-s célpontnak, a 431 HP-s fának, a türkiz Deep Mines-sínnek
és a bossmenekülésnek. A biztonsági/prioritási regressziók megmaradtak.

## Zöld kapuzseb és hiányzó biomjel

A `docs/runs/20260829-071943-play/frame-00034` sátor–kőfal zsebénél a nagy narancs
szikla ellenére az `orangeRockBiomeVisible=false` volt. A karakter a negyedik fázisban
mégis kijutott: a `frame-00062` már nyílt füves udvart mutatott. Ezért egyetlen statikus
szakasz vagy a biomjel hibája nem elég Unstuckhoz.

A hat valóban sikertelen fázisú Unstuck-kapu ugyanakkor most elfogad egy második, szűk
környezeti bizonyítékot is: lezárt Island 4 HUD + célhiány + erősen balra mutató
minimap. A sikeres kameramozgás továbbra is lenullázza a számlálót, tehát a fenti
`071943` példán nem nyitott volna menüt. Az Unstuck időzárát a 102-es fejezet szerinti
HUD-visszacsatolás védi.

## Aktuális élő ellenőrzés

A végleges kombinált build futása: `docs/runs/20260829-072159-play`. A 0. képen a
karakter még a bedőlt sátor mellett állt, a `frame-00048` már nyílt udvart mutatott.
A 192-es helyi elit ezután az automatikus Unstuckot is kiváltotta. A
`frame-00084→00088→00100→00110→00116` sor explicit halált, medencés 134→717→747
gyógyulást és megmaradó hét fegyvert bizonyított.

Az első élő jutalomhiányos ág a 259. eseménynél indult. A `frame-00258` még sátor és
fák között, a `frame-00286` a központi útnál, a `frame-00302` pedig a Titan-portálnál
mutatta a karaktert. A minimap `(-0,97; -0,25)` körüli bal irányból `(0,05; -1,00)`
felfelé fordult, ezért a 303. esemény szabályosan megszakította a hosszú módot.

Az új minimapirány azonban egy kerítés mögötti, ismeretlen szintű 499 HP-s humanoidhoz
vitt: a fenyegetést 335→164 pixelre hozta, majd statikus kerítésbe futott. Később egy
122K boss is megjelent, amelytől a bot helyesen menekült. Következő javításként a
hosszú ág minimap-elfordulásos lezárása után 80 tényleges döntéses növekvő szabad
felderítés fut; a visszahúzó piros pontot ideiglenesen figyelmen kívül hagyja. Biztos
cél, quest vagy láda megszakítja, a bossőr pedig minden képen megelőzi. A
`docs/runs/20260829-073011-replay` ezt az 499/253 célok és a 122K boss képein igazolta.

Az első élő szabadfelderítéses build: `docs/runs/20260829-073131-play`. Az első utána
szerzett jutalom még mérés alatt van. A 302→346. események között a szabad felderítés
ugyanabba a híd–sátor zsebbe szorult, miközben két kameraállapot váltakozása tévesen
nullázta a statikus fázisszámlálót. A javítás és a bizonyíték külön fejezete:
[104-kameracsuszas-nem-torol-elakadast.md](104-kameracsuszas-nem-torol-elakadast.md).

A következő `074813-play` már a kamerafüggetlen 192-es kapuőr-azonosítóval közvetlen
Unstuckot indított, 310→747 HP-ra gyógyult, majd a `frame-00090` képen fizikailag is
elhagyta a zsebet. A részletes bizonyíték a 105-ös fejezetben található.
