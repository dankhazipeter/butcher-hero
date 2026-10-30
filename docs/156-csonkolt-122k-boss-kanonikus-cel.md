# Csonkolt 1.22K-páncélos mint kanonikus 1220 HP-s cél

## Élő megfigyelés

A `docs/runs/20260829-135451-play` 194–198. képein a már kétszer legyőzött
1.22K-s páncélos balról teljesen láthatóvá vált. A csík 59 pixeles, a fejszeikon
erős volt, a képen az `1.22K` felirat látszott. A cél-ROI azonban sorban:

- HP nélkül;
- `:22` → 22 HP;
- üres OCR mellett megtartott 22;
- `1122`/`1.22` számjegysor mellett 22 HP és bossEvidence.

A régi kutatási indító csak 800–8000 belső HP-t fogadott, ezért az ismert, könnyen
legyőzhető célon nem indult el, a normál bossőr pedig eltávolodott tőle.

## Döntés

A cél kanonikus HP-ja 1220, ha egyszerre teljesül:

- a belső csonkolt érték 15–29;
- a piros csík legalább 45 pixel széles;
- a fejszeikon-bizonyíték legalább 0,15;
- a cél saját bossEvidence-et hordoz;
- az OCR összefűzött számjegyei tartalmazzák a `122` aláírást.

Ez a szűk kombináció kontrollált 1220-as próbát indít. Aktív próba alatt a széles
csík + fejszeikon + rögzített célirány rövid OCR-kimaradást is áthidalhat. Általános
22 HP-s ellenfél ettől nem válik bossá vagy automatikus próbacéllá.

## Regresszió

A `docs/runs/20260829-140147-replay` 198. eseménye a 22-es belső érték ellenére:

`Kontrollált bosspróba indul 1220 HP-ról`

A következő három, boss nélküli képen a normál rövid célmemória futott; a javítás
tehát a kezdeményezést helyreállítja, de nem állít hamis győzelmet vagy HP-esést.
Az élő ellenőrző folyamat: `docs/runs/20260829-140322-play`.
