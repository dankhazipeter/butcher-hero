# HP-felismerési hibaminták és hitelesítési szabályok

## Egyszámjegyű ezres csonkolás

A `011302-play/frame-00002` látható `1.22K` célja `7` lett, mert az OCR-régió túl közel
kezdődött a csíkhoz. Aktuális védelem: nagyobb/feljebb tolt régió, továbbá ismeretlen
szintű nem-fa 45+ px csíkján 20 alatti numerikus érték is tiltott. Regresszió:
`011508-replay`.

Ez a tematikus lap a képernyőn mozgó, takaró elemek miatt keletkező HP-OCR-hibákat és
az ellenük bevezetett időbeli szabályokat gyűjti. Célja, hogy egy új szűrő ne javítson ki
egy régi hibát úgy, hogy közben elrejti a valódi sebzést vagy újraéledést.

## Ismert hibaminták

| Képi helyzet | Valós érték | Hibás jelölt | Védelem |
|---|---:|---:|---|
| Tizedes animáció 100 HP alatt | `67.3` | `167` | csak a pont előtti egész rész |
| Tiszta háromjegyű HP | `176` | `17` | nincs automatikus kétszámjegyű részablak |
| Ellenséges szám belóg a HP-régióba | kb. `201` | `21` | nagy esés időbeli megerősítése |
| Teljes zöld csík mellett zajos sor | kb. `177` | `17.9` | pixelcsík-vétó 65% fölött |
| Fa-időzítő ráfed a HP elejére | `232` | `32` | három közeli, egymást követő mérés kell |
| HP és időzítő összeragad | `252`/`330` | `14`, `21`, `83`, `56` | az egész időegységes sor nem numerikus HP |
| Hibás alacsony előzmény a timerhez vonz | `212–216` | `9–15` | zöldcsík-konzisztens előszűrés |
| Csak hosszú időzítő olvasható teljes csíknál | `286` | `57` a `4h 57m`-ből | nincs numerikus HP; ideiglenesen pixelarány |
| A zöld csík széle tizedes HP elé tapad | `85.8–88.8` | `185.8–188.8` | alternatív egészrész + pixelarányos választás |
| Gyors medencés gyógyulás | `69→176` | régi alacsony érték | magas, tiszta háromjegyű jelölt elfogadása |

## Jelenlegi hitelesítési sorrend

1. Az OCR összes, időegységet (`m`, `s`, `h`) nem tartalmazó sorából készülnek jelöltek.
2. A tiszta, legfeljebb 40 HP-s változás azonnal elfogadható; ez fedi a megfigyelt
   10–30 körüli harci sebzéseket és a fokozatos regenerációt.
3. A 60-nál nagyobb lefelé ugráshoz három egymást követő, egymástól legfeljebb 25 HP-ra
   lévő alacsony mérés kell. Üres OCR-képkocka megszakítja a sort.
4. Ha a zöld csík legalább 65%-osnak látszik, a maximum 35%-a alatti számozott jelöltet
   akkor is elutasítjuk.
5. A maximum felső 75%-ába visszatérő tiszta érték gyors gyógyulás/respawn miatt azonnal
   elfogadható; más nagy emelkedéshez két közeli magas mérés kell.
6. Időzítős szövegben (`252 3m 15`, `2523m 14`, `1m 59s 152`, `33m 56s`) nincs
   numerikus HP. A korábbi részablakos szabály történeti és elvetve: 330 HP-ból hamis
   83/56 kritikus állapotot készített.
7. A tanult teljes zöldcsík-szélesség nem lehet nagyobb a képszélesség 12%-ánál; ez
   megakadályozza, hogy egy összeolvadt zöld UI-elem hatástalanítsa a pixelvétót.
8. Legalább 65%-os zöld csíknál a numerikus jelöltek közül előbb kiesik minden olyan,
   amely a csík becslésénél több mint 30 százalékponttal alacsonyabb. Ha egyetlen
   konzisztens szám sem marad, azon a képen nincs számszerű HP: a döntő a pixelarányt
   használja, és megvárja a következő tiszta OCR-t.
9. Több tizedes jelöltnél előbb a pixelcsíkhoz 18 százalékponton belül illeszkedő
   nagyságrend marad. A 60 HP-nál nagyobb esés azonnal elfogadható, ha a szám és a
   pixelarány 12 százalékponton belül egyezik.

## Regressziós bizonyítékok

- `docs/runs/20260828-194843-replay`: a 67.3/176 nagyságrendi hibák javítása.
- `docs/runs/20260828-200704-replay`: valódi, fokozatos sebzés korai menekülést indít.
- `docs/runs/20260828-201911-replay`: hosszú regeneráció és teljes zöld csíkos hamis
  alacsony sorok kezelése.
- `docs/runs/20260828-202645-replay`: a fa-időzítő alatti hamis 32 elutasítása, miközben
  a későbbi 232→222→213→193 sebzéssor továbbra is felismerhető.
- `docs/runs/20260828-203914-replay`: a `2523m14` és `2521` sorozat végig 252 marad;
  egy későbbi valódi sérülésnél a 252→233 változás továbbra is elfogadott.
- `docs/runs/20260828-205548-replay`: a hibás előzményhez vonzó timer-számok helyett
  a problémás mentett képek 211/214/216 HP-t adnak.
- `docs/runs/20260828-210417-replay`: a `4h 57m`-et tartalmazó, teljes zöld csíkos első
  képen nincs hamis 57 HP; a következő képen a tiszta OCR helyesen 286-ot ad.
- `docs/runs/20260828-214733-replay`: a `188.8` nyers OCR 88 HP és 27%-os állapot lesz;
  a teljes 85→88→92→143 gyógyulássor alatt nem indul korai járőr.
- `docs/runs/20260828-223438-replay`: a 330 HP-ra fedő timeres mentett kép 330/100%-os
  marad; a korábbi kerítéshurok tesztelése közben sincs hamis kritikus menekülés.

## Kötelező új ellenőrzés HP-szűrő módosításakor

Minden HP-szabály-változás után legalább egy ismert OCR-hibás és egy valódi sebzéses
futást vissza kell játszani. Élő futás csak akkor indulhat újra, ha a hamis menekülés
megszűnt, de a valódi sebzésreakció megmaradt.
