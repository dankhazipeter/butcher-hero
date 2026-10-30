# Venom18,1,43K DPS és hosszú cooldown — 2026-09-19

## Győzelem

`160134-caa5c204-play/0–7`: nyolc0,62s célirányú swipe a déli nyílt területről.
8,16:01:48: a3,06Kőr elérve;10,16:01:51: képen **Venom Shard18,
Damage595→630**, saját5860. A megközelítés és győzelem17s a futás kezdetétől;
az előző kijáratfejlesztés ideje nincs ebbe beleszámítva.9képen5840, utána5860;
halál vagy tartós HP-veszteség nincs.

`160347-611f7f86-observe/0`: inventory/statpanel **1,43K DPS,5,86K HP,
68regen**, Phantom4+Venom18. Cut125,piercing111+1,03K+1%.
Ez felülírja a239-es1,39K/Venom17 adatot; nem új kézi fegyvercsere.

## Most már nem30perces cél

10képen a megölt őr helyén, közvetlenül a karakter alatt új kör **9h58m**.
Ez nem pusztán távoli háttérszöveg: a helyét az élő őr8-as képével összevetettük.
További9h58m körök a már kimerült környező céloknál is látszanak.
Hipotézis: a gyors ismétlések után közös napi resetig zár a cél;00:00UTC
környéke összhangban van ezzel, de a pontos játékszabály nem bizonyított.

A20–30perces időzítőre szűkített automatikus győzelemkönyvelő ezt NEM mentette;
csak háromperces „helyhez értem” hűtést írt. Ezt a felügyelő képi bizonyítékból
helyesbítette `landmark-goals.json`-ban. Konzervatív új ellenőrzés:
**2026-09-20 02:01 Budapest**, nem16:31. Az órás időzítő automatikus
könyvelése csak térbeli hozzárendeléssel bővíthető; tilos a háttér legnagyobb
óraszámából következtetni (lásdDOC234 cáfolat).

## Még javítandó

10–20képen a LEVEL UP ellenére a harci állapotgép tovább keresett egy már
legyőzött őrt. A keresés korlátos, de felesleges; a közeli, friss fegyverjutalom
zárja le a megfelelő aktív kisőr-próbát. Ez következő kódjavítás, most még nincs
implementálva.43után kézzel megszakítottuk, majd statpanel-ellenőrzés történt.
Az új célkarantén az utólagos nyugati visszairányt ismét keletre cserélte;
nem húzott vissza az elért déli köztes pontra. Új teljes farmkör még nincs.

Következő felügyeleti kör: friss kép, jutalom utáni harclezárás regressziója,
más elérhető Island2-cél; DOC16:11:37körül várható. Venomma már kimerült.
Átadás:160511tappal inventorybezárás,160532-3e7bd74e-observe/0friss
játéknézet,5860HP. Nem fut élő input; a következő felügyeleti kör előbb
a jutalom utáni visszakeresést javítsa, ne indítson változatlan vak futást.
