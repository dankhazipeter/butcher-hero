# Kézi húzásvédelem és Free-újrapróba — 2026-10-30

Frissebb élő ellenőrzés: [287 — húzásvédelem éles igazolása](287-huzasvedelem-elo-igazolasa.md).
Az alábbi végponti ablakhiány azóta megszűnt; két húzás utáni átvétel igazolt.

## Kérés és döntés

A felhasználó a285-ös diagnózis után javítást kért: kézi mozgás alatt ne
kattintsunk; elengedés után frissFreekártyából próbálkozzunk. Az elküldött
kattintás nem siker: a megmaradó kártyára1másodperc múlva újrapróba kell.
Ez felülírja a282/284állandó foglalásos éles kattintásvédelmét.

## Implementáció

- `HumanInput`: öt egérgomb lenyomottsága a munkamenet eseményállapotából,
  továbbá legalább250ms szünet az utolsó gomb-/húzásesemény óta. A kurzor
  puszta mozgatása nem tiltás. Trackpad elsődleges kattintása is egéresemény.
- Ellenőrzés az automatikus átvétel előtt, alkalmazásaktiválás előtt,
  aktiválási várakozás után és közvetlenül az egérlenyomás előtt. Ha közben
  húzás indul, nincs kattintás; lenyomott gomb alatt a takarítás sem helyezi
  vissza a kurzort vagy vált alkalmazást. A fizikai és szintetikus események
  közötti nagyon rövid versenyablakot a lekérdezés nem zárja ki teljesen.
- Elengedés után új játékablakkép és pontosFree/jutalomazonosság kell.
  Nem kattintunk eltűnt, megváltozott, fizetős vagy menübeli ajánlatra.
- `RewardClaimVerification`: monotón idő alapján legkorábban1s után a
  változatlan, ismét felismertFreekártya újrapróbálható. Lenyomott gombnál
  várakozás; nem marad vissza végleges foglalás. A tényleges ütem a képkészítés
  és felismerés ideje miatt valamivel több is lehet1másodpercnél.
- Siker csak két egymást követő, látható játékHUD-os képen eltűnt kártya
  után. AFreefelirat OCR-olvasatán kívül a zöld jelzés külön pixelvizsgálata
  is jelenlétnek számít: puszta olvasási hiba nem elég a könyveléshez.
  TakartHUD vagy olvashatatlan, de jelen levő kártya nem siker és nem kattintás.
- Változó ajánlat, előző eltűnésének észlelése nélkül: a régi claim nem
  igazolt, az új külön azonosítást kap. Nem találunk ki korábbi jutalmat.
- Újrainduláskor a régi blockedFingerprint nem tiltja le az élőFreekártyát;
  új stabil felismerés kell. A régi `RewardGate` csakdry-runban marad használva.

## Napló és statisztika

`input_deferred`: kézi gomb/húzás miatt várakozik.
`click_not_confirmed`:1s után ugyanaz a kártya megmaradt, újrapróbálható.
Minden tényleges input külön `click_sent` esemény, saját előképpel.
Az újrapróbák ugyanazt alogikai claimID-t használják, a statisztika csak
az egyszeri `claim_confirmed_ui` alapján számol jutalmat.

Az időintervallumot a claim UTOLSÓ elküldött próbájának ideje határozza meg.
A korábbi sikertelen próba időszakába nem számítjuk át a későbbi sikert.
Új `click_attempts` mező mutatja az összes inputpróbát; a jutalomösszegek
ettől függetlenül egyszeriek. A történeti naplósorokat nem módosítottuk.

Állapot: `data/free-rewards/state.json`, benne waitingForMouseRelease,
pendingClaimID és verificationMode. A normál figyelés1s, nincs karaktermozgás,
harc, bolt vagy heartbeat. Az egér-/fókuszhasználat továbbra előtérbeli;
ez nem valódi háttérinput, és kézi átvételt nem tudunk abszolút bizonyossággal
elkülöníteni egy korábbi botkattintást követő képi eltűnéstől.

## Ellenőrzés

A régi66033folyamat szabályosan leállítva fordítás előtt.
ReleasebuildPASS;11tesztPASS, kb.1,4s tesztidő:

- 8ikon,591védelem,680sebzés,18K/időzítő, negatív menük és számparser.
- Lenyomott gomb tiltás,250ms elengedési türelem.
- Megmaradt kártya1s-os újrapróba, több egymás utáni sikertelen próba.
- Két hiánykép kell; takartHUD és olvashatatlan jelzés nullázza a hiánysort.
- Valódi578-as előtte/nemigazolt képek: kártya jelen; igazolt18K-utókép:
  kártya nincs. Tartós másolatok `references/2026-10-30/free-578-moving-*.png`
  és `free-18k-confirmed-after.png`.
- Valódi parancssori statisztikateszt elkülönített ideiglenes naplón:
  4inputpróba,1igazolt claim,1függő claim,összeg578, nem1156;
  korábbi sikertelen időablakban0jutalom, végső próbáéban578.

Javított figyelő elindítva:PID83220,execsession97973. A friss státusz mindig
az állapotfájl; a kézi gombnyomás miatti éles várakozás és az újrapróba
csak valódi megfelelő helyzet/napló alapján nevezhető élőben igazoltnak.

Végponti állapot:10:24:32.217Zutolsó sikeres ablakellenőrzés;
10:24:33.239Z„Játékablak nem található; várakozás.” A83220folyamat él,
de az új verzióból még nincs igazolt élő átvétel. Nem indítottuk újra a
játékot és nem kattintottunk más alkalmazásba; az elérhetővé váló ablakot
a figyelő automatikusan újra ellenőrzi. A hiányzó ablak okát nem bizonyítottuk.
