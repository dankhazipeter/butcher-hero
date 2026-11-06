# Háttérkattintás: az Autoplayer ablaka fölé kerülő játék és a bezáródó Spotlight

2026-11-06. Felhasználói jelzés:

1. gyűjtéskor a játék ablaka előtérbe kerül, de csak a Butcher Hero Autoplayer
   ablaka fölé; ha más app ablaka van fölötte, nem;
2. ha a Spotlight nyitva van, minden gyűjtésnél bezáródik, akkor is, ha a
   játék nem kerül előtérbe; egy Outlook-helyi menü viszont nem tűnik el.

## Ok (a kód és a megfigyelés alapján)

A háttérkattintás (`BackgroundInput.click`) a játéknak egy `applicationActivated`
AppKit-eseményt küld, mert a UIKit csak „aktív” appként alakítja érintéssé az
egéreseményt. Erre a játék saját magától előre hozza és aktiválja az ablakát.
Más app ablaka fölé a rendszer ezt nem engedi. A mi appunk viszont épp előtérben
van, amikor az eseményt küldi, ezért a mi ablakunk fölé engedi. A Spotlight panelje
bezáródik, amint más ablak veszi át a fókuszt; az Outlook-menü appon belüli,
arra ez nem hat. A kattintás sikerességéhez az aktiválási jelzés szükséges, ezért
nem hagyható el.

## Javítás (a kattintás maga változatlan)

- Ha kattintáskor a mi appunk volt elöl, a kattintás után a látható ablakainkat
  eredeti sorrendjükben visszahozzuk a játék fölé (`orderFront`, aktiválás nélkül).
  Egy kb. 0,1 s-os felvillanás maradhat, mert az emelés a játékon belül történik.
  Az `input_geometry` naplósor `ownWindowsRestored=true` értékkel jelzi.
- Amíg a Spotlight panelje a képernyőn van (`com.apple.Spotlight` folyamat
  bármely 40×20-nál nagyobb, látható ablaka; zárva nincs ablaka, ezt
  ellenőriztük), a kattintás vár, ugyanúgy, mint lenyomott egérgombnál. Az app
  állapota „A Spotlight nyitva van” okot mutat. A Spotlight csak másodpercekig van
  nyitva, ezért a gyűjtést érdemben nem lassítja.

## Ellenőrzés

Fordítás és teljes tesztkapu. A nyitott Spotlightot és az előtérben lévő
Autoplayert élőben nem nyitottuk meg helyetted; ezt a felhasználó a következő
gyűjtéseknél látja. A naplóban az `ownWindowsRestored` és a várakozási ok
ellenőrizhető.

## Visszavonva: Spotlight-várakozás — 2026-11-06 délután

A felhasználó jelezte, hogy nyitott Spotlightnál továbbra is kattint és bezárja,
de nem akarja, hogy emiatt várjon: a bezáródást elfogadja. A Spotlight-ellenőrzést
(`HumanInput.spotlightOpen`) kivettük, a kattintás nem vár rá. Hogy az észlelés
miért nem fogta meg a nyitott panelt, nem vizsgáltuk tovább. Az ablakaink
visszahozása megmarad.
