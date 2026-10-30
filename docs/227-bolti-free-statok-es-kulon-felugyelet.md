# Bolti Free-statok és külön felügyelet — 2026-09-19

## Utóellenőrzés — téves piros jelzés

140618-play/120: nincs jelzés a bolton, a mögötte levő vörös szikla mégis
pozitív színküszöböt adott. Felesleges ismételt auditok következtek. Javítás:
a piros közép és zöld tető mellé a fehér körszegély is kötelező. A valódi
134512-es jelzés és három hamis kép külön tesztelve, bekapcsolt ellenőrzésekkel.
141140-playben az induláskori nyitott panel lezárása után nem volt ismételt
téves boltnyitás342képkockáig. Költés/reklám továbbra sem történt.

## Felhasználói helyesbítés és bizonyíték

A jobb oldali bolti piros pont valódi elérhető ingyenes statjutalmat is jelez.
A korábbi203/209audit csak a felsőFREE IN időzítőt vizsgálta; **nem volt teljes**,
az abból levont „nincs ingyenes jutalom” következtetés hibás. Az időzítő nem
tilthatja le a bolt többi részének vizsgálatát. A felhasználó két képpel mutatta
meg a Damage-szekció zöldFree ajánlatát.

`134549-e235be81-observe/1`: Damage első kártya+2, zöldFree és piros pont;
alatta piercing+1/Free részben takarva. Középső/jobb kártyák200/550gemben árazva.
`134615-1c22c85b-tap`: a biztos elsőFree átvétele.
`134643-0cdd64af-observe/1`: a+2/Free kártya helyén+43/50gem. Az ingyenes
ajánlat felhasználása így igazolt; a pontos össz-DPS-növekedést külön statpanel
még nem mérte meg. A gemes következő ajánlatot nem vettük meg.

## Új programrészek

- `ShopInspector.swift`: valódiSHOP-cím, külön bolti piros pont+zöldtető;
  OCR-rel pontosanFree, zöld gomb, saját piros pont, teljes láthatóság együtt kell.
  A grafikusFREE, FREE IN, OPEN QUESTS, árak és alsó fül mögé vágott gombok kizárva.
- `ShopAuditor.swift`: külön állapotgép, képileg ellenőrzött átvétel, teljes
  statlista pásztázása, legfeljebb20görgetés, biztosX-zárás. Legfeljebb két tap
  változatlanFree gombnál; utána anomália, nem végtelen kattintás.
- `docs/shop-state.json`: az audit állapota és megerősített gombváltozások száma
  újraindítás után is megmarad. Observe/replay nem írhatja.
- `play --shop-only`: mozgás nélküli külön boltfelügyelet és élő tesztmód.
  Normál játékban is külön, harcon kívüli prioritás a piros boltjelzés.
  Fennmaradó jelzésnél5percenként újraaudit; eltűnő majd új jelzéskor korábban.

Vásárlás, gemköltés, reklámindítás és külső quest-ajánlat tiltva. A görgetés
csak felismertSHOP-ban, a kártyák közti sávból indul; visszaadja a fókuszt/kurzort.
Felhasználói aktivitás alatt a bolti állapotgép sem lép tovább.

## Ellenőrzés

A felismerő régiFree képen pontosan egy teljes gombot talál; a már gemes képen
nullát, a normálHUD-on felismeri a piros boltjelzést. Release build sikeres.
`135240-07d34394-play`, mozgásmentes40s élő audit:

- 6→9: piercing+1 Free átvétele, majd ugyanott+34/50gem.
- 11→14: Health+60 Free átvétele, majd ugyanott+1,51K/50gem.
- 30: normálHUD vizuálisan5,81K, ami5750+60-nak felel meg. Az OCR81K-ra
  csonkolta, ezért a bot tartós maximuma még5750; statpanellel is ellenőrizendő.
- A legalul teljesen látható regen+1/Free y≈0,878 helyét a0,875-ös képszélőr
  tévesen kihagyta. Javítva0,895-re: a gomb továbbra teljesen a0,918-nál kezdődő
  alsó fülsor fölött marad. Ez nem sikeres teljes audit volt; javítás utáni új kör kell.

Szigorítás: sikerhez aFree eltűnése önmagában nem elég; ugyanazon helyen sárga,
számárral jelölt következő ajánlat is szükséges. OCR-kimaradás nem átvétel.

## Befejezett statlista és friss statok

`135533-d6609c3d-play/0`: a javított felismerő automatikusan átveszi a regen+1-et.
A következő képeken a helyén sárga50gemes ajánlat van. Felhasználói aktivitás
közben a stratégia helyesen vár, ezért az időkorlát a belső sikerbejegyzés előtt
lejárt. A következő verzió a függő átvételt is tartósítja, legfeljebb5percre.
`135706-a6528a56-play`: a teljes lista újra tetejétől aljáig pásztázva,
15–18 felgörgetés,20–24 lefelé audit,25biztos bezárás. Nem maradtFree gomb,
és utána a jobb oldali bolti piros jelzés is eltűnt. A maximum5810-re beállt.

Összes bizonyított átvétel: cut+2 (első célzott próba), piercing+1, HP+60,
regen+1 (utóbbi három automatikusan). Gem0 maradt; reklám nem indult.
A program `confirmedClaims` számlálója a korai megszakítás miatt csak két
automatikus sikert tartalmazott; ez könyvelési hiány, nem hiányzó jutalom.

`135940-489b8418-observe/0` független Stats-panel:
1,22K DPS;5,81K HP;66regen;cut123+550;piercing110+490+1%.
FelszerelésBat11/Venom14; Phantom2,Steel22,Fang17 tartalék.
A korábbi1,16K/58→mai1,22K/66 teljes változását nem kizárólag aFree-k okozták:
közben farm és Venom14 fejlődés is volt. AHP+60 viszont közvetlenül igazolt.
