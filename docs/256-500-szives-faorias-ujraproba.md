# 500 szíves faóriás célzott újrapróbája — 2026-09-19

## Bizonyíték és hipotézis

186történeti győzelem:4,31K/500szívfát1,97K sajátHP ésrégebbi build mellett
legyőztük, +500éskb.59perces kör. Ma a kisfahelyek napi kerete kimerült;
ezért a nagy, ismerten legyőzhető cél friss keresése következik, nem új
7,15K/18,8K/27,7K humanoidpróba.

181510-observe/0szélmalomtól északkeletre,5,99K.181537-nudge:két0,38s
keleti swipe a nyílt sávon,181540/0részleges500/4.31Kfaóriás a jobb oldalon.
181612-nudge:újabb két0,38s kelet,181615/0teljes, **4,31K+500pirosszív**,
bar398..456×495..502,136,7px távolság. Saját5,99K. Játékos és cél ugyanazon
zöld nyílt területen, északi palánk mögöttünk; ez nem a havas7,15Kőr.

Hipotézis: a korábbi siker és a mai erősebb build alapján a jelenlegi
kontaktusoldalról rövid harcban legyőzhető. A tényleges sebzést/HP-t/jutalmat
külön ellenőrizzük, nem az ellenség/sajátHP arányából jósolunk.

## Szűk programengedély

KnownHeartGuardianPolicy:4200–4400HP,0,06pirosszív-bizonyosság,
500vagy501nyers jutalomszám (utóbbi ikon-OCR), nincs lilaobjektum-jel.
Csak300px-en belül, teljesen látható csíkkal, friss95%+sajátHP éslegalább
4000ismertmaximum mellett kerülhet az egyébként korlátozott próbaágba.
Korábbi vesztes sáv és életveszély-őr továbbra működik; globalbossflagOFF.
A brownfa testét a lombszűrő0-nak méri: nem terjesztjük ki találomra a
passzivitás-felismerést minden barna humanoidra, az engedély célazonosító.

Build és célazonosítóegységtesztPASS. Elsőreplay a5840-es régi fixture miatt
helyesen nem indult:5,99K nem lehetett friss elfogadottHP egyetlen képből.
A tényleges induló állapotot rögzítő5990fixture-rel célzott replayPASS;
a frissHP-feltételt nem lazítottuk. Kisőr/DOCnegatívregresszió is ellenőrizve.

## Élő eredmény — 18:19–18:23

**Tény:** `20260919-181916-6138f614-play/0` képen a faóriás helyén
57m3s kör, a játékos fölött 6,49K. A 8. képen ismét 6,49K és 56m53s.
`182308-3f1048b2-observe/0` új, aktuális képen 6,49K és ugyanott 53m11s.
A korábbi 5,99K-hoz képest +500 kijelzett HP; a gépi maximum 6490.

**Következtetés:** a cél a legutolsó rövid keleti közelítés után, a két
futás között automatikus támadással elpusztult. A találat és a +500 animáció
nincs megörökítve. Az új próbaág ezért csak replayben igazolt: a következő
élő futás már a győzelem utáni állapotból indult, nem ez hajtotta végre a harcot.
A timerből becsült következő elérhetőség körülbelül 19:16 Budapest; akkor
friss képpel ellenőrizendő, nem garantált ismétlési vagy napi keret.

181916/8 a 923HP-s fa még él; a végső kép naplójában új 3m49s kör,
182308/0 ugyanott 21s. Ez újabb faaratással összhangban van; konkrét
fejszestat-növekedést friss statpanel nélkül nem állítunk.
Felszerelés változatlan Phantom4/Venom18; Bat12 összehasonlítása még nyitott.
