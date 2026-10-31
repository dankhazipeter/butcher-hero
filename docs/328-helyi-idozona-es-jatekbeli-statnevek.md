# Helyi dátumok és eredeti játékbeli statnevek

2026-10-31. A felhasználó már nem Romániában van: a dashboard időpontjai
egy órával későbbiek. A magyar felületen is a játék eredeti angol statneveit
kérte, mert a játék nem magyar nyelvű.

## Bizonyított ok és döntés

A dashboard/app.js fix Europe/Bucharest zónát adott minden formatternek,
a server.py pedig ugyanezzel számolta a Ma éjfelét és a naiv customidőt.
A rendszer /etc/localtime linkje most Europe/Budapest. Az eltérés a
megjelenítésben/szűrésben volt; a napló UTC-időpontjait nem kell eltolni.
Az ellenőrzéskor13190jutalomnapló-időpont mind explicit UTC/offsetes,
0naiv. Történeti naplóhoz/reconcile-hoz nem nyúltunk.

## Megvalósítás

A böngésző Intl.DateTimeFormat().resolvedOptions().timeZone eredményét
használjuk és minden pollnál újraellenőrizzük. OS-zónaváltáskor a következő
poll újraalkotja a formázókat és új zónával kér adatot. Nincs geolokációs
engedély, külső szolgáltatás, rögzített magyar zóna vagy kézi egyórás levonás.
Nyelvváltás a szöveg-/számformátumot módosítja, nem a zónát.

Az API timezone queryje IANA ZoneInfo-validált. A Ma a kért zóna helyi
éjfelétől számol, DSTnapokon is; a from/to datetime-local falióraidő
ugyanebben értelmezett. ExplicitZ/offsetes bemenet azonos pillanat marad.
HiányzóAPIzone UTC, hibás/többszörösparaméter hiba. A tavaszi óraátállítás
nemlétező helyi ideje elutasított; az őszi ismétlődő falióraidő elsőfoldja
az alapértelmezés, explicitoffsettel egyértelmű időpont adható az API-nak.
Utazáskor az aktív custommezők szövegét megőrizzük, az új kijelzett zóna
szerint értelmezzük; inaktív mezők az új helyi most/előzőóra értékre állnak.

A statnevek a HU és EN katalógusban is változatlan játéknevek:

- Health és Health Regen;
- Pierce Damage, Cut Damage, Smash Damage;
- Pierce Defense, Cut Defense, Smash Defense.

A kártya, összesítettgrafikon-jelmagyarázat, lista, tooltip és ARIA ugyanazt
a labelOf útvonalat használja. A többi UI-szöveg magyar marad, a számok
magyar tizedesvesszősek. Az ismeretlen jutalom nem játékstatnév, azt továbbra
lefordítjuk. Új nyelvi fájlnál is kötelező az angol statnévkészlet.

## Regresszió és határok

Három új Pythonunit: Budapest/Bucharest/NewYork helyi éjfél/custom/UTC,
óraátállítás és nemlétező helyi idő, hibás/többszörös zóna. A meglévő HTTP
teszt zónametadata és400ellenőrzéssel bővül. A korábbi Bucharestteszt nem
tűnt el: explicit zónakérésként maradt meg.

Három új Node-regresszió: tényleges app.js dátum-/APIkérés három zónában,
nyelvváltástól független idő, poll közbeni utazás/customkérés, valamint
a nyolc rögzített angol statnév minden katalógusban. A meglévő magyar
név-elvárásokat a felhasználó kért új szerződése miatt Health-re cseréltük,
nem képfelismerő ground truth módosításaként. Előbb mindkét tesztkör
reprodukálta a régi hibát, utána átment.

A gyűjtőképfelismerés és input nem változott. A backend betöltéséhez a
közös runner rövid stop/startja szükséges, --resume-run megőrzésével.
A korábban jelentett GitHub4launcher-startuptimeout külön nyitott ügy:
e feladat nem javítja és nem lazítja annak tesztjeit. A távoliCI sikerét
nem állítjuk a helyi futásokból.

## Betöltés és élő ellenőrzés

A teljes helyi173teszt és7JSsyntax sikeres (69Swift,22statPython,
7game,3git,10supervisor,19launcher,43Node). A legutolsó üreszone-HTTP
validálás után a22Python teszt külön is újra átment; commit/push kapu
a végső teljes fájlkészletet ismét ellenőrzi.

Aktív kristály/event/pendingFree tranzakció nélküli ponton a saját közös
runner stop/startja történt, resume megőrzéssel. Napló:21:17:09.087Z
watcher_stopped →21:17:09.646Zwatcher_resumed, kb.0.56s különbség.
Új watcher_started nincs. Új runner80593/dashboard80612/supervisor80613/
worker80614, execsession74565; a PID-ek történetiek, runtimeJSON a forrás.
21:17:41.373Zúj Health18100claim_confirmed_ui, friss sikeres képidők.

A valódi API Ma+Europe/Budapest kérésére a kezdet2026-10-30T23:00Z,
azaz helyi október31éjfél. Új háttér-IABtesztlap tényleges UI-ja
22:18:32frissítést, Europe/Budapestzónát, angol Health/HealthRegen és
mindhárom damage/defensepárt mutatott magyar környező szöveggel.
A21:17:39Zkattintás helyesen22:17:39ként jelent meg a listában.
A régi lap visszakötése eszközhibát adott, ezért azon nem állítunk
sikeres reloadot; a felhasználó egyszer frissítse saját lapját.
Helyi kép: .build/ui-proof/dashboard-local-time.jpg, nem Gitbe küldött
személyes statisztika. Nincs logjavítás vagy korábbi jutalom újrakönyvelése.
