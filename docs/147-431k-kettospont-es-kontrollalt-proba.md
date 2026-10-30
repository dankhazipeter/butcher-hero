# A 4.31K kettőspont-OCR-je és a kontrollált óriásfapróba

## Élő megfigyelés

A `20260829-130403-play` futásban ugyanaz az óriásfa több eltérő gépi HP-értéket
kapott. A 171. esemény környékén az OCR a pontot kettőspontként olvasta (`4:31K`),
amit a régi parser `431000` HP-ra nagyított. A 224. esemény mentett
`frame-00224.png` képe közben tisztán mutatja a tényleges célt:

- felirat: `4.31K` HP;
- statikon: vörös szív `500`;
- saját HP: `778/778`;
- cél: nagy, kétlábon járó növényi óriásfa;
- térképi helyzet: az Island 4 zárfal zöld oldalán, tehát fizikailag elérhető.

A régi élő folyamat ugyan elindított egy kontrollált próbát, de hibásan 7500-as
kezdőértéket naplózott. Az első auditkor a cél takarásba kerülésének látszott; a
későbbi, részletes `frame-00228.png` vizsgálat ezt felülírta. Valójában közelharc
indult, a cél 2.18K-ra, a játékos 317 HP-ra esett. A teljes újraértékelés és a
burst-taktika a 148. fejezetben van.

## Programjavítás és regresszió

A `K` utótagú cél-HP normalizálása most a vessző mellett a kettőspontot is
tizedespontként kezeli. Ezért:

- `4.31K` → 4310;
- `4,31K` → 4310;
- `4:31K` → 4310.

A `20260829-131225-replay` a mentett 224. képen friss release builddel pontosan ezt
adta: `Kontrollált bosspróba indul 4310 HP-ról`. A saját HP-t ugyanazon a képen
friss OCR-ből 778-nak ismerte fel, ezért a próbaindítás teljes HP-s biztonsági
feltétele is valóban teljesült.

## Taktikai döntés

A 4.31K-s óriásfa a jelenlegi 693 DPS builddel külön kontrollált mérési sáv:

1. csak teljes vagy legalább 95%-os, friss numerikus saját HP-ról indítható;
2. a cél `4310` HP-/OCR-aláírását meg kell tartani, más boss nem veheti át;
3. 112 pixelen kívül izoláló közelítés, belül oldalkite fut;
4. öt stagnáló közelítés után hétlépéses oldalváltó kerülő indul;
5. az első érdemi sebzés után 82% alatt burst-visszavonulás, 45% alatt végső
   vészkapu kötelező;
6. az entitás eltűnése önmagában nem győzelem: cooldown, jutalom vagy közvetlen
   tartós statváltozás kell az ölés igazolásához.

## Nyitott mérés

A `131149-play` után a 148. fejezet további HP- és sebzésbizonyítékot, valamint új
burst-visszavonulási javítást vezetett be. A legfrissebb élő folyamat
`20260829-132032-play`; a legyőzhetőség és a jutalom továbbra is nyitott.
