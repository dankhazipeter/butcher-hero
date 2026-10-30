# Tizedespont nélküli 941-es hamis boss és maximumzaj

## Hamis boss — `20260829-021337-play`

A bot az 5. és 34. eseménynél teljes HP-n megszakította egy 136 HP-s kaktusz harcát,
és hathúzásos bossmenekülést indított. A `frame-00034.png` közvetlenül megmutatja az
okot: a kaktusz egy találat után `94.1` HP-n áll, a játékos mellett. A Vision ugyanebből
`941` egész számot adott; a 800-as bossküszöb ezért tévesen aktiválódott.

Ez nem az Island 4 távoli bosscsoportja: a hamis veszélyjel csíkja a korábbi kaktusz
48 px széles, 115 HP-s csíkjából 19 px széles maradékcsíkká zsugorodott ugyanazon a
helyen. A valódi 1.16K bossok külön, a havas képszélen láthatók.

## Javítás

Ha ugyanazon cél csíkja legalább 8 px-szel rövidül, a korábbi HP pedig ismert, akkor
egy 800–999 közötti, tizedespont nélküli OCR-jelöltet tizedként is megvizsgálunk.
A `941→94` helyreállítás csak akkor fogadható el, ha az eredmény a korábbi HP alatt,
legfeljebb 100-as csökkenésben van. További őr: ugyanazon cél HP-ja keskeny csíknál sem
ugorhat egyetlen képen 40-nél többet felfelé.

- `20260829-021819-replay`, régi bináris: a 115 HP-s első kép után a második kép bossmenekülés.
- `20260829-021914-replay`, javított bináris: a második kép 94 HP-s normál cél, támadásfigyelés.
- `20260829-022038-replay`: a végleges binárisban ugyanaz a regresszió továbbra is átmegy.

A valódi bossőr nem gyengült: a külön 500-as statikon, a K-s HP és az új célként
felismert 800+ érték változatlanul veszély. A friss `022045-play/frame-00000.png` több
valódi 1.16K ellenfelet lát a havas felső peremen, és helyesen menekül.

## Egyképes 464 maximumzaj

A `021337-play` 259. eseménye jutalom nélkül egyetlen képen 464 HP-t olvasott, míg a
közvetlen előző és következő friss OCR 463 volt. Ez nem hiteles fejlődés, mégis 464-re
írta a `bot-state.json` értékét.

A tartós maximum őre most:

- közvetlen jutalomemléknél azonnal elfogadja a kis növekedést;
- a +3 vagy nagyobb, korábban bizonyított jutalomlépcsőt azonnal elfogadja;
- jutalom nélküli +1/+2 értéket csak két egymást követő azonos OCR után tartósít.

A hibás gépi állapotot a közvetlen 463-as bizonyítékok alapján 463-ra javítottuk.

## Nyitott `2x Reward!` jelző

A `021337-play/frame-00108.png` bal szélén egy részben levágott, nagy szív-, filmes
ikon- és `2x Reward!` felirat látszik. A képen ez egy közeli cél/respawn-objektumhoz
kötött ajánlatnak tűnik, nem általános HUD-fejlesztésnek. Nem koppintunk rá: a filmes
ikon valószínű reklámot jelez, a pontos mechanika pedig még nem bizonyított.
