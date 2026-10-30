# Butcher Hero bot

2026-09-19: [újraindítás, aktuális adatok és audit](docs/203-ujrainditas-es-audit.md).
A korábbi teljes visszatérési makró még nem reprodukált útvonal; felügyelt
helymeghatározás és rövid kísérletek alatt javítjuk.

Legfrissebb: [bolti Free jutalmak teljes auditja](docs/227-bolti-free-statok-es-kulon-felugyelet.md),
[saját képi térkép](docs/228-sajat-terkep-es-sebessegfuggetlen-helyzetkovetes.md),
[14 mozgásos Venom-farm](docs/230-minimap-tampont-es-venom-farmcel.md),
[képpel igazolt helyi útvonalgráf](docs/222-keppel-igazolt-utvonalgraf.md),
[térképvédő és folytonos kerülő](docs/226-bosskerulo-folytonossaga-es-terkepvedo.md).

Aktuális:5860 HP,1,43K DPS,68regen, Phantom Edge4 + Venom Shard18 (242).
Bat Cleaver11 tartalék. A statösszehasonlítás költésmentes1,30K→1,35K javulást adott.
A18,8K/27,7K bossok még nem legyőzöttek; a kitérős kísérlet alapból kikapcsolt (232).

Képernyő-visszacsatolásos, helyben futó macOS bot az iPad-verziójú Butcher Hero játékhoz.
Nem használ billentyűzetes mozgást: kitartott swipe-okkal vezérli a karaktert. A húzás
képenként kiválasztott, szabad játéktérpontról indul, ezért a mozgó panelek nem takarják
le a rögzített alsó vezérlőpontot.

## Gyors használat

```bash
# Csak megfigyelés és képfelismerési napló; nem nyúl a játékhoz
swift run -c release ButcherHeroBot observe --frames 3 --debug

# Egyperces, időkorlátos játékmenet
swift run -c release ButcherHeroBot play --foreground --seconds 60 \
  --save-every 1 --min-user-idle 0 --interval 0.10

# Külön, egyszeri HP-sávos nagyellenfél-mérések oldalkite-tal
swift run -c release ButcherHeroBot play --foreground --seconds 600 \
  --controlled-boss-trials --save-every 1 --interval 0.10

# Korábbi futás újraelemzése, a játék érintése nélkül
swift run -c release ButcherHeroBot replay docs/runs/20260828-172545-play

# Külön boltfelügyelet: piros jelzés, teljes lista, csak biztos Free; nincs mozgás
swift run -c release ButcherHeroBot play --foreground --shop-only --seconds 300 \
  --save-every 1 --min-user-idle 0
```

A játékablak legyen elindítva és látható. A vezérléshez a futtató alkalmazásnak macOS
**Kisegítő lehetőségek**, a képelemzéshez **Képernyő- és rendszerhangfelvétel** engedély kell.
Azonnali leállítás: `Ctrl+C`.

A natív iPad-réteg a közvetlen háttér-inputot jelenleg nem fogadja el, ezért a bizonyított
játékmódhoz `--foreground` kell. A felhasználó legújabb kérése szerint
`--min-user-idle 0` módban nincs emberi aktivitásra várakozás. A bot átveheti
az egeret és a fókuszt; a swipe végén ezeket továbbra visszaállítja.
A korábbi kímélő mód szükség esetén `--min-user-idle 1.5` értékkel visszakapcsolható.

A futások képei és géppel olvasható eseménynaplói a `docs/runs/` alá kerülnek.
Az embernek szánt megfigyelések és stratégiai döntések a `docs/` Markdown-fájljaiban vannak.
A futások között megtartandó, kis gépi tudásállapot (jelenleg a legnagyobb hiteles HP)
a `docs/bot-state.json` fájlban van.

2026-09-19 13:55: Bat Cleaver11 + Venom Shard14; a tartós5750 után közvetlen
bolti+60 és vizuális5,81K. A mai buildcsere851→1,1K DPS-t adott; későbbi statok
a tudásbázisban. A18,8K és27,7K bossok jelenleg kerülendők, újrapróba-kapu
6852/6732 (heurisztika, nem játékszabály). A nagy+300kaktusz három győzelem után
órás/napi cooldownra váltott, ezért nem végtelen hatperces farm. A DOC4,4K-s
őre északról elérve legyőzhető. Aktuális elsőbbség: Free statok, járható kisebb
őrök és nem kimerült farmcélok. Részletek és bizonyítékok: [index](docs/README.md).
