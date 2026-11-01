# Gördülő statösszegek — 2026-11-01

## Kérés és választás

A Növekedés kártyáin a felpörgő CountUp helyett a régi feliratot váltsa
az új, iOS-szerű függőleges gördüléssel. Nagy K/M értéknél is legyen
észrevehető, melyik stat frissült.

Átnézett elsődleges források:

- [NumberFlow](https://number-flow.barvian.me/): gördülő számváltás, külön
  spin/opacity időzítés, kompakt Intl-formátum és reduced-motion támogatás.
- [Element.animate](https://developer.mozilla.org/en-US/docs/Web/API/Element/animate):
  a böngésző natív képkocka-animációs API-ja.

A felület továbbra is saját, játékhoz igazodó pontos K/M-formátumát használja.
Nem vettünk fel új függőséget: két teljes felirat mozog natív animációval,
nem számjegyenként számolunk köztes értékeket. A CountUp runtime script
kikerült az oldalból; régi pinelt forrása/licence megmaradt, dokumentáltan
nem aktív függőség. Nincs új szerverútvonal vagy backend-betöltési igény.

## Viselkedés

- 650ms: régi felirat felfelé távozik, az új alulról érkezik, enyhe áttűnéssel.
- A pontos nyersérték változása indít, nem a kompakt felirat különbsége:
  100000000→100018300 esetén mindkét címke +100M, mégis látszik a gördülés.
- Kezdeti render, nyelv-, időszak- és munkamenetváltás nem új jutalomjelzés.
- Változatlan poll nem indítja újra a mozgást. Gyors új érték megszünteti a
  korábbi két effektet; régi callback nem írhat vissza elavult értéket.
- Kimenő réteg aria-hidden; pontos aktuális title/aria továbbra az appból.
- Reduced motion, rejtett lap vagy hiányzó/hibás API esetén azonnali pontos
  felirat. Befejezés és külső cancel eltakarítja mindkét ideiglenes réteget.
- Csak megjelenítés: összeg, K/M-csonkolás, típus, percátlag, napló és
  grafikonadat változatlan. Nincs Number-konverziós egészpontosság-korlát.

## Ellenőrzés

9 új natív animációs teszt váltja az 5 CountUp-specifikus tesztet. Ellenőrzik
a két végfeliratot/képkockákat, azonos +100M-et, egységhatárt, nagy pontos
decimális stringet, csökkenést, gyors frissítést, stale callbacket, scope-ot,
reduced motiont/rejtést, fallbacket és takarítást. Teljes kapu228teszt+
7JS-szintaxisellenőrzés sikeres; commit/push hook ugyanezt újrafuttatja.

Izolált loopback böngészőtesztben tényleges WAAPI transformok mindkét
rétegen, hidden overflow és45px változatlan magasság ellenőrzött. A +100M
is mozog; befejezéskor +36,6K és +100M, nincs rétegmásolat. A próba
szándékosan szintetikus adatokat használ, nem ír éles statot/naplót.
Helyi, nem commitolt képek: `.build/ui-proof/341-rolling-*.png`.

Az élő dashboard8kártyája új tesztlapon rendben megjelent; a régi lapot
egyszer újra kell tölteni. A gyűjtő frissképes/idle maradt, fejlesztési stop
vagy backendrestart nem történt. Ez UI-igazolás, nem új felismerőjavítás.
