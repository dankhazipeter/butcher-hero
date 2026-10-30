# Váratlan18,8K bosskontaktus — 2026-09-19

## Élő eredmény

`docs/runs/20260919-131134-4f9932c0-play`: a3,06K őr körüli harc után
Venom Shard13→14, később a672-es őrcsoporttal5670→5710 maximum.
A126. döntés a már ismert vesztes27,7K lovagtól távolodott. Ez a délkeleti
út azonban egy másik,18,8K boss felé vezetett:

- 131:18,8K224px;132:18,88K120px (ugyanazon sáv OCR-zaja).
- 133: közelharc, a boss HP helyett25 stat olvasat.
- 134: saját képi4,45K, ellenfél17,6K, vörös1,3K bejövő sebzés.
- 136: friss saját3200,137:1990;141–144:YOU DIED.

Ez valódi, de nem szabályosan elindított kontrollált próba. A boss továbbra
túl erős közvetlen kontaktusban, gyors menekülés nélkül. A18,75K vesztes sávot
képi bizonyítékkal4450→5710-re korrigáltuk; alap újrapróba6852 maximumtól.
A halál előtt elért5710 és a Venom14 megmaradt. A visszaúti kis célok után5730.

## Feltárt és javított hibák

Az ellenfélmemória csak explicit próbaindításkor frissült, ezért a váratlan
boss halála nem a megfelelő sávot tanította. A230px-nél közelebbi
nagy humanoidot most külön találkozásként megjegyezzük, kezdőHP-val és kifelé
iránnyal. Csökkenő maradékHP nem cseréli le a kezdőértéket;90döntéses memória.

Kritikus numerikus takaráskor ez az irány továbbra menekülést ad, akkor is,
ha már nincs aktív kutatási próba. YOU DIED törli, és a külön gyógyulási kapu
input nélkül vár. A korábbi „helyben várok friss számra” ebben a kontaktusban
veszélyes volt.

Új korai biztonsági kapu: megjegyzett nagy boss mellett friss numerikus,
65% alatti HP azonnal folyamatos kifelé mozgást indít. A megkezdett menekülést
számtakarás nem szakítja félbe. Ez a 136. képen még előforduló általános
felderítő lépést előzi meg. Build sikeres; `133000-ddd07db9-replay`136–140.
képe mind kifelé menekülést ad,141–144 halálvárás,145-től numerikus gyógyulásvárás.
A korábbi elrontott futás visszajátszása nem bizonyítja, hogy ezzel túl is élünk;
csak a döntési hiba javítását igazolja.

Nyitott kockázat: közeli két külön nagy humanoid azonossága nem mindig választható
szét puszta HP-sávval. További képi követés és veszélytérkép szükséges; a jelen
esetben a18,8K boss képi azonossága és a halál egyértelmű.
