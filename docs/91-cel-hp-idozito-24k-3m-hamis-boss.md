# Cél-HP timerátfedés: `24k 3m` mint hamis boss

## Élő bizonyíték

A `20260829-054356-play/frame-00144` egy 253 HP-s cél saját HP-OCR-je mellett
`24k 3m` sort is adott. A képi környezetben több `20h 13m` újratermelődési kör
látszott; a Vision az egyik időzítőt torzította K-s számmá. A régi cél-HP feldolgozó
a K miatt 243 000 HP-ra bővítette, miközben a célazonossági simító 253-at mutatott.
Ez hamis bossmenekülést indított 747/747 HP-n.

## Döntés

Időegységet (`h`, `m`, `s`) tartalmazó OCR-sor nem lehet cél-HP-forrás. A szabály
azonos a játékos HP-jánál már bevált timerőrrel, de célonként, az OCR-sorok előtt
fut. Ha ugyanabban a régióban külön tiszta `253` is látszik, az továbbra is
feldolgozható; csak az időzítős sor esik ki.

## Regresszió

- `054356/frame-00144`: hamis bossmenekülés helyett normál Island 4-kifelé átló;
- `033954/frame-00014`: valódi `1.22K`/923 boss továbbra is menekülés;
- `002956/frame-00140`: a csonkolt 4.31K és független 500-as statikon továbbra is boss;
- `052132/frame-00238`: a mínuszos lebegő sebzésőr változatlanul kiszűri a zajt.

Az új élő build `20260829-054840-play` néven indult.

## Statikonmezőben maradó timerdarab

Az első javított kör `frame-00059/00060` képein a HP-régió `40m`/`10m` sora már
kiesett, de a külön statikon-ROI `202`-t olvasott. A 253-as cél így a régi,
túl tág `levelNumbers >= 100` szabályból még bossjelet kapott. A közvetlenül
bizonyított tartalék boss-statikon 500 (OCR-ben 501), ezért a független nagy
statikon kapuja először a 400–699 tartományra szűkült. A nyers 800+ HP-bossőr ettől
változatlan.

Új regresszió:

- `054840/frame-00060`: a 202 timerdarab nem boss;
- `002956/frame-00140`: az 501 statikonos csonkolt 4.31K változatlanul boss;
- `033954/frame-00014`: az 1.22K/923 nyers bossőr változatlan.

A következő élő build `20260829-055128-play`.

## Sűrű csoportban összeragadt HP és statikon

A `055128/frame-00040` újabb átfedést mutatott: két 253-as cél között az egyik
nyers HP-ja `1253`, statikon-OCR-je pedig `2534` lett. A későbbi mentett képen
`2531|8021|*253` alakok is előfordultak. Egyetlen alsó küszöb ezt nem tudja jól
szétválasztani a valódi bossoktól.

A döntő ezért csoportkonszenzust használ: ha legalább két aktuális cél ugyanazon,
800 alatti simított HP-n áll, és a nagy nyers szám csak ennek 1–2 jegyű elő- vagy
utótagos változata, az adott képen nem bossjel. A 150-es ismeretlenszint-őr ettől
még nem engedi vakon farmolni. A teljes `055506-replay` mindkét hamis menekülést
megszüntette, miközben a 4.31K/500, 1.22K/923 és 923 regressziók továbbra is
menekülést adnak. Az új élő build `20260829-055702-play`.

Az élő build 95. eseménye később `505` zajértékkel cáfolta a tartománykaput. A
végleges, bizonyítékalapú kapu csak a pontos 500/501; részletek a 93-as jegyzetben.
