# Pierce549: miért volt ismeretlen az összeg?

2026-11-01. User kivizsgálást kér a mentett képekből, majd pontosan két
kimaradt +549összeg beírását engedélyezi. Külön jóváhagyja a további
felismerés javítását új mintával és regresszióval, küszöblazítás nélkül.

## Két bizonyított átvétel

| Claim | Click UTC / Budapest | Validált előkép | Utókép |
| --- | --- | --- | --- |
|6F6EA993-4647-4567-9CFA-BBB20A76D7CE|21:12:18.661Z /22:12:18|549nyíl|+549lebegőnyíl|
|43E4FD3B-0DA9-4AA5-B392-0E250B1022B8|21:13:23.127Z /22:13:23|549nyíl|+549lebegőnyíl|

A kind helyes volt, a claim_confirmed_ui is megvolt, kizárólag az amount
hiányzott. Nem kézi felvételt tulajdonítunk a botnak: saját click_sent,
validált kép és meglévő kártyaeltűnés-igazolás tartozik mindkettőhöz.

## Nem a szám rossz pozíciója

Mindkét637×882képen a meglévő crop három helyes komponenst ad:
x45/57/68px, y567px,16pxmagasság, szélesség10/9/10px. A5és4jó,
a harmadik helyen9az első, de túl közel van a8hoz:

| Számjegy | Legjobb hiba | Második hiba | Eredmény |
| --- | --- | --- | --- |
|5|0.0997395833|9:0.1895833333|elfogadható|
|4|0.0789583333|1:0.3071056548|elfogadható|
|9|0.1010416667|8:0.1246875000|különbség0.0236458333<0.035, elutasított|

A teljes számot a harmadik glyph biztonsági kapuja nilre teszi. A pixel-
számolvasás nem a reward kindjából vagy egy korábbi jutalom összegéből
tippel. Ezen a helyen nincs automatikus Tesseract-számfallback sem.
Az aktív és source58glyph JSON SHA256-je egyezett:
`9ac43879486e8848bcf593b760ce8d2849c88bbc07b2c38a29091b053220e6f9`.

## A két külön engedélyezett történeti pontosítás

Kizárólag a fenti két claim kapott `reward_corrected` eseményt amount/rawAmount
549értékkel. Nem írjuk át az eredeti sorokat, nem gyártunk új click/confirm
eseményt, nem változtatunk átvételi időpontot vagy darabszámot. Classification
és message kimondja: user által engedélyezett, képről kézzel ellenőrzött
összeg, nem a régi felismerő eredménye és nem karakterstat-mérés.

Egy helyi, nem Gitbe kerülő egyszeri script a natív Journaléval azonos
flock+O_APPEND védelemmel, explicit kétID-re, meglévő saját click/confirm
és képek ellenőrzése után fűzte hozzá a két korrekciót. Újrafuttatás dryrun
alatt mindkettő már javítottnak látszott: nincs duplázás. Az eredeti teljes
byteprefix SHA256-je az append után is egyezett. A szűk21:12–21:13:30Z
intervallumban az élő API és a natív stats is kétPierceclaim/1098egység,
0ismeretlen összeget adott. Más történeti hibát nem javítottunk, globális
reconcile nem futott. Napló és a helyi korrekciós script nem publikus Gitadat.

## További felismerés célzott javítása

Az első claim validált képe `references/2026-11-01/pierce549-calibration.png`,
a másik `pierce549-heldout.png`. Külön átvételi képek, eltérő teljesPNG-
bájtokkal, de a normalizált számjegyrács azonos. A második nem kalibrációs
bemenet, viszont diagnóziskor már láttuk; nem nevezzük vak vagy más betűméretű
független validációnak. Mindkét címke elő- és utóképből ellenőrzött549.

A kalibráló a teljes549címkével ellenőrzi a háromkomponenses szegmentálást,
de csak a9-es glyphöt adja hozzá. A5és4már elfogadható, nem bővítjük velük
feleslegesen a modellt.20forrásból59glyph, az első58objektum mezőről mezőre
azonos a HEAD-del. Új9error0, második8error0.1246875; az első5marginja
az új9mellett is0.0721354>0.035. Nincs runtimeReader-/crop-/baseline-/
parser-/küszöbváltozás és nincs549re hardcode-olt felismerési ág.

A fixképes korpusz54→56, a régi elvárások változatlanok.1új Swiftunit
ellenőrzi a helyes, változatlan cropot, teljes549olvasást, kind/amountot,
valamint a külön tesztkép kizárását a kalibrátorból. A változtatás előtt
4assert piros, utána a célteszt és az összes56korpusz-olvasás sikeres.
Teljes224teszt+7JS-szintaxis sikeres.21:23:29Z-re az új adat atomi
`.next-340`→rename cserével került a runtime és staging bundle-be.
Mindkettő és a source JSON SHA256-je:
`a8a20b416ee41f3354d3f609ec2d88d2a78369c515b42e422480187c9641dd9a`.
Nem írtunk futó binárisra, adatbetöltéshez nincs gyűjtőstop: a meglévő
RewardVision minden számméréshez új RewardNumberReader-t hoz létre, így
újraolvassa a JSON-t. A normál release `inspect` a külön tesztképet ezután
PierceDamage/549nek olvassa. Worker25484 friss ok/hud képekkel, saját stop
nélkül folytatja. Új élő549átvétel az írás pillanatában még nem igazolt;
az offline minták helyes olvasása nem ilyen állítás.
