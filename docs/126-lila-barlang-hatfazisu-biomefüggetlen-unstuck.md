# Lila barlang: hatfázisú, biomfüggetlen Unstuck

## Biztos élő megfigyelés

A `100443-play/frame-00163.png` új, részletes Island 4-zsebet mutat:

- lila barlangtalaj és magas lila sziklafalak;
- balról fém sín/korlát;
- jobbról nagy szikla és csontív;
- a karakter a szikla tövében áll, teljes 778 HP-n;
- nincs látható farmcél vagy boss;
- az `UNLOCKS AT / ISLAND 4` HUD egyértelműen látszik.

A 96–211. élő esemény között a bot minden átlót, oldalirányt és minimap-kerülőt
többször kipróbált. A háttér változatlan maradt, a sikertelen statikus fázisszám
`0→11` lett. Az Unstuck mégsem indult.

## Ok

A hatfázisú Unstuck-ág az Island 4 HUD-on, célhiányon, teljes HP-n és a fázisszámon
felül még az alábbiak egyikét kérte:

- narancsszikla biomjel; vagy
- erősen balra (`x < -0,75`) mutató minimapvektor.

A lila barlang egyik feltételt sem teljesítette. A biom- és iránykapu itt nem adott
extra biztonságot: hat teljes, statikus iránypróba már önmagában bizonyította a
fizikai elakadást.

## Javítás

Hat sikertelen statikus fázis után az Unstuck feltételei:

- használati belső cooldown nincs;
- az Island 4 HUD látható;
- nincs biztonságos cél;
- a játékos legalább 90% HP-n van;
- nincs kiemelt szívfa.

A narancsszikla/minimap-irányszűrő megszűnt. Boss, friss sebzés, visszavonulás és
kiemelt cél továbbra is korábbi prioritás, az Unstuck saját UI-visszacsatolása és
900 döntéses időzárvédelme változatlan.

## Regresszió és élő állapot

A `100935-replay` hatvan példányban játszotta vissza ugyanazt a lila barlangképet.
A fázisok `0→6` sorrendben lefutottak, majd:

- 25. döntés: Settings megnyitása;
- 26. döntés: Unstuck megnyomása;
- 27-től: inputmentes helyreállítási várakozás.

## Élő igazolás

A `101003-play` teljes sikert adott:

- 167. esemény: hatodik sikertelen statikus fázis;
- 169: Settings megnyitása;
- 170: Unstuck megnyomása;
- 171–175: a HUD 15%-ra esett, tehát valódi teleportátmenet történt;
- 193: friss 756 HP, majd 195: friss 778 HP;
- 200: a 30 ciklusos helyreállítás lezárult;
- 201-től a védett 120 döntéses helyi szabad felderítés fut.

A lila barlangi biomfüggetlen Unstuck ezzel replayben és élőben is igazolt.

A későbbi őrtorony–sátorzseb ugyanezt a kaput új terepgeometrián is igazolta, és
`352→778` medencés gyógyulást mutatott; lásd a [128. fejezetet](128-ortorony-satorzseb-unstuck-es-352-778-gyogyulas.md).
