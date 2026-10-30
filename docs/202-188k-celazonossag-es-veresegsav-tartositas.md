# 18,8K célazonosság és vereségsáv-tartósítás

## Az észlelt hiba

- A `20260830-102327-play` Island 2-i harcában ugyanaz a boss az egymást követő
  képeken `18,8K`, majd egyetlen képen csak `8K`, utána ismét `18,8K` HP-val
  szerepelt.
- A régi elemző a hibás `8K`-t új, engedélyezhető vereségsávnak tekintette,
  ezért a 18,8K-s tiltás ellenére kontrollált támadást kezdett.
- A boss 18,8K-ról körülbelül 17,2K-ra sérült, miközben a 4450 maximális HP-jú
  karakter mintegy két másodperc alatt meghalt. Ez bizonyítja, hogy sebezhető,
  de a jelenlegi életerő/DPS arány még nem elegendő.

## Javított célazonosság

- Az elemző 12 képkockán át megőrzi a legalább 10K-s, explicit tizedes-K alakban
  felismert boss HP-ját és képernyőpozícióját.
- Ha ugyanazon a helyen, legfeljebb 90 pixeles eltéréssel csak egy durva `8K`,
  `8:K` vagy `8.K` olvasat jelenik meg, a bot az előző hiteles 18,8K-s értékkel
  folytatja a cél követését.
- Ez célazonossági korrekció, nem általános HP-felülírás: távoli vagy tartósan
  más helyen álló valódi 8K-s ellenfelet nem minősít át.

## Javított vereségmemória

- A halál pillanatában a boss aktuális HP-ja már kisebb a kezdőértéknél. A régi
  logika ezért tévesen 17,5K/17,0K/17,25K sávokat is létrehozhatott.
- A bot most a kontrollált próba kezdeti boss-HP-ját tartja meg, és halálkor ezt
  az egyetlen sávot írja a tartós állapotba.
- A hibás rész-sávokat és a hamis 8K-s bejegyzést eltávolítottuk. A hiteles
  állapot: `18750: 4450`, tehát a következő automatikus próba 5340 saját maximum
  elérésekor engedélyezhető.

## Regressziós bizonyíték

- A `20260830-103823-replay` 16 kivágott harci képkockán futott.
- A korábban hibás képkockát már 18,8K-ként értelmezte; az egymást követő
  célértékek 18,8K, 18,8K, 18,8K maradtak.
- A fordítás és a visszajátszás sikeres. A javított binárissal külön élő
  Island 2-ellenőrzés következik.
