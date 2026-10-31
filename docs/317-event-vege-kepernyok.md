# Esemény vége: NO,THANKS → CONTINUE → HUD — 2026-10-31

## Engedély és képi tények

A felhasználó két eredeti képet adott, és kifejezetten kérte a rajtuk
látható elutasításokat. Első kép: **DIAMOND LEAGUE**, **Time is over**,
LEAGUE PROGRESS, lent pink **NO, THANKS**. Fölötte két zöld, árjelölt
időhosszabbítás van: ezek nem engedélyezett célok. Második kép:
**EVENT ENDS!**, **DIAMOND LEAGUE**, CRYSTAL REWARDS és arany **CONTINUE**.
A felhasználó közlése szerint ezzel térünk vissza a játékhoz. A két kép
nem ugyanaz a modal; a másodikat önállóan is kezeljük kéziNoThanks után.

Eredeti, változtatás nélküli referenciák:

- [Lejárt esemény ajánlata](references/2026-10-31/event-end/offer-user.png).
- [Eseményösszesítő](references/2026-10-31/event-end/summary-user.png).

A kérést nem általánosítjuk reklámra, vásárlásra, bármelyCONTINUE-ra,
másleague-re vagy ismeretlen modalra. A bemutatott statok nem automatikusan
a Freejutalomnaplóba tartozó nyereségek. Nincs eladás, fejlesztés vagy költés.

## Implementáció és egy fontos cáfolat

EventEndVision: alsó pink/arany gomb pixelaránya után kis helyiTesseract
sávokban teljes szövegegyezés kell. Offer: NO THANKS + DIAMOND LEAGUE +
TIME IS OVER + LEAGUE PROGRESS. Summary: CONTINUE + EVENT ENDS +
DIAMOND LEAGUE + CRYSTAL REWARDS. Szám, ár, statösszeg nem célkoordináta.
A gomb célpontja a megfelelően felismert alsó gombon belül van, távol
a zöldáras ajánlatoktól. A feliratokhoz tartozó képernyő is kötelező.

**Képes tesztben cáfolt feltevés:** az offer nem feltétlen gameHUDVisible=false.
A saját pinkgomb és zöldprogressziós csíkja átengedi a korábbiHUDszínkaput.
Ezért a konkrétevent felismerése aHUDvisszatérés elfogadása és a másik
két automatizáció előtt fut. Egyedül a régiHUDheurisztikára bízni a panel
eltűnését nem lenne helyes.
Ha a nagy alsó gombszín megvan, de a kontextus olvashatatlan/takart,
az eredményunknown, nem a régiheurisztika szerinti tévesHUD-visszatérés.

EventEndFlow: két stabil kezdőkép, majd a cél aktiválás utáni új képi
ellenőrzése; azonos ablak, maximum3s képéletkor, STOP- és kézi egérvédelem.
Legalább1s két elküldött próbálkozás között, legfeljebb3küldöttkattintás
lépésenként és60s teljes folyamat. Ismeretlen kép nem ad kattintást;
lejártkeret blokkot eredményez, nem vakkattintást. KéziNoThanks után
elfogadja az önállóan azonosított összesítőt; kéziHUD-visszatérés feloldja
a sajátvárakozást, de nem gyárt automatikusContinue-sikert.

## Koordináció és könyvelés

Prioritás: **event → kristály → Free**, egyetlen inputgazdával. Már az
első ismert eventképen felfüggesztjük a másik két automatizáció inputját,
akkor is, ha az egér lenyomása miatt az eventfolyamat még nem indulhat.
A Freejelölt törlődik, a megszakított függőclaim claim_unconfirmed lesz.
Nem állítunk Freeátvételt abból, hogy az eseményképernyő után eltűnt egy
korábbi kártya (közben lejárhatott). Ez tudatos konzervatív könyvelés.

Két frissHUD-kép után a közösfigyelő visszaadja a normál gyűjtést;
újra frissFreejelölt és a szokásos átvétel-ellenőrzés kell. A kristály
állapotát nem nyitjuk meg vakon és nem léptetjük eventkattintással.

Külön napló: `data/event-dismissals/events.jsonl`, eredeti képek:
`data/event-dismissals/evidence/`. Események: event_started, event_screen,
event_click_validated/sent/rejected, event_blocked, event_dismissed_ui,
event_returned_to_hud. Az utóbbi nem teljes automatikusContinue-bizonyíték.
`state.eventEndPhase` mutatja a fázist. Eseménybezárás nem kerül a
Free-statokba vagy a kristályjutalmakba.

## Ellenőrzések

10EventEndTests a közös `make test`, commit, push ésPR-kapu része:

- Mindkét eredeti kép rögzített elvárással; erőltetettHUDtrue esetén is
  a helyesmodal nyer; célpont nem a fizetős gombsor.
- Mind35korábbi Free és12kristály referencia negatív erre a funkcióra,
  beleértve a kristály sajátCONTINUE-ját.
- Teljes NO THANKS→CONTINUE→kétHUD replay, pontos két elküldött művelettel.
- Önállósummary, kézimozgásvárás, kéziállapotváltás/visszatérés, egyszeri
  lezárás,1s újrapróba/3küldés, unknown/timeout.
- A valóban használt EventEndInputPolicy az elsőmodalképet is lefoglalja;
  nem adhatja át annak megtévesztőHUD-ját a Freeigazolásnak.
- Változottablak, STOP, negatív/3s-náltöbb képéletkor preclickelutasítás.
- Szintetikus, memóriában takartfejléc a valódi képekből: gombszín megmarad,
  kontextus eltűnik → unknown, nem tévesHUD vagy kattintás. Ez nem új valós
  screenshot, hanem külön hibainjektálás; az eredeti referenciák változatlanok.

Teljes helyi kör:52Swift+16Pythonstats+3Gitkapu+10supervisor+31Node =
**112teszt**, további7JSszintaxisellenőrzés, mindPASS. A képek ugyanakkor
kalibrációs források is; új, független élő képpel bővítendők, nem nevezzük
általános modal- vagy felbontásvalidációnak. A GitHuberedmény külön követendő.

## Betöltés és valós állapot

Az eddigi figyelőt a különreleasebuild/tesztek alatt nem állítottuk le.
Előre fordított bináris betöltése után `--resume-run` ugyanazt a logikai
statfutást folytatja. Checkpoint2026-10-31T18:10:34Z: supervisor16250,
worker16284, tartóssession36072. **Ekkor a játékablak nem volt található**,
így az újverzió várakozott. Ez történeti betöltési megfigyelés, nem későbbi
futásiállapot-állítás. Nem állítunk sikeres képernyőbezárást pusztaPID-ből.
Aktuális állapot mindig a frissstate/supervisor és folyamatlista, nem
ezeknek a checkpointPID-knek a későbbi feltétlen újrahasználata.

Később a játékablak újra elérhető lett, a korábbi build ismét gyűjtött.
Végső betöltés18:17:20Zsupervisor18213/worker18248/session63806,
--resume-run;18:17:37.387ZPierceDamage575UIigazolás, claimAE1DB63B.
Az utóképet vizuálisan is ellenőriztük: explicit+575 és nyíl látszik.
Helyi bizonyíték:
`data/free-rewards/evidence/AE1DB63B-86C5-43F9-BC9F-DF0A16ADC370-after.png`.
A konkréteventképernyő ekkor már nincs nyitva, az eventnapló még üres,
így a két lépés élesautomatikus bezárását nem állítjuk. A112tesztes
csomag sikeres, a következő valódi popup megjelenésekor külön éles bizonyíték
keletkezhet. A program és saját felügyelete futva marad.
