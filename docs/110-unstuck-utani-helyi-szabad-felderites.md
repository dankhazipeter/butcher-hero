# Unstuck utáni helyi szabad felderítés

## Élő anomália

A `081746-play` sikeresen kiszabadította és teljesen visszagyógyította a hőst. A 32.
döntéstől azonban a normál minimapvezérlés rögtön a legközelebbi piros jel felé indult.
A bot közben bosselkerülést és 120 döntéses oldalirányú útvonalhűtést is használt, de
a 151. döntésnél ismét megjelent az `UNLOCKS AT ISLAND 4` zárfal. Jutalom vagy
farmcél nem került elő.

**Következtetés:** az Unstuck a pozíciót helyreállítja, de a minimap prioritása nem
változik. Ha a legközelebbi piros jel ugyanaz a zárt elit/boss, a normál navigáció
idővel visszaviszi ugyanabba a zsákutcába.

## Döntés

Sikeres Unstuck és 30 inputmentes gyógyulási ciklus után 120 döntéses, növekvő
négyzetspirál-felderítés indul. Ezalatt a régi piros minimapjel nem vezérel. A módot
azonnal megszakítja:

- biztonságos látható farmcél;
- szívfa vagy más normál célfelismerés;
- látható quest-sín;
- biztonságosan azonosított helyszíni láda;
- a korábbi prioritások szerint boss vagy friss sebzés.

A jutalomhiány-számlálót az Unstuck nem nullázza: az áthelyezés útvonaljavítás, nem
fejlődés. A 120-as ablak csak a helyi célkeresés navigációs prioritását módosítja.

## Ellenőrzési terv

1. A következő sikeres Unstuck után a 31. döntés még kivárás, a 32. már
   `helyi szabad felderítés` indokú swipe legyen.
2. Cél nélküli képen 120 döntésig ne szerepeljen minimap-alapú piroscél-követés.
3. Egy valódi szívfa/humanoid/láda/quest azonnal szakítsa meg a spirált.
4. Mérjük, hogy a 120 döntésen belül létrejön-e jutalom; ha nem, a spirálméret és a
   spawn körüli terep alapján új útvonalmodell kell.

## Replay-ellenőrzés

A `082205-replay` a ritkított `081746-play` képsoron a 31. replay-döntésig input nélkül
várt, majd a 32. döntéstől a minimap helyett növekvő szabad felderítést adott. A
közben megjelenő ismeretlen szintű fenyegetést a spirál biztonságos eltérítéssel
kezelte, a bossmenekülés után pedig visszatért a szabad felderítéshez. A prioritási
sorrend regressziója sikeres.
