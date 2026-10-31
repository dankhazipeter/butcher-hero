# FREE graphic templates

Three manually reviewed real screenshots supply the fixed badge masks in
`templates.json`. `source` points to the exact versioned source screenshot.
No generated artwork or OCR labels are used to synthesize these templates.

Each mask is48×24:0other/dark,1green,2white. Runtime compares a bounded
±1pixel neighbourhood. White-letter Dice similarity must reach0.82;
the weighted score (85%white,15%green) must also reach0.82. This score
is not an82%probability or an estimated precision of the classifier.

Calibration is an explicit offline developer step:

`swift run ButcherHeroAutomation badge-signature <visually-reviewed-FREE.png>`

The command prints the mask only; it neither controls the game nor rewrites
the model or test expectations. Copy reviewed output into the model in a
normal change, record the visual evidence and run `make test`. Keep separate
held-out screenshots: `regen81-ree-heldout.png` is deliberately not a template.

If an image is not a confident template match, strict FREE-only Tesseract
remains a fallback. No approximate FRE/REE text is accepted. HUD, structural
badge and card-border checks remain separate safeguards.
