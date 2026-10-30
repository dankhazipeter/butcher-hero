# CPU-s OCR és valóban blokkoló tesztkapu — 2026-10-30

303FELÜLÍRÁS:az explicitCPUbeállítással is visszatért a hiba. Az aktív
Free-körből aVisionOCRt kiváltottuk; ez a fejezet a sikertelen hipotézis
és a kezdeti indulási eredmény történeti dokumentuma, nem a mai backend.

Ad6f6404helyi commit után a push előtti külön tesztfutás háromSwift-
ellenőrzésen megállt; a push1-gyel kilépett. A remote ekkor még af2cbf2.
A kaput nem kerültük meg és nem állítottunk sikeres feltöltést. A helyi
és izolált folyamatok közti eltérés külön vizsgálatot igényel.

Az élő régiOCRfolyamatokban ismétlődött aTextRecognition.CRImageReaderError1;
CPU-/memóriakimerülést nem bizonyítottunk. A52053worker például19:01:38kor
~123MBRSS, és később friss képidővel,19:05:39korHP18300átvétellel működött.
A hibát nem szabad automatikusan egy általunk okozott leállításnak nevezni,
de a felügyelet és a gyors helyreállítás az asszisztens felelőssége.

## Következő szűk kísérlet

A Visionkérés explicitCPUeszközt kap azokban a feldolgozási szakaszokban,
ahol a keretrendszer támogatja. A támogatott eszközök lekérdezése után
`setComputeDevice(_:for:)` állítja be, nincs ismeretlen GPU/ANEkiválasztás
vagy nem támogatott eszköz ráerőltetése. Külön teszt ellenőrzi a választást.

Ez az accelerator-sessziókhoz kötődő hibalehetőség kerülésének hipotézise,
nem bizonyított véglegesgyökérok. Nem lazul OCRbizonyosság, ikonmargin,
jutalomkönyvelés vagy képi tesztelvárás. Az első célzott futásban mind27
korpuszkép és a CPUeszközválasztási teszt átment.

APIforrás: a telepített AppleVision/CoreMLSDKfejlécei és a hivatalos
[compute device API](https://developer.apple.com/documentation/vision/vnrequest/setcomputedevice(_:for:)).
A deprecatedusesCPUOnlyhelyett a macOS14+eszközválasztó APIt használjuk.

A release build külön `.build/reward-staging` helyen készül, amíg a már
működő gyűjtő tovább fut. Így a fordítás nem írja felül a futó binárist;
csak kész, ellenőrzött build betöltése igényelhet rövid leállást. A teljes
teszt és a távoliCIeredmény külön igazolandó.

## Helyi eredmény és rövid éles betöltés

A teljes csomag sikeres:20Swift,13statisztika,3Gitkapu,9felügyelet,5Node
és kétJSszintaxisellenőrzés. A kész külön release bináris és a betöltött
binárisSHA256azonos: `b28f83ea8bcb7c5523e813307af19bbd6c92b6f1ffe8b3a5bdfa130761e6c379`.
A referenciaresourcebundle a csere előtt egyezett; nem fordításra állt meg
a gyűjtő.19:09:59.238Zúj54705felügyelő/54789worker tartós90309sessionben.
19:10:19.174ZHealth18300újra igazolt;19:10:34.507Zaktuális sikeres képidő.
Ez indulási/átvételi bizonyíték, hosszú távú frameworkstabilitást nem bizonyít.
