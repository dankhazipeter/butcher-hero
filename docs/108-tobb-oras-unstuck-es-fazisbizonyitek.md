# Többórásnak hitt Unstuck-időzár és folyamaton belüli fázisbizonyíték

## Élő megfigyelés

A `075542-play/frame-00454` képen a karakter a zöld Island 4-előtérben, a vörös
határszikla, egy fenyő és a törött kőkerítés közti szűk zsebben állt. A bot az ötödik
sikertelen statikus fázis után helyesen megnyitotta a Settings panelt és egyszer
megnyomta az Unstuckot. A `frame-00452` valójában `YOU DIED` állapot: a tap sikerült,
csak a HUD-biztonság maradt tévesen 100%. A játéktér 17h 55m feliratai más elemekhez
tartoznak; a többórás Unstuck-következtetés **cáfolt**.

A következő `080512-play` futásban a hatirányú kiszabadítás elindult, de az első két
fázis közti kis kameracsúszás ismét nullázta a fázisbizonyítékot. A karakter ugyanabban
a fenyő–szikla–kerítés háromszögben maradt. Később az elérhetetlen bossok miatt a
stratégiai respawn is aktiválódott, de a falon túli célhoz nem tudott eljutni.

## Döntések

- Ha az Island 4-fal látszik, nincs cél, és már legalább egy statikus fázis ténylegesen
  sikertelen volt, a kis kameracsúszás a 150 döntéses drought előtt sem törölheti a
  bizonyítékot. Így a bot végigjárja a teljes relatív iránykört.
- Sikertelen, visszaszámlálós Unstuck-tap után a folyamat belső hűtése 900 döntés.
  A `081017` képei közvetlenül `01:45→01:43` játékbeli számlálót mutattak.
- A maximumváltozás progressziós jele az Analyzer tartós maximumőréből érkezik. Ez
  nem téveszti össze a normál 751→768 gyógyulást egy új maximummal; csak a már
  hiteles `docs/bot-state.json` érték fölé elfogadott lépcső kap külön szekvenciát.

Az első mindhárom változtatást tartalmazó élő futás: `081017-play`.

## Ellenőrzési terv

1. Az első sikertelen fázis után a következő kameracsúszás ne állítsa nullára a
   `failedStaticEscapePhases` értéket.
2. A bot próbálja végig a négy relatív átlót és az ellenirányt; valódi kijutásnál a
   fal eltűnése vagy egy elérhető farmcél szakítsa meg a ciklust.
3. A cooldownos Unstuck panel a 900 döntéses hűtés alatt ne nyíljon újra.
4. A következő valódi max-HP jutalom külön maximumszekvenciával nullázza a
   jutalomhiány-számlálót; puszta medencegyógyulás ne tegye ezt.
