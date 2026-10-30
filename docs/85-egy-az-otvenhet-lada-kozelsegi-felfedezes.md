# 1/57 láda: közelségi felfedezés

> Friss megfigyelés, `074055-play/frame-00006`: ugyanannál a hídba rejtett ládánál
> ismét `You found 1/57 chests` jelent meg. A számláló nem lett 2/57 és nem keletkezett
> jutalomszekvencia, ezért az azonos 1/57 felirat ismételt felvillanása önmagában nem
> új fejlődési esemény.

## Élő megfigyelés — `20260829-050324-play`

Az Island 4-zárfal elhagyása után a bot egy zöld tábori emelvény és egy fehér,
részben nyitott ládatest mellé jutott. A 68–114. esemény képein fekete értesítés
jelent meg: `You found 1/57 chests`.

Ebben a szakaszban a program sem `OPEN` gombot, sem `TAP TO CLAIM` képernyőt nem
ismert fel, és egyetlen tapet sem adott. Kizárólag mozgási swipe-ok történtek. Erős
következtetés, hogy ez a ládatípus közelségből automatikusan felfedeződik vagy
begyűjtődik, és külön, 57 elemes gyűjteményszámlálóhoz tartozik. Ez eltér a korábban
dokumentált, narancssárga `OPEN` gombos világládától.

## Biztos és nyitott részek

Biztos:

- az értesítés pontosan `1/57 chests` értéket mutatott;
- a játék normál HUD-ja megmaradt;
- nem történt tap, vásárlás vagy reklámaktiválás;
- a környéken fehér ládatest látszott, a bot pedig elhaladt mellette.

Nyitott:

- jár-e a felfedezéssel külön stat-, pénz- vagy tárgyjutalom;
- az 57 láda egyszeri világkollekció-e vagy újratermelődő rendszer;
- pontosan mekkora a közelségi aktiválási sugár;
- a számláló tartósan megmarad-e újraéledés és alkalmazás-újraindítás után.

Taktikai döntés: az ilyen ládát nem kell megtapogatni. A normál mozgás elég, az
értesítés pedig fejlődési jelként dokumentálandó, de egyelőre nem nullázza a max-HP-
vagy fegyverjutalomhoz kötött boss-hurok számlálóját.
