# Játékostest mint hamis távoli láda

## Hamis pozitív — `20260829-015352-play/frame-00100→00108`

A távoli világláda első ezüsttest/aranyfény-detektora több egymás utáni képen ládának
minősítette a középen álló karaktert. Az ezüst fegyver 55–67 px széles világos komponenst,
a narancs ruha pedig 335–503 közeli aranyszínű mintát adott — vagyis pontosan utánozta a
láda két színfeltételét. A bot emiatt képenként más irányba próbálta „megközelíteni” saját
mozgó animációját.

## Javítás

A távoli testdetektor csak a játékos képi középpontjától legalább 120 px-re lévő jelöltet
fogad el. Közelebbről nincs szükség testnavigációra, mert a valódi láda mozgó `OPEN`
gombja külön, erősebb OCR- és színbizonyítékot ad.

- `20260829-015644-replay`: a valódi, távoli láda továbbra is cél `(0,78; 0,62)` iránnyal.
- `20260829-015645-replay`: a karakter ezüst/narancs alakja már nem láda; a döntő az
  Island 4-határ szabályát használja.

## Második negatív: kapuvasalat

A 120 px-es kizárás után a `015654-play` Island 4-kapujának ezüst patkóvasalata és
világos faoszlopa is ládának látszott. A hamis világos komponens 21–22 px magas volt,
míg két biztos távoli ládakép 29, illetve 56 px magas testet adott. A minimum ezért
25 px-re nőtt; a közeli fehér csillogás legalább hat mintája is kötelező.

- `20260829-020201-replay`: mindkét valódi ládakép továbbra is ládanavigáció.
- `20260829-020202-replay`: a kapuvasalat már kiesik, a határszabály marad.

Élő ellenőrzés: `20260829-020221-play`.

## Harmadik negatív: fehér ponyvás szekér

A `020221-play/frame-00022.png` fehér ponyvás szekere átment a méret-, aranyfény- és
csillogásőrön is: a jelölt teste 51×34 px, körülötte 449 tág aranyszínű és 18 fehér
csillogásminta volt. A valódi ládát azonban szigorú, világos sárga külső ragyogás övezi,
amiből két biztos képen 5, illetve 16 minta látszott; a szekérnél egy sem.

A végleges testőr ezért legalább négy, az ezüst testen kívüli szigorú sárga
ragyogásmintát is kér.

- `20260829-020512-replay`: a valódi láda a szigorítás után is navigációs cél.
- `20260829-020513-replay`: a ponyvás szekér kiesik, a bot nem üldözi ládaként.
- Élő ellenőrzés: `20260829-020635-play`.

Ez a negatív bizonyíték különösen fontos: a színpár önmagában objektumosztálynak kevés,
ha ugyanaz a párosítás a játékos felszerelésén is előfordul.
