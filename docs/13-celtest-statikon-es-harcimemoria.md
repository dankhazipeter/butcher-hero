# Céltest, statikon és harci memória szétválasztása

Ez a lap a `210934-play` képauditja után bevezetett kéttengelyű célmodellt rögzíti.
Korábban a „fa” és a „fejszejutalom”, illetve a „humanoid” és a „szívjutalom” fogalmakat
összekötöttük. A képek ezt megcáfolták.

## Két független tulajdonság

1. **Testforma és veszély:** a türkiz lombos fenyő passzív, a humanoid visszaüthet.
2. **Statikon és jutalom:** a kék fejsze támadóerőt, a piros szív maximális HP-t ad.

Biztos példák:

- fenyő + 1 kék fejsze → +1 támadóerő (`205205/frame-00060.png`, `00070.png`);
- fenyő + 10 piros szív → +10 max HP (`183521/frame-00005.png`,
  `204159/frame-00095.png`);
- humanoid + 3 piros szív → +3 max HP (`204458/frame-00035.png`, `00040.png`).
- humanoid + 1 kék fejsze → +1 támadóerő (`221123/frame-00000.png`, `00010.png`).

Következmény: a statikon nem használható közvetlen fenyegetésosztályozásra. Szíves cél
lehet passzív fenyő és támadó humanoid is.

## Ikonbizonyíték

A cél HP-csíkja fölötti, keskeny mintarégióból két arány készül:

- `heartIconEvidence`: erősen piros pixelek aránya;
- `axeIconEvidence`: cián/kék pixelek aránya.

A `212343-replay` első, 291 HP-s fejszés fenyőjén a fejszebizonyíték 0,053, a
szívbizonyíték 0,0008. A 10-szíves fenyőn a szívbizonyíték 0,25–0,32, a fejsze nulla.
Az ikonok így erősebb jutalomjelzők, mint az OCR által gyakran szintnek nevezett szám.

Keresztregresszió: a `213411-replay` +3 szíves humanoidja 0,13–0,22 szívbizonyítékot,
nulla faértéket és közeli fenyegetést ad. A `213459-replay` fejszés fenyőjén a kék jel
0,022–0,058, a barna fejszenyélből korábban keletkező hamis szívjel pedig 0–0,005.

## Közelharci testtípus-hiszterézis

A játékos teste 100 px-en belül részben eltakarja a fenyő lombját. A `210934` futásban
ugyanazon cél nyers fa-aránya 0,51-ről 0,21–0,24-re esett. Ha az előző kép ugyanott már
legalább 0,25-ös fát mutatott, a közeli cél 0,30-as minimumot őriz. Ez csak a cél
folyamatos követésén belül él, új célra nem öröklődik.

## HP-arányos befejezési memória

A régi háromképes memória a `210934/frame-00080.png` pillanatában kifutott, miközben a
10-szíves fenyőnek még 14 HP-ja volt. Az új szabály:

- hosszabb kivárás csak korábban fának minősített, már ténylegesen sebzett, 92 px-en
  belüli célon indul;
- a sérülés bizonyítéka a vörös csík rövidülése vagy legalább 5 cél-HP esés, és már a
  82 px-es támadási küszöbön kívül is elmentődik;
- a becsült ütésszám `ceil(utolsó HP / 25)`, ütésenként három döntési képpel;
- minimum 8, maximum 36 tényleges stratégiai döntés;
- felhasználói aktivitás miatt kihagyott input/állapotlépés ezt a számlálót sem fogyasztja;
- humanoidnál marad a háromképes rövid memória, és a visszavonulás mindent töröl.

A cél a már megkezdett passzív statjutalom befejezése úgy, hogy támadó cél mellett ne
keletkezzen hosszú, vak várakozás.

A `213745-replay` a felhasználói aktivitás alatt történt 174→145 HP-esést a következő,
86 px-es valódi stratégiai döntésnél harckezdetként rögzíti. A cél eltűnésekor így már
az első képtől a passzív-fa befejezési memória fut.

Az első játékbeli eredmény: `213551/frame-00065.png` még 58 HP-t, a 80. kép már
újratermelődési kört mutat. A következő `213819-play` stabil 296 HP-ja a korábbi 286-ról
közvetlenül igazolja a +10 max-HP-jutalom megszerzését.

## Jutalommal történő korai lezárás

A HP-alapú felső várakozási korlát biztonságos, de a cél halála után fölöslegesen hosszú
lehet. A játékostól jobbra lévő külön OCR-régió ezért kizárólag `+N` alakú jutalmat fogad
el. Minden új felvillanás növekvő sorszámot kap és 30 elemzésig megmarad, de a stratégia
egy sorszámot csak egyszer fogyaszthat el. A `214325-replay` a `+10`-et felismerte, a
`214603-replay` pedig igazolta, hogy ugyanaz az 1-es sorszám új harcot nem zár le újra.
