# Hajókonkáv és helyhez kötött visszaút — 2026-09-19

## Biztos mérés

`132005-361fb55b-play` a zöld oldalon ismét a kék hajó alá ment az általános
WNW kereséssel. Nem helyes ezt bárhonnan „kimért kapuélnek” nevezni.

Kijutás képi ellenőrzéssel:

- `132138-7a392b52-nudge`: 5 kelet,0,55s; `132209-observe/1` a sziklacsoportnál.
- `132305-a5d04e9a-nudge`: 3 dél,0,50s; `132311-observe/1` kövezett út a szikla alatt.
- `132413-f512a2ff-nudge`: 6 WNW,0,50s; `132440-observe/1` az Island2 kapu zöld oldala.
- `132547-683342a5-nudge`: 5 WNW,0,50s; `132621-observe/1` a narancs oldalon.

WNW: normalizált(-1,-0,25). Ez egy konkrét kiindulási helyről igazolt út,
nem minden zöld területre érvényes navigációs szabály.

## Következő futás és új akadály

`132918-969a9f36-play` helyi célokkal5730→5750 kijelzett maximumot ért el,
majd a déli765-ös kaktuszhoz a kerítésen át próbált közelíteni. A kerülő
keletre, az épülethez szorította; a felügyelet a62. kép után leállította.
Új hipotézis: a nyugati falvéget kell megkerülni. `133040-nudge`6W után
`133102-observe/1` az út nyugati oldalát, szabad déli folyosót mutatja.
A további6S (`133139-nudge`) a kerítés északi oldaláig ért;3W (`133246`)
a nyugati végén túlra vitt. Innen2S (`133333`),3 enyhe ENE (`133445`), majd
egy0,35s-os(1,-0,45) finomítás (`133538`) valódi kontaktust adott.
`133558-80011c16-observe/0`: a765-ös kaktusz helyén5m41s újratermelődési kör,
tehát a győzelem biztos. A jutalom közvetlen effektusát nem rögzítettük.

## Programdöntés

A helyi útvonalgráf több független, biztonságos kijárati végpontot is kezeljen.
Nem erőltetjük minden helyet ugyanahhoz a globális célhoz. Továbbra is pontos
képi belépési egyezés és élenként igazolt érkezés kell; új él csak mért végponttal.

A nyugati kerítésvégi részgráf három éle bekerült. Mért felső korlát6W,6S,3W;
az első élen a4. lépés után már megérkezünk, az utolsó két kézi W felesleges volt.
A regressziós aláíráslánc ezeket az érkezés utáni ismétléseket kihagyja, hogy a
következő élt ne hamis, még az előző irányból származó képekkel tesztelje.
Mindhárom érkezés ellenőrzése sikeres. Ez továbbra visszajátszás, nem élő
automatikus láncpróba; azt külön kell igazolni.
