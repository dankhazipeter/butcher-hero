# Jobb oldali 92/192 elit: helyi azonosító és respawnforrás

## Miért több egyszerű farmtiltásnál

Az Island 4 jobb oldalán ismételten ugyanaz a fegyveres humanoid jelent meg:

- előbb stabil 192 HP-részlettel;
- közelebbről teljes 1,927K nyers értékkel;
- később 92-re csonkolva;
- a `060446` képen a jobb oldali HUD által 19 pixelre takart csíkkal, 92/192 alakban.

A 150-es ismeretlenszint-őr és az új 100 alatti helyi tiltás megakadályozta a téves
támadást, de a cél nem számított boss-találkozásnak. A bot így teljes HP-n is sokáig
kerülgette a híd–1/57 láda környékét, a büntetésmentes újraéledési rövidítés nélkül.

## Helyi bossazonosító

Bossbizonyíték a 90–199 közti csonkolt HP, ha egyszerre teljesül:

- lezárt Island 4 HUD és narancssziklás biom;
- a cél a fal jobb, elérhető oldalán áll;
- nincs felismert szintje;
- nincs szív- vagy fejszejutalom-ikonja;
- nem fás testű.

Ez a minta a dokumentált elit minden 92/192 alakját lefedi, de kizárja a szíves kis
humanoidokat és a fás/kaktuszos normál célokat. A teljes 1927/1192/1.927K nyers alak
a külön 800+ őr miatt továbbra is azonnal boss.

## Stratégiai következmény

A bot most megelőzően eltávolodik az elittől, a találkozást pedig beleszámítja az
öt eredménytelen bosskörbe. Az ötödik után, 90%+ HP-n és kiemelt szívfa hiányában
az elérhető jobb oldali elitet szándékos, büntetésmentes újraéledési rövidítéshez
használhatja, hogy visszajusson a Meadowlands biztonságos farmjára.
