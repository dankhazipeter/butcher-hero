# CHESTS-audit és1,30K DPS — 2026-09-19

## Teljes ládalista

144453-observe:CHESTSlista alja,ArmorIsland5és14zárak.
144624-scroll két lefelé húzás után144628-observe:lista teteje,Weapon.
144700-scroll további húzás után144703-observe ugyanaz a teteje.
WeaponSquire1láda250gem,Warrior5láda1100gem; továbbiWeaponIsland6zárt.
ArmorIsland5/14zárt;SoulésCrystalsfül lakatos. Nem voltFreeajánlat a bejárt
CHESTSlistán. Nem vásároltunk, nem indítottunk reklámot; gemtovábbra0.

Biztonsági javítás: a statFree-detektor csak aktívSTATSfülön adhat jutalomtapot.
CHESTSfülről a statfigyelő előbb aSTATSfülre vált. Egy esetleges ládásFree
nem tekinthető automatikusan reklámmentes statjutalomnak. Külön tabtesztek készültek.
Kézi felügyelt auditot a `scroll` mód segíti: csak igazoltSHOPon, idle-védelemmel.

## Friss statpanel

144707-bc592525-observe/0:

- DPS1,3K;HP5,84K;regen68.
- Cut123+550; piercing111+560+1%.
- FelszereltBat11+Venom16.
- TartalékPhantom3,Steel22,Fang17.

A további fejlődéshez a30percesVenom-kör, új bejárható célok vagy érdemben
módosított boss-taktika kell; a jelenlegi fizetős bolt nem ingyenes erőforrás.
