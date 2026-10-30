# Világláda: hármas tartós jutalom és `TAP TO CLAIM`

## Élő bizonyíték — `20260829-013448-play`

- Az 544. eseménynél a bot a világban álló láda `OPEN` gombjára koppintott.
- A `frame-00546.png` rövid, input nélküli ládanyitási animációt mutat.
- A `frame-00548.png` sötét `REWARDS` képernyőjén három jutalom látszik:
  piros szív `+10`, kék fejsze `+2`, piros szív `+1%`.
- Alul pontos `TAP TO CLAIM` felszólítás jelenik meg. Ez nem automatikusan bezáródó
  átvezető: a régi bot több száz képen át helyesen várt, de a jutalom átvételéhez
  külön, bizonyított tap szükséges.

## Biztonságos claim

A döntő csak akkor koppint a képernyő alsó közepére, ha az alsó OCR-régióban szerepel
a `TAP TO CLAIM` kifejezés. Első felismeréskor egy tap engedett, tartós képernyőn pedig
legfeljebb egyetlen késleltetett újrapróbálás; más HUD nélküli képen továbbra sincs input.

A `20260829-014607-replay` a mentett jutalomképen `(312, 708)` koppintást adott. A friss
bináris `20260829-014620-play` 0. eseménye élőben ugyanott átvette a jutalmat.

## Igazolt fejlődés

A claim utáni első HUD-kép `438 / 100%` HP-t mutatott, és a `bot-state.json` maximuma
438-ra nőtt. A `424→438` összesen +14: ez megfelel a kijelzett fix `+10` és az addigi
maximum kb. `+1%`-ának együtt. A százalékos bónusz pontos kerekítési sorrendje még nem
választható szét, de a kombinált HP-hatás biztos.

A kék fejsze `+2` tartós támadófejlődést jelez; a következő tiszta normál találaton kell
megmérni, hogy pontosan két sebzésponttal növeli-e az alap támadóstatot. A láda ismétlődése
és újratermelődési ideje továbbra is nyitott.

## Útvonal- és gombfelismerési javítás

Az `OPEN` gomb nem rögzített képernyőhelyen van: a ládával együtt mozog. A bot ezért
narancssárga, lapos gombkomponenseket keres a teljes játéktérben, majd minden jelölt saját
régióján kér `OPEN`/`NEDU` OCR-t, és a felismert komponens tényleges közepére koppint.

A távolabbról látható láda ezüstfehér, széles testét és közeli aranyfényét együtt
felismerő navigációs jel lett. Biztos testjel esetén a bot a ládát közelíti meg; boss,
friss sebzés és statikus akadályőr továbbra is megelőzi. A játékos ezüst fegyvere és
narancs teste ugyanezt a színpárt adhatja, ezért 120 px-es játékosközeli kizárás kötelező;
lásd a 44. tudáslapot.

A későbbi negatív példák további három kaput tettek kötelezővé: legalább 25 px-es
testmagasság, legalább hat külső fehér csillogásminta és legalább négy szigorú sárga
ragyogásminta. Ez kizárja az Island 4 lapos kapuvasalatát és a fehér ponyvás szekeret,
miközben a két biztos valódi ládakép megmarad.
