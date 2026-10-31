# Ismeretlen jutalmak: audit és a további felismerés javítása

2026-10-31. A felhasználó először az ismeretlenek visszanézését kérte,
majd külön jóváhagyta az ikonvágás és számolvasás javítását. A megállapodás:
a korábbi jutalomnapló változatlan marad, a jövőbeli felismerést javítjuk.

## Mely tételeket néztük meg?

A legutóbbi watcher_started óta megőrzött logikai futásból,21:23Z-ig
(Budapest22:23), kizárólag a saját click_sent és claim_confirmed_ui párok
utolsó elküldött képét választottuk. Korábbi reward_corrected sorokat
figyelembe vettük; próbálkozás, kézi átvétel és diagnosztika nem jutalom.

| Eredeti napló | Darab | Régi aktuális kóddal már jó | Még hibás |
| --- | ---: | ---: | ---: |
| Ismeretlen típus | 14 | 5 | 9 |
| Ismert típus, hiányzó összeg | 32 | 8 | 24 |
| Összesen, egyedi claimenként | 46 | 13 | 33 |

Az5régi típushiba Cut Defense593 volt. A8régi, mára olvasható összeg
6Pierce575 és2Cut567. Ezek régebbi javításoktól váltak olvashatóvá,
nem ebből a körből: a változatlan történeti napló nem javul át magától.
A később érkezett új jutalmak nem részei ennek a lefagyasztott46-os auditnak.

## Konkrét ikonhiba: négy pixellel alacsonyabb vágás

A kilenc fennmaradó típushiba mind788×1083-as külsőablakkép:

| Claim eleje | Kézzel ellenőrzött kártya |
| --- | --- |
| 93C3E4CD | Smash Defense823 |
| C2B1DD70 | Smash Damage692 |
| 5628209E | Cut Damage567 |
| 5C50309D | Smash Damage692 |
| 0B3AE4AD | Smash Defense811 |
| 29B33629 | Smash Defense805 |
| 7B9332F7 | Smash Damage683 |
| 27AD6F3A | Smash Defense805 |
| FF01DE23 | Smash Damage683 |

Nem olvashatatlan képek. Az eredeti mintával és változatlan küszöbbel a
diagnosztikai,4px-szel feljebb helyezett téglalap mindegyiket helyesen
azonosította. Például C2B1DD70alaperror0.4703/margin0.0021; a feljebb
vizsgált vágás error0.1077/margin0.3229 ésSmashDamage. A régi dy[-2,0,2]
keret túl szűk volt. A javítás csak dy[-4,-2,0,2]-re bővít, dx[-1,0,1]
megmarad. Összesen9→12igazítás; elfogadás továbbra
error<0.48 és két külön típus közötti margin>0.035. Nincs nagyobbhibatűrés,
új ikonsablon vagy értékből/kártyaszínből kikövetkeztetett típus.

## Számhibák

22régiPierce-képen a felirat521, nem522. Mindegyikben a2es a legjobb,
de hibája0.1791667, a8asé0.2109375: különbség0.0317708<0.035.
Helyesen nil maradt, de hiányzott az adott fontváltozat. A692kalapácsnál
a9/8ütközött; kisebb képen néha a8volt az első, így nem szabad a legjobb
jelölt vak elfogadásával688-at könyvelni692helyett.

A Health18.4K D548013A képen négy szám/suffix és a decimalpont mellett
egy hatodik világos komponens is a ROI-ba került a K után. A háttérfolt
alsó éle nem a számok baseline-ján volt, mégis számjegyjelölt lett;
a jelöltsor18.4K8ként érvénytelen, ezért nincs összeg. Nem aK=1000 parser
hibája. Most a magas komponensek medián alsó éle is szükséges:
eltérés<=max(2,maxHeight/10), a korábbi méret/felsősor feltételek mellett.
A decimalpont külön szabálya és a szigorú teljesérték-parser megmarad.
Nem vágjuk le utólag önkényesen a hibás szöveg végét.

## Kalibráció és regresszió

Öt új, teljes képből vizuálisan ellenőrzött számkalibráció:

- E5DD3F11:521;
- 250B3491:692,637×882;
- C2B1DD70:692,788×1083;
- 9700E4DF:18.1K, a8as egyik pixelfázisa;
- BFC40697:18.6K, a8as másik, jobbra igazított szövegbeli pixelfázisa.

A két Healthforrás azért is fontos: az új9minta az első tesztkörben a
háttérfoltos18.4K8-asának margóját0.02609re csökkentette. A teszt ezt
megfogta, nem engedtük ki. A második valódi8minta után a helyes8hiba
0.02604,9-é0.13411; a szigorú0.035különbség újra teljesül.

19kalibrációs kép,58glyph a korábbi14/41helyett. A régi41glyph JSON-adatát
összehasonlítottuk a HEAD-del: bitazonos prefix maradt. Nem szedtünk ki
kényelmetlen mintát és nem lazult a digiterror<0.30/margin>0.035.

Heldout, tehát nem számkalibráció: külön521füves és521havas claim,
5C50309Dkülön692claim, valamint a háttérfoltos18.4K. Unit ellenőrzi,
hogy a kalibráló ezeket a fájlneveket nem veheti fel. A kisméretű692
teljeskép önmagában kalibrációs; külön azonosméretű, másikclaimből származó
692holdoutra nincs állítás. A nagy692külön önálló átvételi eset.

16eredetiPNG került a references/2026-10-31/reward-audit mappába, fix,
képből ellenőrzött címkékkel. A teljeskép-korpusz38→54; egyetlen régi
elvárás sem változott. Három új Swiftunit:9ikon,521/692fontok+heldout,
Healthbaseline+suffix. Először27állítás bukott; a javítások után minden
kép és teljes176teszt+7JSsyntax sikeres. A stagingrelease is lefordult,
egymástól külön buildhelyen futó ellenőrzéssel, a régi gyűjtőt nem írta felül.

A46eredeti kép mindegyikét újraolvastuk a végső kóddal és58glyphfel:
mind a46típus és összeg egyezik a kézi ellenőrzéssel. Privát diagnosztika:
.build/reward-audit/report-before.json, report-after.json, két képkontaktlap
és tesztlogok. Ezek nem futó statnaplók és nem újravégrehajtott átvételek.
A másolt valódi képek publikus regressziósforrások; a teljes személyes
játéknapló nem került Gitbe.

A privát audit első standalone fordítása hibás helyről kereste a Swift
resourcebundle-t és még feldolgozás előtt kilépett. Utána explicit aktív,
majd explicit tesztbundle-ből olvastuk a41-, illetve58glyphmodellt. Ez
nem a gyűjtő hibája/leállása volt, és nem váltottunk be közben éles adatot.

## Éles betöltés és korlát

Saját runner, idle kristály/event és függőFree nélküli állapot után stop;
stagingbináris és a hozzá tartozó58glyph JSON együtt került az aktív
release helyére. Nem adtunk új modalt/harcot/eladást/boltinputot.
21:42:17Zúj runner90106/dashboard90117/supervisor90118/worker90119,
session2092, resume-run. Friss valódi képidők;21:42:27.450Z8FF900E8
PierceDamage575claim_confirmed_ui. Ez új működési bizonyíték, nem az
összes javítottSmash/Cut-eset új élő előfordulása.

Utána új igazolt normálkörök:21:42:59.394ZADC2067FCutDamage557,
21:43:32.949ZF4FC302FHealth18600,21:44:37.344Z8F07BA21CutDefense631.
A Cut557 ésHealth18.6K eredeti validatedképeit kézzel is ellenőriztük:
egyeznek a naplóval. Nem a korábbi567félreolvasása557-nek. A játékablak
közben637×882lett; így eltérőméretű új siker is van, de ez nem a kilenc
külső788×1083-as hibáshelyzet mindegyikének új élő ismétlése.

A történeti46sorhoz sem reconcile, sem reward_corrected nem íródott.
A dashboard régi unknown/nil számai emiatt megmaradnak; nem kell ezt új
felismerési hibának nézni. Jövőbeli eltérőfont/háttér/ablakméret továbbra
új bizonyítékot igényel. Korábbi GitHub4launcher-startuptimeout külön
nyitott, a launcher tesztjei ebben a körben nem változtak.
