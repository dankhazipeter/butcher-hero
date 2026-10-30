# Island 4: gombok által takart 92-es elitcsík

## Képi bizonyíték

A `20260829-060446-play` 11. eseménye egy 92 HP-nak olvasott, ismeretlen szintű,
mindössze 19 pixeles piros csíkot biztonságos célként jelölt 228 pixelen. A szomszédos
mentett `frame-00010` és `frame-00012` képen a cél teljes fegyveres humanoidteste,
a feje fölött `192` részlet és a korábbról ismert jobb oldali elit helyzete látható.
Ez ugyanaz az 1,927K-s veszély, nem 92 HP-s normál ellenfél.

A csík nem a képszél miatt rövid: a jobb oldali bolt-/ládakezelő HUD-elemek takarják
a végét, így a vörös pixeldetektor csak `x=528...547` részt mér. A „45 pixel alatti
csík lehet próbacél” szabály tehát belső HUD-takarásnál sem biztonságos.

## Döntés

Lezárt Island 4 HUD és narancssziklás biom mellett minden ismeretlen szintű,
100 alatti humanoid farmtiltott a mért csíkszélességtől függetlenül. A 100 fölötti
ismeretlen humanoidokra már eleve a 150-es/K-csonkolási őr vonatkozik. Más biom
ismert szintű kis céljai változatlanul farmolhatók.

## Következmény

Az elit 92/192/1927 olvasási sorának minden eddig látott alakja tiltott. A cél
fenyegetésként és képi bizonyítékként megmarad, de többé nem indít szándékos
megközelítést pusztán a HUD által lerövidített vörös csík alapján.
