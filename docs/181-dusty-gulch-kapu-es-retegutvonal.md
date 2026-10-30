# Dusty Gulch kapu és rétegútvonal

## Biztos topológia

A nagy térkép szerint a zöld és a narancssárga régió közös határán nem a
közvetlen északnyugati célvektor a járható út. A rögzített sziklafal alatt egy
nyugat–délnyugati kapupont van. A `211939-play` 98–100. képe bizonyította az
átkelést: a karakter a zöld oldalról hosszú nyugat–délnyugati szakasszal érte el
a patkó alakú átjárót, majd tiszta nyugati mozgással belépett.

Belépéskor a játék a következő overlayt mutatta:

- `Dusty Gulch – 2`;
- `Enemy weapon`;
- `Weakness`.

Az utóbbi két jel területi harci módosító, nem játékos-HP és nem jutalomérték.

## Jelenlegi útvonalmemória

| Szakasz | Irány | Bizonyíték | Állapot |
| --- | --- | --- | --- |
| Zöld határ → alsó kapupont | nyugat–délnyugat `(-0,82; 0,57)` | `211939/45–97` | járható |
| Kapun való áthaladás | nyugat `(-1; 0)` | `211939/98–100` | járható |
| Alsó kanyon → nagy kaktusz közvetlenül | északnyugat | `212644/45–58` | blokkolt |

## 22:19-es szakaszhossz-korrekció

A sikeres `211939-play` belépőlába 14 nyugat–délnyugati, majd 12 tiszta nyugati
döntésből állt. A később 52 döntésre nyújtott változat a `221934-play` 20–59.
képén negyven egymás utáni WSW swipe-pal ugyanazt a fás–sziklás határsarkot
nyomta. A program ezért ismét a mért 26 döntéses útvonalat használja. Ez nem új
kapuhipotézis, hanem a bizonyított szakasz időzítésének helyreállítása.

## Nagy térképes falvégi korrekció

A `222304-play` után kibontott térképen a játékos nyila a zöld–narancs határ
jobb oldalán állt. A türkiz átjárójel nyugatra, a sárga átjárójel délnyugatra
látszott; a képernyőn ugyanezt egy hosszú, függőleges narancssziklafal rajzolta
ki. A diagonális WSW a falnak ütközve nem csúszott végig annak oldalán, ezért a
bot új, egyszeri topológiai korrekciót kapott: 12 tiszta déli lépés a fal mentén,
majd 12 tiszta nyugati lépés a sárga jel magasságában. A szakasz élő sikerét még
az orange biom és/vagy terület-overlay megjelenésével kell igazolni.
| Nagy városi szikla megkerülése | délnyugat → nyugat → észak | `220041/25–77` | járható, DOC-kapuhoz vitt |
| DOC-udvar 4,4K-s őre | külső párkányról közvetlenül | `212644/85–103` | másik réteg, nincs kontaktus |

A kapuútvonalat a program 52 döntéses folyosóként tárolja: negyven hosszú
nyugat–délnyugati swipe után tizenkét tiszta nyugati swipe következik. A
narancsszikla képi aránya csak 68% fölött bizonyítja biztosan, hogy a karakter
belül van; a határszikla 10–35%-os téves narancsszínét ez kiszűri.

## Felfedezett célok

- A havas felső csoportban több körülbelül `1,16K` HP-s ellenfél áll
  (`211939/frame-00114.png`).
- Egy `18,8K` HP-s páncélos őr az erősebb felső ág közelében látszik
  (`211939/frame-00125.png`).
- Egy külön `4,4K` HP-s, fegyverjutalmas páncélos a DOC-udvarban áll
  (`212644/frame-00085.png`).
- A nagy kaktusz és a rózsaszín ív fix tereptárgy; a képen közeli ellenség nem
  jelenti, hogy a karakter ugyanazon a járható szinten van.

## Egyszeri magaslati ládaplató

A város fölötti sziklaplató külön, korlátozott navigációs réteg. Az ottani
különleges ládák egyszer adnak jutalmat; kifosztás után a hely nem farmcél. A
`213307-play` 49–123. képein a bot ezen a rétegen maradt, miközben a 4,4K-s őr
alul látszott, de egyik fél sem került kontaktusba. A három általános statikus
kiszabadítási fázis végül helyesen nyitotta meg a Settings panelt, de 123 döntés
fölösleges volt.

A gyors rétegazonosító most három jelet köt össze:

1. legalább 75% tömör narancsszikla a középső játéktérben;
2. legalább egy órás ládaidőzítő a középső OCR-területen;
3. nincs biztonságos, azonos rétegen álló farmcél.

Ha a biztos `OPEN` után külön `pendingOneShotHighlandExit` állapot jelzi, hogy az
egyszeri platóról még ki kell jutni, e jelkapcsolat azonnal Unstuckot indít. A
tartós kifosztottság önmagában nem elég, mert az alsó út is mutathat sok órás
kört és 80% fölötti narancsszínt. A `Dusty Gulch` sík terepén végzett összehasonlításban a
100. kép csak 55,9% narancssziklát, a 114. kép 51,8%-ot adott; a 89,2%-os 125.
képen pedig nem volt középső órás időzítő. Ez csökkenti a normál kanyon téves
elhagyásának kockázatát.

## Stratégiai következmény

- A kifosztott ládaplató végleg nem hozamcél, de a teljes magaslati hálózat nincs
  lezárva: új láda, küldetés, rámpa vagy ellenfélbizonyíték új felderítést indokol.
- A 4,4K-s és 18,8K-s őröket nem szabad a ládaplató egyszeri állapotával
  összemosni. Ezekhez alsó szintről külön bejáratot kell keresni.
- Az ellenfél HP-ja önmagában nem dönt a próbáról; a tényleges sebzéscsere és a
  kontaktus számít. A réteg nélküli, nulla sebzéses közelítés útvonalhiba.
- A következő cél a szekér–fakerítés mikrokapu élő igazolása, majd a 4,4K-s őr
  tényleges sebzéscseréjének mérése.

## 21:44–22:08 topológiai pontosítás

A `214244-play` megmutatta, hogy az alsó városi út is elérheti a 87%-os
narancsszikla-arányt, és egyszerre több órás kör látszhat rajta. Ezért a biom +
timer nem elég felsőréteg-azonosító. A gyors Unstuck csak friss, biztos láda-OPEN
vagy külön függő kijutási állapot mellett engedélyezett; a tág narancsos statikus
küszöb ismét hat fázis.

A `215234-play` a 4,4K-s DOC-őrt a külső kis ház mögött 416–488 pixelen látta.
A közvetlen üldözés a rózsaszín udvarfalnak ment. Az aktuális helyen megnyitott
nagy térkép további biztos jeleket mutatott:

- a játékos az orange régió belsejében állt;
- a piros ellenféljel északnyugatra volt;
- egy türkiz négyzet balra-délnyugatra jelezte a rétegváltó/kapupontot;
- egy új, aranyfényű láda messze északon, a köd fölött látszott;
- a zöld régió keleti ellenféljele és a lila Titan-hely külön cél maradt.

A `220041-play` módosított 18,8K-s útvonala először délnyugatra kijutott a
vezetékes útra, majd nyugatra megkerülte a nagy városi sziklát. Az 55–77. képen
egy házfalra szerelt létra/feljáró mellett haladt északra. A rétegváltás után a
4,4K-s őr távolsága `427→332→237→167` pixelre csökkent, tehát ez az első
bizonyítottan jobb megközelítési oldal.

A 92–105. képen még nem volt HP-csökkenés: az őr és a karakter közé egy fehér
szekér, rövid fakerítés és a rózsaszín ív kapuja került. A következő mikrokapu
ezért balra kerüli a szekeret, északon elhalad a fakerítés vége mellett, majd
jobbra fordul az udvar belsejébe.

Két programhiba is kiderült:

1. a `4:4` OCR-alakot a nyers parser egy képen `4` HP-nak adta, noha ugyanaz a
   71 pixeles őrcsík volt; aktív 4,4K-s próbában ez most kanonikus 4400;
2. az általános képaláírásos akadálytérkép felülírta a kontrollált bosspróba
   saját oldallábát. Kontrollált harci és fix térképi útvonalat többé nem adaptál.

Az északi arany láda új, hosszú távú felderítési cél, nem a már kifosztott városi
plató újranyitása. Külön helyazonosítást és biztos OPEN/CLAIM sort kell kapnia.
