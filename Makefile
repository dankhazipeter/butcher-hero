# Butcher Hero — Makefile. `make help` listázza a parancsokat; a sima `make`
# (a 326-os szabály szerint) továbbra is csak a setup célt futtatja.
# Paraméterezés: make <cél> VÁLTOZÓ=érték … (lásd a súgó alján)

PORT   ?= 8765        # dashboard/listener port (start)
ITEM   ?= crystal_jar # a save-* parancsok cél-tárgya (kulcsok: make save-items)
COUNT  ?= +1          # save-copies/save-jar/save-field új érték: N vagy +N/-N
SECRET ?=             # hash-kulcs felülírás, csak ha új játékverzió más kulcsot használ
FIELD  ?=             # save-field pontozott útvonala (pl. vip.points)
SECTION ?=            # save-section cél-szekció (lista: make save-sections)
DEPTH  ?=             # save-section kibontási mélység (1..4, alap 2)

BACKUP ?=             # save-diff/save-revert cél-mentés neve (alap: legutóbbi)

.DEFAULT_GOAL := setup
.PHONY: help start stop status install-cli setup test test-vision \
        save-check save-items save-sections save-section save-field \
        save-diff save-copies save-jar save-revert

help: ## Ez a súgó: az elérhető parancsok listája (make help)
	@printf "Butcher Hero parancsok — make <cél> [VÁLTOZÓ=érték …]\n\n"
	@awk 'BEGIN {FS = ":.*## "} /^[a-zA-Z0-9_-]+:.*## / {printf "  \033[1;36m%-14s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@printf "\nVáltozók: PORT=%s  ITEM=%s  COUNT=%s  SECRET=%s\n" "$(PORT)" "$(ITEM)" "$(COUNT)" "$(if $(SECRET),adott,nincs)"
	@printf "\nPéldák:\n  make start PORT=8766\n  make save-items\n  make save-copies ITEM=gem_ring COUNT=+1\n  make save-sections\n  make save-section SECTION=vip\n  make save-field FIELD=vip.points COUNT=+100\n"
	@printf "\nA sima make a setup célt futtatja (326-os szabály), a save-* parancsokhoz\nTeljes lemezhozzáférésű terminál kell, a játék legyen zárva.\n"

# ---------- Gyűjtő + dashboard (a meglévő belépési pontok) ----------

start: ## Gyűjtő + dashboard indítása az előtérben (PORT=8765)
	python3 scripts/butcher-hero.py start --port $(PORT)

stop: ## Gyűjtő + dashboard leállítása
	python3 scripts/butcher-hero.py stop

status: ## Gyűjtő + dashboard állapota
	python3 scripts/butcher-hero.py status

install-cli: ## ~/.local/bin/butcher-hero parancs telepítése
	python3 scripts/butcher-hero.py install

# ---------- Fejlesztés / tesztek ----------

setup: ## Teszthookok telepítése (klónozás után egyszer; a make test magában foglalja)
	./scripts/install-git-hooks.sh

test: setup ## Teljes offline tesztkapu (a commit/push előfeltétele)
	./scripts/check-rewards.sh

test-vision: setup ## Csak a képfelismerési (corpus) tesztek
	swift test --filter RewardCorpusTests

# ---------- Mentés-eszközök (Teljes lemezhozzáférés, játék zárva) ----------

save-check: ## Mentésállapot: hash érvényessége, ITEM adatai, PlayerPrefs
	python3 scripts/butcher-save-edit.py --check --item $(ITEM) $(if $(SECRET),--secret $(SECRET))

save-items: ## A mentés összes tárgya: key, level, copies
	python3 scripts/butcher-save-edit.py --items

save-sections: ## A mentés 32 adatszekciójának listája (név, típus, darab)
	python3 scripts/butcher-save-edit.py --sections

save-section: ## Egy szekció kibontása értékekkel (SECTION=vip [DEPTH=2])
	python3 scripts/butcher-save-edit.py --section $(SECTION) $(if $(DEPTH),--depth $(DEPTH))

save-field: ## Int-mező állítása pontozott útvonalon (FIELD=vip.points COUNT=+100)
	python3 scripts/butcher-save-edit.py --set-field $(FIELD) $(COUNT) $(if $(SECRET),--secret $(SECRET))

save-diff: ## Mostani mentés vs. backup mezőszintű diffje (BACKUP=név, alap: legutóbbi)
	python3 scripts/butcher-save-edit.py --diff $(BACKUP)

save-copies: ## Az ITEM tárgy példányszáma COUNT-ra (N / +N / -N)
	python3 scripts/butcher-save-edit.py --item $(ITEM) --copies $(COUNT) $(if $(SECRET),--secret $(SECRET))

save-jar: ## Crystal Jar lelk-számláló COUNT-ra (N / +N / -N)
	python3 scripts/butcher-save-edit.py --jar $(COUNT) $(if $(SECRET),--secret $(SECRET))

save-revert: ## Visszaállítás mentésből (BACKUP=név, alap: legutóbbi)
	python3 scripts/butcher-save-edit.py --revert $(BACKUP)
