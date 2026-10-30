# Közös darabszámgrafikon — 2026-10-30

## Felhasználói kérés és jelentés

Közös idődiagramon látszódjon az összes jutalomtípus, külön vonalakkal,
de ne a kapott statértékek, hanem az összeszedési darabszám alapján.
A nagyHealthérték így nem torzítja a gyűjtési gyakoriság összehasonlítását.

Új szakasz a már működő helyi nézetben: „Mit kaptunk gyakrabban?”
Nyolc közös skálájú, halmozott lépcsős vonal; x=idő,y=igazolt átvétel(db).
Az eddigi nyolc értékalapú statdiagram és pontos átvételi táblázat megmarad.
A gyűjtőt nem állítottuk le, nem módosítottuk, nem fordítottuk újra.

## Számítás

Csak `claim_confirmed_ui`,claimID-nként egyszer, az utolsó `click_sent`
időpontjára szűrve és a legutolsó típuskorrekció szerint. Egy18.3KHP,
egy0,5regen vagy más nagyságú jutalom egyaránt1darab. Az újrapróba nem
új átvétel. Ha a típus ismert, de az összeg nem olvasható, a gyűjtés
darabként akkor is beleszámít; a statértékbe továbbra nem találunk ki számot.

Új APImezők: `collectionCounts`, `collectionSeries` (at/count egész szám),
`unclassifiedClaims`. A régi `series` és nyers statösszegek változatlanok.
Az új sorozat ugyanazt a legfeljebb kb.96idővödröt használja; az időbeli
pontosítás a fejlécben látszik. A sorozatvég mindig a pontos darabszám.

A jelmagyarázat típusonként darabot és százalékot mutat. A nevező az
azonosított, igazolt átvételek összege. Az ismeretlen típusú átvételek
külön, jól látható megjegyzésben szerepelnek, nem soroljuk őket találomra
egy ismert típus vonalába. Ezt az arányszám nevezője mellett is kiírjuk.
Az egy tizedesre kerekített százalékok összege eltérhet100-tól.

## Felület

Stabil színek és eltérő vonalminták; minden típus alapból látható.
Jelmagyarázatgombbal egyenként elrejthető/visszakapcsolható, billentyűzetről
is. A közös y-skála és a százalékok nem változnak csak attól, hogy egy vonalat
elrejtünk. Rámutatáskor az adott időpont összes látható vonalának darabja
közös részletdobozban olvasható. Mobilon kétoszlopos jelmagyarázat.
Ugyanaz az időszakszűrés és automatikus frissítés működik, mint eddig.

## Ellenőrzés és éles állapot

12Pythonstatisztikai tesztPASS (3új): eltérő nagyságú jutalmak azonos
darabértéke; ismert típus hiányzó összeggel; ismeretlen típus elkülönítése;
újrapróba/időablak/típuskorrekció; üres egészszám-sorozatok.
5korábbiNodeformázási/ikon-teszt és JS-szintaxisPASS.

Böngészőben8vonal és8gomb látszott. Healthkikapcsoláskor7vonal maradt,
visszakapcsolva8; a közös részletdoboz8darabszámos sort mutatott.
360pxnézetben nincs vízszintes túlcsordulás. Nincs konzolhiba.
19:24:32Bucharestpillanatképben62igazolt átvétel=55azonosított+7ismeretlen.
Health19db,regen5,pierce8,cut4,smash0,piercedef6,cutdef12,smashdef1;
az összeg55, az ikononkénti statértékek nagysága nem játszik szerepet.

Csak a statisztikakiszolgáló indult újra (execsession85053),
http://127.0.0.1:8765/ címen. A gyűjtőPID2444végig futott. Nincs történeti
naplóátírás, képújragenerálás, külső függőség vagy hosting. Képernyőkép:
`outputs/reward-dashboard/collection-count-chart.jpg`.
E változtatási kör a projekt szabálya szerint commitot és main-push-t kap.
