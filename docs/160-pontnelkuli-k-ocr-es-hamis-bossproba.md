# Pont nélküli K-OCR és hamis bosspróba

## Megfigyelés

A `143954-play/frame-00148.png` képen vizuálisan egy `11.4K` HP-s, 300-as
szívikonos kaktusz látszik. A Vision első olvasata `114K` volt, ezért a nyers
elemzés 114 000 HP-t tárolt. A kontrollált próba régi kanonizálója minden 8000
fölötti, százzal osztható értéket ismételten százzal osztott, így ebből hamis
1140 HP-s próbacél lett.

A 149–152. képeken az OCR már `11:4K`, `11.4K`, majd `11K` alakot adott, a cél
helyes HP-ja 11 400 lett. A közelben két külön 765 HP-s, 10-es szintű kaktusz is
látszott; ezek nem az 11.4K-s cél sebzett állapotai.

A `frame-00181.png` alsó képszélén egy külön cél csak `272K` alakban látszott.
A régi normalizálás ezt is 2720 HP-ra szűkítette és kontrollált próbát indított,
noha a hiányzó pont helye egyetlen képből nem volt meghatározható.

## Kockázat

Az `114K` jelentheti egy 1.14K, 11.4K vagy 114K felirat pontvesztett alakját. A
puszta százzal oszthatóság egyik értelmezést sem bizonyítja. A 4.31K-s cél korábbi
élő próbája megmutatta, hogy már ez a sáv is súlyos sebzést okoz; egy valódi 11.4K
vagy nagyobb cél téves 1140/2720 sávba engedése indokolatlan kockázat.

## Javítás

- A kontrollált bosspróba kanonizálója többé nem osztja automatikusan a 8000 fölötti,
  pont nélküli K-alakokat.
- Az ilyen cél nem indíthat kontrollált próbát addig, amíg explicit pont/kettőspont
  vagy egy későbbi biztosabb OCR-kép egyértelmű értéket nem ad. A későbbi
  `153119-play` és `154552-play` bizonyítékai alapján explicit tizedes + K felirat
  20K-ig külön kontrollált nagypróbát kaphat; pont nélküli alak továbbra sem.
- Egyetlen kivétel a már képekkel és két győzelemmel bizonyított 1.22K-s Savage
  Fang-páncélos: széles csík + legalább 0,15 fejszeikon + saját bossEvidence +
  `122/1122` számjegyaláírás mellett a `15…29`, `1100…1250` és `122K` csonkolás
  kanonikusan 1220 lehet.
- A bossveszély felismerése ettől nem gyengül: normál módban, pont nélküli alaknál
  és 20K fölött a bot továbbra is azonnal eltávolodik.

## Regresszió

- `144649-replay`, `frame-00148`: nincs 1140-es próba; a döntés a 11.4K-s
  veszélytől eltávolodik.
- `144650-replay`, `frame-00181`: nincs 2720-as próba; a pont nélküli `272K`
  alakot nagy veszélyként kezeli és eltávolodik.
- A teljes 433 képes `145011-replay` is lefutott; sem az 1140-es, sem a 2720-as
  hamis próba nem tért vissza, miközben a védett Dusty-felderítés állapota végig
  konzisztens maradt.

## Bizonyosság

- **Biztos:** a 1140-es próba OCR-normalizálási hiba volt; ugyanazon ellenfél
  következő képein 11.4K látszott.
- **Biztos:** a két közeli 765-ös cél külön csíkkal és képi pozícióval rendelkezett.
- **Nyitott:** a `272K` pontos valós értéke; biztosabb, nem képszéli minta nélkül
  nem szabad 2720-nak tekinteni.
