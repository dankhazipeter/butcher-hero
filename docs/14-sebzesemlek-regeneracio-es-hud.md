# Sebzésemlék, regenerációs mód és HUD-folytonosság

Ez a lap a `214101-play` veszélyes, képről eltűnő támadójából tanult túlélési modellt
írja le. A cél nem a halál mindenáron való kerülése, hanem az ismert támadásra következetes
reakció és a megszerzett fejlődés időhatékony védelme.

## Vezető 1-es tizedes HP-hiba

A játék 100 HP alatt tizedes számot mutat. A zöld csík bal széle a `85.8` és `88.8`
elejére tapadva `185.8`/`188.8` OCR-t eredményezett. Mindkét jelölt előállt, de a régi
temporális szabály a korábbi 185-höz közelebbi hibásat választotta.

Új bizonyítási sorrend:

1. több jelöltnél a pixelcsíkhoz 18 százalékponton belüli nagyságrend marad;
2. 60 HP-nál nagyobb esés egy képen is elfogadható, ha a szám és a csík 12
   százalékponton belül egyezik;
3. történeti szabály volt a numerikus és pixelbecslés minimuma; ezt a `214936` incidens
   elvetette, mert a hibásan rövidnek mért csík a tiszta gyógyulást is felülírta;
4. aktuálisan a friss, elfogadott OCR az elsődleges, és csak hiányzó/elutasított számnál
   veszi át a pixelcsík a taktikai arányt.

Bizonyíték: `214733-replay`, ahol a nyers `188.8` 88 HP és 27%-os taktikai állapot.
A frissességi és forrásszabály részletes folytatása: `15-hp-meresi-eredet-es-kuldetesallapot.md`.

## Láthatatlan támadó és ragadós visszavonulás

- Legalább 2,5 százalékpontos esés 12 döntéses sebzésemléket indít.
- A memória nem követeli meg, hogy a támadó HP-csíkja éppen látszódjon.
- 85% alatt a memória visszavonulást indít és a mód 85%-ig aktív marad.
- Amíg friss sebzés van, látható cél nélkül is tovább mozog biztonságos irányba.
- Ha 12 döntésen át nincs új sebzés és fenyegetés sem látszik, 85% alatt helyben várja
  a regenerációt, nem indít vak járőrt.

Ez a `218→85→88→92→143` szakaszt végig veszély-/regenerációs állapotban tartja.

## HUD-folytonosság célcsík nélkül

Regenerációkor egyszerre lehet takart játékoscsík és nulla piros célcsík. Ez önmagában
nem ismeretlen képernyő. A felismerhető sárga játékosjelből a piros minimappont felé
mutató vektor 45% HUD-bizalmat ad, a friss játékos-OCR további 20%-ot. A képmérettel
együtt a normál játéknézet eléri a 60%-os biztonsági küszöböt; valódi menü/reklám minimap
nélkül továbbra is megállítja a botot.

## 340 HP-s élő regresszió — `225111-play`

A 9–18. eseményen képen kívüli támadás 340-ről 226-ig vitte a játékost; a köztes
regeneráció miatt az érték fűrészfogasan változott. A vörös cél eltűnése ellenére a
12 döntéses sebzésemlék 84%-tól folyamatos visszavonulást tartott. A 19–29. eseményen a
pixelcsík többször hamis 31%-ot adott, de a következő tiszta OCR 240→266→280→306 volt;
a bot nem ragadt bele, 30-nál 90%-on felderített, 35-nél ismét teljes 340 HP lett.

Ez egyszerre igazolja, hogy a láthatatlan támadó elleni memória működik, a friss
numerikus OCR elsőbbsége feloldja a hibás pixelállapotot, és a magasabb maximumon sem
változott meg a 85%-os regenerációs küszöb jelentése.

## Halál után kizárólag friss HP oldhatja fel a védelmet

A `225111-play/frame-00080.png` biztos halált (`YOU DIED`) mutatott. Az átmeneti
`frame-00085.png` már a zöld medencét ábrázolta, de nem tartalmazott megbízható numerikus
játékos-HP-t; a régi döntő mégis a 340-es memóriából 100%-ot képzett és felderítésre
indult. A 87. élő elemzés csak 45/340-et olvasott, utána a karakter fokozatosan
139→162→…→317→340 értékre gyógyult.

Új invariáns: kritikus állapot után csak `ocr-current` forrású numerikus mérés igazolhat
helyreállást. 90% alatt a visszavonulás marad; memória vagy pixel által mutatott magas
értéknél a bot mozdulatlanul vár. A `225618-replay` a 80–105. mentett képen végig vár,
291/340-es friss OCR-nél még visszavonul, és csak 317/340-nél oldja fel az állapotot.
