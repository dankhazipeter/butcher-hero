# Gyorsulás, képi csomópontok és Steel Splitter 17

## Új eredmény

Az Unstuck a hajóroncs–kőfal zsebéből a zöld gyógyítómedencéhez vitt. Innen
kézzel felügyelt, képenként ellenőrzött útvonalon ismét sikerült belépni a
`Dusty Gulch - 2` területre. A belépés pillanatában a saját maximum 3,25K volt,
az aktív fegyverek Bat Cleaver 11 és Steel Splitter 17. Az alsó kanyon első
kisebb csoportharcai után a kijelzés előbb 3,26K-ra, majd 3,27K-ra nőtt.

## Miért hibázott a régi számlálós út?

A korábbi, 3,12K/Steel 15 állapotban mért `13 dél → 20 nyugat → 12 észak →
8 nyugat` sorozat irányai helyesek maradtak, de azonos 0,62 másodperces swipe-ok
most eltérő távolságra vitték a karaktert. A 13 déli lépés túlfutott a
T-elágazáson, ezért a következő nyugati láb már a hajóroncs–kőfal zsebébe ért.

Biztos következtetés: a hosszú útvonal nem tárolható kizárólag swipe-számban.
A fejlődés, mozgási paraméter vagy eltérő induló mikrohelyzet megváltoztatja a
tényleges megtett távolságot. Az útvonal állapotváltásait képi csomópontokhoz
kell kötni.

## Új csomópontgráf

1. Deep Mines `magic anti-stone potion 0/1` kapu.
2. A kőút T-elágazása, középen fa irányjelzővel.
3. Nyugati út a nagy narancs sziklafal és a fémkapu látványáig.
4. Északi ráfordulás a nagy, kék vitorlás hajó alá.
5. Rövid déli igazítás a kapunyílás vízszintes útjára, ha a hajó tartóoszlopa
   blokkolja a nyugati mozgást.
6. Nyugati belépés; a `Dusty Gulch - 2`, `Enemy weapon`, `Weakness` overlay és
   a 68% fölötti narancsszikla-fedettség biztos sikerkritérium.

## A gyógyítómedence körüli akadályok

- A közvetlen nyugat a kék hajóroncsba visz.
- A hajó mellől keletre ki lehet szakadni a nyitott táborba.
- A hosszú kerítés és a hordó miatt a tiszta kelet/észak ismét blokkolódhat.
- A sátor mögül délnyugati átló visz a nagy fa mögé; innen a nyugat eléri a
  pallós rámpát.
- A pallós rámpa nyugatra és északnyugatra zárt, keletre viszont kijut a
  függőleges főútra.
- A megbízható Deep Mines-kapuhoz vezető ág a függőleges főúton észak.

## Programváltozás

Új, kézzel felügyelt `tap` diagnosztikai mód készült. Ablakarányos koordinátát
fogad, a játékot aktiválja, elvégzi az egyetlen koppintást, majd visszaállítja a
korábbi fókuszt és kurzorhelyet. Ezzel a Settings/Unstuck és a térképnagyító
vizsgálható anélkül, hogy a bot hosszú ideig birtokolná a felhasználó egerét.

## Következő fejlesztés

- A visszaút szakaszváltását OCR/képi landmarkokhoz kötni.
- Rövidebb, 0,35 másodperces közelítő swipe-ot használni csomópont közelében.
- A Dusty-belépés után azonnal a két koponya felé fordulni, passzív kis farm
  nélkül.
- A 27,7K-s célponton a helyben tartott sebző kombót újraellenőrizni.

## Alsó kanyon és bosspróbák

- A felső házzsebből a járható célút: dél a narancs kőív alatt, majd további
  dél a sínes alsó kanyonba. A közvetlen északnyugati koponyavektor a felső
  sziklafal túloldalán mutatja a bosst, ezért ott nem szabad közvetlenül nyomni.
- Az alsó kanyonban több 98–632 HP-s cél és `+4` jutalom jelent meg.
- A bot innen 4,4K-s kontrollált próbát indított, később a 18,8K-s páncélost is
  ismét felismerte. A két próba még kontaktus előtt takarásba került; a megközelítő
  akadályút finomítandó.
- Aktív Island 2-koponya mellett a tartós régi vereségsáv ezentúl nem tiltja le
  a kontrollált próbát. A teljes HP, friss sérülés és távolság biztonsági őrei
  továbbra is kötelezőek.
