# Titan 0/7 tábor, kijárat és újraindítási állapot

## Biztos élő megfigyelés

A `225035-play` 173–174. képe a Deep Mines zárt kapujától indított 36 döntéses
déli kijárás után egy alsó, járható zöld Island 4-táborban mutatta a karaktert.
Az OCR két egymást követő képen felismerte a küldetést:

`Collect all gems to unleash the Titan's power – 0/7`

Ez ugyanaz a lila Titan-oltár, amely a minimapon külön helyszínjelként látszik.
A táborban több körülbelül háromórás újratermelődési kör, sátor, őrtorony és fix
fakerítések vannak. A karakter nem magaslati sziklarétegen állt, de a
sátor–kerítés belső sarkában a szabad négyzetspirál sok lépést vesztett.

## Nagy térképi állapot

A kézzel megnyitott nagy térképen a játékos a középső zöld régió északi felében
állt. Biztosan elkülönülő jelölések:

- a lila Titan-hely a játékostól délre;
- egy narancssárga ellenféljel közvetlenül keletre;
- több piros/narancs cél a nyugati narancs régióban;
- türkiz és sárga kapupontok a zöld–narancs határon;
- a még fel nem derített, aranyfényű láda messze északon, ködben.

A térkép azt is igazolta, hogy a régi északnyugati piros jel globális némítása
túl tág: ugyanabban az iránynegyedben több, egymástól különböző cél és kapu van.
Egy konkrét ládaág lezárása nem zárhat le korlátlanul egy teljes világtáj-negyedet.

## Unstuck és respawn

A felhasználói utasításra végrehajtott Settings → Unstuck először `YOU DIED`
átmenetet mutatott, majd teljes, 1,97K kijelzett HP-val a közeli zöld
gyógyítómedencéhez helyezte a karaktert. A medence mellett a Titan `0/7`
buborék rögtön újra látszott. Ez bizonyítja:

1. az Unstuck ezen a helyen is büntetésmentes, halál-alapú teleport;
2. a tábor medencéje stabil gráfcsomópont;
3. egy új botfolyamatnak a már tartósan hűtött oltár mellett is újra kell építenie
   a még végrehajtandó kijárási szándékot.

## Megtalált programhiba és javítás

A `225035-play` felismerte a `0/7` állapotot és 28 lépéses oltárkijáratot épített,
de a kijárat régi feltétele csak piros minimapjel hiányában engedte a mozgást.
Ezért a kifosztott magaslati ág globális északnyugati némítása négyzetspirálra
ejtette vissza a döntőt.

A javítás háromrészes:

- az aktív Titan-kijárat távoli piros minimapjel mellett is elsőbbséget kap;
- az első friss `0/7` felismerés folyamat-újraindítás után is felépíti a 28 lépést;
- tizenkét Titan-buborék nélküli kép kell az újrafegyverzéshez, így a pulzáló OCR
  nem nullázza végtelenül a hátralévő kijáratot;
- a régi északkeleti zöld útvonal nem indul és nem folytatódik aktív Titan-kijárat
  vagy már látható helyi cél mellett.

## Következő élő ellenőrzés

A medencéből induló északkeleti út 24 döntés alatt ismét elérte a 4,31K HP-s,
500 szíves fát és a 200 HP-s Titan-kőobjektumot. Ez erős, rövid gráfél a
medence és a nagy szívfa között. A következő mérés azt ellenőrzi, hogy az új
északi, majd nyugati kapukerülő valódi sebzéscserét nyit-e, vagy további fix
falvég szükséges.
