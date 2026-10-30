# Folyamatos futás és felügyeleti protokoll

## Aktuális kiegészítés — 2026-09-19

239: aktív percenkénti, azonos beszélgetéshez kötött felügyeleti ébresztés.
Azonosító: `butcher-hero-k-pi-fel-gyelet-s-fejleszt-s`.
Ez időszakos modellértékelés, nem valós idejű modellnézés minden képkockára.
Felhasználói stopkor a bot szabályos megszakítása mellett ezt is PAUSED-re kell
állítani. Az alkalmazásnak és gépnek működnie kell. Elakadásnál a12-inputos,
képi/minimap-haladásőr leállíthat; újratervezés nélkül nem indítható újra vakon.
Élő igazolás:154802-play/12. A rövid futások közötti ellenőrzés és dokumentálás
kötelező, hosszú futás nem automatikusan jobb.

## Cél

A bot nem önállóan „darál”, hanem a fejlesztő munkamenet aktív kísérleti eszköze. A
felhasználó 2026-08-28-i utasítása alapján a játékfolyamatot explicit „állj le” üzenetig
folytatjuk. Egy konkrét folyamat javítás, biztonsági stop vagy technikai időkorlát miatt
megszakadhat, de a felügyeleti lánc nem: diagnózis és ellenőrzés után új folyamat indul.
HUD-hiány önmagában a jelenlegi verzióban már nem stop: ismeretlen vagy átvezető képen a
bot input nélkül tovább rögzít, amíg a normál HUD vissza nem tér.

## Ellenőrzési ritmus

- A konzolkimenetet rövid, legfeljebb néhány tíz másodperces lekérésekkel olvassuk.
- Rendszeresen megnyitjuk a legfrissebb mentett PNG-t, nem csak a szöveges összegzést.
- Az `events.jsonl` alapján összevetjük a HP-t, céltávolságot, OCR-nyersszöveget,
  döntést és a közeli fenyegetések számát.
- Érdemi ölés, jutalom, halál, újraéledés, küldetésszám-változás vagy új képernyő után
  azonnali képi ellenőrzőpont készül.

## Javítást kiváltó anomáliák

- legalább 8–12 egymást követő azonos swipe, mérhető helyzetváltozás nélkül;
- ugyanazon cél távolsága négy aktív megközelítésen át nem csökken;
- a HP hirtelen tízszeres/tizedes nagyságrendre vált, vagy nem egyezik a zöld csíkkal;
- a bot távoli vagy nem látható fenyegetés elől tartósan menekül;
- a HUD hat képen át ismeretlen, felugró ablak vagy menü jelenik meg;
- a folyamat hibával, időkorláttal vagy váratlanul befejeződik;
- a játék haladása megáll: nincs ölés, új cél, útvonalváltozás vagy új információ.

Kivétel: a biztos `Tap to continue` küldetéspárbeszéd célzott tappal léptethető. A Cursed
Girl piros hajdísze nem popup-X; szöveg nélküli kővé válási jeleneten csak várunk.

## Javítási sorrend

1. A futó folyamat kontrollált megszakítása.
2. A kiváltó képkockák és eseménysor azonosítása.
3. A hipotézis és a kívánt új viselkedés leírása.
4. Minimális kód-/taktikajavítás és release build.
5. Releváns korábbi futás `replay` ellenőrzése.
6. Rövid élő ellenőrzés, majd azonnali hosszú újraindítás.
7. A mechanika, taktika, kronológia és nyitott kérdések frissítése ugyanebben a ciklusban.

## A felhasználó gépének védelme

A működő iPad-input jelenleg rövid előtéraktiválást igényel. A program minden swipe után
visszaállítja a kurzort és a korábbi fókuszt, és legalább 1,5 másodperc friss felhasználói
aktivitás esetén nem küld mozgást. Ilyenkor az elemzés tovább futhat; a várakozás önmagában
nem hiba. Tartós inaktivitás mellett viszont a játékmozgásnak folytatódnia kell.

## Első felügyeleti incidens

A `docs/runs/20260828-194118-play` futásban a tizedes HP OCR-je 176 helyett 17-et tartott
meg, ezért a bot 10%-os életerőt feltételezett és ismételten lefelé menekült. A képi
ellenőrzésen a valós teljes `176` és teljes zöld csík látszott. A javítás megszüntette a
tiszta háromjegyű szám részablakokra bontását, felismeri a gyors teljes gyógyulást, és
négyirányú járőrre váltotta az egyirányú céltalan mozgást.

## Második felügyeleti incidens

A `docs/runs/20260828-195444-play` futásban két közeli humanoid számai beszennyezték a
játékos OCR-régióját (`201` után téves `T21`), majd a halál átmenetében a HUD hat képnél
tovább nem volt felismerhető. A bot biztonságosan megállt, de a képernyőellenőrzés már
automatikus újraéledést és 204 HP-t mutatott. Javítás: 60 HP/képkockás lefelé fizikai
korlát, valamint kritikus állapot után 15 képes, inputmentes respawn-türelem.

## Harmadik felügyeleti incidens

A `195726` futás négyirányú járőre visszatért a kiinduló medencéhez, tehát formálisan
mozgott, de nem haladt. A minimap sárga játékosjelét és piros pontjait elemző irányítás
a `200046` élő futásban öt képen belül célt talált. Ugyanitt kiderült, hogy a nagy
HP-esés teljes tiltása a valódi halál/respawn-sorozatot is elrejti; ezt két alacsony
méréses megerősítés váltotta fel.

## Negyedik felügyeleti incidens

A `200418` futásban 75% HP-n a minimap egy képen kívüli támadócsoporthoz vezette a
karaktert. A HP-felismerés már helyes volt, de a távolságos menekülési feltétel túl későn
reagált. A minimap-küszöb 90%-ra nőtt, és a friss HP-esésből négyképes támadási emlék
készült. A `200704-replay` ugyanott már 120/204-nél visszavonult.

## Ötödik felügyeleti incidens

A `201344` futásban a bot az őrtorony–kerítés sarkánál 24+ döntésig ugyanazt a
minimap-vektort követte. A nyolclépéses merőleges kerülő után a vektor megváltozott és
egy fa elérhetővé vált. Ugyanebben a futásban a HP-OCR nagy gyógyulásnál alacsony értéken
ragadt és két hamis alacsony sort is elfogadott. Javítás: minden OCR-sor összesítése,
kétméréses felfelé hitelesítés és teljes zöld csíkos lefelé vétó. Regresszió: `201911`.

## Hatodik felügyeleti incidens

A `201932` futásban egy fa eltűnése után a karakter fölötti, kb. négyperces köridőzítő
két elemzésen át a valós 232 HP-t 32-nek olvastatta. A kétméréses nagy-esés szabály ezért
egyszer hamis kritikus visszavonulást indított. Képi ellenőrzés bizonyította a teljes zöld
csíkot és a megszakítás nélküli életet. Javítás: három egymást követő, 25 HP-n belüli
alacsony jelölt, OCR-hiánynál sorozat-reset. A `202645-replay` a hamis esést elutasította,
de a későbbi valódi fokozatos sérülésre továbbra is reagált.

## Hetedik felügyeleti incidens

A `203027` futásban a bot egy 41 HP-s humanoidot választott, mert a következő társ kb.
110–120 px-re állt, éppen a régi 105 px-es izolációs sugáron kívül. A képen valójában
háromfős csoport látszott, és a karakter 243→198 HP-ig sérült. A menekülés aktiválódott,
de a hozam/kockázat döntés hibás volt. Javítás: egységes 150 px-es társ-, klaszter- és
túlerősugár. A `203209-replay` ugyanazon a kritikus képen már fát választott a humanoid
helyett; élő eltérő útvonal-ellenőrzés következik.

## Nyolcadik felügyeleti incidens

A `203326` futásban a fa-időzítő a helyes 252-t több alakban összeragasztotta
(`2523m14`, `2521`), amitől a bot hamis 14/21 HP-t fogadott el. Ugyanebben a futásban a
felhasználói aktivitás miatt kihagyott swipe-ok mellett a stratégia mégis elfogyasztotta
a szikla mögötti cél háromlépéses kerülőit. Javítás: többpozíciós időzítős HP-jelöltek,
12%-os zöldcsík-szélességkorlát, és aktív felhasználónál befagyasztott stratégiai állapot.
A `203914-replay` az OCR-hibát megszüntette és a valódi sérülést megtartotta; az
input-végrehajtási invariáns élő ellenőrzése következik.

Az élő ellenőrzés a `204159` futásban sikerült: az aktív felhasználói képek `VÁR`
döntései között minden tényleges swipe mérhető távolságcsökkenést okozott. A 10-es fa
68 px-nél automata támadásba került, majd a `frame-00095.png` közvetlen +10 szívvel
igazolta a 258→268 maximális HP-jutalmat.

## Kilencedik felügyeleti incidens

A `204458` futásban a cél-HP OCR a `1.22K` elitből csak 22-t tartott meg, ezért a bot
olcsó izolált humanoidként választotta. Az elit 30-as sebzésekkel kritikus állapotba vitte.
A visszavonulás működött, de leoldás után a régi elveszett célmemória háromszor visszafelé
indított. Javítás: ezres HP-rövidítés kibontása, 300+ HP-s humanoid farmtilalma és
meneküléskori üldözésimemória-törlés. A `204932-replay` az elitet kizárta, és a gyógyuló
szakaszban már biztonságos járőrt választott.

## Tizedik felügyeleti incidens

A `205205` futásban a HP-parser a helyes 212–216 mellett a `3m59s` időzítő számait is
jelöltként megtartotta. Egy korábbi hamis alacsony előzmény miatt a „legközelebbi” szabály
9–15-öt választott, noha a zöld csík és a képen látható szám magas volt. Javítás: legalább
65%-os csíknál a csíktól több mint 30 százalékponttal lefelé eltérő jelöltek előszűrése.
A `205548-replay` a sorozatot 211/214/216-ként tartotta meg.

Ugyanez a képi audit egy második jutalomágat bizonyított: egy 1-es fa `+1` kék fejszét
adott, és a normál/kritikus találat 26/39-ről 27/40-re nőtt. A későbbi audit szerint
nem a testforma, hanem az ikon jelzi a statot: szív max HP, kék fejsze támadóerő.

## Tizenegyedik felügyeleti incidens

A `210202` élő futás első mentett képén teljes zöld játékoscsík mellett csak a `4h 57m`
időzítőt olvasta a Vision. A parser ebből 57-et készített, majd az előző alacsony értékhez
vonzódva hamis alacsony HP-t használhatott volna. Javítás: erős pixelcsík mellett minden
azzal összeegyeztethetetlen numerikus jelölt kiesik; ha nem marad szám, a képkocka csak
pixelarányos HP-t kap. A `210417-replay` első képe így számszerű HP nélkül 100%-ot, a
következő tiszta képe pedig 286/286-ot ad. Ez egyben hitelesítette az új maximális HP-t.

## Tizenkettedik felügyeleti incidens

A `210934` élő futásban az első, 291 HP-s kékfejszés fenyő csíkja 233 HP-nál a játékos
teste mögé került, majd a háromképes memória után a bot elmozdult. Ugyanebben a futásban
egy 10-szíves fenyőnél a csík 14 HP-n még látható volt közvetlenül a régi memória utáni
swipe után. A képaudit egyben helyretette a jutalommodellt: fenyőn szív és fejsze is
előfordul, ezért a testtípus és a statikon külön jel.

Javítás: külön `heartIconEvidence`/`axeIconEvidence`, a közeli takarásra fa-hiszterézis,
és már sebzett passzív fán a legutóbbi HP-val arányos, legfeljebb 36 döntéses harci
kivárás. A `212343-replay` a 291 HP-s fejszés fenyőt 0,053 fejszebizonyítékkal, a
10-szíves fenyőt 0,25–0,32 szívbizonyítékkal tartja nyilván; közelharcban is fa marad.

Az első élő próba (`213551-play`) új rést mutatott: a 174→145 sebzés felhasználói
aktivitás alatt történt, a következő tényleges döntésnél pedig a cél még 86 px-re volt.
A harci jelző korábban csak 82 px-en belül aktiválódott, így az első cél rövid memóriát
kapott. Ugyanebben a futásban a második fa már 58 HP-ról helyben befejeződött; a 80. képen
`3m55s` újratermelődési kör látszott. Javítás: a számszerű vagy csíkalapú célsebzés
távolságtól függetlenül elmentődik. Regresszió: `213745-replay`.

A következő `213819-play` 141–145. eseménye stabil 296/296 HP-t mutatott. Ez igazolja,
hogy a `213551` második fáját a hosszú memória valóban befejezte és +10 max HP-t szerzett.
Ugyanebben a futásban az 1,5 másodperces inputőr 140 képen át várt aktív géphasználat
mellett, majd biztonságosan újra mozgott. A következő folyamat kísérleti, 0,35 másodperces
adaptív küszöböt használ: folyamatos inputnál vár, rövid résekben játszik, fókuszt visszaad.

## Tizenharmadik felügyeleti incidens

A `214101-play` gyorsabb, 0,35 másodperces inputküszöbbel folyamatosan haladt és több
passzív célt befejezett. Két hatékonysági/biztonsági hiba jelent meg. A +10 jutalom már
a 25. képen látszott, de a HP-alapú memória a 41. képig várt. Később egy képről eltűnő
támadó után a négyképes sebzésemlék lejárt, és a bot 218 HP-n járőrre váltott; a valódi
`85.8–88.8` HP-t az OCR `185.8–188.8`-nak olvasta, így csak késve reagált. Végül egy
normál, cél nélküli regenerációs képet 15%-os HUD-bizalommal biztonsági stopnak hitt.

Javítás: sorszámozott `+N` harcvégi esemény; pixelkonzisztens tizedes HP; 12 döntéses,
láthatatlan támadóra is működő sebzésemlék; 85%-ig ragadós regeneráció; minimap-alapú
HUD-folytonosság. A `214603-replay` a jutalomeseményt és 88 HP-t, a `214733-replay` a
teljes visszavonulást és az utolsó normál HUD-kép elfogadását igazolta.

## Tizennegyedik felügyeleti incidens

A `214936-play` harc után számszerűen 120→…→299-ig gyógyult, de a taktikai arány a
pixelcsík miatt 31–79% között maradt. A bot végül több száz képen át „biztonságos
regenerációt” várt. A `frame-00245.png` vizuális ellenőrzése teljes csíkot, tiszta 306
HP-t és `0/7` küldetésbuborékot mutatott. A kiváltó okok: 300-as parserplafon, egy 58
px-es valódi csíkhoz képest túl nagyra tanult teljes szélesség, és a két becslés
konzervatív minimuma. Az összeragadt `2181` OCR-t a pixel-előszűrés ráadásul 81-re
torzította.

Javítás: 999-ig olvasható HP, csak tizedes OCR-nél használható pixel-nagyságrendszűrés,
friss elfogadott numerikus mérés elsőbbsége, pixel tartalék és külön mérési eredet a
naplóban. A `215607-replay` 306/100%-on felderítést választott; a `215627-play` azonnal
mozgott, a buborékot külön kattintás nélkül elhagyta, majd 310 max HP-ra fejlődött. A
fókuszkímélő élő küszöb 0,6 másodperc: jellemzően minden második kép végrehajtott swipe,
a köztes képek elemzése és naplózása megmarad.

## Tizenötödik felügyeleti incidens

A `215627-play` 55. eseménye egy 291→258 HP-ra sebzett, 16-os kékfejszés fenyőt mutatott.
A csík takarása után a bot helyesen maradt támadási helyzetben; a 70. mentett képen a fa
még 43 HP-s és a találati sebzés 33. A fa ezután elpusztult, a 75–80. eseményen kb.
`4m 0s` újratermelődési kör jelent meg, de jutalomfelirat nélkül a bot a teljes 36-as
memóriát majdnem kifuttatta. A második nagy fán ugyanez 10 fölösleges döntést okozott.

Javítás: a közeli perc+másodperc időzítő önálló, naplózott harcvégi bizonyíték lett, amely
sebzett passzív célon azonnal törli a célmemóriát. A tartalék hosszú kivárás megmarad, ha
sem jutalom, sem időzítő nem olvasható. A javított bináris a `220154-play` futásban él;
annak első szakasza 320 HP-ról biztonságosan visszavonult egy 128 HP-s támadótól, 85%-nál
oldotta a visszavonulást, majd folytatta a felderítést.

## Tizenhatodik felügyeleti incidens

A `220154-play` 274. eseményétől a bot ismételten egy 200 HP-s célra állt rá. A
`frame-00500.png` vizuális auditja megmutatta, hogy ez a Titan-terület lila portálja;
a 706. eseményig sem történt HP-esés. Közben a célpontpontozó egy 64 HP-s 5-ös és egy
179–200 HP-s távoli jelölt között több alkalommal ellentétes irányú swipe-okat adott.

Javítás: a portál 0,202-es magenta testaránya alapján 0,06-os struktúrakizárás került a
farm- és fenyegetéslistába; normál kontrollcélok aránya 0. A célváltás három végrehajtott
döntéses zárat kapott. A `221123-play` már a portál helyett valódi 128 HP-s humanoidhoz
ment és megölte. Az így megfigyelt `+1` kék fejszét a Vision `+12`-nek olvasta; újabb
javítás a legutóbbi cél 40 képes statértékével normalizálja az összeragasztott jutalmat.

## Tizenhetedik felügyeleti incidens

A `221559-play` teljes 320 HP-n többször 29–31%-os pixelértéket adott két egymást követő
képen, majd azonnal visszatért 320-ra. A hibás képeken nem volt közeli vörös csík; a
korábbi bizonyított támadásos 31%-os képen volt. Egy további `221123` mentett képen a
hamis `285→25%` szintén közeli támadó nélkül jelent meg.

Javítás: a magas numerikus memória 20 százalékpontnál nagyobb pixelzuhanását közeli,
170 px-en belüli vörös csíknak kell támogatnia. A `222028-replay` a hamis képet 89%-on
tartotta, a `214936` valódi sérülését nem tompította.

Ugyanezen felügyeleti ciklusban egy `ScreenCaptureKit CoreGraphicsErrorDomain 1004`
hiba teljesen leállította a botot. A felügyelő azonnal új járatot indított, majd a kódot
úgy módosította, hogy az átmeneti képhibákat 0,75–5 másodperces backoffal korlátlanul
újrapróbálja. A következő élő járat 24 órás technikai időkorláttal fut; kifejezett
felhasználói stop nélkül a felügyelet annak lejárta után is újraindítja.

## Tizennyolcadik felügyeleti incidens

A `222253-play` előbb újabb 10-szíves fenyőt fejezett be: a 110. mentett képen közvetlen
`+10`, `320→330` és `3m 59s` látszott. Két képpel később a konzol 83, majd 56 HP-t és
kritikus menekülést jelzett. A nyers OCR `83m 565`/`33m 56s`, a képen teljes csík és
semmilyen közeli vörös cél volt. A felügyelet ezért ezt timer-átfedésnek, nem rejtett
támadásnak minősítette.

Ugyanebben a járatban a 275–645. esemény a lezárt Island 4 vízszintes kerítésénél
ismétlődött. A képi célok 64/200 HP-sak voltak, de a karakter a zárt oldalon maradt; a
háromlépéses kerülő célváltások miatt nem futott végig.

Javítás: az időegységes OCR-sor teljes kizárása a numerikus HP-ból; robusztusabb timer-
bizonyíték; nyolclépéses, célváltást túlélő főképi akadálykövetés és két kudarc után
18 lépéses kiszakadás. A `223438-replay` mindkét döntési ágat reprodukálta, majd a bot
új binárissal folytatandó élő ellenőrzésre kész.

Az első `223818-play` ellenőrzésen a főképi nyolclépéses mozgás végrehajtódott és balra
haladt, de a minimap később ugyanahhoz a lezárt sarokhoz vitte vissza a karaktert. A
felügyelet ezért nem fogadta el lezártnak a javítást: a minimap ismételt kerülőciklusa is
hosszú ellenirányú területelhagyást kapott, újabb élő újraindítással.

A `224139-play` második ellenőrzése sikeres volt. A 78. eseménynél induló 18 lépéses
kiszakadás a 120. mentett képre elérhető 10-szíves fenyőhöz vitt; a bot a 124–129.
eseményben megközelítette, majd `+10` jutalommal 330-ról 340-re növelte a maximális HP-t.
A folyamat ezután megállás nélkül folytatta a felderítést.

A hosszabb felügyelet kimutatta, hogy a minimap később mégis visszahúzza a lezárt
irányba: a 290/400. mentett kép ismét kerítést, a 441–452. esemény ugyanazt a 200-as
célhurkot mutatta. A folyamat nem állt le, de az útveszteség miatt újabb javítás készült:
a kiszakadást kiváltó irány 120 döntéses hűtést és oldalirányú felderítést kapott.

## Stratégiai újraéledés felügyelete

A `040308-play` öt bossmenekülése megmutatta, hogy a biztonságos elkerülés önmagában
nem garantál fejlődést: a karakter hosszú ideig ugyanabban a zárfal–Deep Mines régióban
maradhat. Az új `041440-play` build öt jutalom nélküli boss-találkozás után feltételesen
a bizonyított, büntetésmentes Meadowlands-respawnt használja farmrövidítésként.

Élő aktiváláskor külön ellenőrzendő:

- a bot valóban a felismert boss felé mozog-e;
- csökken-e a játékos HP, majd eltűnik-e a HUD;
- friss, teljes numerikus HP-val és megtartott 721+ maximummal tér-e vissza;
- a következő terület valóban Meadowlands-e, és mennyi idő az első jutalom;
- jutalom vagy két tiszta új maximum azonnal megszakítja-e a módot.

Ha 120 végrehajtott döntésig nincs halál, vagy a támadó eltűnése után a karakter teljesre
regenerálódik, a mód időkorláttal felold. A küszöböt csak élő idő/hozam mérés alapján
szabad később csökkenteni vagy növelni.
