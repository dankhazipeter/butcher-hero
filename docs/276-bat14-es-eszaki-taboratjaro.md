# Bat14 és északi táborátjáró — 2026-09-19

## Igazolt fejlődés

212550-01814ad7-play/1:499HPőr, /2–3közelharc. /4 (21:25:59)
közvetlen zöld14-es fegyverjutalom: **Damage650→700**,29m59s időzítő.
/5ugyanez és7,06K sajátHP, /10fegyversorBat14/Venom18. Az őrt legyőztük;
a felszerelt fegyver automatikusan erősödött. TeljesDPS-t ebből nem találunk
ki; új statpanelmérés kell. Várható újraélés21:55:58körül, nem garantált
korlátlan napi farm. A jutalomOCR üres/téves: képi felügyelő igazolta.

## Járható út újrafelhasználása

212136-028e4724-play/0–14 a nyugati kerítést észak felé kerülte, majd
keletre átment a kerítés vége és a havas kapu közötti nyílt területen.
Végigterrain-chart-36, minden köztes optikai mérésvalid; minimum27konszenzus,
maximum3,38reziduum. A0,1,3,4,6,7,10,11,12,13,14pontokat átvettem a
`navigation-v2-corridors.json` fájlba. Irányított és hely/célterülethez kötött;
nem globális út, nem fordítottirányú bizonyíték. NyugatiIsland2célra nem aktiválódik.
Pontos0,8érkezési sugár, minden lépés friss képi helyzettel, nem vak swipe-idő.

Az eredeti bejárás automatikus volt; az importált rövidítőfolyosó teljes
élő újrajátszása még nincs igazolva. A malomnál később felügyelői3×0,40sS
kellett a HP-takarásból kijönni(275), ezért a teljes spawn→jutalom láncot
nem nevezzük beavatkozásmentesnek. Új unit teszt: keleti belső célraNátjáró,
nyugati külső célra nem avatkozik be.

## Következő döntés

Batőr friss30perces hűtésen, keleti500szívfa napi kimerült; ne ismételjük
a tábor üres farmját.212550/16malomtólNW, zárt havas kaputólS, saját7060.
Friss képből a nyugati/Island2terület további aktív fegyverőrei következzenek.

UnitPASS: normál39/gyorsított37/vékonykapu18input, korábbi invariánsok és
újchart36keleti cél→Nátjáró/nyugati cél→nemátjáró. Nem teljes élőismétlés.
212830-4d0abea2-play/11: újra a zárt havas kapu délnyugati kőfala előtt,
Deep MinesNPCészaki oldala. Frontier nem értelmezte a zárt kaput mint
területi tilalmat; ezt nem folytatjuk változatlanul. Chart58,világ
(-299,7464,-333,7930),V2(-13,4886,-15,0207). Nincs új jutalom.
Felügyelői3×0,40sS kijutás a nyílt NPCudvar felé, friss végpontkép szükséges.

212956-43cb73d1-observe/0: a3S csak kis elmozdulást hozott, nem kijutás.
A karakter még a zárt kapu mellett, délnyugatra a ponyvás szekér/NPC.
Következő3×0,40sSE a képen nyitott útra; nincs változatlan északi frontier.

213049-89c23b2f-observe/0:3SE után a kapu alatti észak–déli nyílt úton,
friss képen7,06K,Bat14/Venom18. A falzseb elhagyása igazolt, de ez felügyelői
korrekció. KövetkezőS az úton, majd nyugati/Island2bejárat, friss célkeresés.
Nincs futó hosszú felügyeletlen bot; heartbeatACTIVE visszaellenőrizve.
