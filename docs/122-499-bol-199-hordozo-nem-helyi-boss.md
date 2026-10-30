# 499-ből 199: a fegyverhordozó nem helyi boss

## Élő anomália

Az új közepes hordozókövetés a `092709-play` 19–38. eseményeiben a 499 HP-s,
zöld fegyverkártyás humanoidot 245→242→258→237→222→218→184 pixelre közelítette.
A `frame-00038.png` közvetlenül mutatja a teljes 499-es hordozót a tábor kerítésének
túloldalán; a saját HP stabil 778 volt.

A 39. képen a cél OCR-régiója egyszer `199`-et adott, miközben:

- a célazonossági memória helyesen 499 HP-t tartott;
- a zöld fegyverkártya-bizonyíték `0,0370` maradt;
- a teljes 57 pixeles csík és ugyanaz a testpozíció változatlan volt;
- valódi többezer HP-s boss nem jelent meg a képen.

A jobb Island 4-oldali, ikon nélküli 1,927K elit `92/192/199` csonkolására írt
helyi bossőr mégis bossnak jelölte. A következő képen az előző bossmemória a már
újra 499-et olvasó hordozót is bossként tartotta, ezért a bot elmenekült.

## Javítás

A helyi `90...199` bossőr most csak akkor alkalmazható, ha a zöld fegyverkártya-
bizonyíték `0,006` alatt van. Ez nem általános HP-felmentés: a pontos 499, az erős
zöld ikon, a csíkgeometria, az izoláltság és a saját erőkapu továbbra is külön
ellenőrzött feltétel. Az ikon nélküli 92/192-es elit változatlanul boss.

## Regressziós igazolás

A teljes `092709-play` visszajátszásán, tartós célmemóriával:

- `frame-00034`: 499 HP / 233 pixel, megközelítés;
- `frame-00036`: 499 HP / 184 pixel, megközelítés;
- `frame-00038`: a nyers OCR valójában 199, de a megtartott cél 499 / 184 pixel,
  továbbra is megközelítés;
- `frame-00040`: 499 HP / 247 pixel, megközelítés;
- `frame-00042`: rövid célmemória, nem bossmenekülés.

Az elfogadási feltétel teljesült. Az ikon nélküli 92/192-es elit bossőre megmaradt,
a fegyverkártyás 499→199 hordozó többé nem aktiválja.
