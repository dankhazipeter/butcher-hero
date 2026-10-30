# Bat Cleaver példányjutalom és 133-as sebzés

## Élő esemény — `235416-play`

A zöld landmark, majd a megjelenő piros minimappontok egy új harci területre vezettek.
A `frame-00198.png` egy 499 HP-s humanoidot mutat a játékos mellett; az ellenfél 20-at
sebzett találatonként. A játékos 340-ről 320→310→303→286 HP-ra esett, majd a bot 84%-on
visszavonult és gyorsan 340-re regenerálódott.

## Biztos Bat Cleaver-sebzés

A `frame-00200.png` egy lebegő fehér `133` találatot mutat, miközben a Bat Cleaver még
két példányos. Ez pontosan `33 alapstat + 100 fegyversebzés`. A cél korábbi 499 HP-ja
két 133-as találat után 233, vagyis `499−2×133=233`; a lebegő szám és a HP-csökkenés
egyezik. Ezen a humanoidon nincs levont 12-es védelem.

## Példányjutalom és szintlépés

A következő automata találat befejezte a humanoidot. A `frame-00202.png` közvetlenül ezt
követően mutatja:

- zöld Bat Cleaver kártya;
- `LEVEL UP`;
- példányszám `3`;
- `Damage 100 > 150`;
- az alsó Equipped hely száma `2→3`;
- a halál helyén kb. `30m 0s`, majd `29m 58s` újratermelődési kör.

Erős, időben közvetlen következtetés: ez a humanoid egy Bat Cleaver-példányt adott. A
harmadik példánnyal a fegyversebzés 150. Az előzőleg bizonyított DPS-képlet alapján az
új elméleti DPS `(33+150)/1.2 = 152.5`, amit a következő inventory- vagy harci mérés
ellenőriz. A következő normál találat célvédelem nélkül 183 lenne.

## Taktikai következmény

- a fegyverpéldány tartós fejlődési jutalom, ezért az ilyen zöld fegyverikonos humanoid
  nagyon értékes;
- a 499 HP-s ellenfél három 133-as ütéssel legyőzhető, miközben 54 HP nettó veszteség
  után a regen gyorsan helyreállít;
- a sűrű területen egyszerre látszik 923 HP-s fa, 200-as Titan-portál és 4,31K boss,
  ezért a jutalom ellenére a boss- és klasztervédelem nem lazítható.

## Következő mérés

Az első Bat3 találaton ellenőrizni kell a 183-as normál és kb. 275-ös kritikus értéket,
valamint azt, hogy más zöld fegyverikonos cél is pontosan egy példányt ad-e.
