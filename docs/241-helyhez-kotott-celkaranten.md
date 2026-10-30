# Helyhez kötött célkarantén — 2026-09-19

## Hipotézis és bizonyíték

240: a kijárattervező sikerét a régi távoli minimapcél kiválasztása visszafordította.
`155533-c578f46c-observe/0` friss képen változatlan nyugati sziklazsák,5860HP,
orange-skull(-60,5;0). Nem futott más bot. Az observe hibás Island2-kapuél
javaslatát nem hajtottuk végre.

Hipotézis: nem globális északnyugat-tiltás, hanem e helyről a hibás távoli
irány kizárása szükséges. A nyugati udvarban a sikertelen célt a mért déli
nyílt pont helyettesíti; onnan keleti felderítés következhet. Az új keleti
szakasz még kísérlet, nem bizonyított járható él.

## Javítás

`MinimapTargetQuarantine`, tartós szabály:`docs/minimap-target-quarantine.json`.
Venom-koordinátás régió és blokkolt irány, bizonyítékhivatkozással; a két ismert
minimaptámpont egységes koordinátában. Csak általános navigációban, nincs közeli
fenyegetés és közeli cél. Ismert farmcél és a mért zsákudvarkijárat elsőbbséget
kap. A helyi akadálytérkép és haladásőr továbbra ellenőrzi a tényleges mozgást.
Replay/observe nem módosítja a szabályt. Ez felügyelő által bizonyítékból
rögzített helyi korrekció, nem általános automatikus célkarantén-tanulás.

Mért déli cél:(-44,5;-14,5), `153030-e1c1dbe7-observe/0`.
Teszt: hibásNW→S/SE; a déli pontonE; régión kívül nincs tiltás;
már eleveEirány változatlan; eltérő támpontból ugyanaz az eredmény.
Élő sikerfeltétel: kijutás után nem fordul vissza a nyugati zsákvégbe, hanem
eléri a déli pontot vagy előtte új támadható célt talál.

## Élő ellenőrzés és korrekció

`155746-8f374444-play/0–8`: most az északi zsákvégből a teljes kétpontos kijárat
automatikusan teljesült.9–14: a karantén délre vitt,14képen a villanyoszlopos
nyílt terület, a déli mért pont elérve. Nem tért vissza a nyugati zsákvégbe.
15–38viszont új hurok: az első keleti mozdulat után a már elért köztes pontot
ismét célként választotta.38-nál a minimap-haladásőr automatikusan megállt.
Ez vezérlési hiba, nem akadály. Javítva: elért frontier megjegyzése és a déli
ponttól keletre lévő friss helyzetből újraindításkori következtetés. Külön
regresszió tiltja az elért pontra visszahúzást. HP5860, új jutalom nincs.

Az első teljes replayregressziót hibásan élő, állapotot író játékkal párhuzamosan
indítottuk: minden viselkedési teszt átment, de a globális fájlhash-ellenőrzés
exit1-et adott. Ez nem bizonyít replayírást, a tesztkörnyezet nem volt izolált.
A teljes regressziót leállított élő bot mellett újrafuttatjuk; ilyen állapot-
változatlansági tesztet többé nem futtatunk liveplayjel párhuzamosan.
Második futást a futás közbeni tesztszkript-szerkesztés érvénytelenítette
(bash olvasási eltolódás, szintaxishiba). A kész fájl `bash -n` ellenőrzése
sikeres; harmadik futás változatlan szkripttel, leállított liveplay mellett.
Új indulási őr elutasítja a regressziót, ha élő play folyamat látszik.
Harmadik, izolált teljes regresszió sikeres, az állapot- és fixture-hashok
változatlanok. Releasebuild, célkarantén- és haladásőr-egységteszt szintén sikeres.

Javítás utáni élő kör160134: az elérhetőVenomcél elsőbbsége megmaradt és
győzelmet adott (242).39–40képen a karanténkeletre irányított, nem az elért
köztes pontra vissza. A globális hatékony farmút még nyitott; külön
győzelem-utáni harclezárási hiányt rögzítettünk242-ben.
