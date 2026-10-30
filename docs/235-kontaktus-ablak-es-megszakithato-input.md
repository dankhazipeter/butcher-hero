# Kontaktusablak és megszakítható input — 2026-09-19

## DOC nem fal a megközelítés teljes ideje miatt

`151005-fd0db6ca-play`:0–18DOCmegközelítés a szélmalom túloldaláról,
19–33takarás és visszakeresés.35-nél a régi szintkülönbség-őr lemondott a célról,
mert már régóta tartott a próba, és egyszer korábban közel kerültünk hozzá.
**38-as képen4,05K DOC-HP**, tehát a következő pillanatokban valós kontaktus
alakult ki. A kezdeti szóbeli „már sebzett cél elhagyása” pontatlan: a35-ös
döntésnél még4400volt a követett érték; a fő hiba a túl korai feladás.

Javítás: valódi, megszakítás nélküli nyolc közeli és nulla sebzéses képre
van szükség a szintkülönbség következtetéséhez. Távoli/takart cél vagy tényleges
sebzés nullázza ezt. A már sérülő4Kfeletti őr is helyben tartható automata
támadással; ez korábban csak10Kfelett volt engedett. AHPvédők maradnak.

## Farmcél elsőbbsége

A régi „kifosztott magaslati ág helyett felderítés” eddig kimaradt a térképes
útvonalréteg általános mozgásai közül. Emiatt a már esedékesVenomcél sem
vehette át. Most ezt is felülírhatja a friss minimaptámpontú farmirány;
harcot és menekülést továbbra nem.

## Leállítás: egérfelengedés

Kódellenőrzés: az azonnaliSIGINT-folyamatölés a swipe közepén elvileg
kihagyhatta a mouse-up/fókuszvisszaadás sorait. A képen maradó joystick
önmagában nem bizonyítja a beragadt inputot, de a kódút javítandó.
`RunCancellation` most megszakításkéréssé alakítjaSIGINT/SIGTERMjelét.
Legfeljebb20msrészekre bontott várakozás, feltétlen mouse-up és kurzor/
fókuszvisszaadás; új döntést a playciklus nem hajt végre megszakítás után.
Egységteszt valódiSIGINT-et küld a saját tesztfolyamatnak, ami nem hal meg,
hanem igazolja a megszakítási jelzést és a várakozás elmaradását.

A régi nagyboss-újrapróba továbbra kikapcsolt. Új élő ellenőrzés következik.

Release build, teljes regresszió és SIGINT-egységteszt sikeres.
`151449-8a671d5d-replay/35` már nem állít szintkülönbséget;37–38a4400→4050
sebzést követi. Ez nem új élő győzelem. A takart sajátHPés halál utáni
mozgástiltás, Shop, képi térkép és állapotírás-védelem regressziója is átment.

ÉlőSIGINT151542/36után0,032s-al visszatért a folyamat, szabályos cleanup-pal.
A korábbi zárószöveg ilyenkor tévesen300s időkorlátot írt; külön megszakítási
üzenetre javítva. Ugyanezen futás9,11,13…képein a vörös háztető tévesX-je
minden második képen megszakította a térképezést, ezértSEfarm ésNWáltalános
felderítés váltakozott. A bezárógombhoz most középen fehérX-pixel is kell;
az egész térképezést korábban megakasztó színfolt önmagában nemUI.
