# Az Unstuck panel eltűnése a megbízható sikerjel

## A téves cooldown-következtetés feloldása

A `075542-play/frame-00450` képen az Unstuck gomb még sárga és aktív. A tap után a
`frame-00452` egyértelmű `YOU DIED` állapotot mutat: a helyreállítás sikeres volt.
Az eseménynaplóban mégis 100% maradt a `hudConfidence`, ezért az ötödik képnél a régi
állapotgép cooldownnak minősítette és egy felesleges X-tapot küldött a már bezárt
panel helyére.

A `081017-play/frame-00108→00112` ezzel szemben valódi időzár: a rózsaszín Settings-X
mind az öt képen megmaradt, az Unstuck helyén pedig `01:45→01:43` visszaszámlálás
látszott. A háttér 17h 47m időzítői más játékelemekhez tartoznak; nem az Unstuck
cooldownját mutatják. A 108-as fejezet korábbi többórás következtetése ezzel cáfolt.

## Javított visszacsatolás

- Siker, ha a Settings panel rózsaszín X-e eltűnik, vagy a HUD-biztonság 90% alá esik.
- Siker után 30 tényleges, inputmentes döntés várja ki a halál/teleport és a medencés
  gyógyulás végét.
- Időzár, ha a panel X-e öt képen át megmarad. Ekkor biztos X-es bezárás és 900
  tényleges döntéses, körülbelül tízperces belső hűtés indul.

Az X eltűnése erősebb jel a HUD-biztonságnál: a `YOU DIED` overlay alatt a játékmenet
HUD-ja továbbra is felismerhető maradhat. Az első javított élő futás: `081746-play`.

## Élő igazolás

A `081746-play` tisztán teljesítette az új protokollt:

- 0: Settings megnyitása a jobb oldali 192-es kapuőrnél;
- 1: egyszeri Unstuck-tap;
- 2: eltűnt panel, a hős nulla HP-s teste még az előző helyen;
- 3–4: 80%-os HUD-átmenet;
- 23–29: 714→681→768 medencegyógyulás;
- 31: a 30 inputmentes ciklus lezárása;
- 32-től: friss területről normál minimap-felderítés.

Sem felesleges X-tap, sem idő előtti boss-/minimap-input nem történt. A javítás élőben
igazolt.

## Ellenőrzési terv

1. Aktív gombnál a következő képen eltűnő X indítsa el a 30 ciklusos kivárást.
2. Visszaszámlálós gombnál az ötödik, továbbra is X-es képen záródjon a panel.
3. A kivárás alatt sem boss-, sem minimap-, sem felhasználói aktivitási ág ne küldjön
   játékinputot.
