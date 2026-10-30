# Memóriából megtartott HP nem igazolhat új maximumot

## Megfigyelés

A `083724-play` egyetlen képen 781-nek olvasta a ténylegesen 768-as teljes HP-t.
A következő képen nem volt friss 781-es OCR, de a zajszűrő helyesen megtartotta az
előző kijelzett értéket. A maximumtanuló ezt tévesen második, független
megerősítésnek tekintette, és 781-et írt a `bot-state.json` fájlba.

## Ok

Két külön cél keveredett:

- a képközi HP-memória jó a folyamatos életarány becslésére;
- új, tartós maximumot viszont csak friss képi OCR-bizonyíték igazolhat.

## Javítás

A maximumtanuló csak akkor vizsgál növekedést, ha a kiválasztott HP-érték a jelenlegi
kép nyers `healthCandidates` halmazában is szerepel. Egyetlen 781-es zaj után a
memóriából ismételt 781 ezért már nem számít második mintának. A tartós maximumot
visszaállítottuk a bizonyított 768-ra.

## Ellenőrzési feltétel

A `083724-play` visszajátszásában nem jelenhet meg új
`confirmedMaximumIncreaseSequence`, és a gépi állapotnak 768-on kell maradnia.

## Eredmény

A javított `084443-replay` 53. döntésén friss 781-es OCR szerepelt, az 54. döntésen
pedig csak pixeles/memóriaalapú 781. Egyik sem hozott
`confirmedMaximumIncreaseSequence` eseményt; az 55. döntéstől visszaállt a friss
768-as OCR. A `bot-state.json` a teljes visszajátszás után is 768 maradt.

Az új élő `084349-play` első képe rögtön 768/768-at olvasott, így a javított tartós
állapot a folyamatcserénél is helyesen töltődött be.

## 2026-08-29-i újabb szigorítás

A `094545-play` 649. képe ismét egyszeri 778→781 OCR-zajt adott. Ezúttal nem a
memória lett hamis második minta: a +3 egyképes történeti gyorsút önmagában elfogadta.
Ezért már a +3 is két egymást követő friss OCR-t igényel; részletek a
[125. kutatási fejezetben](125-egykepes-plusz3-hp-zaj-ujra.md).
