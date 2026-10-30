# Island 2 koponyaaréna, Mailbox-audit és 18,8K-s újrapróba

## Nagy térképes helyazonosítás

- A `092858-observe/frame-00000.png` nagy térképén a játékos sárga háromszöge az
  Island 2 narancs területének nyugati-középső részén állt.
- A közelebbi narancs koponya északkeletre, a távolabbi piros koponya északra
  látszott. A két ikon tehát két külön harci cél, nem közönséges minimappont.
- Az alsó kőívből kivezető bizonyított makró után a nyugati hordó-/sziklafal-zsebből
  `4E, 8N, 8NE` élőben elért egy nyitott, járható folyosót. Innen a közelebbi
  koponya arénája további rövid északkeleti mozgással elérhető.
- A felső narancs táborból a hosszú keleti mozgás roncsos átjárón keresztül a
  zöld Island 1-re visz. Ez határél, nem az Island 2 koponya megközelítése.

## Biztos helyi cél

- A koponya folyosóján egy `1,28K`, 2-es szintű, fejszeikonnal jelölt kaktusz
  állt. Két rövid északi közelítés után automatikusan elesett.
- A halála után a képernyő bal szélén piros szívikon, `280` és `2x Reward!`
  sáv jelent meg. Biztos állítás csak az, hogy ez a kaktuszhoz időben kötött
  jutalomjelzés; a `2x Reward!` valószínűleg opcionális reklámos duplázás, ezért
  automatikusan nem nyomjuk meg.
- Saját maximum-emelkedés ezen a képsoron nem bizonyított: a stabil vizuális
  kijelzés továbbra is körülbelül `4,42K`, a tartós pontos állapot 4410 marad.

## A 18,8K-s boss tényleges újrapróbája

- Ugyanebben a járható arénában a 25-ös szintű, szívikonos, `18,8K` HP-s nagy
  páncélos fizikailag elérhető volt; ez nem magassági réteg- vagy kerítéshiba.
- A `093318-nudge` harmadik képe már közvetlen testközeli kontaktust mutatott,
  teljes, vizuálisan `4,42K` saját HP-val.
- A következő megfigyelés első képe már a Titan-medence automatikus újraéledése
  volt, 990 saját HP-val, majd gyors visszagyógyulással. A halál a két képsor
  közötti körülbelül két másodpercben történt.
- A boss maradék HP-ja a rövid képrögzítési rés miatt nem mérhető, de a vereség
  és a valódi kontaktus biztos. A 18,75K-s vereségsávot ezért 4410 saját
  maximumnál tartósítjuk; újrapróba legkorábban `4410 × 1,20 = 5292` hiteles
  maximumnál indokolt.

## Jelzett ikon auditja

- A `092357-play/56–58` futás a piros ponttal jelzett borítékot automatikusan
  megnyitotta, majd bezárta.
- A panel címe `MAILBOX`, tartalma `You have no mails yet`; sem az `INBOX`, sem
  az `ARCHIVE` alatt nem volt átvehető jutalom.
- Következtetés: a boríték piros pontja jelenleg nem bizonyít új levelet vagy
  napi jutalmat. A bot továbbra is ellenőrzi a jelzett UI-elemeket, de az üres
  Mailbox nem szakíthatja meg ismételten az Island 2 küldetést.

## Következő taktika

1. Automatikus visszatérés Titanról Island 2-re a bizonyított gráfon.
2. Az alsó aréna nyugati kijárata után a `4E, 8N, 8NE` bejárati él használata.
3. Ismételhető kaktuszok és 5K alatti őrök farmolása 5292 hiteles HP-ig.
4. A 18,8K és 27,5K vereségsávok addig kerülendők; a két koponya elérhetősége
   már bizonyított, ezért később nem kell újra teljes útvonalat keresni.

## Programjavítás és regresszió

- A felső falzseb `16S, 6W, 12S` makrójának helyjele most kötelezően
  északnyugati koponyavektort kér (`x < -0,20`, `y < -0,52`).
- Ez megkülönbözteti a zsebet a már kijutás utáni nyitott folyosótól, ahol a
  koponya északkeletre (`x = +0,64`) mutat; ott a bot most közvetlenül az aréna
  felé halad, nem indít újabb téves déli kört.
- A `090915-play/frame-00055.png` regressziója továbbra is elindítja a helyes
  hídgráfot, a `092829-observe/frame-00000.png` regressziója pedig közvetlen
  északkeleti koponyakövetést ad. A release build sikeres.
