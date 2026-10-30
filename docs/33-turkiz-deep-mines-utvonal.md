# Türkiz Deep Mines küldetésútvonal felismerése

## Motiváció

A Cursed Girl küldetése világoskék/türkiz, szaggatott sínvonalat rajzol a terepre. A
régi bot ezt nem értette: a piros minimappontok farmcéljaihoz vagy zöld landmarkokhoz
fordult, és a `000913-play` sátoros környezetében többször elhagyta a történeti útvonalat.

## Képi modell — javított

Az elemző a játékmező középső sávjában keresi a nagy zöld és kék, kis piros értékű
türkiz pixeleket. A nyers szín nem elég: a lila szikla türkiz pereme, a híd és egy
20-as szívfa környezete hamis pozitív volt. Csak legalább 100 px kiterjedésű, 80 pixeles,
a játékos 175 px-es környezetét érintő összefüggő komponens lehet sín. Ezen belül a
játékoshoz 65 képpontnál közelebbi mintákat elhagyja; a távolabbi szakaszokat a távolság
négyzetével súlyozza. Legalább 24 pixel és 0,24-es iránykoncentráció kell.

Prioritás:

1. visszavonulás és bosselkerülés;
2. közeli, 110 px-en belüli vagy már megkezdett harc;
3. látható türkiz küldetésútvonal;
4. piros minimap-cél, zöld landmark, majd spirál.

Távoli farmcsík ezért nem téríti le a karaktert a biztosan látható történeti sínről.
Az útvonal a meglévő stagnálás-, kerülő-, kiszakadás- és irányhűtő védelmet használja.

## Regresszió — korábbi hiba és javított eredmény

- `000750-observe/frame-00000`: valódi sín, felismerve;
- `003743-play/frame-00086`: valódi kapuhoz futó sín, felismerve, északi vektor;
- `002956-play/frame-00066`: lila szikladísz, helyesen elutasítva;
- `000913-play/frame-00020`: fa/híd környezete, helyesen elutasítva.

Az utolsó közvetlen sínvektort a döntő hat valódi döntésig őrzi, hogy rövid takarásnál
ne váltson azonnal minimapra. Amikor a sín tartósan nincs képen, a minimap marad tartalék.

## Kapcsolódó javítások

- A kép felső 10%-ában csak részben látható csík nem biztonságos farmcél. Így a felső
  peremen lévő 200-as Titan-portál nem írja felül a küldetésnavigációt.
- Statikus navigációnál a kiszabadító irány a kívánt vektorra merőleges. Bizonyított
  navigációs iránynál legfeljebb tíz swipe-ig követi a falat, de HP-/bossveszély és
  180 px-es biztonságos cél azonnal megszakítja; következő elakadáskor oldalt vált.
- Távoli, fal mögött mozgó célcsík nem akadályozhatja meg a statikus útvonalőr futását.

## Élő eredmény és nyitott elfogadási feltétel

A bot megtalálta a Deep Mines kapuját, jobb oldali kerüléssel bejutott a havas területre,
majd az 1,92K–7,15K ellenfelek miatt 51 HP-n kimenekült. Következő feltétel: a sínt a
havas zónában úgy követni, hogy a bossőrök kerülője ne veszítse el tartósan, és megtalálni
a felvehető főzetet. Részletek: `34-deep-mines-kapu-havas-veszelyzona-es-utvonalszures.md`.
