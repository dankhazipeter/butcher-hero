# A gyűjtés helyreállítása és felügyelete — 2026-10-30

## Biztos történések és felelősség

A felhasználó nem kértSTOPot. A teszt/CIfejlesztés alatt a37802folyamat
élt, de a sikeres képfeldolgozás18:23:34.401Zután nem frissült. A naplóban
`TextRecognition.CRImageReaderError error1` jelent meg, majd beragadás.
Nem állítható, hogy a folyamat létezése miatt a gyűjtés is működött.
Az asszisztens a CI-ra figyelt, és az élő hibát nem kezelte időben.

A saját hibás workert leállítottuk,45731/session30213újraindult technikai
`--resume-run` módban. Igazolt új átvételek:

- 18:40:22.533ZCutDefense593.
- 18:40:55.014ZHealth18300; az utóképen tényleges +18.3Kszív látható.
- 18:41:27.222ZPierceDamage540.

Az utókép: `data/free-rewards/evidence/0CE0F691-DF0A-409B-94BC-3AC91A79B0C2-after.png`.
Ez helyi futási bizonyíték, nem kerül be automatikusan az összes kép Gitbe.
A felhasználó közben kézzel is átvett jutalmakat: azokat nem számoljuk a bothoz.

## Második kiesés: rossz indítási módszer

A47677Pythonfelügyelő/47679gyerek rövid parancsból leválasztottnohupként
indult. Az indításkor még élt, de a parancs lezárása után egyik folyamat
sem maradt meg. A running=trueállapotfájl megmaradt, ez nem élő bizonyíték.
A felhasználó ismét jelezte, hogy saját maga gyűjt.

Az indító most `exec python3 ...supervise-free-rewards.py`, előtérben,
tartós végrehajtási munkamenetben marad.68833session:48519felügyelő,
48521worker.18:47:32SmashDefense833,18:48:04Regen83,18:49:41Health18300
újra igazolt, és18:52Zellenőrzéskor a sikeres képidő is az aktuális másodperc.

## Automatikus helyreállítás

`scripts/supervise-free-rewards.py`:

- Egyetlen felügyelő sajátflockkal; csak a maga indította gyermekfolyamatot kezeli.
- A state.pidnek a gyerekPIDjével kell egyeznie. A `lastCheckedAt` értékének
  változása sikeres feldolgozás; puszta running=truevagy hibanaplózás nem az.
- Induláskor45s, utána30sfriss sikeres feldolgozás nélkül elakadtnak veszi.
- SajátworkernekSIGINT;5salatt nem leálló, beragadt APIhívásnál sajátgyerek
  kényszerített megszüntetése.5sújraindítási késleltetés, `--resume-run`.
- Váratlan hibás kilépés is újraindul; kézi felügyelőSTOPvagy tiszta workerSTOP
  nem. A `stop-free-rewards.sh` először a felügyelőt állítja le.
- Nem nyitja/állítja le a játékot; nem ad mozgási, bolti vagy rekláminputot,
  nem könyvel jutalmat. A worker eredeti egérvédelme és igazolása változatlan.

Állapot: `data/free-rewards/supervisor.json`; saját történések:
`supervisor-events.jsonl`. A jutalomnapló továbbra `events.jsonl`.
A leállási/újraindulási ablak nem nulla: az indulási türelemmel és5+5sidőkkel
akár55sis lehet. Nem állítjuk, hogy minden jutalom garantáltan felszedhető.

Kilenc automatateszt: normál frissülés, élő-de-beragadt állapot, hiányzó
kezdőkép, másPID, hibás aktivitás, szelíd leállás, timeoututáni sajátkill,
már kilépett worker, STOPelsőbbsége és hibából újraindítás. A tesztek nem
használják vagy állítják le az élő gyűjtőt.

Kötelező munkamód: teszt és CI alatt az élő gyűjtő maradjon futva.
Csak éles programbetöltésre állhat meg röviden; utána friss képidő és
valódi átvétel alapján igazoljuk az újraindulást. Tesztelés nem indok
arra, hogy a gyűjtést percekre elhanyagoljuk.

## Élő helyreállítási bizonyíték

18:54:23után ismét ugyanaz aVisionhiba lépett fel. A felügyelő emberi
beavatkozás nélkül18:54:53.724Zelakadást jelzett, az48521worker leállt,
18:54:59.785Z50644indult.18:56:06.907ZújPierceDamage540igazolt;
18:56:28.759Zfriss sikeres képidő. Ez a teljes automatikus újraindítási
ág élő igazolása, nem csak egy tesztbeli elmélet. Nem kéziSTOPvolt.

Teljes helyi tesztcsomag:19Swift,13statisztika,3Gitkapu,9felügyelet,
5Node és kétJSszintaxisellenőrzésPASS. E tesztek közben a gyűjtőt nem
állítottuk le; a frameworkhiba és az automatikus helyreállítás külön esemény.
