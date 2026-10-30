# Szomszéd 253 mint hamis boss és a független statikonőr

## A hiba

A `20260829-052132-play` sűrű Island 4-csoportjában a normál, 4-szíves,
253 HP-s humanoidok `bossEvidence` mezője röviden felvillant, majd eltűnt.
Ez sok hatswipe-os menekülést indított, noha a játékos végig 747 HP-n maradt.

A célok naplójába felvett `levelOCRNumbers` mezővel az egyképes replay közvetlenül
megmutatta az okot:

- `frame-00052`: cél-HP OCR `253`, statikon-OCR szintén `253`;
- a szomszéd HP-felirata belógott a cél statikonjához használt OCR-régióba;
- a régi `levelNumbers >= 100` szabály ezt független, 500-as boss-statikonnak hitte.

Külön zajminta volt a `frame-00236→00240` során a `-3390`/`-3630` lebegő
sebzésszám. A régi HP-feldolgozó a mínuszjelet eldobta, így 3390-es hamis boss-HP-t
alkotott egy vizuálisan 253 HP-s célból.

Az első javított élő kör új alakot mutatott: `053247/frame-00064` esetén ugyanaz
az előző képen biztosan 4-es szintű 253 HP-s cél `2537` lett. Az előző célazonosság,
azonos ismert szint és a beragasztott 253 együtt bizonyítja, hogy ez toldalékos OCR,
nem új 2,537K-s lény.

## Javítás

A háromjegyű statikon csak akkor bossbizonyíték, ha értéke nem szerepel ugyanazon
cél saját HP-OCR-jében. A mínuszjellel kezdődő OCR-sor nem lehet megmaradt cél-HP.
A diagnosztikában minden célhoz tartósan naplózzuk a nyers `levelOCRNumbers` listát.

Az alacsony HP-hoz ragadt nagy számot csak akkor szűrjük, ha az előző és aktuális
cél ismert szintje azonos, a megjelenített HP-t a célmemória változatlanul tartja,
és a nyers nagy szám az előző HP 1–2 jegyű toldaléka. A valódi `1927` ismeretlen
szintű elit ezért nem esik ki; egy valódi célcsere legfeljebb egy képkockás,
üldözés nélküli megerősítést igényel.

## Bossprioritás

A `032640/frame-00058` regresszió külön döntési hibát mutatott: a 923 HP-s boss
272 px-re látszott, de egy 5 HP-nak olvasott normál cél 160 px-en átvette a
`nearestThreat` helyét, ezért nem indult bossmenekülés. Most bármely 360 px-en
belüli boss elsőbbséget kap a közelebbi normál fenyegetéssel szemben; 360 px-en
kívüli boss továbbra sem rejti el a ténylegesen közeli normál támadót.

## Regresszió

- `052132/frame-00052`: hamis bossmenekülés helyett Island 4 kifelé átló;
- `052132/frame-00238`: a `-3390` többé nem boss, kifelé átló;
- `002956/frame-00140`: a csonkolt 4.31K/500-as boss továbbra is menekülés;
- `033954/frame-00014`: az 1.22K és a 923 boss továbbra is menekülés.
- `032640/frame-00058`: a 923 HP-s boss most a közelebbi 5-ös cél mellett is
  azonnali menekülést ad.

Az első élő ellenőrzés `20260829-053247-play`, a toldalék- és bossprioritás-javítást
tartalmazó következő futás `20260829-053646-play`. A szabály kizárólag a
bizonyítékforrások összeragadását szűri; a valódi nagy HP-t és a HP-től eltérő
nagy statikont nem gyengíti.
