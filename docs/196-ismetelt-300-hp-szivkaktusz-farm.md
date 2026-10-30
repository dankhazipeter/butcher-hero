# Ismételt 300 HP-s szívkaktuszfarm

## Biztos megfigyelések

- Az Island 2 alsó narancs arénájában álló nagy szívkaktusz passzív cél: nem
  üt vissza, miközben a két automata fegyver nagyjából 334+191/286 sebzéssorokat
  ad le.
- A nagy példány felirata `300` szív; teljes HP-ja nagyjából 10,9K–11,4K.
  Támadótávolságban helyben állva körülbelül tizenöt kombinált találat kell.
- Az első új sorozatban a biztos maximum 3,43K-ról 3,73K-ra nőtt. A későbbi
  kaktuszokkal és köztes kisebb szívjutalommal a vizuálisan hiteles maximum
  4,41K lett. A `451K`, `4.11K` és `4.11Kg` Vision-alakok ugyanezeken a képeken
  OCR-hibák; a tényleges kijelzés `4.41K`.
- A nagy kaktusz ugyanazon a helyen körülbelül 4–6 perc után újratermelődik.
  Többször levágható, ezért jelenleg ez a legjobb ismert, biztos maximális
  HP-farm.
- A közönséges 1,28K-s kaktusz eltűnt a `081903-observe` előtt, de a maximum
  4,41K maradt. Az órás körrel visszatermelődő ilyen példány nem azonos a
  `300` szíves farmcéllal; a jutalmát nem szabad automatikusan HP-nak tekinteni.

## Botkövetelmények

- A látható szívikonos, passzív kaktusz elsőbbséget kap a távoli koponyával és
  minden már vesztes nagy boss-sávval szemben.
- A nagy kaktusz testközelben eltakarhatja saját HP-csíkját. Aktív célzárban a
  program maradjon helyben és tartsa az automata támadást; a csík rövid eltűnése
  nem jelent célvesztést.
- A jutalom utáni maximum várható értéke `ismert maximum + kijelzett szív`.
  Ettől erősen eltérő egyképes OCR nem írhatja felül az állapotot.
- A farmhely térképi csomópontként tárolandó: `elérhető`, `aktív`, `cooldown`,
  `utolsó biztos győzelem`, `várható jutalom`. A fix helyre csak a becsült
  újratermelődés után érdemes visszatérni.

## Aktuális állapot

- Hiteles maximális HP: **4410**.
- Felszerelt fegyverek: **Bat Cleaver 11 + Steel Splitter 22**.
- Következő biztos farmeredmény esetén a várható maximum **4710**, ami már
  meghaladja a 18,8K-s vereségsáv 4524-es újrapróba-küszöbét.

