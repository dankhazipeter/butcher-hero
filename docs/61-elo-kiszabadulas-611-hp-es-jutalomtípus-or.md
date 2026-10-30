# Élő kiszabadulás, 611 HP és jutalomtípus-őr

## Bizonyított élő eredmény — `20260829-031754-play`

A minden biomra általánosított négyátlós faljáróval indított build nem maradt a zöld
sátorkerítés zsebében. A futás szabad Meadowlands-területen bossoktól távolodott,
majd ismét főképi és minimap-alapú farmcélokat talált. Ez az első élő igazolása a
`60-zold-satorkerites-negyatlos-kiszabadulas.md` javításának.

A folyamat első friss OCR-je már stabil 576 maximális HP volt. A következő biztos
mérési pontok:

- a 2-szíves, 80 HP-s humanoid eltűnése után `576→578`;
- egy 5-szíves, 38 HP-s fenyő közvetlen zöld `+5` effektusa után `578→583`;
- több rövid HP-jú, 3-/4-szíves Meadowlands-cél egymásra fedő ölési sorozata után
  `583→586→595`;
- további 5-ös célok környezetében `595→600→605`;
- a `frame-00256` két 3-szíves, 41 HP-s humanoidját követően `605→611`.

A 611-et a `frame-00263` utáni friss OCR-ek és a `docs/bot-state.json` is megőrzik.
A csoportos lépcsők végösszege biztos, az egyedi célokhoz rendelésük az egymásra fedő
effektusok miatt erős következtetés.

## Kockázat és regeneráció

A 16-os szintű, 9/291 HP-n megfigyelt ellenfelek közelében a pixelcsík röviden
93–95%-ra esett, majd friss OCR-rel ismét teljes lett. A sorozat tehát sebzett, de a
regeneráció gyorsabb volt a következő cél megtalálásánál. A 800+ HP-s bossőr közben
többször megszakította a farmot, látható HP-veszteség nélkül.

## Külön statjutalmak

A `frame-00192→00193` egy zöld `+1` felirat mellett kék fejsze ikont mutatott, a
`frame-00244` pedig kék fejsze ikonos `+2` effektust. A maximális HP mindkettőnél 605
maradt. Ezek nem szívjutalmak; a konzol általános „jutalom +N” megnevezése önmagában
nem azonosítja a stat típusát.

## Programdöntés

A maximumőr korábban bármilyen felismert `+N` feliratot elegendő támogatásnak vett egy
egyképes +1/+2 HP-lépcsőhöz. Mivel ugyanilyen felirat fejszejutalomnál is megjelenik,
ez nem típusbiztos. Most minden +1/+2 maximumjelölthöz két egymást követő azonos friss
OCR kell; a +3 és nagyobb, játékban ismételten bizonyított szívlépcsők azonnali mentése
megmarad.

## Nyitott mérés

A +1/+2 kék fejsze pontos támadóerő-hatását a következő tisztán látható normál találat
előtti/utáni párral kell ellenőrizni. A jutalomeffektus színének/ikonjának automatikus
osztályozása külön fejlesztési ág; addig az általános jutalom-OCR nem lehet HP-típusú
bizonyíték.

## Tizedes effektus nem egész jutalom

A futás `frame-00332` képe valójában zöld `+0.5` effektust mutatott, miközben az OCR
`+0.5C` alakjából a régi számkinyerés 5-öt készített és nyolc képen át „jutalom +5”-öt
naplózott. A HP 611 maradt. A tizedes effektus jelentése még nyitott, de biztosan nem
azonos egy egész +5 statjutalommal. A jutalomértelmező ezért pontot vagy vesszőt
tartalmazó `+N.N` alakot nem ad át az egész jutalommemóriának.
