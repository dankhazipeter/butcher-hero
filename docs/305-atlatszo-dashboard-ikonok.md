# Átlátszó ikonok minden statisztikai háttéren — 2026-10-30

## Megfigyelés és ok

A felhasználó képe szerint a „Mikor, mit, mennyit?” táblázat törtfehér
hátterén fehér négyzetben jelennek meg az ikonok. A fehér statkártyákon
ez nem volt feltűnő. A nyolc dashboard/icons PNG már kis RGBA fájl,
átlátszó sarokkal; az eddigi automata teszt ezt igazolja.

A bizonyított ok a dashboard/style.css két explicit background:#fff
deklarációja: a statkártya/táblázat közös szabálya és a darabgrafikon
jelmagyarázatának képszabálya. Nem a képekben van a fehér csempe.

## Döntés és változás

Mindkét deklaráció background:transparent lett. Így a kép mögött a saját
felület háttere látszik, világos/sötét színsémától és elhelyezéstől függetlenül.
A méretek, belső térközök és a PNG-k változatlanok. Ez felülírja a294-es
fehér CSS-háttér döntését. A felismerési képsablonokhoz nem nyúlunk.

A Sites készség helyi-only munkamenete szerint a meglévő szervert használjuk;
nincs felhős publikálás. A statikus fájlt a szerver kérésenként olvassa,
sem a szervert, sem a gyűjtőt nem kell újraindítani. A nyitott lapot újra
kell tölteni az új CSS-hez; az adatpoll önmagában nem tölti újra a stíluslapot.

## Ellenőrzés és korlát

A tests/reward_format.test.cjs új tesztje mindhárom ikon-szelektor minden
background/background-color deklarációján kizárólag transparent értéket
enged. A meglévő nyolc PNG-alfa ellenőrzés is megmarad. Az új teszt ugyanabban
a teljes helyi és GitHub push/PR-kapuban fut, nem csak külön kézi ellenőrzés.

Böngészős újratöltés nem sikerült: a meglévő lapokon a kapcsolat
„browser.user is unavailable” hibát adott. Nem állítunk friss vizuális PASS-t.
A kiszolgált CSS-t HTTP-n és a teljes regressziót külön ellenőrizzük.

Eredmény: a HTTP-válasz mindkét szabályban transparent értéket tartalmaz.
A teljes kör23Swift+15statisztika+3Gitkapu+9felügyelet+13Node tesztje
és a3JS-szintaxisellenőrzés sikeres.20:48:05Zkor ugyanaz a66095worker
friss képidővel működik; nincs a javítás miatti újraindítás.

A gyűjtő66095 folyamata és friss lastCheckedAt értéke megmaradt;
a javítás nem módosít jutalomnaplót, összesítést vagy játékinputot.
