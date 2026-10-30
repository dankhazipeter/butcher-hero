# Unstuck-szabad mód elsőbbsége a drought felett

## Élő anomália

A `085649-play` 168. döntése megnyitotta a Settingset, a 169. megnyomta az Unstuckot.
A panel eltűnt, a karakter a medencénél 722→744→778 HP-ra gyógyult. A 199. döntés
szabályosan lezárta a 30 inputmentes ciklust és beállította a 120 döntéses helyi szabad
felderítést.

A 200. döntés mégsem a helyi spirált választotta. Mivel a jutalomhiány-számláló 150
fölött maradt és a minimap balra mutatott, ugyanazon képen frissen elindult a hosszú
Island 4 drought-területelhagyás. Ennek kimeneti oka:

`Tartós jutalomhiány az Island 4 zárútján; hosszú kifelé-oldalra területelhagyás`

## Ok

A korábbi javítás a statikus, minimapos, célkerülő és blokkolt útvonalmemóriát törölte,
de két rés maradt:

1. a teleport nem nullázta a külön drought-területelhagyás állapotát;
2. a drought indítófeltétele nem vizsgálta, hogy a 120-as szabad mód már aktív-e.

Ez prioritási hiba: az Unstuck célja éppen az, hogy a régi zárút minimapjelét átmenetileg
figyelmen kívül hagyjuk.

## Javítás

Sikeres Unstuck végén most törlődik:

- `island4DroughtEscapeFrames` és a cooldown;
- a drought iránya, oldaljele és statikus fordulatszáma.

Emellett a hosszú drought-ág csak akkor indulhat, ha
`protectedFreeExploreFrames == 0`. A korábbi implementáció és e történeti mérés ezt
`island4DroughtFreeExploreFrames` néven vezette; a semleges új név rögzíti, hogy nem
Island 4-geográfia, hanem általános védett felderítési időablak. A szabad módot továbbra is megszakíthatja valódi
cél, küldetésútvonal vagy világláda; puszta jutalomhiány és régi minimapjel nem.

A leállítás előtti élő kimenet egy második prioritási rést is megmutatott: amikor a
hibás drought a 234. döntésnél végül szabad módra váltott, hat azonos spirállépés után
a 241. döntés friss statikus faljárást indított. Ezért aktív szabad mód alatt a statikus
kiszabadítás már futó ága és új indítóága is tiltott. A négyzetspirál saját
irányváltása oldja az akadályt; boss, cél, quest és láda biztonsági prioritása megmarad.

## Ellenőrzési feltétel

A `085649-play` javított visszajátszásában a 199. forrásdöntés utáni első mozgásnak
`A jutalomhiányos zárút után ... növekvő szabad területfelderítés` okkal kell indulnia,
nem hosszú drought-területelhagyással.

## Élő igazolás

A teljes javítást már tartalmazó `090616-play` újabb sikeres Unstuckot hajtott végre.
A 326. döntés lezárta a 30 ciklusos helyreállítást, majd a 327–342. döntések
megszakítás nélkül a `A jutalomhiányos zárút után ... növekvő szabad
területfelderítés` ágat futtatták. Nem jelent meg sem hosszú drought-területelhagyás,
sem hatswipe-os statikus faljárás. A prioritásjavítás így élőben elfogadott.

A későbbi sátor–őrtorony kör azt is megmutatta, hogy a védelem alatt a hosszú
spirálszár nem maradhat vak a statikus falra. A teljes faljárás továbbra sem indul,
de három változatlan swipe után helyi negyedfordulat történik; lásd a
[129. fejezetet](129-vedett-szabad-mod-harom-statikus-negyedfordulata.md).
