# Normál gyűjtés újra és fehér pályaháttér — 2026-11-02

## Felhatalmazás és gyors újraindítás

A user előbb külön engedélyezte a további számolvasás javítását, majd kérte:
„indítsd vissza a gyűjtőt, egyelőre engedjük el a más fajta kattintás kérdését”.
Ez feloldja a346tesztelésiSTOPot. Nem kezdünk új háttérinput-próbát, nem
állítunk be új backendet vagy globális fallbacket; normál butcher-hero start,
előző statfutás megtartva. Nincs --new-run, recovery, naplóátírás vagy startup.
Legacy bot/heartbeatPAUSED; kizárólag a meglévő Free/kristály/konkrét lejárt
DiamondLeague ág engedélyezett, nem mozgás/harc/vásárlás/eladás/fejlesztés.

14:17:26.931Zwatcher_resumed, saját előtérben tartott runner-session65109,
indulóworker66381.14:22:43.348Z2D5A406C saját Pierce565UIigazolt; később
új Health18700/Regen84 és más claim is van. Nem csak aPIDet figyeltük:
friss játékforrás com.multicastgames.butcher/PID72012/window2198, ok/hud.
A runtimeJSON továbbra elsődleges, ezek történeti indulási adatok.
Offline olvasójavítás és tesztelés alatt végig maradt gyűjtés.

## Bizonyított hiba és az első piros teszt

A346-ban megőrzött három eredetiPNG kézi címkéje változatlan700/565/817.
Új unit közvetlenül a számolvasót és teljes RewardVisioneredményt is
ellenőrizte:6hiba, nil/nil/1 a várt700/565/817helyett. Nem új inputmód
vagy glyphváltozás okozta: fehér világfolt került a számROI jobb szélére,
és a maxHeight/baseline a nagyobb23–35pxfoltot választotta a15–16pxfont helyett.
700-nál a világfolt fizikailag összeért a végső0 fehér pixeleivel is.

## Szűk végső javítás

Az eredeti fehér maszkon8szomszédos komponensezés után CSAK a ROIperemét
érintő fehér komponenseket bontjuk. E komponens egy fehér pixelét csak akkor
tartjuk meg, ha ugyanazon sorban mindkét vízszintes irányban sötétfontkontúr
van (maxRGB<80), max(3,ceil(képmagasság×.015))pixelen belül. A távolság
a rögzített HUDfontmérettel együtt skálázódik; nem jutalomértékből számítjuk.
Az ép belső glyph-ek változatlanok. Ezután új komponensezés és a korábbi
baseline/decimal/normalizálás/mintamatching fut, változatlan hiba<0.30 és
margin>0.035 kapuval. A fix ROI, parser és59glyph/20forrású modell változatlan.
ModelSHA256:a8a20b416ee41f3354d3f609ec2d88d2a78369c515b42e422480187c9641dd9a.

Nem dobjuk el egyszerűen a peremkomponenst: a700utolsó0-ját visszanyerjük,
nem rövidítjük70-re. Nincs OCReredményből címkefelülírás, jutalomtípusból
értékbecslés, korábbiösszeg-cache vagy acceptance-küszöblazítás.

## A fejlesztés közben feltárt prototípushibák

Az első, minden fehér pixelre alkalmazott kontúrszűrés a külön Regen84képen
szétbontotta volna a4keresztvonalát és8-at adott. A szomszédsoros próbálkozás
ezt javította, de a Health18.7Kképen visszahozott egy zavaró komponenst.
Mindkét képet fejlesztési névre jelöltük, nem állítjuk utólag heldoutnak.
A végső megoldás megőrzi a belső betűket, így mindkét eset helyes.

A végső kód elkészülte után két külön régebbi claimet választottunk, és
vizuálisan címkéztünk:40659136Health18.7K, B83B5C92PierceDefense624.
Ezeken már nem hangoltunk; változatlan kódot ellenőriznek. Nem újfont-
kalibrációk, hanem külön átvételek. A hét eredetiPNG a63képes fixkorpuszban;
az öt első fejlesztési és két utolsó validációs szerep a referenciaREADME-ben.

Négy új unit: három eredeti hiba teljes számával;84és18.7Kmegőrzése;
két külön validációsclaim; és származtatott negatív. A negatív az817képen
csak a valódi kártya/szám területét törli, a korábban1-nek olvasott eredeti
világfoltot megtartja: nem lehet belőle szám. Mesterséges, nem új valódi kép.

## Betöltés és ellenőrzés

A teljes `make test` sikeres:94Swift+79Python+68Node=241teszt,7JSsyntax.
Külön `.build/ocr-347` releasefordítás19.83s alatt sikeres, mind7újkép
helyes a tényleges release inspect kimenetében is. Az aktív resourcebundle
bitazonos a staginggel, modellhash egyezik. A régi gyűjtő a tesztek alatt
végig futott; idle crystal/event és friss ok/hud állapotban saját launcherstop.
Watcherstop14:34:17.110Z→normálresume14:34:18.405Z,1.295smért szünet.
Csere előtt régi bináris külön helyi backup, új végleges fájl atomi rename;
releaseSHA256:63dbf97872e000ee08404fc0cbdfc627154c7859a2fa4f19cc7f0e7403bdc261.

Saját új közösrunner-session16390, indulóworker71640, friss ok/hud és
verified gamePID72012/window2198,8765healthPASS.14:34:39.284Z5B2A793E új
Health18700UIigazolt, eredeti utóképen explicit+18.7Kszív vizuálisan egyezik.
Ez valódi új normálgyűjtés, nem a régi fehérpálya-helyzet élőismétlése:
a játék aktuálisan más pályarészen van. A konkrét7esetet mentett képek és
tesztek igazolják, nem általános hibamentességet. FrissruntimeJSON elsődleges.
Commit/push-kapuk közben a gyűjtő maradjon futva.

Nincs további történeti reward_corrected vagy reconcile; a három korábbi
346pontosítás nem ismétlődik meg. A343külsőmonitoros geodeügy külön marad,
ez a javítás nem tekinthető annak megoldásának.

346CI:4724e2f/run41460011737 completed/success,14:17:57Z. Ez csak az előző
kör igazolása;347távoli eredményét majd a sajátcommit futásából ellenőrizzük.
