"""Offline mentésszerkesztő tesztek; szintetikus adat, személyes mentés nincs.

A scripts/butcher-save-edit.py (364–366) magját rögzíti: Jar-számláló és
crystal_jar copies keresése, int-mező csere minden kódolási átmeneten,
hash-újraszámolás a testvér butcher-save-hash.py receptjével.
"""
import importlib.util
import struct
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


bse = load("butcher_save_edit", ROOT / "scripts" / "butcher-save-edit.py")
bsh = bse._bsh  # a receptmodul (butcher-save-hash)


def key(text):
    b = text.encode()
    if len(b) < 32:
        return bytes([0xA0 | len(b)]) + b
    if len(b) < 256:
        return b"\xd9" + bytes([len(b)]) + b
    return b"\xda" + struct.pack(">H", len(b)) + b


def build_item(copies, jar_value):
    """Egy crystal_jar-szerű tétel üres base64-mentésrészhez."""
    out = bytearray(bytes([0x80 | 9]))  # fixmap(9) — a tétel map fejléce
    out += key("key") + key("crystal_jar")
    out += key("level") + bse.msgpack_write_int(1)
    out += key("copies") + bse.msgpack_write_int(copies)
    out += key("evolved") + b"\xc2"
    out += key("accessory_level") + bse.msgpack_write_int(1)
    out += key("accessory_experience") + b"\xcb" + struct.pack(">d", 3500.0)
    out += key("inheritance_upgrades") + bse.msgpack_write_int(0)
    # ability_counters map: 2 bejegyzés
    counters = bytearray(b"\x82")
    counters += key("accessory_crystal_jar_ability_1|first_proc_attempts") + bse.msgpack_write_int(-1)
    counters += key("accessory_crystal_jar_ability_1") + bse.msgpack_write_int(jar_value)
    out += key("ability_counters") + bytes(counters)
    out += key("accessory_cap_notice_level") + bse.msgpack_write_int(0)
    return bytes(out)


def build_save(salt, copies, jar_value):
    item = build_item(copies, jar_value)
    data = (bytes([0x81]) + key("player") +           # map1: player
            bytes([0x81]) + key("items") +             # map1: items
            bytes([0x91]) + item)                       # array1: egy tétel
    root = bytearray(b"\x85")                           # fixmap(5)
    root += key("version") + b"\xd2" + struct.pack(">i", 2)
    root += key("salt") + b"\xd3" + struct.pack(">q", salt)
    root += key("time") + b"\xd7\xff" + b"\x00" * 8
    root += key("data") + data
    h = bsh.compute_hash(data, salt)
    root += key("hash") + b"\xd9" + bytes([len(h)]) + h.encode()
    return bytes(root)


class FinderTests(unittest.TestCase):
    def test_find_jar_and_copies(self):
        buf = build_save(-853994833, copies=3, jar_value=360)
        save = bse.Save(buf)
        self.assertEqual(save.find_jar_counter()[0], 360)
        self.assertEqual(save.find_item_int("copies")[0], 3)
        self.assertEqual(save.find_item_int("level")[0], 1)
        info = save.describe()
        self.assertEqual((info["jar"], info["copies"], info["accessory_xp"]),
                         (360, 3, 3500.0))

    def test_synthetic_save_is_valid(self):
        buf = build_save(530690136, copies=0, jar_value=7)
        self.assertTrue(bse.Save(buf).is_valid())


class PatchTests(unittest.TestCase):
    def patch_and_check(self, salt, copies, jar, new_value, finder_name):
        buf = build_save(salt, copies, jar)
        save = bse.Save(buf)

        def finder(s):
            if finder_name == "jar":
                return s.find_jar_counter()
            return s.find_item_int("copies")

        value, vs, ve, code = finder(save)
        patched = bse.patch_int(buf, vs, ve, new_value)
        out, new_hash = bse.finish_save(patched)
        final = bse.Save(out)
        self.assertTrue(final.is_valid(), "a patchelt mentés hash-e érvényes")
        self.assertEqual(finder(final)[0], new_value)
        # a másik mező változatlan marad
        def other(s):
            if finder_name == "jar":
                return s.find_item_int("copies")
            return s.find_jar_counter()
        self.assertEqual(other(final)[0], copies if finder_name == "jar" else jar)
        # a külső ellenőrző (repó verify-eszköz receptje) is elfogadja
        self.assertEqual(bsh.compute_hash(final.data, final.salt), final.stored_hash)
        return len(buf), len(out), code

    def test_jar_in_place_same_width(self):
        old, new, _ = self.patch_and_check(-853994833, 0, 360, 500, "jar")
        self.assertEqual(old, new)  # uint16 -> uint16

    def test_jar_encoding_growth(self):
        old, new, _ = self.patch_and_check(-853994833, 0, 7, 350, "jar")
        self.assertEqual(new, old + 2)  # fixnum -> uint16

    def test_jar_encoding_shrink(self):
        old, new, _ = self.patch_and_check(-853994833, 0, 360, 5, "jar")
        self.assertEqual(new, old - 2)  # uint16 -> fixnum

    def test_jar_uint32(self):
        old, new, _ = self.patch_and_check(-853994833, 0, 360, 70000, "jar")
        self.assertEqual(new, old + 2)  # uint16 -> uint32

    def test_copies_in_place(self):
        old, new, _ = self.patch_and_check(1742030218, 0, 10, 5, "copies")
        self.assertEqual(old, new)  # fixnum -> fixnum

    def test_copies_growth(self):
        old, new, _ = self.patch_and_check(1742030218, 0, 10, 300, "copies")
        self.assertEqual(new, old + 2)  # fixnum -> uint16

    def test_copies_uint16_to_uint32(self):
        old, new, _ = self.patch_and_check(1742030218, 350, 10, 70000, "copies")
        self.assertEqual(new, old + 2)


class ResolveValueTests(unittest.TestCase):
    def test_relative_and_absolute(self):
        self.assertEqual(bse.resolve_value(7, "+1"), 8)
        self.assertEqual(bse.resolve_value(7, "+3"), 10)
        self.assertEqual(bse.resolve_value(10, "-1"), 9)
        self.assertEqual(bse.resolve_value(10, "350"), 350)
        self.assertEqual(bse.resolve_value(0, "+1"), 1)

    def test_guards(self):
        with self.assertRaises(ValueError):
            bse.resolve_value(3, "-5")          # negatív eredmény
        with self.assertRaises(ValueError):
            bse.resolve_value(3, "abc")         # nem szám
        with self.assertRaises(ValueError):
            bse.resolve_value(3, "+x")          # nem szám relatív jelzésnél


class PatchIntGuardTests(unittest.TestCase):
    def test_rejects_out_of_range(self):
        with self.assertRaises(ValueError):
            bse.patch_int(b"\x00" * 16, 0, 1, 2**33)
        with self.assertRaises(ValueError):
            bse.patch_int(b"\x00" * 16, 0, 1, -2**31 - 1)


if __name__ == "__main__":
    unittest.main()
