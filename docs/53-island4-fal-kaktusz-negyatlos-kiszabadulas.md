# Island 4 fal–kaktusz zseb: négyátlós kiszabadulás

## Kiinduló anomália

A `20260829-024202-play` elején a karakter a narancs sziklafal, egy kaktusz és
tereptárgyak közé szorult. A minimap felfelé/jobbra mutatott, de a hozzá igazított
ismételt irányok nem változtatták meg érdemben a hátteret.

## Elvetett változatok

- A tiszta jobb/bal váltás (`024836-play`) ugyanazon zseb két falának nyomta a
  karaktert.
- A jobbra-fel/balra-fel páros (`025141-play`) röviden elmozdította, majd
  visszavezette a zsebbe. Ezért a két előre tartó átló sem fedte le a látható
  balra-le nyílást.

## Döntés

Narancsszikla-biomban, látható Island 4 HUD-jel és hat eredménytelen navigációs
döntés után a faljáró négy, a blokkolt irányhoz forgatott átlót próbál:

1. balra-hátra;
2. balra-előre;
3. jobbra-előre;
4. jobbra-hátra.

A falmenti komponenshez az előre/hátra összetevő 0,55 súllyal adódik. Boss, friss
sebzés és 180 pixelen belüli biztonságos cél minden lépés előtt megszakítja a vak
szakaszt.

## Ellenőrzés

- `20260829-025450-replay`: az első statikus kiszakadás a várt balra-le
  `(-0,91; +0,41)` vektor.
- `20260829-025524-play`, 133–140. esemény: az élő faljáró jobbra-fel átlója után a
  korábban 323 pixeles cél 270→208→154→129 pixelre közeledett. Ez biztos
  kameramozgás és élő kiszabadulás; a bot ezután a célközelítésre váltott.

## Bizonyosság

- **Biztos:** a négyfázisú ciklus egyik átlója élőben kijuttatott a statikus zsebből.
- **Nyitott:** az első balra-le fázis ugyanebből a konkrét zsebből még csak replayen
  igazolt; a teljes négyes ciklus sikerarányát további elakadásokból mérjük.

