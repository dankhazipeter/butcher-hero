# Alsó képszél és a 67,5K HP-s boss

## Élő anomália — `20260829-024202-play`

A futás 0–228. eseménye között a karakter ugyanazon függőleges vörös sziklafalnál
ingázott. A minimap jobbra-felfelé, az időnként aktív Island 4-őr jobbra-lefelé
küldte; mindkét vektor a karakter jobb oldalán álló falnak nyomódott. A
`frame-00000→00098` képeken közvetlenül a karakter alatt egy zöld, `3` statikonú,
67,5K HP-s boss is látszott.

A bossőr nem aktiválódott, mert a vörös HP-komponensek régi keresési régiója csak a
kép magasságának 72%-áig tartott, a boss csíkja viszont 85%-on volt. Emiatt a
stratégia nem kapta meg a közvetlenül felfelé mutató menekülési vektort.

## Javítási lépcsők

1. A vörös csíkok látómezeje 72%-ról 90%-ra bővült. Az új fekete-keret kapu védi a
   nagyobb régiót a vörös terepélektől.
2. Az első `024508-replay` látta a csíkot, de az OCR csak a `3` statikont találta;
   ezért veszélyesen 3 HP-s passzív célnak minősítette.
3. A cél-OCR felső margója 18-ról 46 pixelre nőtt, és minden vizuális céljelölt nyers
   OCR-je bekerült a `visibleTargets` naplómezőbe.
4. A `024716-replay` már pontosan `67.5K` szöveget adott, de a 67 500-ra kibontott
   értéket egy régi, 5000-es technikai plafon eldobta. A plafon 1 000 000 lett; ez
   nem enged nagyobb farmcélt, mert a 800-as bossőr külön kizárja.
5. Az alsó 82% alatt részlegesen látható csík soha nem lehet közvetlen farmcél, még
   csonka OCR esetén sem.

## Regressziós eredmény

- `20260829-024803-replay`: `67.5K→67500`, nincs biztonságos cél, tiszta
  `(0,00; -1,00)` menekülés a boss felől.
- `20260829-024812-replay`: a korábbi sziklaíves képen nincs fantom 124; valódi
  136 HP-s cél marad.
- `20260829-024820-replay`: a régi 1.16K bosscsoport továbbra is azonnali menekülést
  vált ki.

Az éles javított futás `20260829-024836-play`. Indulásakor az előző hosszú faljárás
már kijuttatta a karaktert a boss közvetlen aljáról; a HP stabil 475, a bot a minimap
felfelé mutató irányát követi.

A végső élő megerősítés `20260829-025524-play`: már a 0. esemény felismerte a
képszéli többtízezres bosst és azonnal eltávolodott. Később két új bossészlelésnél is
hat azonos swipe-os menekülési memória futott. A bossőr tehát nemcsak replayen működik.

## Mechanikai következtetés

A zöld, óriási testű ellenfél biztos kijelzett HP-ja 67,5K. A fölötte lévő zöld `3`
ikon a már ismert piros szívtől eltérő statikon, nem a cél HP-ja. A boss kockázata és
jutalma nem mérendő közvetlen harccal; a fejezet mérési pontján 475 HP volt.
