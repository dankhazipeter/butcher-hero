# 868-ból hamis 898 OCR és a közvetlen +15 jutalom

## Biztos játékeredmény

A `20260829-153504-play` 88–97. képein a bot egy 765 HP-s, `15` szívikonos
kaktuszt támadott. A 97. képen közvetlen zöld `+15` effektus látszik, a játékos
száma pedig `868`. Ez biztosan új maximális-HP jutalom; a korábban utoljára teljesen
dokumentált 852 után közben egy további, legfeljebb egy pontos változás vagy mérési
eltérés is történhetett, ezért a végállapotot a többször látható 868-cal rögzítjük.

## Az anomália

A `20260829-153810-play` ugyanabban a szikla–kerítés zsebben indult. A mentett
képeken (`frame-00000`, `00009`, `00020`) a játékos száma vizuálisan 868. A Vision
azonban a stilizált középső `6`-ost sok képen `9`-nek olvasta:

- 9. kép: helyes 868;
- 20/22. kép: hamis 898;
- 23. kép: ismét helyes 868;
- később a két alak hosszú soron váltakozott, miközben jutalom nem történt.

A maximumőr minden +4/+5/+10/+20-on kívüli emelkedéshez két aktuális OCR-képet
kért, de a két hamis 898 közé eső pixeles tartalékkép nem nullázta a jelöltet.
Így a pontos +30 különbség tévesen bekerült a `bot-state.json` fájlba. A 931-es
egyedi olvasat további OCR-zaj volt, de a +30-as plafon miatt már nem rögzült.

## Javítás

- A pontos +30 maximumjelölt csak akkor vizsgálható, ha a jutalom-OCR közvetlenül
  30-at látott, vagy a legutóbbi cél biztos statikonja 30-as jutalmat jelzett.
- Ilyen jutalombizonyíték mellett is öt aktuális, egyező OCR-kép szükséges.
- Jutalom nélküli 868→898 alakot a bot nem tanulhat meg, akármilyen gyakran ismétli
  a Vision.
- A hibás tartós állapotot 898-ról 868-ra javítottuk.

Aktuális hiteles tartós maximum: **868**.

## Élő regresszió

A javított `20260829-154552-play` első 83 döntésében több hosszú 898-as OCR-sor
ismétlődött, köztük öt egymást követő aktuális olvasat is. A
`docs/bot-state.json` ennek ellenére 868 maradt. A jutalomkapu tehát élőben is
megakadályozta a hibás +30 tartósítását.
