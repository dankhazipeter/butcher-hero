# Elérhető Island 2-cél és kontaktus előtti újrapróba

## Élő megfigyelés

A Dusty Gulch alsó, járható táborában egyszerre jelent meg egy körülbelül
`3.06K` HP-s páncélos közvetlenül a karakter mellett és egy `4.4K` HP-s DOC-őr
a felső sziklaréteg vetületében. A régi Island 2-választó a legnagyobb látható
nem növényi HP-t rögzítette, ezért az elérhető 3.06K-s ellenfél helyett a
magasságilag leválasztott 4.4K-s célhoz próbált navigálni.

A saját kijelzett maximum közben elérte a legalább `3.27K` értéket. Ez nem
önmagában győzelmi bizonyíték, de a korábban már sebzett 3.06K-s sávval együtt
indokolja a tényleges, helyben tartott sebzéscsere újbóli mérését.

## Hibák

1. Aktív koponya mellett a „legnagyobb HP” szabály nem különböztette meg a
   járható közeli célt a másik magassági rétegen látszó céltól.
2. Ha a kontrollált próba még kontaktus és sebzés előtt elvesztette a célt, a
   HP-sáv mégis bekerült a folyamaton belüli megpróbált sávok közé. Ugyanazt az
   ellenfelet egy később megtalált bejárat felől sem lehetett újra próbálni.
3. Az általános 800+ HP-s menekülési őr aktív Island 2-koponya és teljes HP
   mellett is kivezethette a karaktert a felhasználó által kijelölt célzónából.

## Programdöntés

- Aktív Island 2-koponyánál a 155 pixelen belüli, nem növényi bossjelölt
  elsőbbséget kap a képen távolabb látszó legnagyobb HP-s céllal szemben.
- A kontaktust sem elérő, nulla sebzéses elvesztés nem harci próba: a HP-sávja
  azonnal újranyílik ugyanabban a folyamatban.
- Aktív koponyánál a közeli nem növényi cél nem fut az általános megelőző
  területelhagyásba; a kontrollált harci kapu kezeli. A friss sérülés-, alacsony
  saját HP- és halálőrök továbbra is változatlanul működnek.

## Ellenőrzési feltétel

A következő élő szakasz akkor sikeres, ha a bot a járható alsó táborban megjelenő
3–5K-s őrhöz közelít, ütőtávolságban megáll, és a cél HP-csökkenése alatt nem
fordul vissza a távoli koponyavektorhoz. Az ölés, jutalom, új fegyverszint,
saját HP-vesztés és esetleges újraéledés mind dokumentálandó.

## Az indulás előtti kötelező UI-ellenőrzés

- A Shop piros jelzése megnyitva: ingyenes lehetőség csak `20h 55m` múlva;
  jelenleg nincs költésmentesen átvehető jutalom.
- A Mailbox megnyitva: `You have no Mails yet.`
- Az Inventory/Stats panel pontos aktuális állapota: `796 DPS`, `3.27K HP`,
  `39 REGEN`, fő támadóérték `113 +754`, másodlagos érték `52 +1%`.
- Felszerelve Bat Cleaver 11 és Steel Splitter 17. A tartalék fegyverek látható
  szintje 1, 8 és 13; bizonyíték nélkül egyikre sem váltottunk.

## Első élő regresszió: a hídgráf

A `20260830-050552-play` futás lejutott a nagy vízszintes narancs kőhíd alá,
és útközben 136 HP-s kis célokat is elért. A koponya légvonalbeli vektora innen
kétszer visszavezette a sziklafalhoz: a generikus nyolclépéses tangens után a
következő közvetlen mérés újra északnyugatra mutatott.

Új tartós folyamatállapot készült. Ha a narancsszikla-fedettség legalább 80%,
órás Dusty-timer látszik, a koponya erősen északra mutat és négy képnyi
statikusság bizonyítja a falat, a bot félbeszakíthatatlan topológiai élt indít:
`16 dél → 6 nyugat → 12 dél`. Ez a kézzel már bejárt kőív–sínes alsó bossaréna
útja; egy új koponyavektor nem szakíthatja meg a közepén.

## Második élő eredmény és visszavont DOC-makró

A `050935-play` az új hídgráffal ténylegesen elérte az alsó nyílt arénát. Ott a
bot rögzítette a 3.06K-s páncélost, és legalább egy képen `3.00K` értéket mért.
A cél 157 pixeles közelségben az ütés/kamera takarásába került; a régi háromképes
memória túl korán feladta. A saját HP végig vizuálisan teljes volt, majd hiteles
`3.30K` OCR jelent meg. Az aréna kis ellenfelei tehát közben további legalább
30 maximum-HP fejlődést adtak.

A későbbi 4.4K-s DOC-próba régi déli–keleti makrója bizonyítottan a felső,
kijárat nélküli plató peremére vitt. A szintkülönbséget az alsó zöld/logos réteg
perspektívája és a minden síkbeli irányban statikus karakter igazolta. Az
Unstuck teljes 3.30K HP-val a Titan gyógyítómedencéhez vitt.

Programváltozás:

- a káros DOC-makró új képi bejáratbizonyítékig letiltva;
- a 180 pixelen belül már elért, nem növényi, legfeljebb 5K-s Island 2-őr
  célmemóriája 3-ról 12 képre nőtt, hogy a közelharci takarás ne szakítsa meg
  közvetlenül kontaktus előtt;
- az akkori hiteles maximum 3300 volt.

## Későbbi fejlődés

A visszatérés és az alsó aréna kis céljainak farmja közben a Steel Splitter
17-ről 18-as szintre fejlődött, a saját kijelzett maximum pedig vizuálisan
3,38K lett. A hozzá kapcsolódó OCR-hibát és védelmet a 191-es jegyzet rögzíti.
