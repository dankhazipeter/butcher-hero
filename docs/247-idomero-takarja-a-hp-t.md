# Időmérő takarja a HP-t — 2026-09-19

164311-play mármin-user-idle0: nincs emberi aktivitás miatti várakozás.
0–11mozgás, majd12–41téves kritikus HP-várakozás.
18képen az9h16m időzítő ráfed a saját5,86K feliratra; OCR9h16m86K,
csak13pxzöld marad→23%. A valódi HPnem frissen olvasható, tehát nem
mondjuk a memória alapján, hogy biztosan gyógyult. Élő kör megszakítva.

Javítás: kritikus numerikus megerősítésre várásban, órát+percet tartalmazó
sajátHP-OCR, nulla közeli felismert fenyegetés és inaktív bosspróba mellett
**futásonként legfeljebb egy0,30s keleti oldalmozdulat**. Utána továbbra
friss numerikus HPkell. Ez megfigyelési próba, nem harc vagy gyógyulásbizonyíték.
Nem ismétlődő vak menekülés; ha nem oldja a takarást, felügyelői diagnózis kell.

Releasebuild és42képes replayPASS: pontosan egy oldalpróba, utána nincs vak ismétlés.
164534-play új futásban már2képen friss5860OCR. A takarás megszűnt, de ebben
a futásban a navigációs keleti mozgás oldotta fel, nem az új vészpróba;
az utóbbi élő kiváltása még nincs igazolva.

Új útvonal-konfliktus:164534/4–21az Island2-visszatérő gráf és házkarantén
ki-beviszi a karaktert ugyanazon kapun. A gyors input ezt gyors hurokká tette,
nem fejlődéssé. A23képen a haladásőr szabályosan leállította:12input/66px.
A felügyelő megszakítási kérésekor már befejeződött. Következő javítás a célválasztók
egyetlen tartós cél alá rendelése, nem újabb helyi irányfolt. HP5860.
