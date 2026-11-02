# Fehér pályaháttér és számolvasás — 346/347

Eredeti, módosítatlan623×863PNG-k. A címkék a kártya és az adott claim
explicit lebegő+utóképének kézi ellenőrzéséből származnak, nem az olvasóból.

- `white-scenery-smash700.png`: Smash Damage700, claim4DB09255-93BB-4984-A549-1CE421F0F1E0.
- `white-scenery-pierce565.png`: Pierce Damage565, claimC4F95838-026F-4091-9C4B-59A93D13955E.
- `white-scenery-smash-defense817.png`: Smash Defense817, claim68D3ABCF-8ED0-43E1-A543-5426D82CBF53.

346-ban a változatlan olvasó nil/nil/1 kimenetet adott. 347-ben felhasználói
jóváhagyás után rögzített700/565/817 regresszió lett belőlük, először6hibával.
Kalibrációs glyph/model továbbra nem változik. A346-os naplópontosítás külön,
nem a felismerő javítása;347 nem írja át újra a történeti naplót.

További eredeti, módosítatlan623×863képek, vizuálisan ellenőrzött címkékkel:

- `white-scenery-regen84-development.png`:2A57930D, Health Regen84. Az első
  általános kontúrszűrés levágta volna a4-et; fejlesztési eset, NEM heldout.
- `white-scenery-health18700-development.png`:FDFF1ABF, Health18.7K.
  A szomszédsorral bővített prototípus hibáját feltárta; NEM heldout.
- `white-scenery-health18700-heldout.png`:40659136, másikHealth18.7Kclaim.
- `white-scenery-pierce-defense624-heldout.png`:B83B5C92, Pierce Defense624.

Az utolsó két képet a végső, csakperemkomponens-kód elkészülte UTÁN
választottuk ki és ellenőriztük, további algoritmushangolás nélkül.
Nem új betűtípusok vagy kalibrációs bemenetek, hanem két külön claim.
A kódbeli scenery-only negatív az817képből származtatott mesterséges eset,
nem új valódi minta. A63képes korpusz mind7eredetit tartalmazza.
