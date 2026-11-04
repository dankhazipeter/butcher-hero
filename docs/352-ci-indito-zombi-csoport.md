# CI: piros futások november 4-én, indítóleállítás zombi csoporttal

2026-11-04, `native-app` ág. A felhasználó „run failed” leveleket kapott.
Két külön ok volt; egyik sem a natív app kódjának hibája.

## 1. GitHub-oldali kapacitáshiány (5eae0a7)

Run [41861203577](https://github.com/dankhazipeter/butcher-hero/actions/runs/41861203577):
a job egy lépést sem futtatott. Annotáció: „The job was not acquired by
Runner of type hosted even after multiple attempts”, mellette macOS arm64
kapacitási figyelmeztetés. Ugyanakkor a githubstatus.com részleges leállást
jelzett. Ez nem javítható a repóból; az új push saját futása helyettesíti.
A 06c8926 „cancelled” futása a `cancel-in-progress` szándékos működése.

## 2. Valódi, terhelésfüggő hiba a közös indítóban (e805785)

Run [41809071079](https://github.com/dankhazipeter/butcher-hero/actions/runs/41809071079):
a tesztlépés exit 2-vel bukott, utána a 7652956 változatlan launcherrel
zöld lett. A napló bejelentkezés nélkül nem olvasható, ezért helyben
reprodukáltuk: teljes CPU-terhelés mellett a Python/Node kapu hatszori
ismétlésénél egyszer bukott a
`test_ctrl_c_stops_both_services_and_descendants`, a launcher Ctrl+C után
1-gyel lépett ki 0 helyett.

Bizonyított ok (külön kísérlettel is): macOS-en az `os.killpg` EPERM-et
(`PermissionError`) ad, ha a csoportban már csak le nem aratott (zombi)
folyamat van; ESRCH csak a learatás után jön. A `stop_children` csak a
`ProcessLookupError`-t tűrte, így lassú gépen a SIGTERM/SIGKILL kör
kivétellel szállt el, és a launcher `ERROR`-ral, 1-es kóddal állt le, bár
a szolgáltatások valójában leálltak. Ez a felhasználó gépén is előfordulhatott.

## Javítás

- `signal_group`: saját, azonos felhasználójú szolgáltatáscsoport jelzésénél
  az EPERM is „már nincs mit jelezni”. Más folyamatot nem jelzünk, a
  leállítási sorrend, a 10 s-os türelmi idő és a SIGKILL-takarítás változatlan.
- A folyamatteszt ellenőrzése továbbra is megköveteli, hogy a csoport teljesen
  eltűnjön (ESRCH), de legfeljebb 5 s-ig megvárja a launchd általi learatást.
  Élő tag esetén azonnal bukik, mint korábban.
- Új, valódi folyamattal futó regresszió: kilépett, de még zombi
  csoportvezetőn a takarítás nem dobhat kivételt. Javítás előtt piros volt.

Ellenőrzés: teljes CPU-terhelés mellett a `test_local_app` 25 egymás utáni
köre 0 hibával futott le (előtte 6-ból 1 hiba). A workflow (`make test`, macOS 15)
továbbra érvényes a natív apphoz is: a `swift test` minden targetet lefordít,
a `ButcherHeroApp`-ot is; saját app-unit-tesztje nincs, csak fordítási kapu.
Gyűjtő, játék, napló és statisztika érintetlen.
