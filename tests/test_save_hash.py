"""Offline mentés-hash recept tesztek; csak szintetikus adat, személyes mentés nem része.

A docs/362-mentes-hash-visszafejtese.md-ben leírt algoritmust rögzítik:
hash = BitConverter.ToString(MD5(data + msgpack_str(secret) + optimal_int(salt))).
A várt hash-ek független inline MD5-számítással készültek, nem az eszközből.
"""
import importlib.util
import struct
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts" / "butcher-save-hash.py"

spec = importlib.util.spec_from_file_location("butcher_save_hash", SCRIPT)
bsh = importlib.util.module_from_spec(spec)
spec.loader.exec_module(bsh)

# Függetlenül előre kiszámolt kanonikus vektorok: (data_bájtok, salt, várt_hash)
CANONICAL_VECTORS = [
    (bytes.fromhex("80"), 1, "E4-46-F2-8D-B4-D9-FD-8D-02-79-56-10-88-C9-00-DD"),
    (bytes.fromhex("9201c2"), 530690136, "06-53-DD-17-30-4D-E6-F8-31-5D-BE-99-6F-71-C5-D1"),
    (bytes.fromhex("81a178d30000000000000007"), -853994833,
     "6D-5A-97-58-D2-8D-6A-C0-BC-A5-1E-D1-7E-F5-8F-DC"),
    (bytes.fromhex("c0"), 127, "52-F1-80-21-B5-04-14-9C-F2-FA-26-12-29-3C-17-B6"),
    (bytes.fromhex("81a179cb3ff0000000000000"), 128, "00-67-66-EE-0E-F5-A2-D1-08-45-05-9A-D4-76-A5-1F"),
    (bytes.fromhex("00"), 65535, "A9-BF-21-44-BF-24-4B-BA-21-ED-47-5A-1A-BE-B6-82"),
    (bytes.fromhex("00"), 65536, "7E-08-48-DD-E1-8F-75-31-CC-A6-32-E5-4E-B4-03-6D"),
    (bytes.fromhex("00"), -33, "5E-26-59-D1-95-90-3B-1A-39-E6-4B-E0-B9-0E-78-0C"),
    (bytes.fromhex("00"), -129, "2B-D8-CB-5D-63-AD-4F-92-88-D7-A7-FC-EA-3D-2C-90"),
    (bytes.fromhex("00"), -32769, "2C-23-6E-4E-98-C4-00-3A-2C-04-C6-15-4B-F3-2D-27"),
]

SECRET_MSGPACK = b"\xb8" + b"5b5496vn7456oodw976d95mo"


class OptimalIntEncodingTests(unittest.TestCase):
    def test_all_branches(self):
        cases = [
            (0, b"\x00"), (1, b"\x01"), (127, b"\x7f"),
            (128, b"\xcc\x80"), (255, b"\xcc\xff"),
            (256, b"\xcd\x01\x00"), (65535, b"\xcd\xff\xff"),
            (65536, b"\xce\x00\x01\x00\x00"), (530690136, b"\xce\x1f\xa1\xb0\x58"),
            (-1, b"\xff"), (-32, b"\xe0"),
            (-33, b"\xd0\xdf"), (-128, b"\xd0\x80"),
            (-129, b"\xd1\xff\x7f"), (-32768, b"\xd1\x80\x00"),
            (-32769, b"\xd2\xff\xff\x7f\xff"), (-853994833,
             b"\xd2\xcd\x19\x12\xaf"),
        ]
        for value, expected in cases:
            with self.subTest(value=value):
                self.assertEqual(bsh.msgpack_write_int(value), expected)

    def test_str_encoding(self):
        self.assertEqual(bsh.msgpack_str(b"ab"), b"\xa2ab")
        self.assertEqual(bsh.msgpack_str(b"x" * 31), b"\xbf" + b"x" * 31)
        self.assertEqual(bsh.msgpack_str(b"y" * 32), b"\xd9\x20" + b"y" * 32)
        self.assertEqual(bsh.msgpack_str(SECRET_MSGPACK[1:]),
                         SECRET_MSGPACK)


class CanonicalHashTests(unittest.TestCase):
    def test_vectors(self):
        for data, salt, expected in CANONICAL_VECTORS:
            with self.subTest(salt=salt, data=data.hex()):
                self.assertEqual(bsh.compute_hash(data, salt), expected)


def synthetic_save(salt: int, data: bytes) -> bytes:
    """Szintetikus game_data.bin jellegű MessagePack fájl gyártása."""
    def key(text):
        return bytes([0xA0 | len(text)]) + text.encode()
    out = bytearray()
    out += b"\x85"                      # fixmap(5)
    out += key("version") + b"\xd2" + struct.pack(">i", 2)
    out += key("salt") + b"\xd3" + struct.pack(">q", salt)
    out += key("time") + b"\xd7\xff" + b"\x00" * 8   # fixext8 dummy idő
    out += key("data") + data
    out += key("hash") + b"\xd9" + bytes([47]) + bsh.compute_hash(data, salt).encode()
    return bytes(out)


class RootParsingTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="butcher-save-hash-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)

    def write_save(self, salt, data):
        path = self.root / "game_data.bin"
        path.write_bytes(synthetic_save(salt, data))
        return str(path)

    def test_read_root_roundtrip(self):
        path = self.write_save(-853994833, b"\x81\xa1z\x01")
        salt, data, hash_str = bsh.read_root(path)
        self.assertEqual(salt, -853994833)
        self.assertEqual(data, b"\x81\xa1z\x01")
        self.assertEqual(bsh.compute_hash(data, salt), hash_str)

    def test_verify_success_exit_code(self):
        path = self.write_save(530690136, b"\x92\x03\x04")
        code = bsh.main(["butcher-save-hash.py", "verify", path])
        self.assertEqual(code, 0)

    def test_verify_failure_on_tamper(self):
        path = self.write_save(530690136, b"\x92\x03\x04")
        buf = bytearray(Path(path).read_bytes())
        marker = buf.index(b"\x92\x03\x04")
        buf[marker + 1] = 0x05  # az adat 03→05: szerkezet érvényes, tartalom más
        Path(path).write_bytes(buf)
        code = bsh.main(["butcher-save-hash.py", "verify", path])
        self.assertEqual(code, 2)

    def test_verify_detects_single_data_byte_change(self):
        path = self.write_save(7, b"\xa2ok")
        buf = bytearray(Path(path).read_bytes())
        buf[buf.index(b"\xa2ok") + 1] = ord("p")
        Path(path).write_bytes(buf)
        salt, data, stored = bsh.read_root(path)
        self.assertNotEqual(bsh.compute_hash(data, salt), stored)

    def test_hash_mode_matches_verify(self):
        path = self.write_save(-1004654814, b"\x80")
        salt, data, _ = bsh.read_root(path)
        code = bsh.main(["butcher-save-hash.py", "hash", path])
        self.assertEqual(code, 0)

    def test_hash_data_mode(self):
        path = self.root / "data.bin"
        path.write_bytes(b"\x80")
        code = bsh.main(["butcher-save-hash.py", "hash-data", str(path), "1"])
        self.assertEqual(code, 0)


if __name__ == "__main__":
    unittest.main()
