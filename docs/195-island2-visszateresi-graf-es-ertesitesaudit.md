# Island 2 visszatérési gráf és értesítésaudit

## Biztos megfigyelések

- A jobb oldali piros jelzésű Shopot kézzel végignéztük. A főoldalon
  `FREE IN 19h 20m` látszott, tehát nem volt átvehető napi ingyenes jutalom.
  A Chests fül Squire/Warrior fizetős csomagokat mutatott; automatikus vásárlást
  nem indítottunk.
- A felszerelésaudit idején a Stats 832 DPS-t, 3,43K HP-t, 44,5 regenerációt,
  `118 + 790` támadást mutatott. Bat Cleaver 11 és Steel Splitter 20 volt
  felszerelve; a tartalék 1/8/13 példányok között nem volt jobb biztos csere.
  A későbbi farmban a Steel Splitter 22-re fejlődött.
- A Shop külső piros pontja az ellenőrzés után is maradhat. Ez jelenleg
  promóciós jelzésnek tűnik, nem bizonyít átvehető jutalmat.
- A Titan `0/7` oltártól az Island 2-höz vezető, élőben újramért út:
  `12 N → 14 W → 10 E → 18 N → 10 NE → 10 SE → 20 N → 10 NW → 8 N → 20 W`.
  Az utolsó szakasz az őrtábor járható oldaláról keresztezi a zöld–narancs
  határt. A `083521-observe` őrtábori kép után tíz nyugati hosszú swipe már
  biztosan narancs területre vitt (`083641-observe`).
- A `082127-play` koponyavektora hibás átjárón Meadowlands 1-re vitt. A botot
  azonnal leállítottuk; az oltárnál nem farmolt. A későbbi visszaút bizonyította,
  hogy a minimap euklideszi vektora önmagában nem helyettesíti a topológiai gráfot.
- A `083724-play` Island 2-n ismét közvetlenül a nagy északnyugati sziklafalnak
  vezette a karaktert. A korábban megírt `16 S → 6 W → 12 S` alsó kanyonél nem
  indult, mert a karakteranimáció és a változó órás körök megakadályozták a
  „négy statikus kép” feltételt.

## Programdöntések

- Az alsó kanyon topológiai állapotát most a stabil helyjelek nyitják:
  legalább 80% narancsszikla-fedettség, órás tereptárgy és északnyugatra mutató
  koponya (`y < -0,52`). Ismert falzsebben nem várunk újabb ütközésre.
- A javítás utáni `084413-play` azonnal végrehajtotta a déli–nyugati–déli gráfélt,
  és az alsó bossarénába ért. Ez élő visszaigazolás, nem csak replay-döntés.
- A jövőbeni értesítésaudit külön UI-állapot legyen: csak biztos panelt olvas,
  nem vásárol, az eredményt időbélyeggel dokumentálja és hűtéssel kerüli a
  fölösleges újranyitást.

## Következtetés

Az Island 2-re visszatérés és a szigeten belüli koponyakövetés két külön gráf.
A teljes térkép céljelei stratégiai célterületet adnak, de a fix hajó-, kerítés-,
sziklafal- és magassági csomópontokat külön, irányított élekkel kell tárolni.

