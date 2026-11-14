#!/usr/bin/env python3
"""Butcher Hero mentésszerkesztő — Crystal Jar számláló és példányszám (364–366).

A 362-ben visszafejtett hash-receptre épül:
    hash = BitConverter.ToString(MD5(data + msgpack_str(SECRET)
                                     + optimális_int_kódolás(salt)))
A receptet és a SECRET kulcsot a scripts/butcher-save-hash.py modulból
használja. A 363 szerint a PlayerPrefs cloud_save_local_hash /
cloud_save_local_untrusted kulcsokat is összehangolja, hogy a módosított
mentést a trust-réteg elfogadja és a felhői szinkron vigye.

Módok (csak olvasás, ha nincs mód megadva; írás csak a felsorolt módokkal):
    butcher-save-edit.py --check             # állapot: hash, a --item tárgy adatai, plist
    butcher-save-edit.py --items             # a mentés összes tárgya (key, level, copies)
    butcher-save-edit.py --jar N             # Jar-számláló N-re ('+N'/'-N' relatív)
    butcher-save-edit.py --copies N          # a --item tárgy példányszáma N-re
    butcher-save-edit.py --item gem_ring --copies +1   # pl. gem_ring +1 példány
    butcher-save-edit.py --revert            # utolsó biztonsági mentés vissza
    butcher-save-edit.py … --secret KULCS    # más hash-kulccsal (új verzió)

Az alapértelmezett tárgy a crystal_jar; a --item bármelyik tárgykulcsra
átvált (a kulcsok listája: --items).

A --jar/--copies minden MessagePack-kódolási átmenetet kezel (fixnum, uint8,
uint16, uint32, int8/16/32): azonos hossz esetén helyben cserél, változó
hossznál újraépíti a fájlt. Minden írás előtt ellenőrzi, hogy a játék nem fut
és a jelenlegi mentés hash-e érvényes, majd SHA-256 manifestes biztonsági
mentést készít. A konténer eléréséhez Teljes lemezhozzáférés kell.
"""
import datetime
import hashlib
import importlib.util
import json
import os
import plistlib
import shutil
import struct
import subprocess
import sys

# A hash-recept (SECRET-tel együtt) a testvér-modulból:
_HERE = os.path.dirname(os.path.abspath(__file__))


def _load_recipe_module():
    path = os.path.join(_HERE, "butcher-save-hash.py")
    spec = importlib.util.spec_from_file_location("butcher_save_hash", path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


_bsh = _load_recipe_module()
compute_hash = _bsh.compute_hash
msgpack_write_int = _bsh.msgpack_write_int

CONTAINER = os.path.expanduser(
    "~/Library/Containers/com.multicastgames.butcher/Data")
DOCS = os.path.join(CONTAINER, "Documents")
PLIST = os.path.join(CONTAINER, "Library/Preferences/com.multicastgames.butcher.plist")
BACKUP_ROOT = os.path.expanduser(
    "~/Library/Application Support/Butcher Hero/save-backups")
HASH_KEY = "cloud_save_local_hash"
UNTRUSTED_KEY = "cloud_save_local_untrusted"
GAME_PROCESS = "ButcherherohooknchewRPG"
JAR_ITEM = "crystal_jar"
JAR_COUNTER = "accessory_crystal_jar_ability_1"


# ------------------------- MessagePack (pozíciókövető) -------------------------

class MP:
    """Minimális MessagePack olvasó: (érték, kezdőpozíció, végpozíció)."""

    def __init__(self, buf):
        self.buf = buf

    def read(self, pos):
        buf = self.buf
        start = pos
        code = buf[pos]
        if code <= 0x7F:
            return code, start, pos + 1
        if code >= 0xE0:
            return code - 0x100, start, pos + 1
        if 0xA0 <= code <= 0xBF:
            n = code & 0x1F
            return buf[pos + 1:pos + 1 + n].decode("utf-8", "replace"), start, pos + 1 + n
        if 0x80 <= code <= 0x8F:
            return self.map(pos, code & 0x0F)
        if 0x90 <= code <= 0x9F:
            return self.array(pos, code & 0x0F)
        if code == 0xC0:
            return None, start, pos + 1
        if code == 0xC2:
            return False, start, pos + 1
        if code == 0xC3:
            return True, start, pos + 1
        fmt = {0xC4: (1, "bin"), 0xC5: (2, "bin"), 0xC6: (4, "bin"),
               0xC7: (1, "ext"), 0xC8: (2, "ext"), 0xC9: (4, "ext"),
               0xD9: (1, "str"), 0xDA: (2, "str"), 0xDB: (4, "str")}
        if code in fmt:
            width, kind = fmt[code]
            n = int.from_bytes(buf[pos + 1:pos + 1 + width], "big")
            head = 1 + width + (1 if kind == "ext" else 0)
            raw = buf[pos + head:pos + head + n]
            if kind == "bin":
                return bytes(raw), start, pos + head + n
            if kind == "ext":
                return ("ext", buf[pos + 1 + width], bytes(raw)), start, pos + head + n
            return raw.decode("utf-8", "replace"), start, pos + head + n
        ints = {0xCC: (1, False), 0xCD: (2, False), 0xCE: (4, False), 0xCF: (8, False),
                0xD0: (1, True), 0xD1: (2, True), 0xD2: (4, True), 0xD3: (8, True)}
        if code in ints:
            n, signed = ints[code]
            v = int.from_bytes(buf[pos + 1:pos + 1 + n], "big", signed=signed)
            return v, start, pos + 1 + n
        if code in (0xCA, 0xCB):
            n = 4 if code == 0xCA else 8
            v = struct.unpack_from(">f" if n == 4 else ">d", buf, pos + 1)[0]
            return v, start, pos + 1 + n
        if code == 0xDC:
            return self.array(pos, struct.unpack_from(">H", buf, pos + 1)[0], 3)
        if code == 0xDD:
            return self.array(pos, struct.unpack_from(">I", buf, pos + 1)[0], 5)
        if code == 0xDE:
            return self.map(pos, struct.unpack_from(">H", buf, pos + 1)[0], 3)
        if code == 0xDF:
            return self.map(pos, struct.unpack_from(">I", buf, pos + 1)[0], 5)
        if 0xD4 <= code <= 0xD8:
            n = {0xD4: 1, 0xD5: 2, 0xD6: 4, 0xD7: 8, 0xD8: 16}[code]
            return ("ext", buf[pos + 1], bytes(buf[pos + 2:pos + 2 + n])), start, pos + 2 + n
        raise ValueError(f"ismeretlen msgpack kód 0x{code:02X} @0x{pos:X}")

    def array(self, pos, n, head=None):
        start = pos
        if head is None:
            b = self.buf[pos]
            head = 1 if (b <= 0x9F or b in (0xDC, 0xDD)) else 0
        p = pos + head
        items = []
        for _ in range(n):
            v, s, e = self.read(p)
            items.append((v, s, e))
            p = e
        return items, start, p

    def map(self, pos, n, head=None):
        start = pos
        if head is None:
            b = self.buf[pos]
            head = 1 if (b <= 0x8F or b in (0xDE, 0xDF)) else 0
        p = pos + head
        fields = []
        for _ in range(n):
            k, ks, ke = self.read(p)
            p = ke
            v, vs, ve = self.read(p)
            p = ve
            fields.append((k, v, ks, ke, vs, ve))
        return fields, start, p


def str_content_offset(buf, value_start):
    """Egy msgpack sztring tartalmának kezdőpozíciója (fejléc átugrása)."""
    code = buf[value_start]
    if 0xA0 <= code <= 0xBF:
        return value_start + 1
    if code == 0xD9:
        return value_start + 2
    if code == 0xDA:
        return value_start + 3
    if code == 0xDB:
        return value_start + 5
    raise ValueError(f"nem sztring mező (0x{code:02X})")


# ------------------------------ Mentés-elemzés ------------------------------

class Save:
    def __init__(self, buf):
        self.buf = buf
        root, _, _ = MP(buf).read(0)
        if not isinstance(root, list):
            raise ValueError("A gyökér nem map — nem game_data.bin")
        self.fields = {k: (v, vs, ve) for k, v, ks, ke, vs, ve in root}
        for need in ("salt", "data", "hash"):
            if need not in self.fields:
                raise ValueError(f"hiányzó gyökérmező: {need}")
        self.salt = self.fields["salt"][0]
        self.data_off = self.fields["data"][1]
        self.data_end = self.fields["data"][2]
        hv = self.fields["hash"]
        self.hash_off = str_content_offset(buf, hv[1])
        self.hash_end = hv[2]

    @property
    def stored_hash(self):
        return self.buf[self.hash_off:self.hash_end].decode()

    @property
    def data(self):
        return self.buf[self.data_off:self.data_end]

    def computed_hash(self):
        return compute_hash(self.data, self.salt)

    def is_valid(self):
        return self.stored_hash == self.computed_hash()

    def items(self):
        """A player.items tömb (pozíciókkal)."""
        data_fields, _, _ = MP(self.buf).read(self.data_off)
        player = next(v for k, v, *_ in data_fields if k == "player")
        return next(v for k, v, *_ in player if k == "items")

    def item_fields(self, item_key):
        """A megadott kulcsú tétel mező-listája (pozíciókkal)."""
        for item, _, _ in self.items():
            if isinstance(item, list):
                d = {k: v for k, v, *_ in item}
                if d.get("key") == item_key:
                    return item
        raise ValueError(f"nincs {item_key!r} tárgy a mentésben (lásd --items)")

    def find_item_int(self, item_key, field):
        """A megadott tétel egy int mezője: (érték, kezdő, vég, kód)."""
        for k, v, ks, ke, vs, ve in self.item_fields(item_key):
            if k == field and isinstance(v, int) and not isinstance(v, bool):
                return v, vs, ve, self.buf[vs]
        raise ValueError(f"a(z) {item_key} tételben nincs {field} int mező")

    def find_jar_counter(self):
        """A crystal_jar Jar-számlálója: (érték, kezdő, vég, kód)."""
        for k, v, ks, ke, vs, ve in self.item_fields(JAR_ITEM):
            if k == "ability_counters":
                for k2, v2, ks2, ke2, vs2, ve2 in v:
                    if k2 == JAR_COUNTER:
                        return v2, vs2, ve2, self.buf[vs2]
        raise ValueError(f"nincs {JAR_COUNTER} számláló")

    def describe(self, item_key=JAR_ITEM):
        try:
            jar = self.find_jar_counter()[0]
        except ValueError:
            jar = None
        try:
            copies = self.find_item_int(item_key, "copies")[0]
        except ValueError:
            copies = None
        try:
            level = self.find_item_int(item_key, "level")[0]
        except ValueError:
            level = None
        try:
            acc_level = self.find_item_int(item_key, "accessory_level")[0]
        except ValueError:
            acc_level = None
        xp = None
        for k, v, *_ in self.item_fields(item_key):
            if k == "accessory_experience":
                xp = v
        return dict(jar=jar, item=item_key, copies=copies, level=level,
                    accessory_level=acc_level, accessory_xp=xp)

    def list_items(self):
        """(key, level, copies) az összes tárgyhoz, hiányzó mező None. """
        out = []
        for item, _, _ in self.items():
            if not isinstance(item, list):
                continue
            d = {}
            for k, v, *_ in item:
                d[k] = v
            key = d.get("key")
            if not isinstance(key, str):
                continue
            level = d.get("level")
            copies = d.get("copies")
            out.append((key, level if isinstance(level, int) else None,
                        copies if isinstance(copies, int) else None))
        return out


# ------------------------------ Byte-sebészet ------------------------------

def patch_int(buf, vs, ve, new_value):
    """Int mező cseréje optimális kódolással; azonos hossznál helyben,
    változó hosszál újraépítéssel. Visszaadja az új puffert."""
    if not (-2147483648 <= new_value <= 4294967295):
        raise ValueError("az új érték kívül esik a támogatott tartományon")
    enc = msgpack_write_int(new_value)
    if len(enc) == ve - vs:
        out = bytearray(buf)
        out[vs:ve] = enc
        return bytes(out)
    return bytes(buf[:vs]) + enc + bytes(buf[ve:])


def resolve_value(current, spec):
    """'+N' = növelés, '-N' = csökkentés, 'N' = abszolút érték.

    A Jar-számláló és a copies sosem negatív; a részhalmazra igazolunk.
    """
    text = str(spec)
    if text[:1] in "+-" and text[1:].isdigit():
        new_value = current + int(text)
    elif text.isdigit():
        new_value = int(text)
    else:
        raise ValueError(f"érvénytelen érték: {spec!r} (elfogadott: N, +N, -N)")
    if new_value < 0:
        raise ValueError(f"az eredmény negatív lenne ({current} + {text})")
    return new_value


def finish_save(buf):
    """A patchelt puffer hash-mezőjének újraszámolása; visszaadja a kész fájlt."""
    save = Save(buf)
    new_hash = save.computed_hash()
    out = bytearray(buf)
    if len(new_hash) != save.hash_end - save.hash_off:
        raise ValueError("hash-mező hossz eltér — nem cserélhető helyben")
    out[save.hash_off:save.hash_off + len(new_hash)] = new_hash.encode()
    return bytes(out), new_hash


# ------------------------------- Konténer-műveletek -------------------------------

def die(msg):
    print(f"HIBA: {msg}")
    raise SystemExit(1)


def game_running():
    return subprocess.run(["pgrep", "-x", GAME_PROCESS],
                          capture_output=True).returncode == 0


def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def preflight():
    if not os.path.isdir(DOCS):
        die(f"konténer nem elérhető: {DOCS} (Teljes lemezhozzáférés kell)")
    if not os.path.exists(os.path.join(DOCS, "game_data.bin")):
        die("game_data.bin nem található")
    if game_running():
        die("a játék FUT — zárd be előbb, és várd meg a teljes kilépést")


def make_backup():
    stamp = datetime.datetime.now().strftime("%Y%m%d-%H%M%S") + "-save-edit"
    target = os.path.join(BACKUP_ROOT, stamp)
    os.makedirs(target, exist_ok=True)
    manifest = {}
    for name in ("game_data.bin", "game_data_backup.bin", "game_data_pre_cloud.bin"):
        src = os.path.join(DOCS, name)
        if os.path.exists(src):
            shutil.copy2(src, os.path.join(target, name))
            manifest[name] = sha256(os.path.join(target, name))
    if os.path.exists(PLIST):
        shutil.copy2(PLIST, os.path.join(target, "com.multicastgames.butcher.plist"))
        manifest["com.multicastgames.butcher.plist"] = sha256(
            os.path.join(target, "com.multicastgames.butcher.plist"))
    with open(os.path.join(target, "manifest.json"), "w") as f:
        json.dump(manifest, f, indent=1)
    print(f"Biztonsági mentés: {target}")
    for k, v in manifest.items():
        print(f"  {k}: sha256={v[:16]}…")
    return target


def write_save_and_align(buf, new_hash):
    path = os.path.join(DOCS, "game_data.bin")
    tmp = path + ".tmp"
    with open(tmp, "wb") as f:
        f.write(buf)
        f.flush()
        os.fsync(f.fileno())
    os.replace(tmp, path)
    print(f"game_data.bin írva ({len(buf)} bájt).")
    plist = plistlib.load(open(PLIST, "rb"))
    old_h = plist.get(HASH_KEY)
    plist[HASH_KEY] = new_hash
    plist[UNTRUSTED_KEY] = 0
    tmp = PLIST + ".tmp"
    with open(tmp, "wb") as f:
        plistlib.dump(plist, f, fmt=plistlib.FMT_BINARY)
        f.flush()
        os.fsync(f.fileno())
    os.replace(tmp, PLIST)
    print(f"PlayerPrefs: {HASH_KEY}: {old_h!r} -> {new_hash}")
    print(f"             {UNTRUSTED_KEY}: -> 0")


def cmd_edit(field_name, value_spec, finder, item_key):
    preflight()
    make_backup()
    path = os.path.join(DOCS, "game_data.bin")
    buf = open(path, "rb").read()
    save = Save(buf)

    print(f"\nEredeti állapot: salt={save.salt}")
    print(f"  tárolt hash={save.stored_hash}")
    print(f"  számolt hash={save.computed_hash()}")
    if not save.is_valid():
        die("az eredeti fájl hash-e NEM érvényes — ha a játék betöltötte, az új "
            "verzió más hash-kulcsot használhat; próbáld --secret-tel")
    print("  -> érvényes ✓")

    try:
        value, vs, ve, code = finder(save)
    except ValueError as err:
        die(str(err))
    label = f"{field_name} [{item_key}]"
    print(f"\n{label}: érték={value}, offset=0x{vs:X}, kód=0x{code:02X} ({ve-vs} bájt)")
    try:
        new_value = resolve_value(value, value_spec)
    except ValueError as err:
        die(str(err))
    patched = patch_int(buf, vs, ve, new_value)
    mode = "helyben" if len(patched) == len(buf) else f"újraépítés ({len(buf)}->{len(patched)} bájt)"
    print(f"  új érték: {new_value} — {mode}")
    out, new_hash = finish_save(patched)
    final = Save(out)
    if not final.is_valid():
        die("belső hiba: a patchelt fájl nem érvényes")
    got = finder(final)[0]
    if got != new_value:
        die(f"belső hiba: az érték {got} a patch után, {new_value} helyett")
    print(f"  új hash={new_hash} — patchelt fájl érvényes ✓")
    write_save_and_align(out, new_hash)
    print(f"""
KÉSZ. Indítsd el a játékot, ellenőrizd, hogy {new_value}-e az érték ({value} volt),
hagyj időt a mentésnek és szinkronnak, majd zárd be és futtasd --check-et.
Visszaállítás: --revert""")


def cmd_check(item_key):
    path = os.path.join(DOCS, "game_data.bin")
    if not os.path.exists(path):
        die("game_data.bin nem található")
    buf = open(path, "rb").read()
    save = Save(buf)
    print(f"game_data.bin ({len(buf)} bájt, sha256={sha256(path)[:16]}…)")
    print(f"  salt={save.salt}")
    print(f"  tárolt hash={save.stored_hash}")
    print(f"  számolt hash={save.computed_hash()}")
    print(f"  -> {'ÉRVÉNYES ✓' if save.is_valid() else 'ELTÉR ✗'}")
    try:
        info = save.describe(item_key)
        print(f"  {item_key}: copies={info['copies']}, level={info['level']}, "
              f"accessory_level={info['accessory_level']}, "
              f"accessory_xp={info['accessory_xp']}")
    except ValueError as err:
        print(f"  {item_key}: {err}")
    if item_key != JAR_ITEM:
        try:
            print(f"  {JAR_ITEM}: Jar-számláló={save.find_jar_counter()[0]}")
        except ValueError:
            pass
    else:
        print(f"  crystal_jar: Jar-számláló={save.describe()['jar']}")
    if os.path.exists(PLIST):
        plist = plistlib.load(open(PLIST, "rb"))
        print(f"PlayerPrefs {HASH_KEY} = {plist.get(HASH_KEY)!r}")
        print(f"PlayerPrefs {UNTRUSTED_KEY} = {plist.get(UNTRUSTED_KEY)!r}")
    for name in ("game_data_backup.bin", "game_data_pre_cloud.bin", "game_data_corrupted.bin"):
        p = os.path.join(DOCS, name)
        if os.path.exists(p):
            print(f"  {name}: létezik ({os.path.getsize(p)} bájt, módosítva: "
                  f"{datetime.datetime.fromtimestamp(os.path.getmtime(p)):%H:%M:%S})")


def cmd_items():
    path = os.path.join(DOCS, "game_data.bin")
    if not os.path.exists(path):
        die("game_data.bin nem található")
    save = Save(open(path, "rb").read())
    rows = save.list_items()
    print(f"Tárgyak a mentésben ({len(rows)}):")
    for key, level, copies in rows:
        print(f"  {key:32} level={str(level):>4}  copies={str(copies):>4}")


def cmd_revert():
    if game_running():
        die("a játék fut — zárd be előbb")
    if not os.path.isdir(BACKUP_ROOT):
        die("nincs save-backups mappa")
    candidates = sorted(d for d in os.listdir(BACKUP_ROOT)
                        if d.endswith(("save-edit", "jar-361-consistent")))
    if not candidates:
        die("nincs visszaállítható biztonsági mentés")
    src = os.path.join(BACKUP_ROOT, candidates[-1])
    print(f"Visszaállítás innen: {src}")
    for name in ("game_data.bin", "game_data_backup.bin", "game_data_pre_cloud.bin",
                 "com.multicastgames.butcher.plist"):
        s = os.path.join(src, name)
        if os.path.exists(s):
            dst = PLIST if name.endswith(".plist") else os.path.join(DOCS, name)
            shutil.copy2(s, dst + ".reverting")
            os.replace(dst + ".reverting", dst)
            print(f"  {name} visszaállítva")
    print("Kész — ellenőrizd --check-kel.")


if __name__ == "__main__":
    args = sys.argv[1:]
    item_key = JAR_ITEM
    if "--item" in args:
        i = args.index("--item")
        if i + 1 >= len(args):
            die("--item után tárgykulcs kell (pl. --item gem_ring; lista: --items)")
        item_key = args[i + 1]
        if not item_key or item_key.startswith("--"):
            die("üres vagy érvénytelen tárgykulcs")
        args = args[:i] + args[i + 2:]
    if "--secret" in args:
        i = args.index("--secret")
        if i + 1 >= len(args):
            die("--secret után kulcs kell")
        _bsh.SECRET = args[i + 1].encode()
        args = args[:i] + args[i + 2:]
    modes = ("--check", "--items", "--jar", "--copies", "--revert")
    if not args or args[0] not in modes:
        print(__doc__)
        raise SystemExit(0)
    mode = args[0]
    rest = args[1:]
    if mode == "--check":
        if rest:
            die("--check nem vár további paramétert")
        cmd_check(item_key)
    elif mode == "--items":
        if rest:
            die("--items nem vár további paramétert")
        cmd_items()
    elif mode == "--revert":
        if rest:
            die("--revert nem vár további paramétert")
        cmd_revert()
    else:
        if len(rest) != 1 or not (rest[0].isdigit() or
                                  (rest[0][:1] in "+-" and rest[0][1:].isdigit())):
            die(f"{mode} után pontosan egy szám kell (pl. {mode} 5, {mode} +1)")
        if mode == "--jar":
            cmd_edit("Jar-számláló (ability_counters)", rest[0],
                     Save.find_jar_counter, JAR_ITEM)
        else:
            cmd_edit(f"copies (példányszám)", rest[0],
                     lambda s, ik=item_key: s.find_item_int(ik, "copies"), item_key)
