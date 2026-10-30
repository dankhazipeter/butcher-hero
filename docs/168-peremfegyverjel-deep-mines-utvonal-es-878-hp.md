# Peremfegyverjel, Deep Mines-útvonal és 878 HP

## Miért nem követte a bot a nagy térképen látható ellenfelet?

A `155618-play` Titan-területén a minimap bal felső pereme fölött jól látható
piros fejsze/kalapács jelent meg. Ez nem a térkép belsejében rajzolt 2–10 pixeles
piros pont: nagyobb ikon, és a kör sugarán kívülre lóg. A régi felismerő ezért
nem vette fel a piros komponensek közé, majd cél nélkül négyzetspirálra váltott.

Ez képfelismerési hiba volt, nem stratégiai döntés. A felhasználó helyesen látta,
hogy van kijelölt ellenfél.

## Javítás és élő igazolás

- Külön peremcél-detektor készült a minimap 1,10–1,45 sugaras gyűrűjére,
  legfeljebb 26 pixeles piros komponensekkel.
- A peremre kitolt fegyverjel elsőbbséget kap a köztes passzív farmpontokkal,
  a Titan-oltár lila ikonjával és a türkiz Deep Mines-sínnel szemben.
- A korábbi Deep Mines-kapuhűtés nem némíthatja el ezt az explicit, frissen
  látható ellenféljelzést. A hűtés történeti útvonalbizonyíték, nem örök tiltás.
- A `160206-play` 5–15. eseménye már folyamatosan `(-0,76; -0,66)` irányban
  követte a jelzést. Az út közben felvillanó türkiz sín még egyszer eltérítette;
  a második javítás után a `160521-play` 0–22. eseménye megszakítás nélkül a
  piros peremcélt tartotta.

## Mit talált az út végén?

A `160521-play/frame-00056` havas Deep Mines-peremet mutatott. A felső oldalon
több `1.92K` páncélos ellenfél látszott, jobb oldalon pedig a már ismert `4.31K`,
500-as statikonú óriásfa. A karakter és az 1.92K-s csoport között sziklapárkány,
roncs és kerítés állt. Hat külön statikus kerülési fázis sem nyitott átjárót,
ezért a bot a bizonyított Unstuck-helyreállítást indította.

Ez nem sikertelen harc: támadási kontaktus és 1.92K HP-csökkenés nem történt.
Az útvonal továbbra is kutatási feladat. A helyszíni `Find a magic anti-stone
potion in Deep Mines 0/1` feladat erős jel arra, hogy a fizikai átjárás vagy a
kőakadály feloldása a bájital megszerzéséhez kötődhet; ez még hipotézis.

## Új maximális HP

A `155618-play/frame-00119` egy közeli 10-szíves kaktusz befejezésekor közvetlen
`+10` szíveffektust mutatott. A következő képen a numerikus saját HP `878` lett,
és később többször visszatért ugyanide. A korábbi bizonyított 868 maximumhoz ez
pontosan illeszkedik, ezért a tartós aktuális maximum 878. A közben látott 898 és
929 továbbra is OCR-zaj; jutalom és stabil képsor nélkül nem írhatják felül.

## Következő kísérlet

Az Unstuck után a rövid helyi kijutás lejártával ismét a piros peremcél következik.
Ha a közvetlen út újra a párkányhoz vezet, a türkiz sín nem új célként, hanem az
ellenfélhez tartó lehetséges kerülőút jeleként használható. Győzelem csak tényleges
cél-HP-eséssel, eltűnéssel/cooldownnal vagy jutalommal igazolható.

## Utólagos pontosítás

A `161727-play` komponensmérése megmutatta, hogy a valódi fegyverjel két darabja
1,27–1,31 térképsugárra van, míg egy közönséges belső piros pont 0,91-re. Az első
0,78-as alsó kapu ezért túl tág volt, és időnként egy 1.28K-s kaktuszt választott.
Az aktuális 1,10-es kapu ezt kizárja. A következő élő ciklus azt is megmutatta,
hogy a körön belüli piros pontokat a peremkomponens elé kell sorolni. A későbbi
878→953 fejlődést, a 672-es csoportharcot, a 11,4K-s kaktusz sebzésmérését és a
4,4K-s erődőr célzárát a `169-terkepcel-csoportharc-es-953-hp.md` folytatja.
