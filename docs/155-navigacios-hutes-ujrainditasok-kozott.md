# Navigációs hűtések megőrzése fejlesztési újraindítások között

## Probléma

A bot a Titan `0/7` oltárát és a zárt Deep Mines-kaput folyamaton belül 600
döntésre helyesen lehűtötte. Egy kódjavítás miatti újraindítás azonban lenullázta
ezt a memóriát. A következő folyamat ezért ismét a lila oltárhoz, majd a már
kétoldalról kipróbált kőkapuhoz ment. Ez nem új felderítés, hanem fejlesztési
újraindításból eredő útvonalveszteség.

## Döntés

- Új helyi gépi állapot: `docs/navigation-state.json`.
- Sikeresen felismert Titan-feladat vagy bizonyított zárt Deep Mines-kapu a
  folyamatbeli 600 döntés mellé 420 másodperces falióra-lejáratot ment.
- Új élő folyamat a még hátralévő időből becsült döntésszámmal folytatja a hűtést;
  nem tölti automatikusan újabb teljes időre.
- A visszajátszás sem nem olvassa, sem nem írja ezt az állapotot, így a regresszió
  determinisztikus és egy korábbi élő futás hűtése nem rejti el a tesztelt ágat.
- A fájl csak navigációs lejáratot tartalmaz. Nem állítja, hogy gemet szereztünk,
  kaput nyitottunk vagy bosst győztünk le.

## Mi marad nyitott

A tartós állapot később bővíthető az utolsó biztos Titan-gemszámmal, de ehhez előbb
valódi `1/7` vagy nagyobb képi minta kell. A jelenlegi `0/7` ismeretből nem szabad
gemprogressziót feltételezni.

## Ellenőrzés

A release build sikeres. A következő élő Titan-/kapufelismerés hozza létre vagy
frissíti a JSON-fájlt; az azt követő szabályos fejlesztési újraindításnál mérendő,
hogy a bot nem célozza-e újra azonnal ugyanazt a helyet.
