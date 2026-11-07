# Állapottábla: végtelenül ismétlődő feliratváltás

2026-11-07. Felhasználói jelzés: a bal oldali JÁTÉK táblán „A játék fut” és „A játék
nem fut” váltakozik és villog, pedig a játék egyértelműen nem fut.

## Tények

- Az app tényleges állapota nem váltakozott. Az akadálymentesítési felületen 15 s-on
  át, 0,3 s-onként olvasva a tábla végig „JÁTÉK, A játék nem fut | GYŰJTŐ,
  Leállítva” volt. Nem futott `com.multicastgames.butcher` folyamat, a
  GameMonitor és az AppModel csak változáskor frissít.
- Az ablakról készült hat egymást követő képen a két felirat egymásba úszik:
  a régi „A játék fut” a jó állapot fekete tintájával, az új a piros színnel.
  Az ütem kb. 1,6 s, pontosan a „dolgozik” pötty animációjának hossza.

## Ok (erős gyanú, nem bizonyított)

Az egyetlen végtelenített animáció az appban a pötty gyűrűje volt:
`withAnimation(.easeOut(duration:1.6).repeatForever)` az `onAppear`-ben. Az
ilyen animáció ismert módon átszivároghat a közös tranzakcióba, és akkor a
felirat `.contentTransition(.opacity)` átúsztatása is örökké ismétlődik. Egy
külön tesztablakban (a valódi tábla kódja oldalsáv-listában, leállás és
indulás–leállás sorrend) nem sikerült előidézni, ezért a pontos kiváltó
feltétel nem ismert. Valószínű, hogy a 357-ben jelzett „Dolgozik” ↔ „Fut”
villogás egy része is ez volt, nem csak a kristálynyitás képkockánkénti
állapotváltása. A 357-es javítás ettől függetlenül helyes.

## Javítás

A pötty gyűrűje most `TimelineView`-ból, az órából számolódik (1,6 s ciklus,
easeOut jelleg, 30 fps). Nincs SwiftUI-animáció és tranzakció, ami más nézetbe
szivároghatna. Reduce Motion mellett továbbra is álló pötty. A tábla felirata,
színei és a rövid `.smooth` átúsztatás változatlan.

## Ellenőrzés

Fordítás és teljes tesztkapu. A telepítés után a tábla friss állapotból indul.
Élőben a következő játékindítás és -leállítás mutatja meg, hogy a villogás eltűnt.
