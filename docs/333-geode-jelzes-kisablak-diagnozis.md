# Látható geode-jelzés, mégsem indul nyitás

2026-10-31. A felhasználó azt kérdezte, miért nem nyitjuk ki a láthatóan
rendelkezésre álló geode-ot. Ez a kör diagnózis: production kódot, küszöböt
és játékinputot nem módosítunk a magyarázat kedvéért.

## Futás és bizonyíték

22:42–22:44Z, azaz Budapest23:42–23:44: worker4143 és saját supervisor4142
él, az utolsó sikeres kép fél másodpercen belüli. crystalPhase=idle,
eventEndPhase=idle, nincs egérgomb- vagy függő claim-blokk. A Free-gyűjtés
közben sikeres: 9CB445F5 Pierce575,22:42:55.895Z UI-igazolt.
A kristálynapló utolsó completed_ui sora 9160CB28,21:21:35.706Z.

A Free-kártyákról automatikusan megőrzött teljes HUD-képeket néztük;
nem indult második watcher vagy új képrögzítő. A jobb oldali kék
kristályokon valóban kompakt piros pötty és fehér perem látszik.

Példák az éles, Gitből kizárt evidence-ből:

- `9CB445F5-69AD-40A3-80D4-AE21875596E8-validated-47762596-7645-4115-97B9-083A8A810452.png`;
- `6EAC3A6C-5825-412E-97F8-A5599AC552EA-validated-D9BCF4EC-EB46-4D9D-B63A-9FB19B7748F3.png`;
- `DB92B7FF-DFD5-4A0A-9B3C-D96535A5ABDC-validated-ED3062C1-31C3-4873-8AA3-5A5D60EC4BDA.png`;
- `5F49824C-9429-4631-BABE-D8BE1C4B4DD3-validated-1B396ECC-A57F-464C-9A08-3CB732AC031D.png`.

Mind a `data/free-rewards/evidence/` mappában. A release
`inspect-crystal <saved.png>` nem kattint és nem készít élő képet.
Három friss kép replaye HUD + notification=false, ringDot=absent;
a kristály kékterület-aránya0.371–0.378, tehát a >0.12 kapun átmegy.

## Konkrét elutasítás

A productionnel azonos CG DeviceRGB dekódolású, csak olvasó privát
diagnosztika `.build/crystal-dot-diagnosis.swift`. Képméret637×882,
ROI=(601,396)–(635,445). A piros komponens:

| Feltétel | Mérés | Eredmény |
| --- | --- | --- |
| Közép | 624,428px | ROI-ban |
| Méret | 9×9px | engedett méret/arány |
| Kitöltés | 0.85185 | >=0.55 |
| Nem érinti a ROI szélét | igen | megfelel |
| Sötét körvonal | 24/24 irány | >=16 |
| Fehér gyűrű fix sugáron | 8/24 irány | **nem >=18** |

Tehát a valódi jelzés nem a kékkristály- vagy a piroskomponens-kapun bukik,
hanem a fehérgyűrű-mintavételen. Kis rasterméret mellett a jelenlegi
1.10/1.30/1.50 sugárszorzók és a szigorú fehérpixel-vizsgálat ezt a
látható peremet nem találják meg elég irányban. Nem bizonyított általánosan,
hogy minden kis ablak vagy minden hasonló pötty hibás: ezekre a képekre
konkrétan reprodukált a false negative.

A flow két stabil pozitív notification-t igényel. Ezért az idle itt nem
„már kész” vagy alvó bot, hanem a felismerő elutasítása miatt el sem induló
tranzakció. A korábbi konfettis false positive miatt nem helyes a teljes
védelmet kikapcsolni vagy az ikonra feltétel nélkül kattintani.

## Következő lépés

Külön jóváhagyást kértünk a javításra. Addig nincs production módosítás,
vak nyitás vagy recovery. Javításkor valódi kisablakos pozitív, független
held-out kép és a322konfettis/értesítés nélküli negatív példák szükségesek;
a szigorú teljes kristályfolyamat és az inputbiztonság megmarad.
A Free-gyűjtőt a diagnózis miatt nem állítottuk le.
