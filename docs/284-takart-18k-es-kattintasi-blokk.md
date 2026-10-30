# Takart18K és elutasított kattintás utáni blokkolás — 2026-10-30

## Felhasználói hibajelzés és bizonyíték

A felhasználó szerint a láthatóFree18Kjutalmat nem vette fel a figyelő,
majd ő kézzel felvette. A küldött kép tartós másolata:
`references/2026-10-30/free-hp-18k-occluded.png`.

A javítás előttiinspect a képenFREE-t éshpikont talált, de az összeget nem.
OCR:„Sh1u.18K”,„J...-18K”. A pálya időzítője egy sorba került a jutalommal.
A08:45:37.892Znaplóban24E1D52D-BA75-4554-A72E-9EF9BFEDD75Fhp18000claim
click_failed:„A Free jutalom megváltozott a kattintás előtt.” Nincs hozzá
click_sent, tehát nem ment egérlenyomás. A duplakattintás-védelem mégis
lefoglalva maradt, amíg aFreeajánlat eltűnt. Ez magyarázza a kihagyást.

A felhasználó kézi átvételét nem számoljuk a bot saját gyűjtésének. A bejelentés
idejében másHP-átvételek is futottak, ezért a képhez nem találunk ki további
pontos kattintási időpontot. A rendszer közben működött; nem folyamatleállás volt.

## Javítás

- A numerikus mező a kártya saját számsorára és jobb oldali oszlopára szűkítve.
  Kisbetűsh/midőzítők kizárva, hogy34mne válhasson34milliós jutalommá.
- Hiányzó értéknél szűkebb tartalékOCR a18Kfelirat körül.
- Összeragadt OCR-sornál a számtoken saját Vision-geometriai dobozát kérjük
  le. Így a„J...-18K”kevert sorból a megfelelő helyen álló18Kfelismerhető,
  a pontos, önálló szám-parser szabályait nem lazítjuk.
- Csak az egérlenyomás ELŐTT elutasított kattintás foglalását oldjuk fel;
  későbbi két stabil képből újra próbálkozhat. Elküldött kattintás és pusztán
  bizonytalan képi visszaigazolás nem kap automatikus feloldást.
- Aclick_sentnaplózás külön van a kattintás előtti hibakezeléstől, hogy
  egy elküldött input utáni naplóhibából ne legyen automatikus újrakattintás.

## Ellenőrzés

Új regresszió a felhasználó valódi képén:hp,rawAmount18K,amount18000.
A javítás utániinspect ezt ténylegesen visszaadta. Új egységteszt: elutasított
előellenőrzés után újra szabad próbálkozni, elküldött/foglalt tételnél továbbra nem.
A korábbi8ikon-, negatívpanel-,591védelem-,680sebzés-, számparser- és
újraindítási védelmi tesztek megmaradnak. A javítás idejére a figyelőt
szabályosan leállítottuk; build/teszt után ugyanaz a szűkFreeautomatizáció folytatódik.

Véglegesbuild és mind a6tesztPASS. Új élesPID66033,execsession79555.
09:00:50.169Zhp18000észlelés,09:00:51.489Zkattintás,
09:00:53.168ZUI-visszaigazolás:claimC06B8FFA-500D-4728-BADA-EFE97442D23C.
Az utóképet az asszisztens is ellenőrizte. A következőcutdamage550is
09:01:25.611Z-visszaigazolt; a javított figyelő folyamatosan fut.
