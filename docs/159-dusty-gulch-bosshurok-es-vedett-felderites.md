# Dusty Gulch-bosshurok és védett helyi felderítés

## Kiinduló kérdés

A nagy térkép piros ellenféljele valódi, elérhető célhoz vezet-e, és miért nem
halad oda tartósan a bot?

## Biztos megfigyelések

- A jel követése már korábban elvezetett a `Dusty Gulch – 2` normál bejáratához.
  A `140735-play` és `142259-play` futásokban a terület 253 HP-s, `+4` szíves
  ellenfelei összesen 778-ról 802-re növelték a hiteles maximumot. A piros jel
  követésének tehát volt valódi, nagy hozama.
- A `143131-play` későbbi szakaszában a piros vektor ismételten ugyanahhoz az
  oázis melletti, több tízezer HP-s növényi ellenfélhez vitte vissza a karaktert.
  A 197–258. eseményekben újra és újra ugyanaz a minta látszik: hatswipe-os
  bossmenekülés, rövid oldalirányú kerülés, majd piros minimapkövetés és új
  bosskontaktus. Tartós jutalom vagy maximális HP-emelkedés nem történt.
- Ugyanebben a futásban a 259. eseménynél a kutatási mód egy külön 1400 HP-s
  ellenfélen kontrollált próbát indított. A játékos 100%-ról 88%-ra esett, majd
  visszavonult és kigyógyult. Ez bizonyítja, hogy a bot nem pusztán a nagyobb
  ellenfél-HP miatt tagadja meg a harcot: a mérhető 800–8000 HP-s sávokat
  célazonosan, egyszer továbbra is kipróbálja. A későbbi 165. fejezet az explicit
  tizedes K-alakot előbb 15K-ig, majd a 18.8K-s cél után 20K-ig kontrollált
  nagypróbára is feloldotta.

## Ok

A közeli, 800+ HP-s veszély helyesen felülírta a célkövetést és hat tényleges
swipe-pal eltávolodott. Ezután a 120 döntéses célirány-hűtés csak rövid
oldalkerülést adott. Amint a geometria kicsit megváltozott, a nagy térkép piros
vektora ismét érvényes lett, és ugyanabba az oázis–boss körbe fordította vissza a
botot. Az egyes részszabályok helyesek voltak, de együtt periodikus hurkot alkottak.

## Programdöntés

- A narancssziklás Dusty Gulch-memória alatt minden harmadik, fejlődés nélküli
  bosskontaktus 120 tényleges döntéses **védett helyi szabad felderítést** indít,
  de csak akkor, ha nincs már aktív ablak. A progresszió külön lenullázza a
  találkozásszámlálót.
- A védett szakasz alatt a piros minimapjel nem húzhat vissza az ismert boss felé.
  A növekvő helyi keresés valódi, másik útvonalat és kisebb farmcsoportot keres.
- Látható hasznos cél, küldetésút, világ-láda vagy különleges lila hely továbbra is
  megszakíthatja/átveheti a keresést. Három statikus swipe negyedfordulatos
  oldalkitérést vált ki.
- A kontrollált bosspróba nem lett letiltva. Egy új HP-sáv továbbra is egyszer
  mérhető; explicit tizedes K-alaknál a kutatási plafon 20K. A nagy statikus
  szívkaktusznál az ismétlődő öngyilkos roham helyett helyben tartott automata
  támadás fut.
- Dusty Gulchban a stratégiai halál továbbra is tiltott: a cél másik helyi
  `+4` farmcsoport megtalálása, nem a Meadowlandsra való visszateleportálás.
- A korábbi `island4DroughtFreeExploreFrames` változó neve
  `protectedFreeExploreFrames` lett, mert a funkció nem Island 4-zárhoz kötött.

## Első élő ellenőrzés

A release build után indult `143954-play` futásban:

- 0–5: a bot követi a piros minimapvektort;
- 6, 13 és 19: három külön bosskontaktus és biztonságos eltávolodás;
- 20–31: a menekülési memória lefut;
- 32-től: megjelenik a `Védett szabad területfelderítés` döntési ok, és a bot már
  nem fordul azonnal vissza a piros jelre.

Ez az első élő bizonyíték arra, hogy a periodikus visszafordulás megszakadt. A
szabad keresés tényleges farmhozama és az új helyi útvonal még folyamatos mérés alatt
áll. A keret későbbi lejárta után a `143954-play` ismét a piros jelhez fordult,
ezért a történeti köztes szabály minden harmadik progressziómentes kontaktusnál újratöltötte.
A teljes `145011-replay` ezt a teljes 433 képes soron igazolta: a későbbi
bosskontaktusok után a védett keresés újra aktív maradt, nem esett vissza tartós
piros minimapkövetésbe.

## 2026-08-29-i pontosítás

A `150906-play` megmutatta, hogy az aktív 120-as ablak saját kitérései közben újabb
bossokat lát, és a korábbi újratöltés önfenntartóvá teheti a módot. A számláló ezért
most már csak inaktív állapotból indulhat; futás közben nem tölthető újra.

## Bizonyosság

- **Biztos:** a nagy térkép piros jele elvezetett a Dusty Gulch területre és a
  `+24` állandó HP-fejlődéshez.
- **Biztos:** a régi bossmenekülés–minimapkövetés kombináció ugyanazon nagy cél
  körül ismétlődő hurkot alkotott.
- **Biztos:** az új védett mód a harmadik találkozás után élőben elindult.
- **Nyitott:** hány döntés alatt talál új 253 HP / `+4` csoportot, illetve kell-e
  a helyi spirált tereptípus vagy korábbi útvonalszakasz alapján tovább finomítani.
