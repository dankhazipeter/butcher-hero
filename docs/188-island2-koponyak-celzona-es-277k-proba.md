# Island 2 koponyák, célzóna és a 27,7K-s sebzéspróba

## Cél

Az Island 2 két nagy térképi koponyája az elsődleges küldetés. Ez a fejezet a
zöld területről visszavezető, kézzel kimért utat, a koponyák képi felismerését,
az elért célzónát és az első valódi nagyellenfél-próba eredményét rögzíti.

## Biztos megfigyelések

- A Deep Mines `magic anti-stone potion 0/1` kapujától a bizonyított visszaút:
  **13 dél, 20 nyugat, 12 észak, 8 nyugat**. Az utolsó szakasz belép a
  `Dusty Gulch - 2` narancs területre.
- Az Island 2 bejárati háztól 20 dél, majd 20 nyugat a hosszú déli fal alatti,
  járható alsó kanyonba vezet. Innen további déli haladás eléri a nagy
  ellenfelek táborát.
- A célzónában egymás közelében megjelent 3,06K-s páncélos, 4,4K-s DOC-őr,
  két 2,49K-s őr, egy 1,28K-s szívkaktusz, egy 18,8K-s nagy páncélos és egy
  27,7K-s sárga/narancs lovag.
- A hosszú vízszintes kerítés első kitérőjén a balra kerülés vezetett a valódi
  ellenféltáborba. A jobbra kerülés kevésbé volt eredményes.
- A saját kijelzett maximum a futások során 3,10K, 3,12K, 3,14K, 3,15K, 3,19K,
  majd 3,22K értékre nőtt. Az aktuálisan látható fegyverek Bat Cleaver 11 és
  Steel Splitter 15.
- A 27,7K-s koponyacélpont kontrollált kontaktusban ténylegesen sebződött:
  **27,7K → 27,3K → 26,1K → 24,0K**. A saját karakter túlélte a cserét és
  később regenerálódott. Tehát a célpont a nagyobb HP ellenére legyőzhetőnek
  látszik; a próbát nem vereség, hanem a harctérből kivezető régi kitérő szakította
  meg.
- A Mailbox ellenőrzésekor `You have no Mails yet.` látszott. A Shop állapota
  `FREE IN 23h 53m` volt. Egyik helyen sem volt azonnal átvehető jutalom.

## Koponyadetektor és navigáció

- A nagy térképen a sárga háromszög a játékos. A második sárga/narancs komponens
  az egyik koponya, a magenta komponens a rózsaszín koponya.
- A rózsaszín jelhez relatív geometriai szűrés tartozik: legalább 18 pixellel a
  játékosjel fölött és legalább 20 pixeles távolságban kell lennie. Ez megszünteti
  a HUD-ból eredő észak–dél irányváltást.
- A koponya iránya rövid képi kiesések között nyolc döntésig megmarad. Island 2-n
  ez az irány felülírja a közeli passzív szívfa/kaktusz farmját.
- Öt statikus kép után a bot rövid oldalirányú kerítéskerülőt tesz; az első
  kitérő előjele balra lett állítva a mért táborbejárat alapján.
- Aktív koponyaküldetéskor a bot a látható nem-fa célok közül nem automatikusan
  a legközelebbit, hanem a legnagyobb, 800–30000 közötti HP-jú ellenfelet választja.

## Harci döntés

Nagy, nem-fa koponyabossnál, ha az ellenfél HP-ja csökken, a távolság legfeljebb
100 pixel és a saját HP legalább 45%, a bot nem kezd új keringő kitérőbe. Helyben
vár, hogy a játék automatikus ütéskombója folytatódjon. Kitérés akkor indokolt,
ha a saját HP veszélyesen csökken, a sebzés megszűnik vagy a kontaktus elveszik.

## Visszatérési állapot

Ha a bot már elérte Island 2-t, de három képen át 40% alá esik a narancsszikla-
fedettség, váratlan zöldre távozást állapít meg. A rövid 12 észak + 8 nyugat
korrekció csak akkor indulhat, ha még legalább 12% narancsszikla látszik; mély
zöld területen a teljes Deep Mines-visszatérési küldetésnek kell átvennie a
vezérlést. Ez megakadályozza, hogy a rövid határkorrekciót rossz helyről hajtsa
végre.

## Következő ellenőrzés

1. Mély zöldről a teljes mért visszaút élő ellenőrzése.
2. A rózsaszín koponya stabil követése a déli célzónáig.
3. A 27,7K-s lovagnál helyben tartott automata kombó addig, amíg a saját HP
   biztonságos és az ellenfél HP-ja csökken.
4. Győzelem, jutalom, saját HP-növekedés és esetleges új térképállapot rögzítése.
5. A Mailbox és Shop jelzéseinek ismételt, csak olvasó ellenőrzése a hűtés után.
