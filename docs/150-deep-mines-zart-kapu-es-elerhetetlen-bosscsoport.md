# Deep Mines: zárt kőkapu és jelenleg elérhetetlen bosscsoport

## Biztos megfigyelések

- Az élő `docs/runs/20260829-132425-play` futás 128–133. képe a türkiz szaggatott
  Deep Mines-sínt követte egy új, csontvázas táboron át.
- A küldetésbuborék szövege: `Find a magic anti-stone potion in Deep Mines`, az
  állás `0/1`. A bájital tehát még nincs megszerezve.
- A 134. képtől egy széles türkiz–lila kőátjáró választja el a játékost a havas
  fennsíkon álló `1.92K` és `7.15K` HP-s ellenfelektől. A játékos az átjáró alsó,
  az ellenfelek a felső oldalán maradtak.
- A cél kezdeti `:92K` OCR-je felső képszéli csonkolás: teljesebb képen ugyanaz az
  ellenfél `1.92K`. Nem 920 HP-s új cél.
- Hosszú közvetlen közelítés, majd mindkét tangenciális oldal kipróbálása közben a
  játékos 778 HP-n maradt, egyik boss HP-ja sem csökkent, és nem keletkezett
  találati sor. A 161. képen a jobb oldali hídvéget szikla, a 184. képen a középső
  kaput maga a kőfal zárta. Ez útvonalpróba volt, nem elvesztett harc.

## Következtetés

Erős, több irányból megismételt bizonyíték szerint a havas `1.92K`/`7.15K`
bosscsoport jelenleg fizikailag elérhetetlen erről az oldalról. Valószínű, hogy a
`0/1` anti-stone potion vagy egy másik küldetéslépés nyitja ki az átjárót. A két
ellenfél tényleges legyőzhetősége ettől még nyitott: a bot még nem került velük
valódi ütésváltásba.

## Programdöntés

- A kontrollált próba három stagnáló közelítési ciklus — közvetlen út és két
  oldalváltott kerülő — után zárt Deep Mines-kapuként osztályozza ezt a helyzetet.
- Ugyanez korábban lezárható, ha két teljes, ellentétes oldalkerülő után a cél 300
  pixelen túlra távolodik, és újra megjelenik az alsó `anti-stone potion 0/1`
  táborbuborék: ez bizonyítja, hogy a karakter a kapu innenső oldalára ért vissza.
- Ekkor eltávolodik a bosscsoporttól, és 600 tényleges döntéses
  `deepMinesGateBossCooldownFrames` hűtést indít.
- A hűtés alatt a látható Island 4-zár és a Deep Mines-sín együtt nem indíthat új
  türkiz útvonalkövetést, kontrollált bosspróbát vagy stratégiai respawnt ugyanabba
  az elérhetetlen csoportba.
- Valóban közel kerülő ellenfél, friss sebzés és általános biztonsági őr továbbra is
  felülírhatja a felderítést.

## Visszajátszásos ellenőrzés

A `docs/runs/20260829-133641-replay` 294. eseménye felismerte a kétoldali próba után
a zárt kaput. A 295–320. esemény között csak eltávolodás futott: nem indult új
quest-sín, bosspróba vagy stratégiai respawn. A hűtési védelem e képsoron működik.

A későbbi `docs/runs/20260829-134530-replay` a pontosított célazonossággal a kis
20 HP-s célt kizárta, majd a 141. képen a két oldalkerülő + `0/1` táborba visszaérés
alapján ugyancsak zárt kaput állapított meg.

## Nyitott kísérlet

Fel kell deríteni a `0/1` anti-stone potion elérhető oldalát és jutalomforrását. A
kapu feloldása után az `1.92K`, majd külön a `7.15K` ellenfél kontrollált harci
próbája folytatható; addig egyikre sem állítható győzelem vagy vereség.
