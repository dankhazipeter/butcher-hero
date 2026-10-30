# Deep Mines-küldetésoverlay: a `0/1` nem 1 HP

## Élő anomália

A `docs/runs/20260829-133708-play` 140–162. képein a karakter visszaért a Deep
Mines alsó táborába. A fekete buborék szövege ismét:

`Find a magic anti-stone potion in Deep Mines` — `0/1`.

A 160. képen a játékos zöld HP-csíkja kb. 96%-os, a hiteles maximum 778 volt, de a
HP OCR-régió csak a buborék `0/1` sorát találta meg. A régi elemző ezt 1 aktuális
HP-nak fogadta el, kritikus visszavonulást indított, majd a pixelesen továbbra is
96%-os képeken 17 döntést várt friss numerikus megerősítésre. A 178. képen a 778
újra megjelent. Nem történt halál vagy valódi kritikus sebzés.

Ugyanebben a jelenetben a küldetésbuborék egyetlen képen `824` alakú OCR-zajt is
okozott. Ez sem új maximum; a fekete overlay számai nem játékos-HP adatok.

## Felismerési döntés

- A központi OCR-régió az `anti-stone` + `potion` egyedi kifejezéspárral külön
  `deepMinesPotionQuestVisible` állapotot képez. A `Deep Mines` torzulhat
  `Deep Hines/Nines/Wines` alakra, ezért nem kizárólag erre a két szóra építünk.
- Deep Mines- vagy Titan-feladatbuborék alatt minden aktuális numerikus HP-jelölt
  tiltott akkor is, ha egy részleges zöld komponens játékoscsíknak látszik.
- A korábbi hiteles HP-memória és a következő tiszta kép vezérel. A feladatbuborék
  külön HUD-bizonyíték, ezért a bot mozgásképes marad és nem áll ismeretlen képként.

## A bosscél-azonosság további szigorítása

A 133–135. képen a 20 HP-s kis cél ROI-jába a szomszéd `1.92K` felirata is belógott,
és ettől egy képen maga a kis cél is téves bossbizonyítékot kapott. Ezért az első
javítás önmagában nem volt elég. Ha egy aktuális célhoz konkrét HP tartozik, és az
kisebb `max(250, kezdő boss-HP / 8)` értéknél, az OCR-utótagos tartalék azonosság
nem alkalmazható. Valódi leütött boss csak a külön, közeli, irány-, test- és
bossbizonyítékos csökkenési ágon maradhat cél.

## Regresszió

A `docs/runs/20260829-134530-replay` kontrollált visszajátszásban:

- a 132–140. kép között a próba végig `1920→1920 HP`, a 20-as cél nem vitte le;
- a 140–141. képen az overlay felismerése mellett a játékos HP 778 maradt;
- a 141. képen a két teljes oldalkerülő és a `0/1` táborba visszaérés együtt zárt
  kaput adott;
- ezután a 600 döntéses hűtés elnyomta az újabb Deep Mines-útvonalkövetést.

Az új release build élő futása: `docs/runs/20260829-134633-play`.
