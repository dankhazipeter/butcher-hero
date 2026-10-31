# CI-indulás: loopback DNS nélkül

2026-10-31. A felhasználó kérte a GitHub CI hibájának javítását, a futó
gyűjtés megőrzésével.

## Bizonyíték és diagnózis

A [41241697382 futás](https://github.com/dankhazipeter/butcher-hero/actions/runs/41241697382)
69 Swift-tesztje sikeres volt. Az indító négy valódi folyamattesztje viszont
mind a `setUp` 6 másodperces készültségi várakozásán bukott:
`fixture launcher did not become ready`. Emiatt a tesztmetódusok még nem
juthattak el a Ctrl+C/stop/symlink/gyermekfolyamat-takarítás ellenőrzéséig.
Ez nem képfelismerési vagy jutalomkönyvelési teszthiba.

A fixture külön, standard `HTTPServer`-t használt. Ennek `server_bind`
implementációja a numerikus `127.0.0.1` bind után is `socket.getfqdn`-t
hív. Ugyanez a függőség a valódi dashboard `ThreadingHTTPServer`-ében is
megvolt. Reverz DNS-kérésre egy helyi, loopbackre kötött szervernek nincs
szüksége; lassú/offline resolver az indulást blokkolhatja.

Új regresszióban a `socket.getfqdn` kivételt dob. A régi kód ezen azonnal
megbukott, a javított kód mellett a szerver elindul, kötött IP-je numerikus
loopback, neve ugyanaz, portja a tényleges, OS által kiosztott port.
Ez a DNS-függőség bizonyítéka, nem a régi GitHub-gép stack trace-e:
az eredeti futás nem rögzítette a timeout alatti pontos blokkolási helyet.

## Változtatás

- `LoopbackHTTPServer` továbbra is többszálú HTTP-szerver, de a bind
  közvetlenül `TCPServer.server_bind`; nincs gépnév-feloldás.
- Az egyetlen éles bindcím változatlanul `127.0.0.1`. Host/Origin/token,
  launch-jogosultságok, read-only statadat és HTTP-válaszok változatlanok.
- A négy folyamatteszt most az izolált projektbe másolt **valódi dashboard**
  szerverkódot indítja, nem egy eltérő bindot használó másolatot.
- A gyűjtő és annak leszármazottja továbbra is álfeladat. Csak `/health`
  kérés történik, nincs játékindítás, natív probe, képrögzítés vagy input.
- A fixture saját `PYTHONPATH`-ján levő `sitecustomize.py` megtiltja a
  `getfqdn` hívást minden saját Python-gyermekben. A szülő környezetét és
  a valódi futó alkalmazást nem módosítja.
- A teszt 6 másodperces és az indító 8 másodperces health-határa megmarad.
  Nincs automatikus tesztújrapróba, skip vagy `continue-on-error`.
- Timeout esetén az állapot és a gyermekek kimenete is a hibába kerül;
  a kötelező kapu név szerint, verbose módban futtatja a launcher suite-ot.

## Ellenőrzés és üzemeltetés

Python 3.13 alatt a 19 launcher-, 23 dashboard- és 7 game-control teszt
sikeres. A teljes helyi kapu 177 teszt + 7 JS-szintaxis ellenőrzés:
72 Swift, 23 dashboard, 7 game-control, 3 Git-kapu, 10 supervisor,
19 launcher, 43 Node. A commit/push kapu a pontos Git-fát külön ellenőrzi.
A helyi siker nem helyettesíti az adott commit távoli GitHub-ellenőrzését.

Nem módosult a gyűjtő binárisa vagy a felismerési modell. A már futó
szervert és a gyűjtést nem indítottuk újra; az új bindkód a következő
szerverindításkor lép életbe. A statnapló, képek és logikai futás megmaradnak.
A korábbi folyamateltűnés (325) ettől nem válik bizonyítottan megjavítottá.
