# Egyszeri ládamemória, tartós vereségsáv és Unstuck-időzár

## Új játékszabály: a különleges láda egyszeri

A magaslati, keskeny hidakkal és párkányokkal tagolt helyeken a különleges láda
egyszer szerezhető meg. A láda eltűnése után a helynek nincs közvetlen farmértéke,
de hosszú távon egyszer érdemes minden ilyen zónát felderíteni. A bot ezért már
nem pusztán geometriai akadályt, hanem célállapotot is őriz:

`ismeretlen → láda látható → nyitás/jutalom igazolt → begyűjtött egyszeri irány`.

Ha ugyanazon képi csomópontból a begyűjtett irány felé indulna, és nincs friss
láda-, küldetés- vagy ellenfélbizonyíték, oldalirányú új területet választ, majd
nyolc mozgásig tartja a kijutást. A már a szemantikus memória bevezetése előtt
kifosztott magaslati helyeket a bot csak új megfigyeléssel tudja lezárni; ezért a
zsákutca- és veszélymemória is védi a visszatérést.

## Fix akadályok és lezárt irányok

A `docs/world-map.json` minden helyi háttéraláíráshoz nyolc irány kísérleteit,
blokkolását és sikerét tárolja. A mostani bővítés:

- két nettó blokkolás után jobb oldalirányú kerülő indul;
- a választott kerülő nyolc swipe-ig zárolt, hogy a minimap ne fordítsa azonnal
  vissza ugyanabba a kerítésbe;
- négy blokkolás és nulla siker után az irány tartós zsákutca;
- valódi későbbi helyváltozás feloldhatja a zsákutca-jelölést;
- emberi használat miatti kihagyásból továbbra sem tanul falat.

A `20260829-172808-play` 22–26. döntése már lehűtött minimap-irány helyett
oldalirányú felderítést adott. A 71–88. döntés hosszú területelhagyást futtatott.
A 102. képen a karakter ismét normál zöld terepen volt, de egy íves fakerítésnél;
ez igazolta, hogy a magaslatról kijutás és a helyi kerítéskerülés külön probléma.

## A 18,8K-s ellenfél tartós vereségsávja

A 25-ös statikonú, 18,8K HP-s páncélos egy valódi érintkezésben 984-ről 94-re
vitte a játékos HP-ját. Ez nem azt jelenti, hogy örökre legyőzhetetlen, hanem azt,
hogy a jelenlegi erőn nem érdemes ugyanazt mérés nélkül újra és újra próbálni.

A `navigation-state.json` ezért a boss HP-sávját és a kudarc idején ismert saját
maximumot együtt tárolja. A 18,8K-s sáv 984-es erőn bizonyított kudarc. Új próba
csak legalább 20%-kal magasabb hiteles maximumnál, vagyis jelenleg legalább
1181 körül indítható. Addig a látható boss irányával ellentétes területelhagyás és
600 döntéses útvonalhűtés indul. Más HP-sávú ellenfelek ettől még külön
kontrollált próbát kaphatnak.

## Unstuck: siker és időzár megkülönböztetése

A `172808-play` 154. döntése hat statikus kiszabadítási fázis után megnyitotta a
Settings panelt, a 155. pedig megnyomta az Unstuck helyét. A gombon azonban
`04:39` visszaszámlálás futott, ezért teleport nem történt.

Az elsötétített Settings-háttér 80%-os ál-HUD-biztonságot adott. A régi `<90%`
feltétel ezt téves sikernek tekintette, harminc képet várt, majd a nyitott menüre
küldte a mozgásokat. Ez garantált álhaladás volt.

Javított bizonyíték:

- a bot előbb megvárja a Settings saját, külön detektorral mért X-ét, és csak
  ezután nyomja meg az Unstuck helyét;
- sikeres Unstuck: a korábban biztosan látott Settings-X eltűnik;
- időzár: az X öt képen át megmarad; a bot bezárja a panelt és 900 döntésre
  lehűti az új Unstuck-próbát;
- nyitott Settings panelre navigációs swipe nem kerülhet;
- kézi bezárás után a játéktér 984 HP-val, a sátor és az íves kerítés mellett
  sértetlenül visszatért.

A javított teljes replay a 153–154. képen várta a panelt, a 155. képen nyomta meg
az Unstuck helyét, majd az ötödik változatlan panelképen, a 160. képen az X mért
közepére koppintott. Nyitott panelre a javított élő állapotgép így nem lép tovább.

## Következő mérés

A következő élő futásban két dolgot kell külön ellenőrizni: a hűtött Unstuck után
a Settings valóban öt képen belül bezárul-e, illetve a tartós zsákutca- és
egyszeri ládamemória megakadályozza-e a visszafordulást a kifosztott magaslatra.
