# Elutasított első kristálynyitás ne állítsa meg a gyűjtést — 2026-10-31

## Konkrét észrevétel a317-es éles felügyeletben

Az eseménybezáró fejlesztés feltöltésekor a futó program a
677E54A4-F944-4D1A-9D40-649E66EA1653kristálytranzakció openingfázisában
ismételten `Crystal preclick rejected: openInventory/hud` hibát naplózott
(például18:20:34–40Z). Nem látszott hozzá elküldött elsőnyitás.
A forrás szerint ez HUD-ot, de a friss aktiválás utáni képen hiányzó
értesítésfeltételt jelent. A pontos képi okhoz nincs mentett elutasítási
kép, ezért nem állítunk bizonyított pixelokot vagy valódi geodehiányt.

A bizonyított vezérlési hiba: már az input ELŐTT elutasított nyitás is
lefoglalta a kristályágat a90s keretig, így aFreegyűjtés nem kapott inputot.
Ez nem új mozgási, vásárlási vagy általánosmodal-kezelési feladat: csak a
meg nem történt művelet utáni felesleges várakozást oldjuk fel.

## Szűk javítás

`CrystalFlow.abandonUnsentOpening` csak akkor ad vissza idle-t, ha
phase=opening és openInventory elküldöttpróbák=0. A kristálykap60s
cooldownt, a gyűjtés a következő körben frissFreejelölttel folytatható.
A watcher nem-human kattintás-elutasítási ága hívja, kézi húzás/húzásvédelem
nem. Már elküldött elsőnyitás, feltörés, eredmény vagy Continue nem dobható
el ezzel. Nincs bezárókattintás, UIátugrás, jutalomkönyvelés vagy új költés.

Külön `crystal_opening_abandoned` diagnosztika kerül a kristálynaplóba;
a meglévő `crystal_finished_no_reward` egyszer zárja a tranzakciót.
Az eseményablak-kezelő317 változatlan, aFreeösszeg-felismerő nem módosult.

## Teszt és követés

Újunit: el nem küldött kezdés feloldható,0siker,60s-on belül nincs új
nyitás; utána újrapróbálható. Már küldött kezdet vagyopenOne nem oldható
fel. Teljes csomag:53Swift+16Pythonstats+3Gitkapu+10supervisor+31Node =
113teszt,7JSszintaxis; a végső commit/push kapu ugyanezt újrafuttatja.
A317felismerési mintái és a korábbi rögzített elvárások változatlanok.

Előre fordított318build betöltve18:24:10Z, supervisor21358/worker21386,
tartóssession51821, --resume-run. Friss játékHUD és idle fázis igazolt;
a konkrét régi elutasítás új éleselőfordulása még nem történt meg ezen
a builden, az állapotátmenet tisztatesztből ellenőrzött. A317DiamondLeague
két képernyője ekkor nincs nyitva, így annak élesbezárása sem állított.
A program és a felügyelő futva marad, nem hagyunk kettős watchert.
