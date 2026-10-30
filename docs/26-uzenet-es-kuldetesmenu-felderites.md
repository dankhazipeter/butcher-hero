# Piros jelzésű boríték biztonságos felderítése

## Miért most

A `233720-play` Bat Cleaverrel 111 DPS-en fut, de a medence–Island 4 környezetében a
korábban legyőzött célok `2h 18m–2h 22m` újratermelődési időt mutatnak. A bot a minimap
és a négyzetspirál segítségével ténylegesen több területen mozog, mégsem talál új
főképi HP-csíkot. A puszta járőr ezért ebben az állapotban nem ad tartós fejlődést.

## Képi jel

A képernyő bal felső részén a fogaskerék mellett fehér, piros pecsétes boríték látszik.
A piros pecsét/értesítés arra utalhat, hogy üzenet, küldetés, jutalom vagy útmutatás
érhető el. A pontos funkció még ismeretlen.

## Hipotézisek

1. küldetés-/achievement lista átvehető, játékbeli jutalmakkal;
2. üzenetek vagy rendszerértesítések;
3. napi jutalom;
4. külső, reklámos vagy fizetős ajánlat — ezt nem aktiváljuk.

## Biztonságos protokoll

1. legalább 24 tényleges döntésen át nincs biztonságos főképi cél;
2. játékos-HP legalább 90%, normál HUD biztos;
3. egyetlen tap kb. a kép 13,6% szélesség / 7,7% magasság pontján;
4. a program külön `mailInspectionMode` állapotba lép;
5. az új képernyőn kizárólag vár és képet ment; nem vesz át jutalmat, nem indít reklámot,
   nem vásárol és nem nyom ismeretlen gombot;
6. képi audit után dokumentáljuk a menüt, majd külön megtanított művelettel zárjuk vagy
   csak egy bizonyítottan ingyenes, visszafordítható lépést hajtunk végre.

## Elfogadási feltételek

- pontosan egy nyitó tap;
- legalább egy tiszta mentett PNG;
- a nyitás után minden döntés `VÁR`;
- minden szöveg, számláló, jutalom- és bezárási lehetőség dokumentálva a következő hosszú
  farmfolyamat előtt.

## Eredmény — `234301-play`

A 46. esemény pontosan egyszer koppintott `(85, 66)` pontra. A 47. eseménytől minden
döntés várt; második tap vagy swipe nem történt. A `frame-00047.png` tisztán mutatja:

- fejléc: `MAILBOX`;
- középen: `You have no Mails yet`;
- alul két lap: `INBOX` és `ARCHIVE`;
- jobb felső rózsaszín X, amelyet a meglévő `popupClose` detektor felismer;
- nincs jutalom, számláló, reklám-, vásárlási vagy átvevő gomb.

Biztos következtetés: a boríték postafiók, jelenleg üres. A rajta lévő piros pecsét a
boríték grafikája, nem aktív értesítési jel. Az Archive megnyitása nem indokolt, mert
nincs levél, és nem ad fejlődési lehetőséget.

## Programdöntés

A kutatás lezárt. Új folyamat nem nyitja meg automatikusan a Mailboxot. Ha a képernyő
nyitva maradt, a biztos rózsaszín X-et a közös popup-bezáró ág megnyomja, majd folytatja
a normál játékot.
