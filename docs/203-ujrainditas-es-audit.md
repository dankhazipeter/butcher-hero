# Újraindítás és tudásbázisaudit — 2026-09-19

## Kiindulás és biztos mai adatok

- A felhasználó újraindította a játékot és a fejlesztés folytatását kérte.
- `20260919-114933-observe/0`: Deep Mines kapu déli/zöld oldala, 637×882-es
  ablak; Bat Cleaver 11 és Steel Splitter 22. Saját kijelzés 4,46K,
  tartós gépi maximum még 4450. A kerekített kijelzés nem pontos HP-mérés.
- `114954-observe/0`: Shop, FREE IN 14h 10m 5s, gem 0, VIP 0/20.
  Az ott nézett időzítős lehetőség még nem aktív; vásárlás nem történt.
  **13:45-ös helyesbítés:** ez nem teljes boltaudit. Lejjebb négy különFree
  statjutalom volt; a teljes lista ellenőrzése és automatizálása:227.
- `115320-observe/0`, `115344-observe/0`: Stats 851 DPS, 4,46K HP,
  51,5 regen, 118+814 fő támadóérték, 74+1% másodlagos; a többi négy
  látható támadó/védő mező nulla.
- `115359-observe/1`: Venom Shard 12, piercing, damage 420, cooldown 0,92 s;
  a zöld 455 a következő példány előnézete. HOLLOW TEMPO zárva, 12/130.
- `115501-observe/1`: Savage Fang 16, piercing, damage 128, cooldown 1 s;
  zöld 136 következő példány, STAB DEVOUR zárva, 16/100.

## Dokumentációs hibák és helyesbítés

Az AGENTS.md közel kilencszáz soros történeti naplóvá vált. Egyazon fájlban
„aktuális” volt 611, 1940, 3430 és 4450 HP; egyszer tiltott, másszor kötelező
volt a Shop megnyitása. A 4,31K/500-as Titan-fa győzelme után is nyitott
kérdésként szerepelt, legyőzhető-e. A teljes Island 2-visszaút biztosnak volt
nevezve, noha az utolsó élő futások ezt nem reprodukálták.

- A régi útmutató változatlan tartalma a `docs/archive/AGENTS-20260830.md`
  történeti fájlban megmarad. Az új AGENTS rövid, aktív követelményeket tartalmaz.
- A konszolidált fejezetek új, dátumozott bevezetőt kapnak, a régi alfejezetek
  történeti státuszúak. Nem törlünk megfigyelést, de elavult következtetésből
  nem vezetünk le új inputot.
- 5340/5292 a jelenlegi 20%-os újrapróba-heurisztika, nem játékmechanikai
  győzelmi küszöb. DPS, fegyver és taktika is számít.
- A 200-as jegyzetben szereplő két útvonalél külön mért; az egész makró
  automatikus, ismételhető sikerét még igazolni kell.

## Konkrét programhibák

1. A feladat-OCR öt kis téglalapja között kimaradt a jobbra tolódott buborék.
   Az első javítás egyetlen összefüggő játéktér-OCR. A `105045-play/16`
   regresszió már megtalálta a `Find a magie anti-stone po`, `Deep Mines`, `0/1`
   sorokat, de a csonkolt potion miatt a régi kapu még nem kapcsolt.
   Következő javítás: az anti-stone + Deep Mines + 0/1 hármas is biztos jel.
2. A tárgyazonosító bármely SPECIAL ABILITY szöveget Bat Cleaverként kezelt.
   A Venom Shard és Savage Fang megfigyelésén téves EQUIP-javaslat keletkezett.
   Observe nem hajtotta végre. A javítás automatikus felszerelés helyett a
   bizonyított bezárógombot használja; csere csak statösszehasonlítással.
3. A nyíló inventory animáció közben a játék HUD-ja még teljesen látható.
   A széles szövegfelismerés inventory/equipped és damage/attack cooldown
   szerkezettel tiltja a paneladatok HP-ként történő tanulását.

## Következő mérhető feladatok

- Javított kapu- és tárgymodal-felismerés célzott replaye.
- A maradék felszerelés összehasonlítása, jobb build esetén élő DPS-visszamérés.
- Deep Mines déli oldal → Island 2: friss képi csomópontokkal útvonalat mérni.
- Ismételhető nagy szívkaktusz és elérhető őrök farmidejét mérni; cél a valódi
  HP/DPS növekedés percenként, nem a végrehajtott swipe-ok száma.
