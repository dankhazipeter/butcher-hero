# Kettős +3, 727 HP és 387 sebzés

## Eseménysor — `20260829-041440-play`

A friss, stratégiai respawnt tartalmazó build még az első szándékos újraéledés előtt
két 3-szíves, 41 HP-s humanoidot keresztezett a tábori úton:

- `frame-00076.png`: egy korábbi humanoid teste már a földön, egy második 41 HP-s cél
  még él; a játékos maximuma 721. Fehér fejsze mellett 387, nyílikon mellett 24 látszik.
- `frame-00078.png`: az első elkülönített `+3` szíveffektus és 724 HP, miközben a
  második 41 HP-s humanoid még teljes csíkkal áll.
- `frame-00080.png`: a második humanoid is elesett; újra 387-es fejszes és 24-es
  nyílikonos érték látszik, a maximum még 724.
- `frame-00082.png`: külön második `+3` szíveffektus és tiszta 727 HP.
- A 81., 83. és további események friss OCR-je ismételten 727-et mutat; a
  `bot-state.json` helyesen ezt tartósította.

## Következtetések

- A két külön 3-szíves humanoid két külön +3 maximális HP-t adott: 721→724→727.
- Az út menti, együtéses 41 HP-s csoport továbbra is a legjobb gyorsfarmcélok egyike.
- A `040308/frame-00488` +1 fejszejutalma előtti 385-ös fehér fejszes szám után a
  következő két tiszta normál érték egyaránt 387. A kijelzett találati sebzés tehát
  ezen a mérésen +2-vel nőtt, nem +1-gyel.
- A nyílikonos 24 mind a 385-ös, mind a 387-es képen változatlan. Ez valószínűleg másik
  stat vagy másodlagos sebzéskomponens, nem a kékfejsze-jutalom közvetlen célja.
- A pontos képlet még nyitott: a +1 támadóstat fegyverszorzó vagy kerekítés miatt
  jelenhet meg +2 végső sebzésként. Két azonos 387 erősebb bizonyíték, mint egyetlen
  változó harci szám, de további normál találatok szükségesek.

## Stratégiai következmény

A fejlődés két egymást követő teljes 727-es OCR-rel a jutalomeffektus gépi felismerése
nélkül is lenullázta a boss-hurok számlálóját. Ez élőben igazolja a stratégiai respawn
második, maximumalapú megszakítóőrét: a bot nem választ újraéledést közvetlenül egy
sikeres, de OCR-rel kihagyott farm után.

