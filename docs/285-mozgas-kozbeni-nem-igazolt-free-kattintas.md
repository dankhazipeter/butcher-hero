# Mozgás közbeni nem igazolt Free-kattintás — 2026-10-30

Utókövetés: a felhasználó később javítást kért, amely elkészült:
[286 — kézi húzásvédelem és újrapróba](286-kezi-huzasvedelem-es-free-ujraproba.md).
Az alábbi„nincs implementálva”a diagnózis akkori állapota.

## Biztos megfigyelés

A felhasználó Free578, Cut Defense kártyát mutatott, majd felvetette,
hogy a kézi mozgás ütközhetett a kattintással. Az offline inspect a küldött
képen helyesen adja: gameHUDVisible=true, cutting_defense, amount578.
Ez tehát nem a korábbi18K-felismerési hiba.

Napló: `data/free-rewards/events.jsonl`, claim
`8C61B7B7-03B6-4664-8621-B74FDC000D99`:

- 09:19:54.539Z: reward_detected.
- 09:19:55.936Z (Bucharest11:19:55.936): click_sent.
- 09:20:04.676Z: claim_unconfirmed, nem claim_confirmed_ui.

Bizonyíték: `data/free-rewards/evidence/` alatt ugyanezen claimID
`-before.png` és `-unconfirmed.png`. Mindkettőn ott a Free578kártya.
Az előképen elhúzott, aktív joystick látható; a két kép között a karakter
helyszíne is változott. A kód nem mozgat karaktert.

## Következtetés és bizonytalanság

Elküldött input nem egyenlő sikeres átvétellel: ezt a statisztika helyesen
elkülöníti, az578nincs e claim alapján hozzáadva a sikeres jutalmakhoz.
Nyolc másodperc után a figyelő nem próbálta újra automatikusan, mert az
elküldött kattintás foglalása változatlan ajánlatnál megmarad.

A kézi húzással ütköző kattintás valószínű hipotézis, nem bizonyított ok.
A click_sent csak az egéresemény elküldését igazolja, nem annak játékbeli
elfogadását. Fizikai egérgombállapot és párhuzamos emberi input nincs
naplózva; más inputfogadási ok sem zárható ki.

## Döntés és következő lépés

Ez a kör diagnózis, nem javítási kérés: nincs kódcsere, újraindítás vagy
kézi jutalomkattintás. A már futó szűk figyelőt nem állítottuk le.
Javasolt fejlesztés: lenyomott emberi egérgomb/húzás alatt ne küldjön
inputot; elengedés után friss kártyaellenőrzés. A nem igazolt elküldött
kattintás kontrollált újrapróbálása külön megtervezendő, duplaszámolás és
fizetős/idegen UI-ra kattintás nélkül. Még nincs implementálva vagy tesztelve.
