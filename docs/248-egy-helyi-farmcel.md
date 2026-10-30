# Egy helyi farmcél, nem versengő szigetvezérlők — 2026-09-19

## Bizonyított ok

164534-play/4–23: Island2-visszatérő gráf és házkarantén egymás ellen.
A fő képen üres kapu, minimapon több piros pont. A régi érzékelő4000maximumHP
felett minden zöld környezetű piros pontot kiszűrt, ezért csak a külsőNWjel
maradt. A felhasználó helyesen jelezte a kihagyott helyi lehetőségeket.

## Javítás és korlát

Külön szigetfüggetlen helyi farmcsatorna a minimap belső piros pontjaira,
8–65minimappixel távolság. A választott pont képről képre legfeljebb12px
változással követett; nem ugrál a mindig legközelebbi pontok között.
Ez rövid képi célazonosság, nem bizonyított globális térképpozíció.

Egészséges, fenyegetésmentes általános navigációban,400px-en belüli világcél
nélkül egy helyi farmcél az irányadó. Szigetmakró, farmhűtéses cél és házkarantén
nem írhatja felül. A helyi térkép ezen az ágon csak akadályt kerülhet;
nem választhat másik ellenséget vagy Island2-visszautat. Harc, gyógyulás,
bolt és bossbiztonság nem kerül felülírásra. Min-user-idle0 változatlan.

Mérce: a kapuhurok helyett belső piros cél közelítése, majd tényleges aratás.
Az élő eredmény még igazolandó; a minimappont nem bizonyítja a legyőzhetőséget.
