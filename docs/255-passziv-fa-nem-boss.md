# Passzív kis fa nem boss — 2026-09-19

180327-observe/0:5,95K, a20szíves fa2s körön.180354-play/6friss5,97K,
az előző20szíves cél ismét legyőzve.21képen a923HP/4fejszés fa teljesen
látható a játékos alatt, de13–40a navigáció vár. Felügyelet megszakította.

Konkrét ok: a minden800+HP-t bossnak jelölő régi szabály felülírta a
0,65lombbizonyosságot. Ettől a passzív fa közeli fenyegetéssé vált.
A kisőrpróba másik kapuja a fejszés fát nem engedte elindítani aktív
peremcél mellett; az eredmény sem farm, sem harc, csak várakozás volt.

Új szűk PassiveTreePolicy: friss és simítottHP1–1600, legalább0,45lomb,
0,03jutalomikon,0,12csíkkeret, nincs független bossjel. Csak együtt
oldják a numerikus bossjelölést. Nagyfa, csonkolt nagy nyersHP, hiányos
szám és humanoid nem kap kivételt. A kisőrkutatás nem próbál fát bossként.
400px-en belüli igazolt kisfa a korábbi szigetmakró előtt farmelsőbbséget kap.

180354/9a régi türkizsín-követés is átcsúszott a navigációs szűrőn;
ez a megfigyelt ág isV2-hez került, nem ad közvetlen vak sínkövető inputot.

Build, hétpasszívminta-egységteszt,180354/21replay és kisőr/DOCregresszió
PASS.6kép külön visszanézve:+20szív,3m58s kör és5,97K ténylegesen látszik.

## Élő eredmény

180725/1délen kontaktus a923HPfával,2képen516és748sebzés, fa villan;
4képen helyén3m57s új kör. Ugyanott **Bat Cleaver12,550→600**,30m0s
fegyverőr-kör.6a179HP-s kisfa is516találatot kapott. SajátHP5,97K,
Phantom4+Venom18maradt felszerelve; Bat12tartalék, DPS-cserét nem állítunk.

17–39új időzítő-takarás,39képen a29m27s kör a saját5,97K-ra lóg.
Az egyszer/futás próba már12képen elfogyott, pedig13–16közben friss teljes
HP-mérések voltak. Következő javítás: epizódhoz kötött próbabüdzsé;
két egymást követő friss95%+HP-mérés újraélesít, két próba között legalább8s.
Friss szám nélkül nincs ismételt vak mozgás; a próba önmagában nem gyógyulás.

Próbabüdzsé-egységteszt, korábbi órástimer-replay és percestimer-replay
PASS; továbbra nincs ismétlés friss szám nélkül.181027élő körben a korábbi
takarás már megszűnt, új büdzsé-újraélesítés pozitív esete még nem volt.
4–9egy másik rövid pixel-HPtakarás még várakozást okozott, majd10-től
továbbment.17képen a szélmalmot északról kerüli, élő431/20szívfa;
21újra125px-re. Ez megközelítés, ezen30s-alatt új jutalom még nem igazolt.

181121/0már**5,99K**, a431/20szíves fa helyén**7h48m**. Az utolsó
181027input utáni automata ütés két futás közé esett; új találatképet nem
állítunk, de a+20kijelzésváltozás és a fa eltűnése/időzítője együtt igazolt.
Ez a harmadik mai megfigyelt20szíves győzelem után hosszú hűtés:
a kisfa napi kerete itt is kimerült, nem fordulunk vissza négypercenként.

181121/2és10két megfigyelési próba. Közte5–9friss numerikus magasHP,
11ismét5,99KfrissOCR. Az epizódos újraélesítés élő pozitív esete igazolt;
nem azonos takart epizódban ismételt vak mozgás.
11véghelyzet: szélmalomtól északkeletre, kőszigeten álló díszfa mellett;
923HP/4fejszefa délre újratermett, jobb oldalon a nagy fafajta teste látszik.

## Következő nagyobb hozamú jelölt

180725/5OCR4.31Kés500,6képen jobbfent nagy fatest. A186történeti jegyzet
bizonyított4,31K/500szíves győzelmet ír le1,97K sajátHPésrégebbi build mellett;
nem azonos a havas7,15K humanoiddal. **Friss képi azonosítás szükséges**:
HP+500szív+test+bejárati réteg, csak utána célzott, külön dokumentált farmpróba.
Ez jobb hozamú lehet a kimerült kisfáknál. A régi teljes makró továbbra tilos.
