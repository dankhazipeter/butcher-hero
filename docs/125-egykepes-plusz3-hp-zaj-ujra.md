# Az egyképes `+3 HP` OCR-zaj ismét téves maximum lett

## Anomália

A `094545-play` 649. eseményén a ténylegesen 778-as teljes HP-t az OCR egyszer
781-nek olvasta. A 650. képen már csak pixelesen megtartott 781 szerepelt, a 651.
képen a friss OCR visszatért 778-ra. Jutalom vagy harci eredmény nem volt.

A `bot-state.json` módosítási ideje `09:53:30`, vagyis az élő 649. kép ideje lett;
nem a későbbi replay írta át. A replay mód már eleve írásmentes volt. A hibás
maximumot az okozta, hogy a +3 történetileg közvetlenül bizonyított szívjutalomnak
számított, ezért egyetlen friss OCR-minta is azonnal tartós maximum lehetett.

Ugyanebben a futásban a 671. esemény egyszer 824-et olvasott, de ez a +30-as
plauzibilitási kapun kívül maradt, így nem szennyezte a tudást.

## Javítás

- A `+1`, `+2` és mostantól a `+3` maximumnövekedés is két egymást követő,
  azonos, friss OCR-mintát igényel.
- Az egyképes gyorsút csak a közvetlenül bizonyított `+4`, `+5`, `+10` és `+20`
  lépcsőkre marad meg.
- A tartós állapotot visszaállítottuk a képpel és korábbi jutalommal bizonyított
  `778` HP-ra.
- A képközi pixeles/memóriaalapú érték továbbra sem lehet második maximumigazolás.

## Regresszió

A `100131-replay` csak a 649–651. problémás képsort játszotta vissza 778-as tartós
kiindulásból. Mindhárom döntés 778-at tartott, új maximum-szekvencia nem keletkezett,
és a replay után a `bot-state.json` változatlanul 778 maradt.

Az új szabályt és a javított állapotot a `100443-play` élő folyamat töltötte be.
Valódi következő +3 szívjutalomnál ellenőrizendő, hogy két friss teljes-HP OCR-en
belül elfogadja-e az új maximumot.
