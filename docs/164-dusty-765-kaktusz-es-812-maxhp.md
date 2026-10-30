# Dusty 765-ös kaktusz és a 802→812 maximumnövekedés

## Élő eseménysor

A `20260829-150906-play` a 3.06K-s fegyverhordozó legyőzése után a Dusty Gulch
kerítésekkel és sziklatoronnyal tagolt udvarában maradt. A 392. képen kontrollált
1.28K-s célpróba indult. A környezetben több külön cél volt:

- 765 HP-s kaktuszok 1-es és 10-es szívikonnal;
- 1.28K-s kaktusz;
- 1.91K és 3.06K körüli páncélos ellenfelek;
- egy sziklatorony/szélmalom, amely többször takarta a HP-csíkokat.

A 414–418. képen a karakter ténylegesen egy páncélossal harcolt. Az ellenfél csíkja
`1.91K→568`, a játékos képen látható numerikus HP-ja pedig 611 volt. A döntő közben
a pixeles HP-mérés 28–33%-ra esett, de ez takarási hiba: a numerikus érték és a
későbbi teljes gyógyulás nem igazolta a kritikus állapotot.

## Bizonyított jutalom

A harc után két friss, kb. `5m 45s` és `5m 41s` cooldownkör jelent meg. A 431. képen
a karakter teljes numerikus HP-ja már `812`, szemben a korábbi tartós `802` maximummal.
Az Analyzer a maximumnövekedést megerősítette és a `docs/bot-state.json` fájlt 812-re
frissítette.

A közvetlen környezetben látható 765 HP-s, `10` szívikonos kaktusz és az ugrás pontos
mérete együtt erős, típusazonos bizonyíték: ez a változat `+10` maximális HP-t ad.
Az 1-es szívikonos 765-ös változat várhatóan +1-et ad, de ehhez még külön előtte–utána
mérés szükséges.

## Stratégiai érték

- A 10-szíves 765-ös cél hozama 76,5 ellenfél-HP / tartós HP-pont.
- Az új tartós maximum 812.
- A kb. ötperces cooldown miatt a kaktusz rövidebb ciklusban ismételhető, mint a
  harmincperces 3.06K-s fegyverhordozó.
- A piros minimapklaszter ezért nem pusztán bossveszély: nagy értékű +10 farmcélokat
  is tartalmaz. A helyi képi szívikon alapján kell szétválasztani őket.

## Későbbi állapot

Ez a fejezet a 812-es mérési pont történeti bizonyítéka. A `153119-play` újabb
közvetlen +10 jutalma 822-re, a `153504-play` további jutalmai végül 868-ra emelték
az aktuális tartós maximumot. Részletek:
`165-piros-minimap-es-114k-szivkaktusz-proba.md` és
`166-868-bol-hamis-898-ocr-es-plusz15.md`.
