# Narancs bányatábor, 424 HP és ötperces farmkör

## Terület

A `20260829-004733-play/frame-00280→00348` képei új, narancsszínű kanyon-/bányatábort
mutatnak: vörös sziklafalak, faépületek, bányagépek, sínek/kötelek, kaktuszok és sűrű
minimap-célok. A terület vizuálisan erős Deep Mines-közelség, de a főzetet vagy a
küldetésszámláló változását még nem láttuk, ezért ez egyelőre erős következtetés.

## Célok és jutalmak

- `1` kékfejszés kaktuszok: 53/43/136/80 körüli képi HP-állapotok; passzív célként
  automatikusan támadhatók. Jutalmuk várhatóan +1 támadóstat, közvetlen `+1` felirat még
  nincs biztos képkockán.
- `4` szíves humanoidok: teljes csíkjukon kb. 253 HP látszott. Közvetlen `+4` szívfelirat
  és `400→404→408→412→…→420→424` maximális HP-sor igazolja a +4 max-HP jutalmat.
- `1` fejszés humanoid 428 HP-val is látszott; a biztonsági őr nem választotta célként.
- Piros csont `7` és világos fegyver/erőforrás `8–9` jel látszott a terepen. Jelentésük
  még nyitott.

## Farmérték

A helyi passzív célok újratermelődési körei kb. `5m 5s–5m 47s` értékről indultak,
szemben a korábbi kimerült terület 1–2 órás köreivel. A tábor ezért jelenleg kiemelt
fejlődési régió, ugyanakkor a caktuszok között álló 253 HP-s humanoidokat a karakter
közelségi automata támadása bevonhatja.

## Tartós állapot

A szakasz végén a `docs/bot-state.json` hitelesített maximuma 424 volt. A korábbi 400
a harmadik 20-as szívfa utáni mérföldkő volt, nem végleges plafon. A későbbi világláda
ezt 438-ra emelte; lásd a 42. tudáslapot.

## Sziklaív mint hamis popup-X

A terület egyik narancs sziklaíve 73×31-es rózsaszínes komponenst adott, ezért a régi
általános popupdetektor a `004733-play` 358–469. eseménye között ugyanarra a normál
terep-pontra koppintott. Javítás: általános Rate-us/popup X csak 60% alatti HUD-bizalomnál
aktiválható. Regresszió: `frame-00468` már navigál; a valódi `171107/frame-00000` továbbra
is bezáró tapot ad.
