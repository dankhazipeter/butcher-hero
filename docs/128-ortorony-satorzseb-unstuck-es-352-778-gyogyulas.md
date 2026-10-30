# Őrtorony–sátorzseb: Unstuck és 352→778 gyógyulás

## Új zsákutca — `20260829-102651-play`

Az új U-útvonalas bináris a zöld medence környékéről indult. A szabad és
minimap-alapú mozgás a `frame-00048→00062` képeken egy tábori sátor, görbe fa
kerítés, őrtorony és sziklafal találkozásához vitte a karaktert. A képek eleinte
valódi helyváltozást mutattak, majd a karakter a kerítés alsó végénél teljesen
statikussá vált.

A döntő több különböző iránnyal próbálkozott. A 183. eseményig hat teljes, egyenként
hat végrehajtott swipe-ból álló statikus fázis gyűlt össze. Farmcél, boss és kiemelt
szívfa nem volt látható; a játékos teljes `778 HP`-n és Island 4 HUD-on állt.

Ez a zsákutca eltér a korábbi lila barlangtól és a zöld kaputól. Az élő eredmény
megerősíti, hogy a hatfázisú Unstuck-kapu valóban terepszíntől és konkrét
tereptárgytól független.

## Helyreállítás

- 183: a hatodik statikus fázis indul;
- 185: a bot megnyitja a Settings panelt;
- 186: egyszer megnyomja a bizonyított Unstuck gombot;
- 187: a karakter összeesett állapotban látszik a kerítés mellett;
- 203: a karakter már a zöld medencében fekszik, a képen friss `352` HP olvasható;
- 216: a medencében friss `778` HP látszik;
- 217: a helyreállítás lezárul és elindul a 120 döntéses védett helyi felderítés;
- 228: a karakter már a medencén kívül, teljes HP-n mozog a lila sziklafal mellett.

A `352→778` képsor újabb közvetlen bizonyíték arra, hogy az Unstuck büntetés nélküli
halál/újraéledést és medencés regenerációt használ. A Bat Cleaver-példányszám
mindvégig kilenc maradt.

## Elemzői anomália

A 203. képen a játék maga `352` HP-t mutatott, de a konzol a korábbi `778` értéket
memóriából tartotta, és csak a csíkot olvasta 86%-osnak. Ez a recovery szakaszban
nem okozott veszélyt, mert a döntő ott minden inputot tilt és kivárja a teljes
helyreállítást. A jelenséget később külön OCR-fejlesztésként érdemes kezelni, de
nem indokolja a biztonságos recovery logika megszakítását.
