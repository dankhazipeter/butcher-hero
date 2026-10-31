# Free- és kristálygyűjtés újraindítása — 2026-10-31

A felhasználó kifejezetten újra kérte a program indítását. Ez feloldja314
leállítását kizárólag a meglévő bal oldaliFree-átvétel és a313-ban leírt
kristálynyitás számára. Mozgás, harc, bolt, eladás, felszerelés/fejlesztés,
vásárlás és reklám nincs engedélyezve. Régi bot/heartbeatPAUSED marad.

## Indulás

Friss folyamatlistával igazoltuk, hogy nincs élő korábbi worker/felügyelő.
`scripts/start-free-rewards.sh --resume-run` tartós foreground session91364-ben
elindítva; supervisor95036, worker95041. Indulás2026-10-31T12:22:09Z,
Bucharest14:22. Nem változott a bináris és nem indult második figyelő.
A meglévő logikai statfutás megmaradt, a korábbi naplók/képek érintetlenek.

## Igazolt első átvétel

Claim:37F08443-FA38-4DCD-81FB-2350E4208207.

-12:22:28.157Z: Health18.1K/18100 felismert.
-12:22:29.483Z: frisskép validálva;29.484Zkattintás elküldve.
-12:22:31.699Z: claim_confirmed_ui, a kártya két frissHUD-képen eltűnt.
- Az utóképet vizuálisan is ellenőriztük: explicit **+18.1Kszív** a karakter
  mellett. Ez az átvétel működésének bizonyítéka, nem csak élőPID.

Helyi bizonyíték:
`data/free-rewards/evidence/37F08443-FA38-4DCD-81FB-2350E4208207-after.png`.
Friss `data/free-rewards/state.json`: running=true, új lastCheckedAt,
crystalPhase=idle. A kristályfigyelő ága aktív, de új kristálynyitási sikert
ebben az indulásban még nem állítunk. A06-os külön PierceDamage-összegnil
észrevétel ettől nem javult meg és nem lett régi jutalommal kipótolva.

## Folytatás

A program és saját felügyelete futva marad. A statisztika a helyi naplót
követi; emberi húzás alatt az input várakozik, új stop azonnal leállítja a
gyűjtőt és a felügyelőjét. Következő döntéshez friss state/kép/napló kell,
nem az itt rögzítettPID-k feltétlen újrahasználata. Dokumentációtesztek
közben a gyűjtést nem állítjuk le.
