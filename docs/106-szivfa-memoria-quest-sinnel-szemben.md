# Szívfa-memória a quest-sínnel szemben

## Élő megfigyelés

A `docs/runs/20260829-074813-play/frame-00200` képen egy 10-szíves, 174 HP-s fa
224 pixelen jelent meg. A bot helyesen közeledett, a `frame-00202` képen a távolság
203 pixel lett. A `frame-00204` képen a fa továbbra is látható volt, de az analizátor
egyetlen képre elvesztette a célcsíkot. A türkiz Deep Mines-sín ekkor azonnal törölte
a célmemóriát, és a 205. eseménytől a bot otthagyta a biztos +10 max-HP lehetőséget.

**Biztos tény:** ez nem tudatos kockázati döntés volt. A 10-es fa passzív, 174 HP-val
a jelenlegi sebzés mellett gyors cél, a játékos 747/100% HP-n volt, és ezen a képen
nem látszott boss. A cél elvesztése egyképes felismerési rés volt.

## Döntés

A már igazolt szívfa rövid célmemóriája most a quest-sínnel szemben is érvényes, ha:

- az előző cél biztos fa volt;
- utolsó mért távolsága legfeljebb 300 pixel;
- legfeljebb három tényleges döntés telt el a felismerési résben.

Ilyenkor a quest-ág nem törli a célmemóriát; a meglévő elveszettcél-ág röviden tartja
az utolsó irányt. Új célfelismerés lezárja a rést. A boss-, frisssebzés- és alacsony
HP-s őrök korábban futnak, ezért veszélyben változatlanul azonnal megszakítják a farmot.

## Ellenőrzési terv

1. A `074813-play` visszajátszásában a 200→202→204 sor a 204. képnél ne váltson
   quest-sínre, hanem tartsa a fa utolsó irányát.
2. A teljes élő 173. képen felismert 4.31K boss változatlanul hatswipe-os menekülést
   indítson; a ritkított replayből ez a páratlan képkocka hiányzik.
3. Élőben a következő egyképes fa-felismerési rés után a cél visszakerüljön, vagy
   három döntés után szabályosan átadja a vezérlést a küldetésnek.
