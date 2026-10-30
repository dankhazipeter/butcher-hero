# Új 18,8K-s gólempróba: eredmény és kitérési hibák — 2026-09-19

## Valódi eredmény

203949-12e735ce-play/0–10: a269-ben megtalált nyugati megközelítésből
egyetlen kitérős kísérlet, **7060maximum,Bat13/Venom18,1,49KDPS**.
0–2:18800HPgólem, saját7060.3:valódi kontaktus,17,3Kboss/5,79Ksaját,
408+1,12Kkimenő és1,3Kbejövő találat.4:16,1Kboss, saját4,6K.
6:képen **13,5K**boss/3,45Ksaját; a gépi18,5Khibás OCR/azonosítás.
7:2260saját,8:1080saját.9–10:**YOU DIED,10,8Kboss**.
Legalább8Ksebzést okoztunk, nincs győzelem vagy jutalom. Az8-as bossfeliratot
sebzésszám takarja; a gépi9,12Kszöveget nem tekintjük biztos bossHP-nak.
11–20:automatikus újraéledés, a vezérlő nem kezdett új támadást.
204054-10fbdb9d-observe/0: **friss7060**, felgyógyulás igazolt.

## Konkrét hibák, nem „legyőzhetetlen” következtetés

1. 4-es képen a piros boss-csík látható, de a célfelismerés üres lett.
   A kiter a hiányzó távolságot999-ként kezelte, így regenerációba állt,
   miközben a boss mellettünk támadott. A célhiány nem biztonságbizonyíték.
2. A követő ellenfélhez számított kifelé irány SW→S-re fordult; délre
   háztető/szikla szűkítette az utat. A nyugati megközelítés nyílt volt.
3. A kiter korai visszatérései megkerülték az általános bossmemóriát.
   Halálkor a maradék10,8K-ból **10750-es vereségsáv** keletkezett, nem18800-ból.
4. A csík-/számfelismerés több ütköző számnál továbbra hibázik.

## Javítások és állapotkorrekció

- Regenerációba lépéshez ténylegesen látott,260px-nél távolabbi ellenfél kell;
  eltűnt cél mellett a kiter folytatja a kitérést.
- A hátrálás a próba eleji megközelítés rögzített visszirányát tartja,
  nem fordul a követő boss mozgásával a ház felé. Ez nem teljes visszaút-
  tervező: akadály/megakadás kezelése és térképkapcsolat még külön munka.
- A kiter kezdő bossHP-ja halál után is elérhető; ezt rögzíti a vereségmemória.
  Ismételt halál-overlay nem hozhat létre új, sérült-HP-alapú vereségsávot.
- Képi bizonyíték alapján `navigation-state.json`: hibás10750:7060eltávolítva,
  18750:5840→7060helyesbítve. A régi hibás adat e bekezdésben megőrizve,
  minden más sáv változatlan. Új alap20%-os küszöb **8472**, nem győzelmi garancia.

Nem indul automatikus újrapróba. Jelentős új taktikai bizonyíték külön
kísérletet indokolhat, de a mostani javítás sikerét még nem állítjuk élőben.
A keleti500szíves gólem korábbi győzelme továbbra igaz: nem minden
narancsfej egyforma nehézségű. Következő: nyerhető őrök és igazolt útvonalak.

## Ellenőrzés

Kiting-egységtesztPASS: elvesztett cél mellett ne álljon meg; követő ellenfél
ne forgassa el a visszirányt; kezdőHPmegmarad cancel/halál után; korábbi
kezdés/reset/haláltesztek. Release buildPASS.
**204345-626db9b5-replay/3–8:** végig−0,85/+0,52hátrálás,4nemvár.
9–10:kezdő bossHP18800;11–20halálutáni regeneráció, nincs újratámadás.
Replay nem bizonyít sikeres élőkitérést és nem változtat tartós játékállapotot.

Tartós regresszió:`tests/golem-kiting-contact-regression.sh`PASS:3–8rögzített
irány,4nemvár,9–10kezdő18800,11–20nincs input; öt állapotfájl előtte/utána
ellenőrzőösszege változatlan. Overlapping-contact/red-stub és quick-farm
regressziókPASS. Nem állítjuk a teljes történeti tesztkészlet sikerét.
20:46normál20sélőjáték következik, kiter és globális bossengedély nélkül.

204719-bfc7baa1-play/0–13:normálV2frontier önállóanNWirányban kijutott
aTitan-kőkörtől az úthoz;13képen északnyugaton1,22Kőr, délen töröttkőfal.
Nincs újgyőzelem és nincs nagyroham. Chart36,végpont−719,763/−701,508.
204817-a8174a7e-observe/0:friss7060, a következő biztonságos cél a
látható kisőr az út északi oldalán; ne a távoli nagy gólemhez térjünk vissza.
