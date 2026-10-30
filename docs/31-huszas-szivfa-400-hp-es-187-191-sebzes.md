# Húszas szívfa, 400 maximális HP és 187→191 sebzés

## Három közvetlen +20 bizonyíték

Az első 20-as szívfa a `docs/runs/20260829-000247-play` futásban:

- `frame-00034.png`: 20-as piros szívikon, 57 maradék HP és lebegő 187-es találat;
- `frame-00036.png`: `340→360`, zöld `+20` szív és `3m 59s` kör.

A `docs/runs/20260829-000913-play` két további példát adott:

- `frame-00020→00024`: ismét 187/57, majd `360→380`, `+20`, `3m 57s`;
- a 278–289. esemény újabb 20-as célhoz közelített; `frame-00290` 191-es találat után
  240 maradék HP-t, `frame-00294` `380→400` és újabb `+20` szívet mutat.

Biztos mechanika: a 20-as szívikonú fenyő ismételhetően `+20` maximális HP-t ad. A
hitelesített maximum ekkor 400 volt. A narancs bányatábor későbbi +4 jutalmai 420-ra
emelték; a `docs/bot-state.json` mindig a legújabb hiteles maximumot őrzi.

## A szívikon nem a cél saját HP-ja

Az első két fa egy 187-es találat után egyaránt 57 HP-n maradt; erős következtetéssel
244 volt a kezdő HP-juk. A harmadik fa 191-es találat után még 240 HP-n állt, tehát
kezdő HP-ja legalább 431 körüli volt. Mindhárom fölött ugyanaz a 20-as szívikon és
mindhárom után ugyanaz a +20 jutalom jelent meg.

Ez újabb közvetlen bizonyíték arra, hogy a cél fölötti statikon a jutalomtípust és
értéket mutatja, nem a cél harci HP-ját vagy „szintjét”. Ugyanazon jutalomhoz eltérő
ellenállás és valószínűleg eltérő respawnidő tartozhat.

## Saját sebzés változása

Két egymást követő fán stabil 187 jelent meg, a harmadikon 191. A Bat Cleaver továbbra
is három példányos, 150 fegyversebzéssel; a bal oldali fegyverpanel továbbra is 4-et
mutat. A +4-es újabb lépcső oka még nyitott: lehet rejtett/alap támadóstat-fejlődés vagy
egy másik progressziós bónusz. A 187 és 191 sem illik a korábbi kb. 1,5-szeres kritikus
mintába, ezért normál találatoknak tekintjük őket.

## Program- és taktikai döntés

- A maximális HP tanulásának korábbi `+15` őre túl szűk volt. A legitim +20 miatt az
  őr `+30`; a 360, 380 és 400 lépcsőt egyaránt helyesen mentette.
- A 20-as szívfa továbbra is kiemelt biztonságos cél, de a hozamszámításhoz a kijelzett
  cél-HP is szükséges: az azonos +20 jutalom mögött legalább 244-es és 431-es változat van.
- Következő Stats-mérésen az alap támadás és a bal oldali 4-es progresszió változását
  külön kell rögzíteni; a következő találatokkal ellenőrizni kell, stabil marad-e a 191.
