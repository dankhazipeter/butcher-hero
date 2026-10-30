# Narancssárga gólemjel és új +500 szív — 2026-09-19

## A felhasználói pontosítás és a térkép

A felhasználó szerint a narancssárga fejek gólemek/ellenfelek. A mellékelt
ikon nem veszélyességi vagy legyőzhetetlenségi jel. 192415-29b0f273-observe/0
nagy térképén két azonos narancssárga fej látható: egy a nyugati narancs
területen, egy a keleti zöld területen. A pink fej és az északi arany ikon
külön jel. Az azonos ikon nem egyedi helyazonosító!

## Képpel igazolt harc és jutalom

Kezdés 192038-d939d337-observe/0: Deep Mines zárt kapujától délre, 6,55K.
192447, 192511, 192537 nudge: rövid, képenként ellenőrzött keleti közelítés
a szélmalom északi oldalán. 192541-b5381509-observe/0: jobb oldalt a
**4,31K HP / 500 szív fa-gólem**, északon a magasabb havas rétegben külön
7,15K humanoid. Nem ugyanaz a cél, és az utóbbit nem támadtuk meg.

192608-486caf5d-nudge: három 0,38s keleti mozdulat a nyílt sávban.
192612-5b181452-play:

- 0 (19:26:13): közvetlen kontaktus, az ellenfél már **2,74K**; látható
  **815 és 748** kimenő találatok, valamint 170 piros találatszám.
- 1: saját friss gépi OCR **6260**. A gólem láthatóan sebzett, nem sérthetetlen.
- 2–3 (19:26:16–18): eltűnt ellenfél, egyértelmű **+500 piros szív** jutalom.
  A keleti narancssárga fej szürkévé vált a minimapon. Ez erősen összeköti
  ezt a konkrét ikont ezzel a fa-gólemmel; nem a nyugati bossokkal.
- 10: saját kijelzés **7,06K**. Nincs halál vagy felszereléscsere.

192746-a40e803b-observe/0 statpanel: **7,06K HP, 1,49K DPS, 73,5 regen**,
cutting165+650, piercing111+630+1%, mindhárom védelem0; Bat13+Venom18.
A korábbi panelhez képest +1 cutting is van. A 6550→7060 különbségből
500 közvetlen jutalommal igazolt; a fennmaradó10 pontos forrását nem állítjuk.
A gólemhelyen 192612/2 már **6h33m** hosszú időzítő, tehát nem újabb
korlátlan órás kör. A következő elérhetőség kb. szeptember20 02:00,
friss képpel ellenőrizendő. A napi keret továbbra hipotézis.

## Feltárt programhibák és javítás

1. A régi `island2SkullDirection` csak a játékostól balra/felfelé keresett
   narancssárga komponenst. 192516/0 képen a jobb oldali fej jól látszik,
   az irány mégis null. Javítás: arc/szem sablonillesztés bármely irányban,
   kinagyított térképen tiltva. Az irány nem jelent automatikus harci engedélyt.
   A szürke/legyőzött fej nem új cél.
2. A normál V2 navigátor csak világcélt/piros pontot használ, az önálló
   gólem-felderítési célcsatorna még nincs bekötve. Ezt a detektorjavítás
   önmagában nem oldja meg; nem állítunk teljes autonóm gólemvadászatot.
3. A narancs fej sablon a keleti gólemet is `dusty-gulch-orange-skull`
   horgonyként címkézi (192516/0). Több azonos ikon miatt ez nem biztos
   globális helyazonosság. Külön térkép-/terepegyezés kell; a probléma nyitott.
4. 192612/0-ban a kontaktuskor átfedő piros/zöld csík miatt `visibleTargets=[]`;
   a bot felderítésbe fordult. Az automata fegyver így is befejezte a harcot,
   de ez nem a célkövetési logika sikere. Sérült, ismert gólem követése javítandó.
5. A gépi maximum a látható 7,06K ellenére6550 maradt; 192821 nyolc álló
   képe sem tanította meg. A panelérték dokumentált, nem írjuk át vakon a
   játékállapotot. Friss tiszta HUD-visszamérés/felismerési regresszió kell.

## Ellenőrzés és további térképfelismerési javítás

A regresszió első futása felfedte, hogy a nagy térkép régi, teljes téglalapos
ikonmintája a világos havas háttérrel nem egyezett. A biztos192415mintával
kiegészített detektor már letiltja ezen a nyitott térképen is az inputot.
Régi térképek, normál nézetek és inventory negatív tesztjei továbbra sikeresek.
Release build, `golem-bearing-regression.sh`, `quick-farm-regression.sh` és
`map-overlay-tests.swift`: PASS. A gólemteszt keleti élő fejet, szürke halott
fejet és nagytérképet külön ellenőriz. A harci biztonsági feltételek nem lazultak.
`map-and-shop-regression.sh` teljes célzott csomag: PASS (bolt, térkép,
képi elmozdulás, horgony, felügyeleti stop, folyosó, célkarantén, fegyverjutalom).
Ez nem az összes történeti regresszió futtatása.

## Következő döntés (aktuális)

**19:33 felülírás a HP-kérdésre:**193253-1b16409d-nudge egy0,40s déli
képtisztító lépés;193255-5255bc9d-observe/6–7 már friss **7060 OCR-current**.
Az előző sorozatban6→G olvasatok a7060konszenzust7000-re váltogatták.
Az observe szándékosan nem ment tartós tudást. A statpanel, a tiszta HUD és
az öt képes gépi konszenzus alapján a felügyelő a bot-state maximumát6550-ről
7060-ra korrigálta. Ez nem egyetlen pixelből vagy replayből tanult jutalom.
Most a szélmalomtól északra/északkeletre, a sziklafaltól egy mozdulattal délre
állunk. A normál HUD-ot az új nagy-térkép detektor élőben sem tiltotta le.

Az állítás, hogy a gólemeket általában kerülni kell, cáfolt: ezt a példányt
ismét legyőztük, közvetlen jutalomképpel. A18,8K és27,7K korábbi vereségei
csak azokhoz a konkrét próbákhoz tartoznak. A panel szerinti7060 már mindkét
korábbi20%-os HP-heurisztikánál nagyobb. A gépiHP már visszaigazolt;
a konkrét következő célhoz vezető út azonosítása kell, győzelmet nem ígérünk előre.
Újrainduláskor a sziklafalnál állunk a szélmalomtól északkeletre, nem egy
új sziget bejáratánál. Változatlan északi frontier-falnyomás ne induljon.
