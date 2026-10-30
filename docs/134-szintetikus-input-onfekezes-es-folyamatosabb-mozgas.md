# Szintetikus input önfékezése és folyamatosabb mozgás

## A darabosság oka

A bot a rendszer „utolsó input óta eltelt idő” órájával védi a felhasználó egerét és
fókuszát. A macOS ebbe a bot saját kurzor-warp, mouse-down, drag és mouse-up eseményeit
is beleszámította. Így minden végrehajtott swipe után a következő ciklus tévesen úgy
látta, hogy a felhasználó aktív, és egy teljes döntést kihagyott.

Ez nem taktikai óvatosság volt, hanem önfékezés: mozgás → téves `VÁR` → mozgás.

## Javítás

A `SwipeController` most eltárolja a szintetikus input előtti valódi inaktivitást és a
botinput befejezési idejét. Ha a rendszer nyers idle-órája ugyanazzal az ütemmel fut,
mint a bot utolsó eseménye, a korábbi valódi idle-időt folytatja. Ha ennél rövidebb
érték jelenik meg, az a bot után érkezett emberi input, amely azonnal elsőbbséget kap.

Ezzel:

- megszűnik a saját swipe-ok utáni váltakozó üres ciklus;
- a `--min-user-idle` védelem megmarad;
- a kurzor és az előző fókusz minden gesztus után továbbra is visszaáll;
- felügyelt mérésben `--interval 0.10` használható a korábbi 0,35 helyett.

## Korlát

A natív iPad-kompatibilitási réteg továbbra sem fogadta el a valódi háttér-inputot.
Ezért a javítás nem állít fókuszmentes vezérlést: csak rövidebbé és ritkábbá teszi a
fókuszátadásokat, miközben az emberi aktivitás elsőbbsége megmarad.

## Ellenőrzés

A release build sikeres. A taktikai replayek változatlan döntéseket adnak; az idle-óra
teljes bizonyítása a következő engedélyezett élő futás inputnaplójában történik, ahol a
bot saját swipe-jai után nem szabad minden második eseménynek `A felhasználó aktív`
várakozássá válnia.

