# Mért visszatérés és a vak kerülő kivétele — 2026-09-19

## Élő mérés

`150116-c179548c-play/0`: újraéledési környék, zöld oldal, sátor/kerítés.
Két valóban mozdulatlan input után a helyi térkép kerülőt indított.
18–31: északi út,32–45: nyugat-északnyugati átkelés.
46: képpel igazolt Island2, narancs talaj, tetős ház és zárt sziklaoldal.
Időbélyegek13:01:17Z→13:02:31Z, **74másodperc**.33-tól5,86K kijelzés,
előtte5,84K. A +20 köztes kis őrök mellett történt; nem új nagyőrfarm.
Körülbelül37döntés/perc, nem percenként két mozdulat. Ez önmagában nem sikermutató.

60–63: a korábbi rövid képi útvonal három statikus input után helyesen
elvetette az élt.64–69:18,8K-s boss láttán a vereségmemória kivezette a karaktert,
új harc nélkül.100–101: jelzettMailboxmegnyitva, üres, bezárva; nincsjutalom.

## Feltárt navigációs hiba

Egy régi40swipe-os14S/10W/16N sor még mindig elindult pusztán narancs
talaj, hosszú időzítő és északnyugati minimapcél alapján. Ezek nem egyedi
kezdőhelyek. A teljes ág és a hozzá tartozó állapotváltozók kikerültek.
Történeti leírásuk megmarad.

## Újrafelhasználható visszaút

A térkép az alacsony narancslefedettségű ismert helyről megkeresi az ugyanazon
térképrészhez tartozó, képpel már narancsnak azonosított pontig vezető utat.
Csak rögzített, irányított és nem blokkolt éleken, egyetlen többcélú kereséssel.
Ismeretlen visszafelé járhatóság, közeli de nem összekötött pont vagy másik
térképrész nem helyettesít utat. Gyorsító mellett az aktuálisan mért sebesség
határozza meg a következő csomóponthoz szükséges swipe-ot.

Egységteszt: ismert előreút használható, kapcsolat nélküli narancspont nem,
blokkoltél után nincs út, márIsland2-ben nem indul visszatérési terv.
**Nyitott élő bizonyítás:** egy következő helyvisszaazonosítás után valóban ezt
az utat használja-e, és mennyivel gyorsabb? A74másodperces első bejárás még
nem az újrafelhasználó algoritmus sikerének bizonyítéka.
