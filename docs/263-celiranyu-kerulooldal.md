# Célirányhoz igazított kerülőoldal — 2026-09-19

## Hiba és friss helyzet

185609/11–18: északi falnál a bot kötelezően balra/nyugatnak fordult,
pedig a cél északkeleti. A kőfal–sátorpózna zsebében kötött ki.
190002-observe/0ugyanitt6,52K, délen újraélő174HP/10szívfa látszik.
Nem indítjuk újra a változatlan nyugati kerülést.

## Új döntés

Az első ütközés utáni két lehetséges érintőirányt pontozzuk: a cél felé
mutató komponens előny, a már sikertelenként mért szomszédos él erős hátrány.
Csak a kezdeti oldalt választja így, menet közben nem vált ide-oda az OCRzajra.
Döntetlenben a régi baloldali alap marad. A választott oldal forgásiránya
és az újraindításos checkpoint együtt változik: jobb oldali kerüléskor
elakadás esetén jobbra45fok, bal oldalinál balra45fok.

Külön korrekció: ha biztos látható új cél az előző fal normálisához képest
mögöttünk, a szabad oldalon van, az elavult kerülés nem tarthatja fogva.
A régi úticél/kerülés helyett ezt a friss célt közelíti. Ez nem általános
kerüléstörlés és nem akadályfelejtés; a mért élek megmaradnak.

Tesztek: északi fal+NEcél→kelet; már igazolt keleti akadály→nyugat;
jobb oldali kerülés újraindítás után is óramutató szerinti forgás;
szabad oldali friss cél feloldja az elavult kerülést. Régi fal/kapu/atlasz
invariánsok továbbra ellenőrzendők. Élő eredményt külön rögzítjük.

## Élő eredmény — 19:02

Build ésV2szimulációPASS; új oldalpontozás/ismertakadály/újraindítás/új cél
tesztekPASS. Quick-farm, csonkaHP és korábbiHP-takarás replayPASS.

190216-c0900b03-play/0–5a korábbi kerülést elhagyva a déli174HPfát
célozza; pózna miatt két sikertelen déli lépés után keletre kerül, utána
délre visszafordul.7képen **+10szív,6,53K**,fahely **6h57m**: kimerült.
11–12északi ütközésnél13keletre indul (nem a régi nyugati kőfalnak).
Kelet is részben takart,15–17jobbra/délkeletre fordul,18északipróba.
23képen már a kőfal keleti oldalán, szabad füvön egy alacsony rom mellett.
Ez a korábbi zsákutcából való kijutás és a célirányos kerülés élő bizonyítéka.
A következő alacsony rom is akadály; új teljes útvonal/győzelem még nincs.
19egy takart képen6%pixeljel,20friss6,53K: nem bizonyított sérülés.

## Folytatás — 19:04

190409-991ca71a-play/0–5az alacsony romot kelet felől megkerüli,14képen
már az északi útkereszteződésnél.20a179HPfa eltűnik;23helyén3m55s kör
és a program+1jutalmat zár.26az újabb, Deep MinesNPC melletti174HPfa
516találata ésúj4m0s.190528-observe/0a saját kijelzés **6,54K**, még
időzítővel takart; a gépi maximum6530, tiszta numerikus megerősítés kell.

Végpont a Deep MinesNPC zöld/déli oldala,0/1küldetés zárva. A türkiz sín
nem új járható út: a kaput ne erőltessük. A mért lokalizátor a korábban
ismert47-es chartba tért vissza (190409/26), V2pozíció0,53/−35,28.
Ez nem a51-es charttal való önkényes összemosás. Következő friss kép után
közeli farm/északi zöld terület; a Batőr hűtése rég lejárhatott, de képpel
ellenőrizendő, nem régi időpontból automatikus győzelem.
