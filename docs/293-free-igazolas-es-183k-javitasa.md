# Free-igazolás és18,3K-javítás — 2026-10-30

## Képpel és naplóval bizonyított hibák

A felhasználó szerint a játék átvette a jutalmat, miközben a nézeten
a nem igazolt szám nőtt; aHealth+8324,9pedig nem lehetett helyes4átvételre.
A nézet automatikus frissítése és a CLI-statisztika ugyanazokat az adatokat
adta, ezért a forrásnapló/gyűjtő volt hibás, nem az oldal újratöltése hiányzott.

1. `free-health-18-3k-misread.png`:18.3Klátszik. A régi kód8.3-at tárolt.
   Az eredeti teljes OCR18.3K-tokenje balra kezdődött a túl szűk x-kapunál,
   ezért kiesett; a megmaradt/csonkolt8.3és8.3К(CyrillK) győzött.
   A+8324,9naplóösszeg8300+három8,3volt, nem valódiHP-hozam.
2. `free-absent-grass-false-positive.jpg`:a mostani játékból mentett kép,
   Freekártya nélkül. A régiinspect mégis gameHUDVisible=true,
   freeCardVisible=true,reward=nil. A néhány zöld pixelre épített tartalék
   detektor a füvet is kártyának vette, így nem gyűlt össze két hiánykép.
   Később `Offer changed without observed disappearance; not counted`
   esemény került a naplóba. Nem történt utólagos kitalált könyvelés.

Bizonyítékok:`docs/references/2026-10-30/` alatt a fenti fájlok.
ElsőHealthclaim:D9633F55-5D9F-4448-9B00-ED1DA2ACE46A.

## Engedély és a végső hatókör

A felhasználó először engedélyezte mindkét felismerési hiba javítását és
képi naplóellenőrzést, majd pontosított: a múlt kevésbé fontos, MOSTANTÓL
működjön jól a gyűjtő és a statisztika alapadata. Ezért történeti átjavítás
nem futott. A már mentett napló és a régi bizonytalan tételek megmaradnak.

## Javítás

- A kártyajelenlétet összefüggő, mérethelyes zöld jelzéskomponenshez,
  fehér betűrészhez és sötét kontúrhoz kötjük; puszta zöld fű nem elegendő.
  A két egymás utáni HUD-os hiánykép továbbra is kötelező a könyveléshez.
- A numerikus sor bal oldala befogadja a teljes18.3K-t. A teljes, szélesebb,
  mértékegységes olvasat megelőzi a csonkolt részszámot;K/M/B/T és vizuálisan
  azonos cirill OCR-utótag is normalizálható. Unicodebetű mellett nem
  vágható le és használható önállóan a számtoken mértékegysége.
- A régi takart18K-eset szűk mentőOCR-kivágása megmarad. Egy köztes
  regressziós hiba ezt kimutatta, és a végső körben már ismétPASS.
- Ha egy átvétel ellenőrzése8s-nál tovább blokkolt, egyszeri
  `verification_blocked` képi bizonyíték és HUD/card/readable állapot kerül
  naplóba. Így egy következő anomáliához nem csak a kattintási előkép lesz.
- Az új futás `watcher_started` üzenetében `vision3` jelölés; a292-es
  nézet alapértelmezése kizárólag ez az új futás, a régi adatok keverése nélkül.

## Ellenőrzés és újraindítás

90423PIDszabályosan leállt fordítás előtt.13SwiftRewardTestPASS,
kb.1,6s: új18.3K→18300, cirillK, füves kártyahiány és valódiFree-jelzések,
valamint az összes korábbi18K/8ikon/számparser/duplaszámolás/húzásvédelem.
9statisztikai teszt és JS-szintaxisellenőrzésPASS, releasebuildPASS.

Új gyűjtőPID2444,execsession79280,2026-10-30T16:50:44Zkörül induló
vision3futás. A helyi statisztikaszerver új execsession86374 alatt fut,
http://127.0.0.1:8765/ . Friss futási bizonyítékot az alábbi utókövetés rögzít.

## Élő utókövetés — mindkét hiba javítása igazolt

18:52:31.854Bucharestidőben (16:52:31.854Z) az új gyűjtő
`23B26928-3EF6-4E8D-8C82-E1C13712F0FA` claimreHP18300kattintást
naplózott,18:52:34.166-kor pedigUI-igazolást. Az asszisztens ellenőrizte
az utóképet: explicit+18.3Kszív látszik, aFreekártya eltűnt a zöld füves
pályán. Tartós másolat:`references/2026-10-30/free-health-18-3k-confirmed.png`.

18:53:25-ig4input,4igazolt claim,0függő;HP18300,regen83,pierce540,
cut555. Ugyanarra a lezárt időablakra a helyi APIés az eredetiCLI
mind a8összege és darabszáma egyezett.18:54:28-kor a böngésző automatikus
frissítéssel már6igazolt/0függő,Health54900(3×18300) értéket mutatott,
friss utolsó-átvételi idővel. Régi adatminőségi banner az új futásban rejtve.

A gyűjtő és a helyi nézet futva marad. A múltat nem számoltuk újra és
nem változtattuk meg; csak új, helyes adatok kerülnek az új futásba.
