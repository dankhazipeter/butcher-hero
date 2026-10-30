# Navigációs vezérlőhatár és hamis kritikus HP — 2026-09-19

## Megfigyelés

173528-play/9–16: az önálló akadályadaptáló kikapcsolása után is volt
nyolclépéses kerülő. Ez már a Strategy saját belső állapota: a korábbi
szöveges navigációs besorolás nem ismerte az „Elakadás észlelve” és
„Tartós akadálykövetés” döntéseket. Emiatt ezek V2-n kívül futottak.
26képen a karakter a Titan-oltár közelében, nem sérült harcban.

27képen a saját felirat egyértelműen **5,9K**, teljes zöld csíkkal.
A lokalizált OCR „15.9K”, a parser ebből15900 mellett1590jelöltet is
gyártott a tizedesjel eltávolításával. A maximumszűrő az15900-at kizárta,
így a hibás1590„tiszta numerikus” HP-ként azonnali visszavonulást okozott.
28–39téves kritikus megerősítésre várás, felügyelet megszakította a futást.
**Nem valódi sérülés, vereség vagy bossbizonyíték.**

## Javítás

- NavigationIntentPolicy külön, egységtesztelhető tulajdonosbesorolás.
  A megfigyelt régi kerülők és célzár mozgásjavaslatok is V2-höz kerülnek.
  A110pixelen túli megközelítés már útvonaltervezést kap180helyett;
  közeli finom kontaktus, harc és visszavonulás változatlanul külön ág.
- K-HP parser: ha van tizedesjel, tilos a számjegyek összetömörítésével
  másik nagyságrendet létrehozni. „15.9K” nem1.59K. Nem találunk ki
  helyette5.9K-t sem: a lehetetlen jelölt nem friss numerikus mérés.
  A tizedesjel nélküli korábbi OCR-javító ág megmarad.

## Korlát

A tulajdonosbesorolás még régi szöveges döntésekhez illesztő átmeneti réteg,
nem a teljes Strategy típusos újraírása. A V2 mért térképe az új útvonaltervező;
a régi stratégia további, eddig nem megfigyelt ágainak auditja nyitott.
A globális térképrészek összeillesztése és a terepszintek kezelése sem kész.
Következő: célzott parser/navigációs teszt, rövid élő kör, nincs vak újraindítás.

## Következő kör

Build, navigációs tulajdonos-egységteszt, hibásHP-replay és quick-farm
regresszió PASS.173902/0–3V2megközelítés;4képen új+5szív és3m58s kör,
tehát az élő fa elérve és legyőzve.19képen friss5,91K numerikusHP.
Közben4–17a3m58s respawnfelirat takarta a sajátHP-t; a részleges zöld
csík16%-nak látszott, ezért a navigáció várt. Ez újabb, nem falas megállás.

A247egyszeri megfigyelési oldalmozdulatát kiterjesztjük erre a perces
időzítőre is, még a kritikus mód előtt: korábbi magasHP, nincs friss sérülés,
nincs közeli fenyegetés/boss/panel, futásonként legfeljebb egy0,30s mozdulat.
Nem állítja át a HP-t, nem igazol gyógyulást. Ezután új kép szükséges.

A173902naplóban nulla régi akadálytérkép/akadálykövetés/célzár-végrehajtás.
Ez az adott körben igazolt elkülönítés, nem minden régi ágra teljes bizonyítás.
Új parser- és percestimer-replay PASS; korábbi247teljes replayben továbbra
pontosan egy megfigyelési oldalmozdulat. Teljes történeti tesztcsomag nem
nyilvánítva zöldnek; a korábbi bosskerülő eltérése nyitott.

174054/17élőben egyszeri megfigyelési oldalmozdulat,20képen ismét tiszta
5,91K sajátHP. A20végkép az oltár északi szabad oldalán,124HP-s fa158px-re.
Az újabb30s körben nincs régi kerülő-végrehajtás, de további biztos ölés
nem dokumentálható belőle. A rövid takarási várakozások még nem szűntek meg
teljesen; a megfigyelési lépés nem általános folyamatos mozgásengedély.

174156/2: friss5,92K sajátHP, a124HP-s fa korábbi helyén3m26s kör;
maga az ütés a futások közötti folyamatos játékban nem mentett, külön
találatképet nem állítunk. A karakter a tábor déli kerítésénél van.
9–13V2falkövetés, közeli64HPőrök és kerítés; teljes megkerülés itt még
nem bizonyított. Következő felügyelet ezt a szakaszt ellenőrizze, ne a
korábbi kapuútvonalat indítsa. A0,5pajzs jutalomjel5HP-ként is bekerül:
következő felismerési hibajegy, önmagában nem valódi5HPellenfél.
