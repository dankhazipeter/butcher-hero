# Stratégiai újraélesztés mint farmrövidítés

## Kiinduló probléma

A `20260829-040308-play` első 172 eseménye öt külön bossészlelést, több hosszú
menekülést, útvonalhűtést és faljárást tartalmazott, de addig nem adott fejlődést. A
karakter újra és újra az Island 4 zárfala, a Deep Mines veszélyzónája és a tábori
akadályok között mozgott. Korábbi közvetlen megfigyelés szerint a halál automatikus:
a játék teljes maximum-HP-val, megtartott felszereléssel a biztonságos Meadowlands
kezdőfarmon éleszt újra.

## Bevezetett állapotgép

A bot most külön számolja a jutalom nélküli boss-találkozásokat. Az ötödik után csak
akkor választhat stratégiai újraéledést, ha:

- az `UNLOCKS AT ISLAND 4` zárhatár látható;
- a játékos legalább 90% HP-n van;
- nincs 300 pixelen belüli, legalább 5-szíves, megbízható szívfa;
- az előző négy boss-ciklus óta nem jelent meg tartós fejlődés.

Aktiváláskor a bot a boss felé közelít, támadási távolságban helyben vár, és nem engedi,
hogy a normál frisssebzéses visszavonulás megszakítsa a rövidítést. A mód legfeljebb
120 tényleges döntésig él; ha a boss nem érhető el, automatikusan visszaadja a vezérlést
a normál stratégiának.

## Biztonsági megszakítások

- Bármely felismert szív- vagy fejszejutalom nullázza a boss-számlálót és megszakítja
  a stratégiai újraéledést.
- Az effektus OCR-je kimaradhat. Ezért két egymást követő, tiszta, teljes HP-s új
  maximum ugyancsak bizonyított fejlődés és azonnali megszakítás.
- Kritikus HP vagy HUD-hiány után csak friss, legalább 90%-os numerikus HP zárhatja le
  sikeres újraéledésként a módot.
- A boss felé vezetés csak a már bizonyított büntetésmentes újraéledést használja;
  menüben vagy HUD nélküli képen továbbra sincs vak input.

## Regresszió — `20260829-041322-replay`

A teljes, ritkított `040308-play` képsoron az ötödik bossnál, a 172. eredeti képnél
pontosan aktiválódott a rövidítés. A képsor ezután a régi bot valós mozgását mutatta,
így nem lehetett magát a halált szimulálni. Viszont a közben szerzett, effektus-OCR
nélküli 718→721 fejlődés két tiszta képe után a mód megszakadt, és a 188. eredeti
képnél már ismét a normál bossmenekülés futott. Ez igazolja a legfontosabb téves
öngyilkosság elleni megszakítást.

## Élő állapot

Az új build `20260829-041440-play` néven elindult 721 HP-ról. A stratégiai
újraéledés első valódi aktiválása, a halál–HUD-átmenet és a Meadowlands-visszatérés
élő ellenőrzése folyamatban van. A 76–83. esemény közben szerzett két +3 jutalom
721→727-re emelt; két tiszta 727-es mérés a tervezett módon lenullázta a jutalom nélküli
boss-számlálót akkor is, hogy a lebegő effektus OCR-je nem került a naplóba.
