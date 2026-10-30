# Nyolcféle Free-jutalom és időbélyeges helyi napló — 2026-10-30

## Aktuális felülírás:286

Az alábbi állandó foglalásos kattintásvédelmet éles módban felváltotta a
kézi húzásvédelem és1s-os újrapróba. Két képen eltűnt kártya könyvel,
egyclaimIDegyszer; időszakot a végső inputpróba dönti el, click_attempts
külön mutatja az összes próbát. Részletek: [286](286-kezi-huzasvedelem-es-free-ujraproba.md).

## Felhasználói kérés és típusok

Másodpercenként ellenőrizzük a játék bal oldalán az event visszaszámláló
alattiFreejutalmat, megnyomjuk és naplózzuk, mi jelent meg, mikor kattintottunk.
Csak ez az automatizáció engedélyezett. A korábbi heartbeat szünetel.

A felhasználó két képen megmutatta a teljes statlistát. Tartós másolat:
`references/2026-10-30/reward-stats-top.png` és `reward-stats-bottom.png`.

| Játékbeli típus | Naplóbeli név | Ikon |
| --- | --- | --- |
| Health | hp | piros szív |
| Health Regen | regeneration | zöld szív kereszttel |
| Pierce Damage | piercing_damage | nyíl |
| Cut Damage | cutting_damage | fejsze |
| Smash Damage | smash_damage | kalapács |
| Pierce Defense | piercing_defense | nyíl pajzson |
| Cut Defense | cutting_defense | arany fejsze világoskék pajzson |
| Smash Defense | smash_defense | kalapács pajzson |

A felhasználó szerint ezek szoktak jönni. A százalékos statok is a listán
szerepelnek, de most nem új jutalomkategóriák. Az591-es korábbiFreejutalom
CutDefensevolt; a szín alapjáncutdamagenek minősítő prototípus hibás volt.

## Felismerés és működés

Nyolc valódi statikonból kivágott kép erőforrásként a programba csomagolva.
A színkategóriák térbeli alakját is összevetjük, így a pajzs számít.
Nagy hiba vagy kis illesztési különbség eseténunknown, a bizonyíték megmarad.
Az elsődlegesFreefeltétel a bal oldali rögzített terület, pontosFREEszöveg,
zöld jelzés és látható játékHUD. Két egymást követő felismerés kell.
Aktiválás után friss képen ismét ellenőrzi ugyanazt a jutalmat.

A program nem nyit menüt, nem mozgat karaktert. A kattintás röviden előtérbe
hozza a játékot, utána visszaadja a fókuszt és kurzort. Azonos változatlan
jutalomra nem kattint ismételten, újraindításkor is megőrzi ezt az állapotot.
Képkészítés csak a játékablakról, névleges1s ütemben; tényleges időpontok
a naplóban és az állapotfájlban láthatók. Képet csak kattintási bizonyítékként ment.

## Napló és összesítés

`data/free-rewards/events.jsonl`: append-onlyJSONL; minden sor schemaVersion,
UTC ISO8601timestamp,runID, és jutalomnálclaimID. A rewardmező tartalmazza
a típust, nyers és normalizált összeget, OCRszövegeket, ikonillesztési adatokat.

- reward_detected: első észlelés ideje.
- click_intent: a kattintás előtti tartós bejegyzés és PNG.
- click_sent: az egérlenyomás tényleges időpontja.
- claim_confirmed_ui: két további játékHUD-képen eltűnt aFreeajánlat.
- claim_unconfirmed/click_failed: bizonytalan/sikertelen kimenet, külön kezelve.

K/M/B/T összegekDecimalformában; nincs lebegőpontos kerekítési adatvesztés.
Mivel a játék csak kerekített összeget mutathat, a napló is a kijelzett
jutalomértéket őrzi. Nem azonos a szorzókkal módosított teljes statváltozással.

Lekérdezés: `.build/release/ButcherHeroAutomation stats --from <ISO8601> --to <ISO8601>`.
Időzónás példa: `2026-10-30T22:00:00+02:00` és `2026-10-31T08:00:00+02:00`.
Az időszakot a kattintás ideje dönti el, felső határ kizáró. ClaimIDnként
egyszer számol; csak UI-visszaigazolt jutalom az összeg, bizonytalan külön.
Mind a8típus külön szerepel a kimenetben, ismeretlenek külön számlálóval.

Indítás: `./scripts/start-free-rewards.sh`; leállítás: `./scripts/stop-free-rewards.sh`.
Az indító a már lefordított binárist futtatja, nem fordít folyamatosan.
Egyetlen élő figyelőt folyamatközi zár enged; a régi botéval közös a zár.

## Ellenőrzés

Releasebuild és4tesztPASS: nyolc címkézett ikon felezett képméretnél;
valódi591Free→cutting_defense;Free nélküliHUD és mindkét statpanel nem
kattintható; számok/időzítők elválasztása; ismételt és újraindított kattintás
gátlása. Az éles végponti próba eredménye alább kerül rögzítésre.

## Élő eredmények és véglegesítés

Első igazolt kattintás:2026-10-30T08:16:39.457Z,SmashDamage680.
ClaimID81FBCA4B-E142-4BBC-ACFA-E3477D63E416:előtte/utánaPNG, majd
08:16:41.168ZUI-visszaigazolás. Az utóképen explicit zöld+680kalapács is látszik.
További valódi kártyák:PierceDamage516,HP18K,CutDefense578,PierceDefense611,
SmashDefense802. A képeket az asszisztens ellenőrizte; ezek további
HUD-háttéren készült referenciák az ikonillesztésben.

Két kezdeti alakillesztési bizonytalanság és egy üres OCR-érték javítása:
a teljes pajzs/nyél területet nagyobb kivágás fedi le, hiányzó összegnél
külön szűk számsoros OCR is fut. Képi visszakeresés után három
reward_correctedesemény került a naplóba, az eredeti sorok megmaradtak.
Astats ezeketclaimIDalapon veszi figyelembe. A.reconcileparancs újrafuttatva
0új javítást adott, tehát nem sokszorozta meg az adatokat.

2026-10-30T08:34körül17igazolt UI-átvétel,17elküldött kattintás,
0hibásJSONsor,0függő/bizonytalan átvétel,0besorolatlan jutalom:
HP108000,PierceDamage2064,CutDefense1156,PierceDefense611,
SmashDamage2040,SmashDefense802. A másik két típus ekkor0; mind a8
kategória szerepel az összesítőben. Ez a tesztidőszak, nem éjszakai hozam.

Időintervallumos ellenőrzés:10:16:39+02:00–10:16:40+02:00pontosan a680-as
kattintást adta, az előző1másodperces intervallum0-t. A javítóesemények
nem változtatják meg a kattintás eredeti idejét.

A HUD-ellenőrzés megelőzi az OCR-t és ugyanazt a pixelpuffert használja;
a teljes4tesztes kör ideje az előző32,8s-ról kb.0,47s-ra csökkent.
Az ismeretlen/ismert ikon között váltakozó felismerés nem enged újabb
kattintást ugyanarra az összegű, változatlan kártyára. A naplóO_APPENDés
fájlszintű zár mellett ír; az offlinejavító sem ír felül meglévő sorokat.

A rövid nohup-indításból a futás eszközkörnyezetében nem maradt tartós
folyamat, ezért a végső éles példány tartós parancsmunkamenetben indult:
60266PID,52505execsession. Adata/free-rewards/state.jsona friss státusz forrása.
Nincs heartbeat vagy karaktermozgatás. Fordítás előtt állítsuk le a figyelőt,
majd sikeresbuild után indítsuk újra; futó binárist ne cseréljünk alatta.

Végső állapotellenőrzés08:39:42Z:60266PIDél,3m33sfolyamatos futás,
state.lastCheckedAtfriss.24UI-visszaigazolt jutalom,0hibás naplósor,
0bizonytalan vagy besorolatlan tétel. Összegek ekkor:HP126000,
PierceDamage4644,CutDefense1734,PierceDefense611,SmashDamage2040,
SmashDefense802. A második figyelőindítást a zár szabályosan elutasította,
az éles folyamat tovább futott. A program nem mozgatott karaktert.
