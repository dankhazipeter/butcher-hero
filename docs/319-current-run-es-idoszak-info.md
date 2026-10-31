# Current run és az időszakgombok infóablaka — 2026-10-31

## Pontosan mit jelent és mikor indul újra?

A kérés: magyarázzuk el aCurrentrun/Mostani futás nézetet, és a gombok
mellett legyen egy kis infóikon tooltip vagy modal tartalommal.

Bizonyított forrás: `dashboard/server.py` time_window függvénye a napló
legutolsó `watcher_started` bejegyzését használja kezdésnek. Ez egy logikai
gyűjtési munkamenet, nem a jelenlegi programfolyamat, játék vagy chat élettartama.
Kezdőjel nélkül a megőrzött napló legkorábbi idejére esik vissza.

A collector `--resume-run` kapcsolója meglévő futásnál `watcher_resumed`
bejegyzést ír. Ez a kezdetet nem változtatja meg; a felügyelő technikai
újraindulásai és az általunk kért folytatások ezt használják. Folytatás
nélküli normál indítás új `watcher_started` jel, így aCurrentrun nézet
onnantól újrakezdődik. Új, még futásjel nélküli adatkönyvtárban a resume
sem talál ki korábbi futást: az első kezdés akkor keletkezik.

Nem nullázza aCurrentrunt az éjfél, lapfrissítés, másik szűrő, játékújranyitás,
eseményvége, kristálynyitás vagy önmagában a gyűjtő leállítása. Szünet után
az újraindítás módja számít: resume megőrzi, újsession új kezdet. A korábbi
adat sem újrun esetén nem törlődik, aMinden nézetben továbbra elérhető.
A darabszám nem az utolsóprocessz néhány perce, hanem a
megőrzött teljeslogikai időszak; nem indítottunk kitalált nullázást.

Read-onlyAPI megfigyelés a fejlesztés elején:
range.from=`2026-10-30T16:50:44.381Z`, az oldal Europe/Bucharest zónájában
október30.18:50:44. Ez időponti megfigyelés, nem beégetett kezdődátum.
A Ma a kijelzett időzóna naptári napja, az1/24óra gördülőidőablak,
Minden a teljesmegőrzött napló, a dátummezők egyéni időszakot választanak.

## Megvalósítás

A gyorsgombok mellé külön, kerek i-gomb került, `type=button`,
`aria-haspopup=dialog`, `aria-controls` és fordított címkével. Nincs rajta
data-range, tehát nem választhat időszakot vagy indíthatfetch-et.
NatívHTMLdialog a világos/sötét témaszínekkel, mobilon függőlegesen
görgethető, vízszintes kilógás nélkül. Escape, sajátX és valódi háttérkattintás
bezárja; a belsőpadding nem háttér. Bezáráskor azikon kapja vissza a fókuszt.
A natívmodal teszi inertté a mögöttes vezérlőket; nincs új külső könyvtár.

Tartalom mindkét különHU/EN nyelvi fájlban: aCurrentrun jelentése, miindít
újkezdetet, mi nem, a többiidőszak, aFree-only statisztikai hatókör és
lenyitható technikaiwatcher_started/resume magyarázat. Adata-i18n rendszer
fordítja a tartalmat ésARIA-címkéket; nem injektálunkHTML-t fordításból.
Nem változott a backend, az API, a számlálás, a napló vagy a runhatár.

## Ellenőrzés

- 3újNode-regresszió a valódiapp.js és az index.html statikus hookjaiból:
  nyitás/idempotencia/zárás/fókuszkérés; belső- és háttérkattintás/natívEscape
  nincs felülbírálva; elsőangol betöltés és nyelvváltás megtartja az állapotot,
  szűrőt, számlálót és fetchdarabszámot.
- 3újPython-regresszió: stop+resume+újprocessrunID+éjfél+event/kristály nem
  tolja a kezdést; új sessionnél Currentrun0, de Alltime megőrzi az előzőt;
  kezdőjel nélküli napló fallbackje.
- Korábbi fordításikulcs/ARIA/szűrő- és grafikonállapotteszt továbbra fut.
  Teljes kapu:53Swift+19Pythonstats+3Gitkapu+10supervisor+34Node =119teszt,
  további7JSszintaxisellenőrzés.

A meglévő in-app böngésző kapcsolata `browser.user is unavailable` hibával
nem volt vezérelhető. Ehelyett külön ideiglenesprofilos headlessChrome
csak a helyi dashboardot nyitotta meg; nem érintett felhasználói böngésző-
profilt, bejelentkezést, egérkurzort vagy játékablakot. A teszt végén saját
Chromefolyamatát lezárta. Valódi nativeUI ellenőrzések: EN1280×1000 és
HU375×812 dialoglátható, nincs vízszintesoverflow; Escape zár és azikonra
fókuszál; Xzár; képeket vizuálisan is megnéztük. Helyi, nem verziózott
ellenőrzőképek: `.build/range-help-en-desktop.png`, `.build/range-help-hu-mobile.png`.

A gyűjtő21386 és annak sajátfelügyelete végig futott, nem indult újrun,
nincs új játékinput vagy képrögzítés ettől aUIkörtől. A szerver a statikus
fájlokat kérésenként olvassa, újraindítása nem kellett. A már megnyitott
oldalon egy lapfrissítés szükséges az új HTML/JS/CSS betöltéséhez; a
lapfrissítés természetesen továbbra sem nullázza az adatokat.
