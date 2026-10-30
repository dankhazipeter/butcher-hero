# Jobb képszéli rövid csík: nem biztonságos próbacél

## Élő bizonyíték

A `20260829-055128-play/frame-00234` képen a jobb szélen csak egy cél 18 pixeles,
OCR nélküli piros HP-csíkdarabja látszott. A cél `x=604`, a csík jobb széle
`x=613` volt a 623 pixeles képen. A korábbi szabály a 45 pixel alatti, ismeretlen
HP-jú humanoidot próbacélként engedte, ezért 293 pixelről jobbra indult.

Ugyanezen Island 4-oldalon a bizonyított 1,927K-s elit korábban 192-re, majd 92-re
csonkolódott. A képszéli 18 pixeles részletből sem a teljes HP, sem a testtípus,
sem a csík valódi hossza nem állapítható meg. Ezért a rövidség itt nem biztonsági
bizonyíték.

## Döntés

A kép jobb szélét 12 pixelen belül érintő HP-csík nem lehet közvetlen farmcél.
Fenyegetésként és bossőr-bemenetként továbbra is megmarad; a normál navigáció
előbb teljesen képre hozhatja, és csak utána osztályozható. A felső, alsó és bal
képszéli céltiltásokkal együtt ez lezárja a négy részleges látómező fő vakfoltját.

## Ellenőrzés

- a `055940-replay` során nincs közvetlen célmegközelítés;
- teljesen képen lévő, ismert szintű kezdőcélok változatlanul farmolhatók;
- a levágott cél továbbra is szerepel a `visibleTargets` és `nearestThreat`
  diagnosztikában, tehát a biztonsági érzékelés nem vakul el.
