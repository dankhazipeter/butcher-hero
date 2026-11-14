# Butcher Hero — Makefile. `make help` listázza a parancsokat; a sima `make`
# (a 326-os szabály szerint) továbbra is csak a setup célt futtatja.
# Paraméterezés: make <cél> VÁLTOZÓ=érték … (lásd a súgó alján)

PORT   ?= 8765        # dashboard/listener port (start)
ITEM   ?= crystal_jar # a save-* parancsok cél-tárgya (kulcsok: make save-items)
COUNT  ?= +1          # save-copies/save-jar új érték: N (abszolút) vagy +N/-N (relatív)
SECRET ?=             # hash-kulcs felülírás, csak ha új játékverzió más kulcsot használ

.DEFAULT_GOAL := setup
.PHONY: help start stop status install-cli setup test test-vision \
        save-check save-items save-copies save-jar save-revert

help: ## Ez a súgó: az elérhető parancsok listája (make help)
	@printf "Butcher Hero parancsok — make <cél> [VÁLTOZÓ=érték …]\n\n"
	@awk 'BEGIN {FS = ":.*## "} /^[a-zA-Z0-9_-]+:.*## / {printf "  \033[1;36m%-14s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@printf "\nVáltozók: PORT=%s  ITEM=%s  COUNT=%s  SECRET=%s\n" "$(PORT)" "$(ITEM)" "$(COUNT)" "$(if $(SECRET),adott,nincs)"
	@printf "\nPéldák:\n  make start PORT=8766\n  make save-items\n  make save-copies ITEM=gem_ring COUNT=+1\n  make save-jar COUNT=500\n"
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

save-copies: ## Az ITEM tárgy példányszáma COUNT-ra (N / +N / -N)
	python3 scripts/butcher-save-edit.py --item $(ITEM) --copies $(COUNT) $(if $(SECRET),--secret $(SECRET))

save-jar: ## Crystal Jar lelk-számláló COUNT-ra (N / +N / -N)
	python3 scripts/butcher-save-edit.py --jar $(COUNT) $(if $(SECRET),--secret $(SECRET))

save-revert: ## Utolsó mentés-szerkesztési biztonsági mentés visszaállítása
	python3 scripts/butcher-save-edit.py --revert
