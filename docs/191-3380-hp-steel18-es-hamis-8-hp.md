# 3,38K-s HP, Steel 18 és a hamis 8 HP kiszűrése

## Új, bizonyított erőszint

A `20260830-053913-play` alsó Dusty Gulch-szakaszában a felszerelt Steel Splitter
17-ről 18-as szintre fejlődött. A Bat Cleaver továbbra is 11-es. A saját HP-felirat
a mentett képen teljes zöld csíkkal `3.38K`, ezért a tartós maximum 3380-ra frissült.

Ez az aktuális állapot; a korábbi Bat 11 + Steel 17 és 3300 HP történeti
mérföldkő.

Későbbi állapot: a következő arénakör után Steel 19 és 3,43K lett az
aktuális erőszint; ezt a 192-es jegyzet részletezi.

## Az anomália

Ugyanazt a stilizált 3,38K-s saját feliratot a Vision több képen `BET`, `X8ET`
és `8E` szövegként olvasta. A régi számkinyerés minden nem számjegyet
eldobott, így mindháromból 8 HP lett. Közben a passzív kaktusz, a célcsík vagy
egy timerkör a saját zöld csíknak csak egy rövid darabját hagyta láthatónak.
A két függetlennek hitt hibajel együtt kritikus HP-t és fölösleges menekülést
okozott, holott a karakter vizuálisan teljes életen állt.

Bizonyító események: a futás 179., 184. és 202. mentett képe; a 202. képen
nincs látható támadó, a saját felirat 3.38K, az OCR mégis `8E`.

## Programdöntés

1. Az Analyzer minden új folyamatban a tartós maximumot veszi fel utolsó hiteles
   HP-ként; a folyamatindítás nem törli a megszerzett tudást.
2. Ezres ismert maximumnál az apró, betűket tartalmazó, de sem K-, sem
   idősuffixet nem tartalmazó jelöltet eldobjuk. A valódi, tisztán numerikus `8`
   továbbra is átjut, tehát a halálközeli biztonsági reakció megmarad.
3. Ha csak pixeles HP-esés látszik, a numerikus memória legalább 85%-os és
   170 pixelen belül nincs nem-növényi támadó, a rendszer takarásnak veszi az
   esést. Valódi őr vagy friss numerikus HP-esés azonnal felülírja ezt.
4. Az általános nagyellenfél-kerülés a passzív kaktuszt nem tekinti veszélynek,
   ha a tartós számszerű HP-memória magas, még akkor sem, ha a pixeles csík takart.

## Következő élő regresszió

Az Island 2 alsó arénájában ellenőrizni kell, hogy a 11,4K-s passzív kaktusz
mellett nem indul téves visszavonulás, a 3,06K/4,4K-s nem-növényi őr valódi
kontaktusa viszont továbbra is sebzést mér. A fő cél változatlanul az Island 2
két nagy térképes koponyája; a jelzett Shop és Mailbox csak rendszeres,
költésmentes ellenőrzési mellékfeladat.
