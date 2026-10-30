# Csonka időzítő takarja aHP-t — 2026-09-19

185320-play/32: a képen3m52s időzítő fedi a6,52K sajátkijelzést.
HP-sorOCR„152s16.52K”,lokális„52s16:52K=”. Nincs közeli ellenség.
Az eddigi megfigyelési kapu mbetűt igényelt; elveszett m miatt a bot nem
kapta meg a korlátozott képtisztító lépést,20–32várt.

HPTimerOcclusionPolicy: a meglévő teljes m+s/h alak mellett az azonos
HP-sorban látható szám+s és tizedesK kombináció is **takarásbizonyíték**.
Ez sem16,52KHP, sem gyógyulás, sem friss numerikus állapot. A parser
nem változik, a szigorú HP-védelem és az egyszeri próbakeret marad.

Egységteszt:52s16:52K/152s16.52Kpozitív;6.52K/16:52K/52s/Statsnegatív.
Regresszió a32képre: próbalépés, nemocr-current. A régi teljes időzítős
sorozatban továbbra legfeljebb egy próba szükséges.

Release build, új egységteszt és a32-es képreplayPASS. Korábbi teljes
HP-takarás replay továbbra pontosan egy próbaPASS. NumerikusHPparser változatlan.

Élő185609-2d41a741-play/0egyszeri0,50s próba,1friss **6,52K**,
gépi maximum6520. A takarás feloldása igazolt, nem maradt várakozáshurok.
5–9a vízszintes kerítés nyugati végét megkerülte,9már a felső oldalon.
11–18azonban a bal oldali kőfalhoz került: az északi ütközés után aV2
mindig balra (nyugat) választ kerülést, bár a cél északkeletre van.
Ez új navigációs korlát, nem aHP-javítás sikertelensége.18végkép6,52K,
chart51,V2pozíció14,84/−3,93; kőfal mellett sátorpózna. Új ölés nincs.

Következő hipotézis: kezdeti kerülőoldal a cél érintőirányú komponense
és már mért akadályélek alapján, nem feltétel nélküli balra fordulás.
A forgásirányt és annak újraindításos megőrzését is együtt kell tesztelni.
A mostani nyugati kerülőhurkot változatlanul ne folytassuk; friss képen
keletre nyílt fű látszik, felügyelt kiinduló korrekció lehet szükséges.
