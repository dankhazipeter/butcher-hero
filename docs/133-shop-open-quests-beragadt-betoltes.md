# Shop és Open Quests: beragadt betöltés

## Biztonságos felületaudit

A világképen a jobb felső Shop ikon piros jelzést mutatott, ezért egyszer, felügyelten
megnyitottuk. A Gems lap a következőket mutatta:

- VIP `0/20`, gem `0`;
- hat valódi pénzes gemcsomag 999–44 990 Ft között;
- `FREE IN 14h 49m`, tehát az ingyenes elem még nem volt átvehető;
- `Complete Quests and earn Free Gems!` és egy zöld `OPEN QUESTS` gomb;
- alsó `STATS`, `CHESTS`, valamint zárolt `SOULS` és `CRYSTALS` fülek.

Pénzes csomagot, reklámot vagy ismeretlen fejlesztést nem érintettünk. Az alsó `STATS`
felirat egyszeri koordinátás érintése nem okozott látható változást.

## Anomália

Az `OPEN QUESTS` egyszeri érintése után `Loading...` réteg jelent meg, és tartósan
beragadt. A rózsaszín X, az Escape és az akadálymentességi `Cancel` művelet sem zárta
be. A játékfolyamat újraindítása volt az egyetlen működő helyreállítás.

Az újraindítás után a játék saját Terms & Conditions / Privacy Policy képernyője
jelent meg `Continue` gombbal. Ez jogi feltétel elfogadása, ezért a bot nem nyomja meg
automatikusan; külön felhasználói megerősítés szükséges.

## Programdöntés

Az `OPEN QUESTS` jelenleg tiltott automatikus UI-művelet. A Shop további feltérképezése
csak képernyőnként, visszaút-ellenőrzéssel folytatható. Külső betöltést indító elemnél
előbb kell watchdog és biztos helyreállítás, mint automatikus újrapróbálás.

