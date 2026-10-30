# Új egyszeri láda, csíkátfedés és magassági szintek

## Második bizonyított egyszeri láda

A `20260829-180420-play` futásban a bot az új 1299 HP-s állapotból közvetlen
4,4K-s próbát indított. A 9. döntésnél közben egy valóban új különleges ládát
talált és megnyomta az `OPEN` gombot. A jutalomképernyőt kivárta, majd a 18.
döntésnél a `TAP TO CLAIM` gombbal átvette a tartalmat.

A `docs/world-map.json` ugyanennek a képi csomópontnak az 5. iránybinjét
`collectedChestDirections = 1` értékkel tárolja. Ez közvetlen bizonyíték arra,
hogy a szemantikus ládamemória nemcsak elméleti: az új láda begyűjtése után az
irány már egyszeri, lezárt cél, de maga a tágabb biom továbbra is felderíthető.

## A 4,4K-s próbában talált képfelismerési hiba

A 46. képen a játékos és az őr egymásra rajzolódott. A teljes képen a játékos
zöld csíkja és `1.3K` felirata teljes volt, az őr piros csíkja változatlanul
`4.4K`. A komponensdetektor azonban csak egy 22 pixel széles zöld részletet
választott ki, ezért 32%-os saját HP-t jelentett. Ugyanez megismétlődött a
`180859-play` 38. és a `181257-play` 25/68. képe körül.

Javítások:

- változatlan kontrollált boss-HP mellett az első nagy pixeles esés csak gyanú;
- a második hasonló kép vagy a friss numerikus HP igazolhat valódi sérülést;
- sebzés nélkül elveszett boss után nyolcképes átfedési türelem védi a még
  kirajzolt csíktöredéktől;
- a tévesen eltárolt 4,25K-s vereségsávot töröltük; a 4,4K nem bizonyított
  harci vereség.

Az élő `181257-play` 25. képe már úgy adott 32%-os pixeles becslést, hogy a bot
nem szakította meg azonnal a próbát, a következő kép pedig ismét teljes 1299 volt.

## Miért nem sebezte egyik fél sem a másikat

A bot több ciklusban 50–84 pixeles vetületi távolságig közelített, majd három
rövid helyben álló automata támadási ablakot és egy oldalkite-ot váltogatott.
Több tucat mérés alatt:

- az őr végig 4,4K maradt;
- a játékos végig hiteles 1299 maradt;
- támadás- vagy jutalomeffektus nem jelent meg;
- a teljes képek megmutatták, hogy a játékos a külső rózsaszín párkányon, az őr
  pedig a belső DOC-udvar másik magassági szintjén áll.

Ez tehát nem pajzsmechanika, kevés sebzés vagy elvesztett harc, hanem két, képen
egymásra vetülő, fizikailag külön járható réteg. A `181257-play` 106. és 212.
képe különösen tisztán mutatja az udvar és a külső sziklafal elválasztását.

## Új magassági útvonalmodell

A narancssziklás 4–5K-s DOC-őrnél a döntő megjegyzi, ha a próba már elérte a
112 pixeles közeli vetületet, mégsem történt sem saját, sem célsebzés. Legalább
14 mérés után ezt helyi szintkülönbségként zárja le. Más bossnál a konzervatívabb
32 képes és 84 pixeles feltétel marad.

Szintkülönbség esetén:

- nem készül tartós harci vereség;
- a cél iránya a helyi topologikus térképen elválasztott/lezárt irány lesz;
- a bot közvetlen menekülés helyett a külső fal mentén, enyhén kifelé keres
  rámpát vagy bejáratot;
- 72 falmenti mérés eredménytelensége kimerített magaslati felderítés: az ismert
  Unstuck helyreállítás indul, mert a mozgó őr elfedi a statikus elakadást;
- a már kifosztott láda iránya ettől függetlenül egyszeri marad;
- új képi hely, valódi bejárat vagy más ellenfél továbbra is új cél lehet.

## Nyitott mérés

- Az új falmenti mód megtalálja-e a DOC-udvar valódi bejáratát.
- A 4,4K-s őr onnan támadható-e, és milyen támadó-/szívjutalmat ad.
- A magaslati zóna mely képi csomópontjai tartoznak ugyanahhoz a járható réteghez.
- Az egyszeri ládák száma és a hozzájuk vezető irányok hosszabb távú feltérképezése.
