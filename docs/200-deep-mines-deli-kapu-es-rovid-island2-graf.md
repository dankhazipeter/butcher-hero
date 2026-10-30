# Deep Mines déli kapu és a rövid Island 2-gráf

## A régi útvonalhibát okozó rétegkülönbség

- A `095226-play` futás megszakítás nélkül végrehajtotta a korábbi tízszakaszos
  Titan→Island 2 makrót.
- A `112–131` képeken a karakter a Deep Mines kapu **déli** oldalán állt. Az
  `8N` nem vitte át a zárt kapun, ezért az utána következő `20W` a kapu bal
  pillérének ütközött.
- A korábbi, őrtáborból sikeres nyugati él a kapu északi rétegére vonatkozott.
  Ugyanaz a képernyőirány a déli oldalon nem ugyanaz a topológiai él.
- A `0/1` Deep Mines buborék köztes helyjel, nem cél és nem ok a visszatérési
  makró megszakítására.

## Élőben bizonyított déli út

- A déli kapuoldalról 13 tiszta déli swipe elérte a kövezett útkereszteződést.
- A kereszteződésről a tiszta nyugat a hajótest konkáv zsebébe visz; ezt a
  `094122-play/61–94` képsor ismét bizonyította.
- Ugyanerről a kereszteződésről 12 enyhén északnyugati swipe
  (`x=-1, y=-0,25`, normalizálva) a `101525-observe` képen közvetlenül átlépte
  a zöld–narancs határt Island 2-re.

## Programjavítás

A Titanról induló automatikus visszaút most hat megszakíthatatlan szakasz:

`12N → 14W → 10E → 18N → 13S → 12WNW`

- Az első négy szakasz a Deep Mines déli kapuoldaláig visz.
- Az ötödik a biztos útkereszteződésre ereszkedik.
- A hatodik a hajó fölötti narancs kaput keresztezi.
- A `0/1` buborék nem nullázza az állapotgépet.

## Ellenőrzés

- A release build sikeres.
- A `094122-play` regressziójában a `48`-as, `0/1` buborékos képen a makró nem
  szakad meg.
- A `54–66` döntések 13 déli, a `67–78` döntések 12 nyugat-északnyugati lépést
  adnak; ez pontosan a külön élőben kimért két utolsó gráfél.

