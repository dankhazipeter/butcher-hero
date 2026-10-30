# Jobb oldali boltmenü biztonságos felderítése

## Indok

A Bat Cleaver felszerelése 111-re növelte a DPS-t, de a helyi farmcélok több mint két
órás cooldownon vannak. A Mailbox üresnek bizonyult. A jobb oldali zöld-fehér ponyvás
ikon a következő még ismeretlen játékrendszer, amely ingyenes jutalmat, játékon belüli
valutás fejlesztést vagy fizetős ajánlatot egyaránt rejthet.

## Biztonsági protokoll

1. legalább 24 tényleges döntésig nincs biztonságos főképi cél;
2. HP legalább 90%;
3. egyetlen tap kb. 94,8% szélesség / 51,5% magasság ponton;
4. külön `shopInspectionMode` állapotban a bot csak vár és képet ment;
5. sem árat, sem reklámot, sem vásárló/claim gombot nem nyom meg automatikusan;
6. vizuális audit után minden valutát, ingyenes elemet, időzítőt és bezárást dokumentálunk,
   majd külön programdöntés születik.

## Elfogadási feltételek

- egy nyitó tap, utána kizárólag `VÁR`;
- tiszta PNG a teljes boltról;
- fizetési vagy külső folyamat nem indul;
- a megfigyelés bekerül a konszolidált játékleírásba a következő hosszú futás előtt.

## Eredmény — `234543-play`

A Mailbox biztos X-es bezárása után a 47. esemény pontosan egyszer koppintott `(591,444)`
pontra. A 48. eseménytől minden döntés várt. A `frame-00050.png` képen:

- fejléc: `SHOP`;
- játékosállapot: `VIP 0/20`, gemegyenleg 0;
- bal felső időzítő: `FREE IN: 2h 13m 29s`;
- gemcsomagok és VIP-pontok:
  - 200 gem, +20 VIP, 999 Ft;
  - 500 gem, +50 VIP, 1 990 Ft;
  - 1,2K gem, +100 VIP, 4 490 Ft;
  - 2,5K gem, +200 VIP, 8 990 Ft;
  - 6,5K gem, +500 VIP, 19 990 Ft;
  - 14K gem, +1000 VIP, 44 990 Ft;
- lejjebb `Damage` szekció látszik `+35`, `+152`, `+409` kártyákkal; áraik a mentett
  kép alsó széle alatt vannak, ezért nem értelmezzük őket;
- alsó fülek: `STATS`, kijelölt `CHESTS`, zárolt `SOULS`, zárolt `CRYSTALS`;
- jobb felső rózsaszín X.

Biztos következtetés: a látható gemcsomagok valódi pénzes vásárlások; automatikusan nem
használhatók. Jelenleg nincs ingyen átvehető elem, csak több mint kétórás `FREE IN`
időzítő. A Damage-kártyák tartalma és ára további, de most nem szükséges kutatás.

## Felismerési anomália és javítás

A bolt X-e a kép kb. 90%-os szélességén és 11%-os magasságán van, kívül a régi
`popupClose` keresési tartományon. Emiatt a bolti 5/6 számjegyek átmenetileg 1–2%-os
harci HP-vá váltak, bár az inspeckiós mód nem engedett inputot. A pink-X keresés most
6–68% magasságra és 25–95% szélességre terjed; felismerése minden modalhoz hasonlóan
letiltja a harci HP-jelölteket.

## Programdöntés

A boltkutatás lezárt és automatikus újranyitása tiltott. A következő folyamat a biztos
jobb felső X-szel bezárja a boltot. Valódi pénzes csomaghoz, Damage-kártyához vagy
zárolt fülhöz nem nyúl.

## 2026-08-29-i újraaudit és új hiba

A jobb oldali piros jelzés miatt végzett új, kézi felületaudit ugyanazokat a valódi
pénzes csomagokat mutatta; a `FREE IN` ekkor kb. 14h49m volt. Új elemként látszott a
`Complete Quests and earn Free Gems!` / `OPEN QUESTS` gomb. Ennek egyszeri megnyomása
tartós `Loading...` réteget okozott, amelyet X, Escape és akadálymentességi Cancel sem
zárt be. A játék újraindítása után jogi Continue képernyő jelent meg. Emiatt az
`OPEN QUESTS` automatikus használata tiltott; részletek a 133. fejezetben.
