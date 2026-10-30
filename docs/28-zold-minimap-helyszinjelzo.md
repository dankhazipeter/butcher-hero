# Zöld minimap-helyszínjelző célzott felderítése

## Kiinduló anomália

A `234826-play` Shop bezárása után a bot működő kerülőkkel és spirállal több helyszínt
bejárt, de új HP-csíkot nem talált. A minimap piros pontjai időnként eltűntek; a régi
döntő ekkor vak négyzetspirálra váltott. Ugyanezeken a képeken azonban a minimapon egy
fényes zöld, négyzetes helyszínjelző végig látható volt.

## Hipotézis

A zöld négyzet nem normál vörös harci cél, hanem NPC, játékrendszer, felvehető elem vagy
területi landmark. Tartós farmcélhiányban több új tudást/progressiont ígér, mint az
ismert medence–Island 4 zóna ismételt vak bejárása.

## Detektor és prioritás

- a kör alakú minimapon 5–16 px-es, legalább 15 pixeles, zölddomináns komponenst keres;
- a sárga játékosjeltől legalább 12 px-re lévő legközelebbi jelzőt választja;
- főképi biztonságos cél és piros minimappont mindig elsőbbséget élvez;
- csak piros pont hiányában lesz a zöld landmark navigációs vektor;
- ugyanaz a 24 döntéses stagnálás, nyolclépéses merőleges kerülő, hosszú kiszakadás és
  irányhűtés védi, mint a piros minimapútvonalat.

## Elfogadási mérés

1. a `234826-play` piros pont nélküli mentett képein a replay zöld-landmark swipe-ot ad;
2. élőben legalább több egymást követő végrehajtott döntés ugyanahhoz a jelzőhöz tart;
3. mentett képen új helyszín/objektum jelenik meg, vagy a stagnálásvédő biztonságosan
   leoldja az elérhetetlen landmarkot;
4. bármely új UI-t külön passzív protokollal vizsgálunk, vak tap nélkül.

## Első regresszió — `235348-replay`

- `frame-00194.png`: nincs piros pont, a zöld landmark felismerése `(0,10; -0,99)`
  irányú célzott swipe-ot ad a korábbi spirál helyett;
- `frame-00204.png`: a zöld jelző már nincs biztonságosan mérhető helyen, ezért a
  tartalék spirál marad;
- `frame-00044.png`: piros pont jelenlétében változatlanul a piros cél vektora győz
  `(0,32; -0,95)` iránnyal.

Ez a prioritási sorrendet és a hamis kötelező landmark-követés hiányát is igazolja.
Következő lépés az élő, többképes irány- és helyszínváltozás mérése.

## Élő elfogadás — `235416-play`

A 108–124. esemény több egymást követő zöld-landmark swipe-ot adott. Ezután piros
minimappontok jelentek meg, majd a bot 499 HP-s humanoidot, 923 HP-s fát, Titan-portált
és a 4.31K bosst tartalmazó új területre jutott. A humanoid legyőzése Bat Cleaver
példányjutalmat adott. A zöld landmark így vizuálisan és progressioneredménnyel is
elfogadott navigációs jel.
