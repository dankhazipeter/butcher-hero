# Nyugati zsákudvar kijárata — 2026-09-19

## Biztos képi mérés

`154802-d33bc484-play/12`: a karakter nyugati kerítés és keleti magas szikla
között áll. Északnyugatra nincs út; a minimap piros céliránya a falba vezet.
A haladásőr automatikusan megállította. Nem használunk Unstuckot, mert délen
járható folyosó látszik.

- `154859-add4134e-nudge`:6S,0,50s. Végpont `154908-d84f6df0-observe/0`,
  orange-skull(-60;15), Venomhoz viszonyítva(-64,5;-50,5).
  A déli szikla miatt tovább nem pusztán délre, hanem a jobb oldali nyílt udvarra.
- `154926-cbf980c1-nudge`:6SE,0,50s. Végpont `154946-e85074af-observe/0`,
  orange-skull(-45,5;26,5), Venom(-50;-39). Nyílt, időzítős kaktuszudvar,
  egészség5860; a sziklazsákból kijutottunk. Nem új ölés vagy jutalom.

## Programdöntés

`docs/west-courtyard-exit.json` menti a belépési régiót, két mért köztes pontot
és a képi bizonyítékot. Saját folyosótervező a farmcél hűtésétől függetlenül
előnyben részesíti a kijáratot, de csak távoli/hiányzó cél és közeli veszély nélkül.
Nincs rögzített húzásszám: friss minimappozíció teljesíti a pontokat; helyi
akadályellenőrzés,180s időkeret és hűtés megmarad.

Egységteszt: déli első pont, délkeleti második, végponton megszűnő irányítás.
A teljes automatikus bejárás élő ellenőrzése külön következik; a12kézi mozdulat
önmagában nem bizonyít automatikus reprodukálhatóságot. Új célt kell keresni
a nyílt udvarból; a régi északnyugati minimapirány ismétlése nem stratégia.

Releasebuild és folyosó-egységteszt sikeres. A megelőző haladásőr-javítással a
teljes replayregresszió is sikeres, tartós állapotot nem módosított.
Új élő próba: `155210-a9525cac-play`,120s felső korláttal, idle1.5,
kikapcsolt kitingpróbával. A folytatást a239-es aktív képi felügyelet követi.

## Élő részleges siker és következő hiba

`155210-a9525cac-play/5–9`: a folyosó automatikusan átvette az irányítást;
10képen friss minimap(-46,5;25,5), nyílt udvar,5860HP. A köztes pontok
vezérlése működött a mostani belépési helyről, nem a teljes északi végpontból.
**Utána viszont a régi piros-célkereső ismét északnyugatra fordult**, és23képnél
visszajutott az északi zsákvéghez(-59,5;1).29után kézzel megszakítottuk.
A kijárat helyi sikere tehát nem oldotta meg a stratégiai visszatérést.

Következő kötelező javítás: a sikertelen távoli minimapcélt helyhez kötötten
karanténba kell tenni és más elérhető célt/frontiert választani; nem elég az
útvonal végét elérve visszaengedni ugyanazt a hibás célirányt. A folyosó180s
hűtése miatt változatlan újraindítás most különösen rossz lenne. A friss végpont
`155210/29`, bot inputja leállítva a javításhoz, percenkénti modellfelügyelet aktív.
Az új felügyeleti kör ebből a hibából induljon, ne indítsa vakon a régi playt.
