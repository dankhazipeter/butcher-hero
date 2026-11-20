"""Offline mentésszerkesztő tesztek; szintetikus adat, személyes mentés nincs.

A scripts/butcher-save-edit.py (364–367) magját rögzíti: tárgyválasztás
(--item), Jar-számláló és copies keresése, int-mező csere minden kódolási
átmeneten, hash-újraszámolás a testvér butcher-save-hash.py receptjével.
"""
import importlib.util
import struct
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


def build_item(item_key, copies, jar_value):
    """Tárgytétel a gem_ring/crystal_jar séma szerint (9 mező)."""
    out = bytearray(bytes([0x80 | 9]))  # fixmap(9)
    out += key("key") + key(item_key)
    out += key("level") + bse.msgpack_write_int(2)
    out += key("copies") + bse.msgpack_write_int(copies)
    out += key("evolved") + b"\xc2"
    out += key("accessory_level") + bse.msgpack_write_int(6)
    out += key("accessory_experience") + b"\xcb" + struct.pack(">d", 7500.0)
    out += key("inheritance_upgrades") + bse.msgpack_write_int(0)
    counters = bytearray(bytes([0x82]))
    counters += key(f"accessory_{item_key}_ability_1|first_proc_attempts") + bse.msgpack_write_int(-1)
    if jar_value is not None:
        counters += key(f"accessory_{item_key}_ability_1") + bse.msgpack_write_int(jar_value)
    else:
        counters += key(f"accessory_{item_key}_ability_2|first_proc_attempts") + bse.msgpack_write_int(-1)
    out += key("ability_counters") + bytes(counters)
    out += key("accessory_cap_notice_level") + bse.msgpack_write_int(6)
    return bytes(out)


def build_save(salt, jar_copies, gem_copies, jar_value=360, vip_points=3350,
               geode=100, red_souls=5, vip_value=3350.0, f32=1.5):
    items = (bytes([0x92]) +                                  # array(2)
             build_item("crystal_jar", jar_copies, jar_value) +
             build_item("gem_ring", gem_copies, None))
    vip = (bytes([0x82]) + key("points") + bse.msgpack_write_int(vip_points)
           + key("level") + bse.msgpack_write_int(5))
    currency = (bytes([0x81]) + key("geode") + bse.msgpack_write_int(geode))
    events = (bytes([0x81]) + key("currencies") +
              bytes([0x81]) + key("red") + bse.msgpack_write_int(red_souls))
    user = (bytes([0x82]) + key("in_apps_bought_value_in_rewarded")
            + b"\xcb" + struct.pack(">d", vip_value)
            + key("f32_field") + b"\xca" + struct.pack(">f", f32))
    data = (bytes([0x85]) +                                    # map(5)
            key("player") + bytes([0x81]) + key("items") + items +
            key("vip") + vip +
            key("currency") + currency +
            key("events") + events +
            key("user") + user)
    root = bytearray(b"\x85")
    root += key("version") + b"\xd2" + struct.pack(">i", 2)
    root += key("salt") + b"\xd3" + struct.pack(">q", salt)
    root += key("time") + b"\xd7\xff" + b"\x00" * 8
    root += key("data") + data
    h = bsh.compute_hash(data, salt)
    root += key("hash") + b"\xd9" + bytes([len(h)]) + h.encode()
    return bytes(root)


class FinderTests(unittest.TestCase):
    def test_item_selection(self):
        buf = build_save(-853994833, jar_copies=3, gem_copies=0)
        save = bse.Save(buf)
        self.assertEqual(save.find_item_int("crystal_jar", "copies")[0], 3)
        self.assertEqual(save.find_item_int("gem_ring", "copies")[0], 0)
        self.assertEqual(save.find_jar_counter()[0], 360)
        info = save.describe("gem_ring")
        self.assertEqual((info["copies"], info["level"], info["accessory_xp"]),
                         (0, 2, 7500.0))
        self.assertEqual(info["jar"], 360)

    def test_unknown_item_raises(self):
        buf = build_save(530690136, jar_copies=0, gem_copies=5, jar_value=7)
        save = bse.Save(buf)
        with self.assertRaises(ValueError):
            save.find_item_int("nincs_ilyen", "copies")
        with self.assertRaises(ValueError):
            save.find_item_int("gem_ring", "nincs_mezo")

    def test_list_items(self):
        buf = build_save(1742030218, jar_copies=1, gem_copies=0, jar_value=10)
        rows = bse.Save(buf).list_items()
        self.assertEqual(rows, [("crystal_jar", 2, 1), ("gem_ring", 2, 0)])

    def test_synthetic_save_is_valid(self):
        buf = build_save(530690136, jar_copies=0, gem_copies=0, jar_value=7)
        self.assertTrue(bse.Save(buf).is_valid())


class PatchTests(unittest.TestCase):
    def patch_and_check(self, salt, item, jar_copies, gem_copies, jar,
                        new_value, field):
        buf = build_save(salt, jar_copies, gem_copies, jar)
        save = bse.Save(buf)

        def finder(s):
            if field == "jar":
                return s.find_jar_counter()
            return s.find_item_int(item, "copies")

        value, vs, ve, code = finder(save)
        patched = bse.patch_int(buf, vs, ve, new_value)
        out, new_hash = bse.finish_save(patched)
        final = bse.Save(out)
        self.assertTrue(final.is_valid(), "a patchelt mentés hash-e érvényes")
        self.assertEqual(finder(final)[0], new_value)
        # a MÁSIK tárgy és mező változatlan marad
        other_item = "gem_ring" if item == "crystal_jar" else "crystal_jar"
        self.assertEqual(final.find_item_int(other_item, "copies")[0],
                         gem_copies if item == "crystal_jar" else jar_copies)
        if field == "copies":
            self.assertEqual(final.find_jar_counter()[0], jar)
        self.assertEqual(bsh.compute_hash(final.data, final.salt), final.stored_hash)
        return len(buf), len(out), code

    def test_jar_in_place_same_width(self):
        old, new, _ = self.patch_and_check(-853994833, "crystal_jar", 0, 0, 360, 500, "jar")
        self.assertEqual(old, new)

    def test_jar_encoding_growth(self):
        old, new, _ = self.patch_and_check(-853994833, "crystal_jar", 0, 0, 7, 350, "jar")
        self.assertEqual(new, old + 2)

    def test_jar_encoding_shrink(self):
        old, new, _ = self.patch_and_check(-853994833, "crystal_jar", 0, 0, 360, 5, "jar")
        self.assertEqual(new, old - 2)

    def test_jar_uint32(self):
        old, new, _ = self.patch_and_check(-853994833, "crystal_jar", 0, 0, 360, 70000, "jar")
        self.assertEqual(new, old + 2)

    def test_copies_in_place(self):
        old, new, _ = self.patch_and_check(1742030218, "crystal_jar", 0, 4, 10, 5, "copies")
        self.assertEqual(old, new)

    def test_copies_growth(self):
        old, new, _ = self.patch_and_check(1742030218, "crystal_jar", 0, 4, 10, 300, "copies")
        self.assertEqual(new, old + 2)

    def test_copies_uint16_to_uint32(self):
        old, new, _ = self.patch_and_check(1742030218, "crystal_jar", 350, 0, 10, 70000, "copies")
        self.assertEqual(new, old + 2)

    def test_gem_ring_copies_edit(self):
        old, new, _ = self.patch_and_check(1742030218, "gem_ring", 2, 0, 10, 1, "copies")
        self.assertEqual(old, new)

    def test_gem_ring_copies_growth(self):
        old, new, _ = self.patch_and_check(1742030218, "gem_ring", 2, 5, 10, 300, "copies")
        self.assertEqual(new, old + 2)


class FieldPathTests(unittest.TestCase):
    def setUp(self):
        self.buf = build_save(1742030218, 2, 1, 10, vip_points=3350,
                              geode=100, red_souls=5)
        self.save = bse.Save(self.buf)

    def test_list_sections(self):
        rows = dict((name, (kind, count)) for name, kind, count in
                    self.save.list_sections())
        self.assertEqual(rows["vip"], ("map", 2))
        self.assertEqual(rows["currency"], ("map", 1))
        self.assertEqual(rows["player"], ("map", 1))

    def test_dump_section(self):
        lines = self.save.dump_section("vip")
        self.assertTrue(any("points: 3350" in ln for ln in lines))
        self.assertTrue(any("level: 5" in ln for ln in lines))
        with self.assertRaises(ValueError):
            self.save.dump_section("nincs_ilyen")

    def test_find_field_paths(self):
        self.assertEqual(self.save.find_field_path("vip.points")[0], 3350)
        self.assertEqual(self.save.find_field_path("currency.geode")[0], 100)
        self.assertEqual(self.save.find_field_path("events.currencies.red")[0], 5)

    def test_path_guards(self):
        with self.assertRaises(ValueError):
            self.save.find_field_path("vip")                # túl rövid útvonal
        with self.assertRaises(ValueError):
            self.save.find_field_path("nincs.points")       # nincs szekció
        with self.assertRaises(ValueError):
            self.save.find_field_path("vip.nincs")          # nincs mező
        with self.assertRaises(ValueError):
            self.save.find_field_path("vip.points.még")     # int végű útvonalra lépés

    def test_set_field_patch_flow(self):
        value, vs, ve, code = self.save.find_field_path("vip.points")
        patched = bse.patch_int(self.buf, vs, ve, value + 100)
        out, new_hash = bse.finish_save(patched)
        final = bse.Save(out)
        self.assertTrue(final.is_valid())
        self.assertEqual(final.find_field_path("vip.points")[0], 3450)
        # a többi szekció érintetlen
        self.assertEqual(final.find_field_path("currency.geode")[0], 100)
        self.assertEqual(final.find_jar_counter()[0], 10)
        self.assertEqual(final.find_item_int("gem_ring", "copies")[0], 1)

    def test_set_field_relative_and_encoding(self):
        value, vs, ve, code = self.save.find_field_path("events.currencies.red")
        self.assertEqual(bse.resolve_value(value, "+995"), 1000)
        patched = bse.patch_int(self.buf, vs, ve, 1000)     # fixnum -> uint16
        out, _ = bse.finish_save(patched)
        final = bse.Save(out)
        self.assertTrue(final.is_valid())
        self.assertEqual(final.find_field_path("events.currencies.red")[0], 1000)
        self.assertEqual(len(out), len(self.buf) + 2)       # fixnum(1) -> uint16(3)


class FloatFieldTests(unittest.TestCase):
    def setUp(self):
        self.buf = build_save(1742030218, 2, 1, 10)
        self.save = bse.Save(self.buf)

    def test_find_float_field(self):
        value, vs, ve, code = self.save.find_field_path(
            "user.in_apps_bought_value_in_rewarded")
        self.assertEqual(value, 3350.0)
        self.assertEqual(code, 0xCB)               # float64
        value, vs, ve, code = self.save.find_field_path("user.f32_field")
        self.assertEqual(value, 1.5)
        self.assertEqual(code, 0xCA)               # float32

    def test_patch_float64_relative(self):
        value, vs, ve, code = self.save.find_field_path(
            "user.in_apps_bought_value_in_rewarded")
        new_value = bse.resolve_value(value, "+100")
        patched = bse.patch_value(self.buf, vs, ve, new_value)
        out, _ = bse.finish_save(patched)
        final = bse.Save(out)
        self.assertTrue(final.is_valid())
        got, _, _, code = final.find_field_path("user.in_apps_bought_value_in_rewarded")
        self.assertEqual(got, 3450.0)
        self.assertEqual(code, 0xCB)               # a kódolás változatlan
        self.assertEqual(len(out), len(self.buf))  # helyben, azonos szélesség
        # a többi érintetlen
        self.assertEqual(final.find_field_path("currency.geode")[0], 100)
        self.assertEqual(final.find_jar_counter()[0], 10)

    def test_patch_float32_and_precision_guard(self):
        value, vs, ve, _ = self.save.find_field_path("user.f32_field")
        patched = bse.patch_value(self.buf, vs, ve, 7.5)      # float32-ben pontos
        out, _ = bse.finish_save(patched)
        got, _, _, code = bse.Save(out).find_field_path("user.f32_field")
        self.assertEqual((got, code), (7.5, 0xCA))
        with self.assertRaises(ValueError):                   # float32-ben nem ábrázolható
            bse.patch_value(self.buf, vs, ve, 3450.7)

    def test_int_field_rejects_fraction_spec(self):
        with self.assertRaises(ValueError):
            bse.resolve_value(100, "+2.5")          # tört spec int mezőn
        with self.assertRaises(ValueError):
            bse.patch_int(self.buf, 0, 1, 2.5)      # tört érték int patch-en

    def test_resolve_value_fraction_forms(self):
        self.assertEqual(bse.resolve_value(3350.0, "+100.0"), 3450.0)
        self.assertEqual(bse.resolve_value(3350.0, "3450.0"), 3450.0)
        self.assertEqual(bse.resolve_value(3350.0, "+0.5"), 3350.5)
        self.assertEqual(bse.resolve_value(3350.0, "+100"), 3450.0)  # int delta floaton
        self.assertEqual(bse.resolve_value(10, "-5"), 5)
        with self.assertRaises(ValueError):
            bse.resolve_value(0.5, "-1")            # negatív eredmény
        with self.assertRaises(ValueError):
            bse.resolve_value(10, "abc")


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
