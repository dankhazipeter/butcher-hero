# Magaslati ellenfélcsoport és távoli kontrollált próbakapu

## A ládazóna és az élő cél nem ugyanaz

A narancssziklás, szintkülönbséges régióban az egyszer már kinyitott különleges
láda nem indokol visszatérést. A `20260829-174104-play` azonban megmutatta, hogy
ugyanennek a tágabb régiónak lehet még külön, élő harci értéke: a minimap több
belső piros pontot mutatott, és a képernyő felső részén több egyező, 1,16K-s
ellenfélcsík jelent meg.

Ezért a szemantikus szabály nem tilthatja le az egész narancssziklás biomot:

- a begyűjtött láda iránya friss ládajel nélkül lezárt;
- a biztos belső piros pont és vele egyező látható ellenfél új, önálló cél;
- a 8 órás körök már legyőzött, hosszú újratermelődésű helyeket jelölnek, nem új
  zsákmányt;
- a sziklák és hidak miatt a képi célirány nem azonos a járható útvonallal.

## Miért nem indult el az 1,16K-s próba

A 81–86. eseményekben a célok 423–502 pixelre voltak. A belső piros minimapirány
egyezett a képi céliránnyal, de a kontrollált bosspróba régi felső közelítési
kapuja 420 pixel volt. Néhány pixel miatt a döntő nem rögzített ellenfelet, hanem
újra akadálykerülésbe váltott.

Javítás: belső piros ponttal irányegyező, látható 800–20K HP-s cél esetén a
próbakapu 520 pixel. Térkép-igazolás nélkül marad a 420 pixeles korlát. A már
súlyos vereségként tárolt sávok — jelenleg a 18,8K 984-es saját maximumnál —
ugyanezen 520 pixeles körön belül már távolról területelhagyást váltanak ki.

## Élő 3,06K-s kontaktus

A régi kiadás még a javítás előtt végül más útvonalon elért egy 3,06K-s célt.
A 182. döntés kontrollált próbát indított. A friss numerikus saját HP
`984→928→905` volt, majd a cél röviden takarásba került. A 189. képen egy
ismeretlen közeli cél 70 pixelre jelent meg és a saját pixeles csík 33%-ra esett;
a bot azonnal kifelé mozdult.

A 3,06K-s fegyverhordozó korábban 802-es maximummal, 566-os numerikus mélyponttal
már bizonyítottan legyőzhető volt. A mostani rövid kontaktus ezért nem vereség,
hanem félbeszakított csoporthelyzet. A 33%-os pixeles mérés harc közben, valódi
közeli csíkkal együtt biztonsági szempontból elfogadható visszavonulási jel; friss
teljes numerikus HP után a sáv újra próbálható.

## A következő futás eredménye: 999 HP és végtelen visszavonulás

A `20260829-174731-play` az új kapuval már a 3. döntésben 1,28K-s, majd a 19.
döntésben 2,49K-s kontrollált próbát indított. A harci szakasz után a mentett képen
teljes zöld csík fölött egyértelmű **999** látszott. A korábbi 984-hez képest ez
pontosan +15, az ismert szívjutalomlépcső; az új tartós maximum ezért 999.

A 2,49K-s közelítésnél 29%-os pixeles esés indított visszavonulást. Később több
mint hatvan képen át teljes maradt a pixeles csík és nulla közeli fenyegetés
látszott, de a numerikus OCR-t a körök takarták. A bosspróba ezért nem oldódott
fel. Javítás: ha a friss sebzési memória már lejárt, nyolc egymást követő, legalább
97%-os pixeles HP-kép és nulla közeli fenyegetés lezárja a visszavonulást. Ez nem
igazolhat új maximumot; kizárólag a navigációs holtpontot oldja fel.

## Mérendő

- Az 1,16K-s magaslati csoport egyenként milyen jutalmat és saját HP-mélypontot ad.
- A 3,06K-s hordozó most ugyanaz a fegyverjutalmas típus-e, és megmaradt-e a
  korábbi legyőzhetősége 984 maximumnál.
- Az utolsó piros pont eltűnése után a bot elhagyja-e a hosszú időzítős,
  kimerített folyosót ahelyett, hogy a régi ládahelyre navigálna.
