# Jobb képszéli 192-ből 1,927K: a próbacél visszavonása

## Élő ellenbizonyíték — `20260829-050827-play`

Az erőfüggő, 151–250 HP-s kísérleti kapu élőben felvette a korábban stabil 192-nek
olvasott humanoidot. A cél 275→227→199→170, majd 160 pixelre közeledett. A 160–180
pixeles szakaszon a fa emelvény és kerítés geometriája miatt elakadt, ezért a
nyolclépéses tartós kerülő átvette a vezérlést.

A `frame-00058` tisztább képe döntő ellenbizonyítékot adott:

- a cél helyreállított HP-ja 1927 lett;
- `bossEvidence == true` aktiválódott 230 pixelen;
- a szűk cél-OCR szövege közben továbbra is csak `192` volt;
- a nyers bossőr azonnal balra, a veszélytől kifelé indította a botot;
- a játékos 747/747 HP-n maradt, tehát sérülés nem történt.

A cél valójában kb. 1,927K HP-s elit. A jobb képszéli UI és levágás miatt a K/utolsó
számjegy nem látszott minden célrégióban. Ez ugyanannak a korábbi `1.22K→221/7`
hibacsaládnak egy új változata, nem valódi 192 HP-s normál humanoid.

## Visszavont döntés

A 700+ játékosmaximumhoz kötött 151–250 HP-s lazítás elvetve és a kódból eltávolítva.
Ismeretlen szintű, nem-fa humanoid 150 fölötti kijelzett HP-val továbbra sem lehet
közvetlen farmcél pusztán a magas játékos-HP vagy sebzés miatt. A büntetésmentes halál
csökkenti a kockázatot, de az ismert elit felé vezető hosszú kerülő rossz időhozam,
és nem ad új tudást minden ismétlésben.

A későbbi erőskálázás csak további, a K-csonkolástól független bizonyítékkal térhet
vissza, például biztos szintikonnal, többképes nyers HP-helyreállítással vagy ismert
testazonossággal. A puszta `151…250` numerikus tartomány önmagában nem elég.

## Regresszió és folytatás

A visszaállított build a `050827/frame-00008`, `frame-00020` és `frame-00058` képeken
egyaránt kizárta a közvetlen farmcélt. Build sikeres; az élő felügyelet
`20260829-051233-play` néven azonnal folytatódott 747 hiteles maximummal.

