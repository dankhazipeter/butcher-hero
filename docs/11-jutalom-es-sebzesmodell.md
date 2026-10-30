# Jutalom- és sebzésmodell

Ez a lap a célpontok várható tartós statjutalmát, ütésigényét és kockázatát gyűjti. A
stratégiai cél az egységnyi idő alatt szerzett tartós fejlődés, nem pusztán a legtöbb ölés.

## Biztos jutalmak

| Cél teste | Statikon | Példa HP | Biztos jutalom | Bizonyíték |
|---|---:|---:|---:|---|
| fenyő | 1 kék fejsze | 60 körül | +1 támadóerő | `205205/frame-00070.png` |
| fenyő | 5 piros szív | 38, 124 | +5 max HP | korai futások |
| fenyő | 10 piros szív | 48, 174 | +10 max HP | `183521-play`, `204159-play` |
| fenyő | 20 piros szív | erős következtetéssel 244 | +20 max HP | `000247`, `000913` |
| humanoid | 3 piros szív | 41 | +3 max HP | `204458/frame-00040.png` |
| humanoid | 1 kék fejsze | 128 | +1 támadóerő | `221123/frame-00010.png` |
| humanoid | 4 piros szív | 253 | +4 max HP | `020221/frame-00078`, `frame-00130`; `020635/frame-00016`; `023210/frame-00140` |

Az aktuális modellben a cél teste a visszaütési kockázatot, a statikon a jutalmat jelzi.
A kék fejsze a kijelzett értékkel növeli a támadóerőt, a piros szív a maximális HP-t;
szívikonos fenyőt és humanoidot is bizonyítottunk. Az első 1-es fejszés fenyő közvetlen
`+1` effektusa után a normál sebzés 26-ról 27-re nőtt.
A jelenlegi hitelesített maximális HP 727. A `222253-play/frame-00110.png` egy korábbi
10-szíves fenyő után közvetlen `320→330`, `+10` szív és `3m 59s` kört mutat; a
`224139-play` 131–132. eseménye a következő elérhető 10-szíves fenyőnél `330→340` és
felismert `+10` jutalmat rögzített. A `213551` hosszú memóriával befejezett
10-szíves fenyő után a `213819` tisztán 286→296 növekedést mutatott. A korábbi 271→286
növekedés egyedi jutalmai még nem teljesen rekonstruáltak.
Három új 20-as szívfa ezután közvetlen `340→360→380→400` és háromszor `+20` képet adott.
Ez 400-as mérföldkő volt; a narancs bányatábor `+4` humanoidjai később
`400→404→408→412→…→420→424` fejlődést adtak.

A `013448-play/frame-00548.png` világládája egyszerre `+10` fix szívet, `+1%` szívet
és `+2` kék fejszét adott. Claim után `424→438` lett a HP, ezért a két szívjutalom
együttes +14 max-HP hatása biztos; a százalékos kerekítés pontos sorrendje még nyitott.

A láda után a narancstábor két közvetlen +4-ével `438→442→446`, majd a következő
felügyelt körben újabb közvetlen +4-gyel `450→454` történt. A `446→450` lépcsőre nincs
elmentett felirat, ezért az csak erős +4-következtetés. Egy 76 HP-n eltűnő 1-es kaktusz
után `454→459` lett a teljes HP; ez erősen +5 kaktuszjutalomnak látszik, de közvetlen
jutalomfelirat híján még nem kerül a biztos jutalmak táblájába.

A `020635-play/frame-00376.png` ezután közvetlen `+4` szívet és teljes 463 HP-t mutatott.
Ezt a következő `021337-play` első friss OCR-je is megerősítette, ezért a `459→463`
lépcső biztos tábori humanoidjutalom.

A következő `022045-play/frame-00048.png` ismét közvetlen `+4` szívet adott ugyanebben
a táborban, és `463→467` lett a teljes HP. Ez megerősíti a 253 HP-s, 4-szíves humanoid
ismételhető +4 jutalmát.

A `023210-play` már stabil 471 HP-ről indult; a köztes `467→471` azonos jutalomnak
látszik, de közvetlen felirat nélkül csak erős következtetés. A
`frame-00136→00140.png` következő humanoidja viszont 253-ról 34 HP-ra fogyott, eltűnt,
majd közvetlen `+4` és teljes 475 HP jelent meg. Ez az akkori biztos maximum volt.

A `023210-play/frame-00248→00250` 252 HP-s kaktusza zöld, szív alakú `1` statikont és
öléskor zöld `+1` effektust mutatott, de a max-HP 475 maradt. Ezért a jutalom nem kerül
a piros szíves max-HP táblába; pontos statja/erőforrása nyitott.

A `025524-play` automatikus újraéledése után egy 48 HP-s, 10-szíves fenyő közvetlen
`+10` felirattal `475→485`, majd egy 38→5 HP-s, 5-szíves fenyő közvetlen `+5`
felirattal `485→490` fejlődést adott. Egy 2-es cél után a stabil maximum 492 lett;
közvetlen felirat híján ez erős +2-következtetés. A rövid cél-HP miatt a Meadowlands
szíves fái jelenleg a legjobb mért biztonságos max-HP/idő célok közé tartoznak.

A `030113-play/frame-00054→00064` következő, szintén 48 HP-s 10-szíves fenyője
közvetlen `+10`-zel `492→502` fejlődést adott és kb. 3:58-as respawnkört hagyott.
Ez a +10 célosztály második közvetlen, ismételhetőséget támogató mérése.

Ugyanebben a futásban a 2-szíves, 80 HP-s humanoid közvetlen +2-vel `502→504`, a
3-szíves, 96 HP-s humanoid közvetlen +3-mal `504→507` fejlődést adott. A második
9 pillanatnyi sebzést okozott, ami gyorsan regenerálódott. A kijelzett piros szívérték
tehát ezeknél is pontosan a max-HP jutalom.

A `030113-play` következő sorozata három +5 fát, egy további látható +10 fát, három
+4-es és hat +3-as humanoidot tartalmazott; `507→573` lett. A 41–43 HP-s humanoidokat
a 252–306-os találat egy ütéssel ölte. A `frame-00450` +10 effektusa mellett a
kijelzett maximum 553→564, azaz +11 lett; a korábbi +1%-os szívjutalom kerekítési
hatása erős hipotézis, de még nem közvetlenül bizonyított.

A `031754-play` az élő négyátlós kiszabadulás után `576→611` fejlődést rögzített.
A közvetlenül elkülöníthető lépések között 2-szíves 80 HP-s humanoid és 5-szíves
38 HP-s fenyő volt; a további 3–5-ös lépcsők részben csoportosan fedték egymást.
Ugyanez a futás kék fejsze ikonos +1/+2 effektust is mutatott változatlan max-HP mellett.
Ezért az OCR-rel olvasott `+N` csak az értéket, nem a jutalom stat-típusát bizonyítja.

A `032640-play/frame-00090` 431 HP-s, 20-szíves fája 486-os normál találat után
közvetlen +20-at és `611→631` fejlődést adott. A `frame-00130` közvetlen +3-mal 634-re,
a `frame-00164→00166` két külön +4 effektussal 638-ra, majd 642-re emelt. A 20-szívfa
ezen a sebzésszinten együtéses és a legjobb közvetlenül mért max-HP/idő cél.

A `033114-play` következő +5/+5/+3 sorozata 642→655 fejlődést adott. Ugyanott egy
1-fejszés, 67 HP-s fa vizuális +1 effektusát a Vision `+12`-nek olvasta, mert a kék
fejsze egy része számjegyként tapadt hozzá. A változatlan 655 max-HP és a kép közvetlenül
igazolja, hogy ez nem +12 szívjutalom.

A futás későbbi, 4-es statikonú rövid célja után stabil 659 jelent meg. A 655→659
lépcső biztos; közvetlen effektuskép nélkül a +4 célhozzárendelés erős következtetés.

A `033451/frame-00248` közvetlen +3-mal 662-re emelt. A futásváltás alatt eltűnő,
4-szíves 43 HP-s humanoid után az első friss OCR 666; a végérték biztos, a +4
hozzárendelés erős.

A `033954-play` két következő 10-szíves, 174 HP-s fája kiemelt prioritással külön
közvetlen +10 effektust adott: az első 203→140→93 pixelen 676-ra, a második
243→191→151→116 pixelen 686-ra emelt. A `034946-play` harmadik azonos célja
146→107 pixelen további +10-zel 696-ra vitt. Ez az új célprioritás háromszoros
közvetlen hozambizonyítéka.

A `034946-play` következő 41 HP-s humanoidcsoportja két átfedő, majd egy külön +3
effektussal 696→702→705 lépcsőt adott. Egy újabb 10-szíves cél közvetlen +10-zel
715-re emelt. Az egyszeri OCR-750-et a mentett kép és a következő 715-ös sorozat
egyaránt cáfolta.

A `035832-play` későbbi 3-szíves célja 31→3 HP-ra sérült, eltűnt, majd 718-as stabil
maximum következett. A +3 lépcső biztos és megfelel a típus korábbi hozamának; közvetlen
effektuskép nélkül a konkrét célhozzárendelés erős.

A `040308-play/frame-00180→00186` egy következő 3-szíves, 41 HP-s humanoidot
bossmenekülési mozgás közben zárt le. A 41→17→0 cél-HP után közvetlen `+3` szíveffektus
és 721-es tiszta maximum látszott. Ez egyszerre igazolja a humanoid +3 hozamát és azt,
hogy az automata támadás aktív swipe közben is befejezhet egy keresztezett célpontot.

A `040308-play/frame-00486→00490` 67 HP-s, 1-fejszés fenyője közvetlen +1 kékfejszét
adott 721 változatlan HP és 6 változatlan Bat Cleaver-példány mellett. A halál előtti
fehér fejszes 385 valószínű normál találat. A `041440/frame-00076` és `00080` két
következő fejszes értéke egyaránt 387, míg a nyílikonos 24 változatlan: a +1 támadóstat
ezen a felszerelésen +2 kijelzett végső sebzéssel járt, a pontos szorzás még nyitott.

A `044329-play` 291 HP-s, 1-fejszés fenyője újabb zöld +1 kékfejszét adott. A kártya
az effektus képén még 6, a következő élő futás első releváns képein már 7 példányt
mutatott. A következő 20-szívfa ölési képe 442-es fejsze- és 36-os nyílikonos értéket
adott. A 442 a korábbi 387-nél 55-tel nagyobb, a 36 pontosan a korábbi 24 másfélszerese;
a fegyverpéldány-, alapstat- és kritikus komponens szétválasztásához ismételt minta kell.

Ugyanez a két cél külön +3/+3 szíveffektussal 721→724→727-re emelt. A két 41 HP-s
humanoid elkülöníthető volt, ezért ez nem egy összeragadt +6 jutalom, hanem két ismételt
szintnyi max-HP jóváírás.

## Saját sebzés fejlődése

| Szakasz | Normál találat | Kritikus/erősített | Megjegyzés |
|---|---:|---:|---|
| kezdet | 12 | ismeretlen | első 1-es fa |
| korai fejlődés | 13 | 20 | 5-ös/10-es fák |
| középső fejlődés | 23–25 | ismeretlen | több 200+ HP-s fa |
| korábbi biztos | 27 | 40 | a kritikus kb. 1,5×; narancs kitörés jelzi |
| jelenlegi mérés előtt | 33 | ismeretlen | `215627/frame-00070.png` |
| későbbi, 3-as fegyverszámláló | 69 | 104 | `224139/frame-00180`, `frame-00130` |
| barna fegyver, 4 példány | 69 | 104 | Stats: `33 +48`, DPS 62.3 |
| Bat Cleaver, 2 példány | mérés következik | mérés következik | `33 +100`, 1.2 s, kijelzett DPS 111 |
| Bat Cleaver, 3 példány | mért 187→191 | még ismeretlen | három 20-as szívfán; a lépcső oka nyitott |
| zöld kártya, 7 példány | mért 442 | nyílikonos 36 | szerepük/normál-kritikus felosztásuk még nyitott |
| Bat Cleaver, 10 példány | közvetlen fegyver-Damage 500 | fehér 24 szerepe nyitott | `104751/frame-00867`; a második fegyver és alapstat miatt a teljes találat külön mérendő |
| Savage Fang, 2 példány | közvetlen fegyver-Damage 16 | 1.22K páncélos jutalma | `121101/frame-00086`; előtte Fang1 / Damage 8 |
| Savage Fang, 3 példány | közvetlen fegyver-Damage 24 | második 1.22K páncélos jutalma | `123510/frame-00190`; előtte Fang2 / Damage 16 |
| Ismeretlen zöld fegyver, 2 példány | közvetlen fegyver-Damage 70 | 3.06K páncélos jutalma | `150906/frame-00247`; előtte Damage 35, inventory-név/cooldown még nyitott |

A lebegő fehér fejsze melletti szám találati sebzés, nem gyűjthető erőforrás. A
`204458/frame-00070.png` 39-es kritikus, a `frame-00105.png` 26-os normál találatot mutat;
a következő 1-es fa `+1` fejszejutalma után a `205205/frame-00070.png` már 27-es normált,
a `frame-00020.png` 40-es kritikust mutat.

A későbbi 69/104 ugrás nem magyarázható egyetlen lineáris +1-gyel. A Bat Cleaver
részletképe bizonyította, hogy a kártya `2` értéke példányszám: példányonként 50
fegyversebzést ad, ezért kettőnél 100. Az Equipped barna fegyver `4` értéke erős
következtetésként ugyanennek a fegyverenkénti példánymodellnek a része. Részletes bizonyíték:
`docs/20-fegyverpeldany-es-sebzeslepcso.md`.

A Stats panel alapján a kijelzett DPS képlete a jelenlegi fegyveren biztosan összeillik
az `(alap támadás + fegyversebzés) / cooldown` modellel: `(33+48)/1.3 = 62.3`. A Bat
Cleaver elméleti értéke ezért `(33+100)/1.2 = 110.8 DPS`; a felszerelés utáni panel a
következő közvetlen ellenőrzés. A `233539-play/frame-00001.png` pontosan 111 DPS-t és
`33 +100` statot mutatott, ezért ez már közvetlenül igazolt, nem csak előrejelzés.

A `235416-play/frame-00200.png` a kétpéldányos Bat Cleaverrel 133 normál találatot,
a `frame-00202.png` pedig a 499 HP-s humanoid halála után azonnali `LEVEL UP`, `2→3` és
`Damage 100→150` állapotot mutat. A humanoid zöld fegyverikonja erős bizonyíték arra,
hogy célzott Bat Cleaver-példányjutalmat adott.

A Bat3 két következő élő találata külön 20-as szívfán egyaránt 187 volt
(`000247/frame-00034`, `000913/frame-00020`), a harmadikon már 191
(`000913/frame-00290`). Mind normál értéknek látszik; a négyes lépcsők eredete külön
statmérést igényel.

A `104751-play/frame-00866→00867` teljes 499 HP-s hordozóról közvetlenül a tizedik
Bat Cleaver-jutalomra váltott. A kártya felirata `Damage 450 > 500`, ezért a fegyver
saját 500-as komponense biztos. Nem állítjuk automatikusan, hogy minden teljes találat
pontosan 500 vagy `alap+500`: ekkor már két aktív fegyver, több +1 támadóstat és
ismeretlen 24-es harci komponens is jelen lehetett. A bosspróba a tényleges cél-HP
csökkenésből méri majd a kombinált sebzést.

A 2026-08-29-i stat-info audit feloldotta az „alap támadás” korábbi bizonytalanságát:
a jelenlegi Cut Damage 92 forrása Enemy +90 és Secret Chest +2, a Pierce Damage 16
forrása Enemy +16. A fegyverek saját Damage értéke ezekhez támadástípusonként adódik.
A Bat10 + Steel14 build képlete:

`(92 + 500) / 1,2 + (92 + 168) / 1,3 = 693,3 DPS`.

A játék 693-at mutat, ezért a képlet közvetlenül igazolt. A Savage Fang lecserélése
előtt `(92+500)/1,2 + (16+8)/1,0 = 517,3`, kijelzése 517 volt.

## Hozam/kockázat következmények

- A 3-as, 41 HP-s izolált humanoid jelenleg kiváló cél: kb. két normál ütésért +3 HP.
- A 10-szíves, 174 HP-s fenyő kb. hét normál ütésért +10 max HP, jó és passzív cél.
- A 20-szíves fenyő +20 max HP-t ad, de legalább 244 és 431 körüli változata van; a
  kisebb az egyik legjobb biztonságos cél, az erősebb hozama külön pontozandó.
- Az 1-es, 256 HP-s fa kb. tíz normál ütésért csak +1 támadóerő; alacsony prioritású.
- A 2-es, 416 HP-s fa még rosszabb időarányos cél, ezért a jelenlegi HP-korlát kizárja.
- Az `1.22K` páncélos elit első kontrollált próbája sikeres volt: a lebegő 30-as
  harci érték mellett a saját HP csak 778→751-ig esett, majd regenerált. Savage Fang
  `1→2`, Damage `8→16` jutalmat adott és kb. húszperces cooldownra került. Teljes
  HP-ról, izoláltan már ajánlott cél; a többellenfeles helyzet külön kockázat.
- A második 1.22K-s győzelem 778→737 HP-mélyponttal Savage Fang `2→3`, Damage
  `16→24` jutalmat adott. Ez ismételhető fegyverpéldány-forrás, nem egyszeri jutalom.
- A 3.06K-s páncélos győzelem 802→566 hiteles HP-mélyponttal új zöld fegyvert
  `2` példányra, `Damage 35→70` értékre fejlesztett, majd kb. harmincperces cooldownra
  került. A fegyver nem szerelődött fel automatikusan.
- A Dusty-udvar 765 HP-s, 10-szíves kaktusza `802→812` maximumnövekedést adott;
  a jutalomhatékonysága 76,5 ellenfél-HP egy tartós HP-értékért.
- A +10 Dusty-jutalom megismétlődött `812→822`, majd `842→852` lépésként, mindkét
  esetben közvetlen zöld `+10` szíveffektussal. A köztes `822→842` növekedés ténye
  biztos, de a forráscél a zsúfolt harc miatt még nincs azonosítva.
- A 765 HP-s, 15-szíves kaktusz közvetlen `+15` effektust adott; a következő
  hiteles teljes érték 868. A 898-as OCR-t nem szabad további +30 hozamként
  könyvelni, mert ugyanazon mentett képen 868 olvasható.
- A következő bizonyított 10-szíves kaktusz közvetlen `+10` effektusa 868→878
  maximumnövekedést adott. Ez újabb független megerősítés, hogy a szívikon száma
  a kaktusz tartós max-HP jutalmával egyezik.
- A 300-szíves, 11.4K-s kaktusz első folyamatos támadása 822 saját HP-veszteség
  nélkül legalább 1.3K célsebzést adott. Jutalomhatékonyság csak teljes győzelem
  és a tényleges +300 effektus után számolható; ezt még nem tekintjük bizonyítottnak.
- A frissebb `163416-play` ugyanezt a kaktuszt 11K→7,96K-ig vitte 938 saját HP
  mellett; a külön megjelenő 444 és 130 sebzés a két fegyver hozzájárulását mutatja.
  A cél továbbra sem tekinthető legyőzöttnek, de a harc kockázata eddig közel nulla.
- Három 672 HP-s, 10-es szívikonú lovag után a maximum 908→938 lett. Erős
  következtetésként ez 2016 összes cél-HP / 30 tartós HP, azaz 67,2 ellenfél-HP
  egy max-HP-értékért; a csoportharc időhatékonysága jobb lehet az izolált farmnál.
- A következő +15-ös cél után a tartós maximum 953. A pontos cél-visszakötés még
  hiányzik, de a maximumemelkedés stabil és a gépi állapotban is megmaradt.

## Nyitott kérdések

- Minden szíves cél a kijelzett értéknyi maximális HP-t ad-e?
- Létezik-e 5-ös vagy 10-es kék fejszés cél, és pontosan ekkora támadóerőt ad-e?
- A bal oldali nagy fejsze `4` pontosan milyen külön statot vagy szorzót jelez?
- Az elit/boss ad-e gemet vagy más, a nagy kockázatot indokoló jutalmat?
- A kritikus találat esélye állandó-e, illetve fejleszthető-e?
