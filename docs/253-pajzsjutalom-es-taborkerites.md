# Pajzsjutalom nem HP; tábori kerítés — 2026-09-19

174428-observe/0friss helyzet: a tábor délnyugati sarkának külső oldala,
saját5,92K. Északra sátor/palánk, nyugatra szabad ösvény, keletre64HP-s
őrök és499HP-s fegyverőr a palánk mögött. Új élő futás még nem indult.

174156/3nyers cél-OCR: „0.50”,„64”,„0.5”, de a végsőHP5.
Ok: a0,5pajzsjutalmat a parser0és5számokra bontotta; az egyszer már
elrontott kisHP a temporális összerendelésben fennmaradt a64ellenére.
Javítás: önálló0.x törtjutalom (utána ikon-OCR lehetséges) nem célHP.
Nem tiltunk minden kisHP-t; valódi sérült cél egészHP-ja változatlan.
A level/statmezőben a0,5→5félreértés még külön hiba, nem megoldottnak állított.

Hipotézis: a hibás olcsócél-azonosítás megszüntetése stabilabb célt ad a
V2-nek. Navigációs siker csak a nyugati kerítésvég tényleges megkerülése,
majd belső cél elérése lesz; helyben álló őrmozgás nem bizonyít haladást.

Első regresszió FAIL:174156/6„0.” és„5” külön sorok,7képen64mellett
még5memória. Javítás kiterjesztve kizárólag szomszédos„0.”+„5”/„50”
jutalomtöredékre; önálló5HP és„0.”utáni64sor nem tiltott. Nem lazítjuk
a tesztet a hibás képkocka elhagyásával.

Második build és teljes174156célzott replay PASS; quick-farmreplayPASS,
beleértve friss2320sajátHP-t, közeli csíkmaradékot,1160képszéli ellenfelet
és narancskoponya-támpontot. Rövid élő kerítéskísérlet következik.

## Élő ellenőrzés — 17:48

174801/0–3: újratermett124HPfa előbb megközelítve,3képen516találat és
villanó fatest.8képen saját5,93K (korábban5,92K).17képen újabb516találat
szövege;29végkép tiszta5,93K, tábor déli–délkeleti nyílt oldala.
A kerítés belső oldalának elérését ez **nem** igazolja: a közeli fák elvitték
a prioritást, a kör farmolt. Pontos ölés/percet ebből nem állítunk.

Új korlát: a0.5helyett OCR1.5is megjelent (1kép), ez továbbra5HP-t
gyártott és2–3képre célmemóriába ragadt. A korábbi0.5/szétszakadás javítás
tesztje helyes, de **nem teljes pajzsjutalom-megoldás**. Következő: a csík
saját HP-sorának és felette lévő jutalomsornak geometriai elkülönítése,
nem minden új félreolvasott számalak egyenkénti javítgatása.

29végképen a környék több, korábban rövid hűtésű fahelyén **8h11m** kör.
Biztos megfigyelés az órás hűtés; következtetés: több kis farmhely is napi
keretre váltott. Egységes02:00körüli reset csak hipotézis. Nem szabad most
ezeket korlátlan négyperces farmként újracélozni; a tábor élő őrei következnek.
