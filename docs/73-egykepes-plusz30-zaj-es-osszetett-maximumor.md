# Egyképes +30 zaj és összetett maximumőr

## Anomália — `20260829-034946-play`

A 715-ös, sok képen stabil maximum után a 451. esemény egyetlen alkalommal 745-öt
olvasott. Nem volt új célbefejezés vagy jutalomeffektus, a 450. kép 715, a 452–486.
eseménysor ismét következetesen 715 volt.

A tartós maximumőr mégis elmentette a 745-öt, mert a történeti szabály minden
`<= +30` növekedést azonnal elfogadott. A +30 határ eredetileg a valódi +20 szívfa
engedésére készült; az azon belüli tetszőleges ugrás egyképes elfogadása túl tág.

Az új `035832-play` emiatt 715-öt 96%-os életerőnek számolta: a tartós maximum szennyezése
tehát nemcsak dokumentációs hiba, hanem a sebzés- és visszavonulási döntéseket is torzítja.

## Javítás

- Egy képen csak a közvetlenül bizonyított elemi `+3/+4/+5/+10/+20` maximumlépcső
  fogadható el.
- A `+1/+2` továbbra is két egymást követő azonos OCR-t igényel.
- Minden más, legfeljebb +30-as összetett ugrás (`+6/+9/+14` stb.) szintén két
  egymást követő azonos teljes-HP OCR után válik tartóssá.
- A kétképes ág megőrzi a valós, egymásra csúszó csoportjutalmakat, de kiszűri az
  egyképes 745-típusú zajt.
- A `bot-state.json` képi bizonyíték alapján 715-re lett helyreállítva.

## Regressziós feltételek

- A 451. képet tartalmazó replay nem menthet 745-öt.
- A `696→702` összetett +6 csak a következő azonos 702-es OCR után menthető.
- A közvetlen +3/+4/+5/+10/+20 lépcsők késleltetés nélkül megmaradnak.

## Replay-eredmény — `20260829-040155-replay`

A javított teljes replay a kritikus `frame-00450→00454` szakaszon végig 715 HP-t
tartott; a köztes 745 nem vált elemzett vagy tartós maximummá. A `bot-state.json`
read-only replay után is 715 maradt. Az egyképes +30 regresszió teljesült.
