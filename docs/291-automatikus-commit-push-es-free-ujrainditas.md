# Automatikus commit+push és Free-újraindítás — 2026-10-30

## Két új felhasználói utasítás

1. Minden lezárt változtatási kör után külön kérés nélkül commit ÉS push
   készüljön amainágra. Ez állandó felhatalmazás, nem egyszeri feltöltés.
2. A játék újra fut; aFree-jutalomgyűjtő programot indítsuk el.

A központiAGENTS.mdlegelső munkarendi szakasza mindkettőt rögzíti.
A korábbi külön push-kérés követelménye és a288-as játékSTOP a mostani
kérés erejéig felülírva; a STOP-történet megmaradt.

## Commit és feltöltés rendje

Releváns ellenőrzés → friss dokumentáció → célzott staging/diff-ellenőrzés
→ beszédes commit → `git push origin main` → helyi/távoli egyezés ellenőrzése.
Nincs force-push, idegen munka felülírása vagy titok/build/futási napló
feltöltése. Hiba, jogosultsághiány vagy távoli eltérés esetén ezt jelezzük;
nem állítunk sikeres feltöltést. Csak olvasási körben nincs üres commit.

Most tiszta helyimainág és beállítottSSHoriginfogadott; `git fetch origin`
utánmain...origin/main=0/0volt. Remote:
`git@github.com:dankhazipeter/butcher-hero.git`.
A jelen dokumentációs/munkamenet-változás egy commitba kerül és ugyanebben
a körben amainágra pusholjuk; saját hashét aGit-napló igazolja.

## Újraindítás és engedélyezett hatókör

Nem futott régi vagy új figyelő; a felhasználó által elindított játék
90056PID-je látszott. A már ellenőrzött, változatlan releasebináris indult:
`.build/release/ButcherHeroAutomation watch-free --interval 1`.

ÚjPID90423,execsession95760,runIDa futási naplóban;
2026-10-30T16:09:56.000Z (Bucharest18:09:56) `watcher_started`.
Friss állapot mindig `data/free-rewards/state.json`; nem indítunk másodikat.
A tartós parancsmunkamenet használatának korábbi oka282-ben dokumentált.

Csak a bal oldali event alattiFree-jutalom figyelése/átvétele engedélyezett.
1s mintavétel, kézi húzásvédelem, elengedés után friss ellenőrzés,
megmaradt kártyán1s-os újrapróba; két HUD-képen hiányzó kártya könyvel,
claimenként egyszer. Napló: `data/free-rewards/events.jsonl`, bizonyítékok:
`data/free-rewards/evidence/`. Régi játékbot/heartbeat továbbraPAUSED.
Nincs karaktermozgás, harc, bolt, vásárlás, reklám vagy ismeretlen modalkezelés.

## Élő ellenőrzés

Első claim: `830CF745-347A-40EA-8EA4-D8A16125A9EB`, CutDefense593.
16:09:56.200Zészlelés,16:09:57.477Zclick_sent,
16:10:02.768Zclaim_confirmed_ui. Az asszisztens az utóképet ellenőrizte:
aFreekártya eltűnt, játékHUD látszik. Ezen az utóképen külön zöld+593
feliratot nem állítunk; itt azUI-eltűnés igazolja az átvételt.

Az új futás kezdőidejétől futtatottstatskövetkező pillanatképe:
2elküldött input,2igazolt claim,0függő/besorolatlan/hibás sor,
CutDefense1186. Ez két kijelzett593-as jutalom összege, nem független
teljes karakterstat-mérés. A figyelőt futva hagyjuk a folytatott gyűjtéshez.

Kód nem változott, fordítás vagy új regressziós kör nem kellett; a változatlan
program legutóbbi11tesztje sikeres (289), és az új indítás most élőben is
eredményt adott. E kör ellenőrzése: JSONmunkamenet, Gitdiff, folyamat,
napló, jutalomutókép és statisztika; lezáráskor commit/push/ref-egyezés.
