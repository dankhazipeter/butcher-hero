# Kézi útbemutató — előkészítés, 2026-09-19

**21:16 felülírás (274):** a felhasználó közben bejárta az utat; ezt nem
rögzítettük. Önálló folytatást kért, heartbeat ACTIVE. Az alábbi várakozás
már történeti, nem érvényes szüneteltetési utasítás.

A felhasználó felajánlotta, hogy körbeviszi a karaktert a járható úton.
A bot210801/16a kőív/fal előtt, saját7060;210905frisskép is készült.
A célválasztó már fegyverőrt követett, de a geometriai navigáció nem oldotta
meg az átjárást. Nem állítjuk, hogy a fal problémája már megoldódott.

## Szünet és rögzítés

Önjáróinput leállva; nincs élő botfolyamat. A percenkénti heartbeat az app
eszközévelPAUSEDállapotra állítva és visszaellenőrizve. A kézi bemutató
indulási jelzésére várunk. Addig nincs önjáró újraindítás.

Új `record --seconds 180 --interval 0.15` mód: csak a játék ablakát menti
PNG-kbe, időbélyeggel. Nem hív vezérlőt, fókuszváltást, kattintást/swipe-ot
vagy stratégiai döntést; az OCR késleltetése nincs a felvételi hurokban.
Ugyanaz az egyetlen élő képrögzítő zár érvényes. SIGINT szabályosan lezárja.
A0,15sbeállítás célzott várakozás, nem garantált képfrekvencia; a tényleges
időbélyegekből mérjük, nincs kitaláltFPS.

## Feldolgozási terv

Indulópont, kanyarok, szűkületek és végpont képi ellenőrzése; folyamatos
elmozdulásmérés, hibás/ugró képpárnál megszakított lánc. Terep és minimap
együttes visszaazonosítás. Irányított útpontokból követhető folyosó, nem a
kézi swipe-idők vak visszajátszása. Fordított út csak külön bizonyítékkal.
Rögzítés végén a felhasználó „kész” jelzésére megállunk és elemezzük.
Jelenleg még nincs rögzített emberi demonstráció, csak az előkészítés.

BuildPASS.211253-b951a54d-record:1másodperces műszaki próba3PNG-vel,
időbélyegesinputExecuted:falseeseményekkel; szabályosan lezárult.
Nem útbemutató és nem garantált3FPS. A tényleges felvétel az indulási
jelzés után kezdődik; most nincs futó felvétel vagy játékinput.
