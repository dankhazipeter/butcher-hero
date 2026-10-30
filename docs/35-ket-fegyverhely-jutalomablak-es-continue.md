# Két fegyverhely, jutalomablak és CONTINUE

## Esemény

A `20260829-004437-play/frame-00170.png` képen modális fejlődési ablak jelent meg:

- `2 WEAPON SLOT UNLOCKED!`;
- `New Weapon Slot unlocked! Now you can equip extra Weapon in it!`;
- alul sárga `CONTINUE` gomb.

Az ablak mögött a játék állt, a HUD-bizalom 15% volt. A dialógus-OCR stabilan pontosan
`CONTINUE`-t olvasott, de a régi bot ismeretlen HUD-hiánynak tekintette és várt.

## Automatizálás

Pontos `CONTINUE` OCR esetén a bot a gomb geometriai közepére, a kép `(0,50; 0,80)`
pontjára koppint. Ez nem általános menükattintás: csak a külön megtanult felirat engedi.
A `20260829-004733-play` 0. eseménye a gombot lezárta, a normál HUD azonnal visszatért.

## Játékmechanikai eredmény

A folytatás utáni képen az alsó fegyversorban két aktív ikon látszik:

- Bat Cleaver, `4` kijelzéssel;
- egy világos második fegyver, `1` kijelzéssel.

A karakter képe két fegyvert mutat. A feloldás kiváltó oka még nem bizonyított; közvetlenül
előtte az `1.22K` páncélos elleni veszélyes találkozás és visszavonulás történt.

## Kapcsolódó biztonsági tanulság

Az `1.22K` feliratot a Vision élőben `221`-nek olvasta. Ismeretlen szintű, nem fa
humanoid 150 fölötti OCR-HP-val ezért nem biztonságos cél; OCR nélküli széles csík sem az.
Csak legfeljebb 150 HP, igazolt legfeljebb 2-es szint és legfeljebb 300 HP, vagy rövid,
ismeretlen csík maradhat próbacél.

## A második fegyver azonosítása és optimalizálása

A világos `1` fegyver közvetlen inventory-auditban Savage Fangnak bizonyult: Common,
Piercing, Damage 8, cooldown 1,0 s. A tartalék Steel Splitter 14 Common/Cutting,
Damage 168 és 1,3 s. Explicit második slotba szerelve a Bat Cleaver megmaradt, a
Savage Fang inventoryba került, és a DPS `517→693` lett. A feloldás eredeti kiváltó
oka továbbra is nyitott; maga a fegyver és a jobb build már biztos.
