# Iránymenti haladás és több kerülőszög — 2026-09-19

`151848-9e71493d-play/9–20`: a DOCszélmalom melletti kerítésnél a kért
délnyugati irány helyett4–6pixeles északnyugati csúszást mértünk.
A puszta elmozdulás nagyobb volt4pixelnél, ezért a bot sokáig haladásnak vette.
Ez nem a cél felé tett előrelépés; a12ismétlés új javítást indokolt.

Javítás: a világképből mért elmozdulás skalárszorzata a valóban elküldött
irány egységvektorával adja az előrehaladást. Két elégtelen input után az
adott irány helyi akadályjelölt lesz. Küszöb4–12px, a mért sebesség/inputidő
12%-ával skálázva; gyorsító mellett sem siker a lassú falcsúszás.
A sebességtanulás és a150px-es kerülő befejezése is iránymenti mozgásból számol.

A kerülőjelöltek eddig csak±90°és180°voltak. Most±45°,±90°,±135°,180°;
helyi blokkok és látogatottság rangsorolnak. Így egy átlós célhoz tisztán
déli vagy keleti kijárat is kipróbálható. Ez keresési heurisztika, nem igazolt
járhatóság; minden inputot új kép ellenőriz.

Nyitott: DOCkülső/belső réteg biztos topológiai címkézése, teljes farmkör,
a ritka mozgásirányok kalibrációja. Az új élő próba következik.

## Élő próba és következő szűk javítás

`152443-6312276c-play/5–15`: az új45°-os lehetőségek valóban keleti és
déli mozgást adtak; kijutottunk a korábbi szélmalom–szekér helyről.
31képen a DOCkeleti ház–szikla zsebében a jobb szélső vörös kődarab
hamis HP-csík lett: nincsOCR, nincs testsziluett,0,10csíkkeretbizonyosság,
de a háttérből hamis szívikon keletkezett. Ezt a képen nem tekintjük ellenfélnek.
A bot emiatt távoli célközelítés/eltűntcél ciklussal keletre erőltette az utat,
kikerülve a térképes réteget.

Javítás: a180pxnél távolabbi csík megközelítése és eltűnt cél után menés is
navigáció. A helyi akadálymérés és az esedékes, frissen helyhez kötött farmcél
felülírhatja. Közeli harc, veszély és biztos visszavonulás nem változik.
