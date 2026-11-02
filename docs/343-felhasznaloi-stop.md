# Felhasználói leállítás — 2026-11-02

A felhasználó kifejezetten leállította a programot, egyelőre nincs játék.
A `butcher-hero stop` a közös indítót és saját szolgáltatásait leállította.
Felügyelő naplója: supervisor_stopped2026-11-02T08:04:11.083359Z,
azaz09:04:11Europe/Budapest. A state.running=false; folyamatellenőrzéskor
nincs watcher, supervisor, közös runner vagy dashboard, és8765nem figyel.

Nincs további képernyőfigyelés/input, automatikus újraindítás vagy ütemezés.
Új kifejezett folytatási kérés szükséges. Régi bot/heartbeatPAUSED marad.
A naplók, mintaképek és statisztikák változatlanul megmaradtak; a következő
normál indítás alapértelmezett resume-run, nem automatikus statnullázás.

## Korábbi read-only diagnózis, javítás nélkül

Külső kijelzőn623×863ablaknál a geodejelzés időnként nem jutott át a friss
preclickellenőrzésen, ilyenkor nem történtinput és60s cooldown következett.
Később sajátFBD7D4C8nyitáskor látható x1mellett inventoryUnavailable,
célzottgoldbutton-olvasás nem adott pontosX1-et, ezért saját panelt zárt.
A két userHUDképen a releaseoffline inspect notification=true; más eredeti
Free-előképeken ugyanazon látható jelzésre false is reprodukálható.
A konkrét elutasított kristály-preclickkép nem mentődik a régi kódban,
ezért annak pontos pixelszintű elutasítási oka nincs bizonyítva.

Laptopra visszatétel után5F042063önálló új kör05:23:11.998Z→05:23:34.351Z:
openInventory→openOne→ütések→result→Continue→inventoryX→HUD, completed_ui.
Külső panelXkomponens70px, laptopon73px, az ablak mindkettőn623×863;
ez képi megjelenítési eltérésre utal, de nem bizonyított konkrét DPI-/színprofil-
gyökérok. A Free gyűjtés a külső kijelzőn is működött. Nem változtattunk
felismerőt, küszöböt, inputot vagy történeti jutalomnaplót ebben a diagnózisban.

Ez a kör csak operatívSTOP és dokumentáció; a kötelező offline tesztkapu
nem indít valódi gyűjtést. A leállítás a tesztek/commit/push alatt is érvényes.
