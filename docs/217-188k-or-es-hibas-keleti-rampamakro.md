# A 18,8K-s őr nem azonosít egy rámpát — 2026-09-19

## Kísérlet és bizonyíték

`docs/runs/20260919-124302-0d8ce147-play`: a kis célok után a tartós maximum
5580-ra nőtt. Az 53–57. képen az explicit 18,8K-s őrt északon láttuk, saját
HP teljes; közvetlen megközelítés közben egyik HP sem változott.
Az 58–69. döntés a régi, 12 keleti érintést adó rámpamakró volt.
A 62–69. képeken a célok távolsága 265–269 px körül stagnált; a 71. kép
a játékost sziklaoldali szélben mutatja. **Valódi harci kontaktus nem igazolt.**

A napló „bizonyított topológiai kerülő” szövege túlzó volt. A feltétel mindössze
18–19,5K HP, narancs biom, sebzetlen cél és első stagnáló kerülő; nem egyedi
kezdőhely-azonosítás. Ráadásul a makró végén automatikusan hosszú útvonalhűtést
mentett, valódi végponti siker/hiba-ellenőrzés nélkül.

## Programdöntés

A külön keleti makró indítása törölve. A célazonos, rövid, váltott oldali
általános kerülő marad. Új feljáró csak helyi képi csomópontokkal és mérhető
mozgással kerülhet hosszabb útvonalba. A meglévő többi történeti makró ettől
még nem tekinthető auditáltnak.

## Következő élő mérés

`124711-4d03adf0-nudge`: 4W, egyenként 0,50 s. A `124737-372945ae-observe/1`
szerint csak kb. 80 px kameramozgás; nem jutottunk a boss síkjára.
Következő hipotézis: délnyugaton a látható fa járófelület mentén kijutás,
utána friss képből feljárókeresés. Ez még nem bizonyított útvonal.

`124855-ac4a7524-nudge` 5SW és `124928-213cbfbc-nudge` 4S (0,50 s)
szintén nem nyitotta ki a zsebet; a 124938-as képen a karakter a szélmalom
mellett maradt. Következő irány a látható fa híd felé északnyugat.

## Regresszió

A release build és a teljes `tests/regression.sh` sikeres. A teljes 124302-es
képsor `124902-d66e649a-replay` visszajátszásán az 58–69. döntés már nem a
keleti rámpamakró. A rövid kerülő célvesztéskori folytatása még külön javítandó:
jelenleg a cél eltűnésével túl korán bossirányú visszakeresésre vált.
