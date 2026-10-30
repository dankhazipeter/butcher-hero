# Unstuck-időzár és HUD-visszacsatolás

## Második automatikus próba

A `docs/runs/20260829-070131-play` 60. eseménye megnyitotta a Settings panelt, a 61.
esemény pedig az ismert Unstuck helyére koppintott. A teleport nem indult el. A gomb
helyén `05:24`, majd csökkenő `04:48` körüli időzítő látszott, miközben a normál HUD
biztonsága végig 100% maradt.

**Biztos tény:** az Unstuck használata után többperces újrahasználati időzár él.
Időzár alatt ugyanarra a pontra koppintva a Settings nyitva marad, nincs teleport és
nincs medencegyógyulás.

## Feltárt veszélyes hiba

Az első állapotgép minden Unstuck-tap után vakon harminc ciklust várt, majd normál
mozgásra váltott. Időzár esetén ez a nyitott Settings panel mögött kezdett swipe-olni.
A futást felügyelten leállítottuk. A `docs/runs/20260829-070448-play` ideiglenes
ellenőrzése a bizonyított rózsaszín X-et a kép `(0,665; 0,127)` arányos pontján
megnyomva biztonságosan bezárta a panelt.

## Végleges képi visszacsatolás

Az állapotgép az Unstuck-tap után nem feltételezi a sikert:

1. minden tényleges döntési ciklusban méri a Settings-X jelenlétét és a HUD-biztonságot;
2. ha az X eltűnik vagy a HUD 90% alá esik, ezt teleportátmenetnek tekinti, és legalább harminc
   inputmentes döntést vár;
3. ha öt tényleges ciklus alatt az X végig megmarad, időzárat feltételez,
   megnyomja az ismert Settings-X-et, és normál játékra tér vissza;
4. sikertelen próbánál 900 tényleges döntéses újrapróbálási hűtés indul;
5. felhasználói aktivitás miatti várakozás sem az öt/harminc ciklust, sem a
   900 döntéses hűtést nem fogyasztja.

Ez nem OCR-rel próbálja kiolvasni a stilizált visszaszámlálást, hanem a teleport
biztos képi következményét ellenőrzi. Így új időformátum vagy részleges takarás mellett
is a biztonságos ág marad.

## Élő ellenőrzés és útvonal-megfigyelés

A végleges változat felügyelt hosszú futása: `docs/runs/20260829-070657-play`.
Az Unstuck utáni környezetben a bot 174 HP-s célt 321→284 pixelre közelített, majd
négy változatlan közelítés után elérhetetlennek minősítette. A 17 tényleges swipe-os
ellenirányú kiszakadás a `frame-00198→00240` képpáron jelentős kameramozgást és új
kerítésszakaszt mutatott. A köztes „felhasználó aktív” képkockák szándékosan nem
fogyasztották a számlálót; ez nem beragadás.

## Következő mérés

Az első pontot a `072159-play` megválaszolta: 192-es elit → Settings → Unstuck →
`YOU DIED` → 134 → 717 → 747 HP, megmaradó hét fegyverpéldánnyal. A HUD-visszacsatolás
helyesen különítette el ezt a korábbi időzáras, 100%-os HUD-jú sikertelen próbától.

A `075542/frame-00452` új bizonyítéka szerint sikeres `YOU DIED` alatt a HUD még 100%
lehet; az eltűnt panel-X ezért erősebb sikerjel. A `081017` valódi cooldownja
`01:45→01:43` volt. A 900 döntéses belső hűtés ezt biztonságosan meghaladja.
