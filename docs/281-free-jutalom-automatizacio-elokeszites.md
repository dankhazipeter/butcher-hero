# Free-jutalom figyelő — előkészítés, majd felhasználói stop

2026-10-29. A felhasználó1másodperces ellenőrzést, a bal oldali event
visszaszámláló alattiFreejutalom átvételét és helyi időbélyeges jutalomnaplót
kért, későbbi éjszakai HP/sebzésstatisztikához.

## Elkészült alapok

KülönSwiftPMtermék:ButcherHeroAutomation; források aSources/ButcherHeroAutomation
ésSources/RewardAutomationCoremappában. Parancsok:inspect,watch-free,stats.
Napló:data/free-rewards/events.jsonl; állapot:data/free-rewards/state.json.
K/M/B/TmennyiségekDecimalalapon; kattintási szándék, elküldött kattintás és
képi visszaigazolás külön esemény. Duplakattintás elleni alapvédelem.
Releasebuild és két célzott szám-/duplikációteszt sikeres volt.

Csak dry-run futott. Az első figyelőindulásCG-inicializációs hibával leállt;
NSApplicationinicializálással javítva. A következő8másodpercesdry-run HP18,2K
Freejutalmat ismert fel. Valódi jutalomkattintás még nem történt, nincs
igazolt átvétel vagy éjszakai statisztika. A program még nem kész.

## Felhasználói helyesbítés és kézi feltárás

A224727/0képen aFree591fejszés ikon védelmi jutalom volt; az első
színheurisztika tévesencutting_damagekategóriát adott. Nem használható éles
statisztikához. A felhasználó8típust jelölt:3damage,3defense,Health,HealthRegen.

A hátizsákot és a felső infópanelt az asszisztens nyitotta meg kézi
eszközhívásokkal, nem a jutalomfigyelő.230057/0statpanel:473MHP,21BDPS,
2,5Mregen.230230/0részleteslista:Health,HealthRegen,PierceDamage,
CutDamage,SmashDamage, ezek százalékos sorai ésPierceDefense.
Az alsó további védelmi sorokat még nem sikerült végiggörgetni.
A CUA-görgetés változatlan maradt, a húzás helyenként statrészletet nyitott.

A kéziHealthrészlet147Mflat×3,22=473Mképletet mutatott, különReward
forrássorral. A jutalom feliratának összege és a szorzókkal módosított teljes
statnövekedés tehát külön fogalom; a napló a látott jutalomértéket tárolja.

## Leállítás

A felhasználó „Hagyjad, majd folytatjuk… zárd be a játékot teljesen” utasítására
a játékCommand-Q-val bezárva. Folyamatellenőrzéskor sem játék, sem
ButcherHeroBot/ButcherHeroAutomation nem fut. Afigyelőstate.running=false,
heartbeatPAUSED. Nem futtatunk további tesztet vagy képrögzítést.

Következő kifejezett folytatáskor: pontos nyolctípusos ikonfelismerés,
éleskattintás és napló/statisztika végponttól végpontig tesztje, kezelhető
indító/leállító megoldás. Ezek még hátralévő feladatok.
