# Kiemelt szívfa felülírja a küldetésutat

## Élő elvesztett lehetőség — `20260829-033451-play`

A 7–10. eseményben egy biztos 10-szíves, 174 HP-s fenyő 236→194→182 pixelre került.
A `Target` minősége erős volt: `treeConfidence=0,398`, `heartIconEvidence=0,108`,
szint/statikon 10, HP 174. A 11. döntés mégis a türkiz Deep Mines-útvonalat követte,
mert az általános közeli cél küszöbe 180 pixel volt. A fa mindössze két pixellel maradt
kívül, majd a hűtő 197–198 pixelen is elfordította tőle a botot.

## Hozamérv

A korábbi 10-szívfák biztosan +10 max HP-t adtak. A 431 HP-s 20-szívfa már egyetlen
486-os normál találatból +20-at adott, ezért a 174 HP-s fa is gyakorlatilag azonnali,
biztonságos jutalom. Egy ilyen cél többet ér a még nyitott, bossokkal szegélyezett
Deep Mines-küldetésút néhány másodperces előrehaladásánál.

## Programdöntés

Kiemelt szívfa, ha egyszerre teljesül:

- a stratégia már `safeTarget`-ként kiválasztotta;
- legfeljebb 300 pixelre van;
- `treeConfidence >= 0,25`;
- `heartIconEvidence >= 0,05`;
- a statikon legalább 5;
- a játékos legalább 90%-os HP-n van.

Ilyenkor a cél megszakítja az általános rövid statikus faljárást, a bossirány-hűtés
utáni oldaljárást és a türkiz küldetésnavigációt. A cél saját stagnálása miatt elindított
nyolclépéses tartós kerülőt és a hosszú, bizonyítottan elérhetetlen területből
kiszakadást nem szakítja meg, hogy falon túli cél ne okozzon új hurkot. Boss- és
frisssebzéses őr a kiemelés előtt fut, tehát mindig elsőbbséges marad.

## Ellenőrzés

Replayen a 35. képnél a döntésnek már közvetlen célközelítésnek kell lennie. Élőben a
következő 5/10/20-szívfán mérendő, hogy 300 pixelen belül megszakítja-e a quest-/hűtőágat,
és csökken-e folyamatosan a távolsága.

Az első teljes replay további tanulsága: a 198 pixelen statikus célhoz a döntő helyesen
indított tartós kerülőt, de a kiemelés azt a következő képen lenullázta. A végleges
változat a cél saját `persistentDetour` állapotát megőrzi; csak a régi navigációs
szándékokat törli.
