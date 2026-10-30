# Rövid roham–visszahúzódás kísérlet — 2026-09-19

## Miért új próba, a korábbi bossvereség ellenére?

Nem a5840/18800HParány változott meg döntően. MostBat11+Venom16,1,30K DPS,
68regen áll rendelkezésre, de az érdemi új hipotézis taktikai: rövid támadás
után kifutni a hatósugárból, felgyógyulni, majd a megmaradt bossHP-t folytatni.
Eddig nem bizonyított, hogy a bossHP kint megmarad, hogy a boss utolér-e, vagy
a terep engedi-e a kitérést. Ezért külön kapcsoló és egyetlen korlátozott próba.

## Implementált mérési kapuk

`--kite-boss`: csak17,5–20Kközött felismert cél, friss saját95%HPés350pxközelség
indíthat.27,7K-cél láttán a kísérlet véget ér, nem szélesítjük a célt.
1,4s közeli kontaktus vagy82%alatti frissHPután távolodás;55%alatt megszakítás.
260pxen túl regeneráció;96%frissHPután következő roham. Legfeljebb3ciklus/90s.
Ha a korábban csökkent bossHP visszaáll99%ra, az inkrementális sebzés hipotézise
cáfolt és a próba véget ér. Eltűnés nem győzelem. Halál után nincs automatikus
ismétlés; a rendes gyógyulási/veszélykezelés veszi át.

A minimap csak a koponyához ad durva megközelítést, a helyi térkép kerülheti
az akadályt. Ez továbbra nem garantált út a magaslati rétegek között.
Minden eredményt képpel ellenőrzünk, és csak utána állítunk nyerhetőséget.

## Tesztek

FrissHP-kezdés, korai visszahúzódás, bossHP-reset miatti megszakítás,
ismétlés tiltása, rossz boss és halál külön szimulált.

## Élő eredmény és cáfolat — 14:51–14:55

Biztos: `20260919-145145-cae9073c-play/8–19` során valódi18,8K bosskontaktus,
majd YOU DIED. A19-es halálképen **12,4K** maradt az ellenfélből. A vezérlő
csak17,4K-ig követte, így a korábbi szóbeli17,4K eredmény hiányos volt.
A13-as képen saját4,57K és kb.1,3K bejövő sebzés; az OCR ezt régi5840
memóriának hagyta, a rövidült pixelcsík viszont már figyelmeztetett.

Hibák: takart numerikusHPmellett a próba nem vonult rögtön vissza; a piros
boss-csík elvesztése után a „nincs veszély” őr hamis teljesHPmemóriát használt.
Halálkor a HUD-bizonyossági kapu megkerülte a kísérlet saját állapotának lezárását,
így újraéledve folytatta és felülírta a rendes gyógyulási várakozást.
A44-es képnél a felügyelő megállította. `145333-observe/0`:5840, teljes gyógyulás.

Javítás: halál-overlay feltétlenül lezárja a kísérletet; a halál utáni regeneráció
elsőbbséget kap. Már az első hiányzó frissHPvisszahúzódást indít. Az utolsó
közeli piros csík nyolc képes emléke tiltja a hamis veszélytelen HP-visszaugrást;
ez **nem** önálló numerikusHPvagy tartós vereségbizonyíték. A régi akadálykerülő
nem írhatja felül a kísérleti biztonsági döntést. Cancel és takartHPteszt hozzáadva.

Döntés: normál farm folytatása, `--kite-boss` nélkül. Új18,8K vereségsáv5840,
alap20%-os újrapróba7008. A bossHP kint regenerálódása és a kitérés valódi
életképessége nyitott: a hibás próbából nem állítjuk, hogy a taktika lehetetlen.

## Visszaellenőrzés — 15:00

Release build és az összes korábbi regresszió sikeres, tartós állapot változatlan.
`150037-f8161cef-replay/13`: már visszahúzódás;14–17nem hamis veszélytelen
teljesHP.19–44: halál/gyógyulás miatt végig vár, nincs kitérős újraindulás.
Ez regressziós bizonyíték, **nem** új élő bossgyőzelem. A44képes sor bekerült
a tesztkészletbe külön5840HP-fixture-rel.
