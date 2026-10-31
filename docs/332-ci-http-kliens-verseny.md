# CI: a korán elutasított kérés kliensoldali versenye

2026-10-31. A 331-es új munkamenet-funkció első távoli ellenőrzése,
[41247735058](https://github.com/dankhazipeter/butcher-hero/actions/runs/41247735058),
c135ae3 commiton a `test_rejects_missing_or_arbitrary_body_fields_and_unsafe_transport`
tesztben hibázott. Swift72, dashboard23 és game-control7 előtte sikeres.

A trace konkrétan `http.client._send_output → self.send(b'0\r\n\r\n')`
soron BrokenPipe: az urllib külön küldi a fejlécet, a chunked testet és a
záró chunkot. A szerver a tiltott fejléc alapján korábban elutasíthatja
a kérést és zárhatja a kapcsolatot, így a teszt nem jut el a HTTP400
kiolvasásáig. Helyben Python3.13-on sikeres volt, távol a más időzítés
előhozta a versenyt. Ez nem a 330-as DNS-függőség visszatérése.

## Javítás és megőrzött elvárások

Csak a teszt HTTP-kliense változik. A `tests/http_test_support.py` egy
kisméretű, teljes loopback POST-ot egyszerre küld (`socket.sendall`), majd
valódi `HTTPResponse`-ból olvassa a státuszt és JSON-választ. Nincs újrapróba,
BrokenPipe/URLError elfogadása vagy lazább elvárt kód. A chunked kérésre
továbbra 400 kell, a jogosulatlanra 403, és nem keletkezhet statkezdőpont.
A tiltott chunked kérést tízszer egymás után is ellenőrizzük.

A régebbi game-launch contract suite ugyanilyen, potenciálisan versenyző
POST-kliensét is a közös helperre állítjuk; minden előző assertion megmarad.
A GET-kliens, a production szerver, a session-CAS, a UI, a gyűjtő és minden
HTTP-védelmi szabály változatlan. Nem kell új éles szerver-/workerrestart.

Helyi Python3.13 session10 + game-control7 sikeres. A kötelező teljes kapu
továbbra 193 teszt + 7 JS-szintaxis; a javított commit saját GitHub-runja
szükséges a távoli siker kimondásához. Az eredeti bukó run nem nevezhető
utólag sikeresnek. A valódi munkamenetet e tesztjavítás sem nullázza.
