# Egyszámjegyű K-csonkolás: 92 és a szélescsík-őr

## Élő bizonyíték

A `20260829-051233-play` 228–232. eseményén a jobb képszéli, ismeretlen szintű,
nem-fa cél HP-ja `92`, majd ismét `92` volt. A célcsík körülbelül 57 px széles
maradt, az OCR pedig a 232. képen már `192` nyers szöveget is adott. Ugyanez a
cél a megelőző `050827-play` futásban teljesebben látható helyzetben `1927` volt,
ezért a `92` nem olcsó cél, hanem az `1.927K` végződésének képszéli csonkolása.

A bot a régi, csak 20 alatti szélescsík-őr miatt a `92`-t még elfogadta és
233→201 px-re közelítette. A játékos röviden 747→741/742 HP-ra esett, majd
visszagyógyult. A sebzés célhoz rendelése nem teljesen biztos, de a célbiztonsági
hiba a korábbi 1927-es azonosság miatt ettől függetlenül bizonyított.

## Döntés és regresszió

Ismeretlen szintű, nem-fa, legalább 45 px széles célcsíknál mostantól minden
100 alatti OCR-HP tiltott. Ez a K-jelölés elejének elvesztését és az ezres érték
utolsó két számjegyre csonkolását együtt kezeli. Az ismert szintű célokra a szabály
nem vonatkozik.

A javított replayben a `051233/frame-00228` és `frame-00232` már nem adott biztonságos
célpontot. A `030113/frame-00222` ismert 1-es szintű, 67 HP-s fenyője továbbra is
farmcél maradt, tehát a kezdőterületi biztos célokat az új őr nem tiltja.

## Utólag feloldott érzékelési anomália

Az új `20260829-052132-play` futásban a 253-as cél boss-jelölése egyes képeken
felvillant, majd a következőn eltűnt (`frame-00048→00050`, illetve
`frame-00073→00074`). Első hipotézisként pozícióalapú boss-hiszterézis merült fel.
A későbbi `levelOCRNumbers` diagnosztika ezt pontosította: a közvetlen kiváltó ok
a szomszéd 253 HP-jának statikonrégióba lógása, illetve külön esetben egy mínuszos
lebegő sebzésszám volt. A megoldást és regressziót a
`89-szomszed-253-hamis-boss-es-fuggetlen-statikon-or.md` rögzíti.
