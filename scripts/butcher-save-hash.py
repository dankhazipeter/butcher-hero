#!/usr/bin/env python3
"""Butcher Hero 2.1 mentés-hash eszköz — a game_data.bin integritásmező olvasása/ellenőrzése.

A játék (Unity 6, IL2CPP, Multicast.UserData.UdRoot) minden mentéskor így írja a
gyökér `hash` mezőt (lásd docs/362-mentes-hash-visszafejtese.md):

    hash = BitConverter.ToString(MD5(
        data_msgpack_bájtok
        + msgpack_str("5b5496vn7456oodw976d95mo")      # fixstr, 24 bájt
        + msgpack_write_int(salt)                        # optimális int kódolás
    ))

A `salt` a gyökér azonos nevű mezője: UnityEngine.Random.Range(int.MinValue,
int.MaxValue), a fájlban int64 (0xD3) kódolással, de a hash-be az optimális
int kódolású alakja kerül. A `time` és a `version` NEM része a hash-nek.

Használat (csak olvasás, nem ír fájlt):
    butcher-save-hash.py verify <game_data.bin>        # fájl hash-ének ellenőrzése
    butcher-save-hash.py hash <game_data.bin>          # data+salt alapján a hash kiírása
    butcher-save-hash.py hash-data <data.bin> <salt>   # adott bájtokra és salt int-re

Kilépési kód: 0 = érvényes, 2 = eltérő hash, 1 = olvasási/formátumhiba.
"""
import hashlib
import struct
import sys

SECRET = b"5b5496vn7456oodw976d95mo"
ROOT_FIELDS = ("version", "salt", "time", "data", "hash")


class SaveFormatError(Exception):
    """A fájl nem game_data.bin formátumú."""


def msgpack_str(value: bytes) -> bytes:
    n = len(value)
    if n < 32:
        return bytes([0xA0 | n]) + value
    if n < 256:
        return b"\xd9" + bytes([n]) + value
    if n < 65536:
        return b"\xda" + struct.pack(">H", n) + value
    return b"\xdb" + struct.pack(">I", n) + value


def msgpack_write_int(value: int) -> bytes:
    """MessagePack-CSharp `MessagePackWriter.Write(int)` optimális kódolása."""
    if 0 <= value <= 127:
        return bytes([value])
    if -32 <= value < 0:
        return bytes([0xE0 | (value + 32)])
    if 128 <= value <= 255:
        return b"\xcc" + struct.pack(">B", value)
    if 256 <= value <= 65535:
        return b"\xcd" + struct.pack(">H", value)
    if -128 <= value < -32:
        return b"\xd0" + struct.pack(">b", value)
    if -32768 <= value < -128:
        return b"\xd1" + struct.pack(">h", value)
    if value > 65535:
        return b"\xce" + struct.pack(">I", value)
    return b"\xd2" + struct.pack(">i", value)


def compute_hash(data: bytes, salt: int) -> str:
    digest = hashlib.md5(data + msgpack_str(SECRET) + msgpack_write_int(salt)).digest()
    return "-".join(f"{byte:02X}" for byte in digest)


def _skip_value(buf: bytes, pos: int) -> int:
    """MessagePack érték átugrása; visszatérés a következő elem pozíciójával."""
    if pos >= len(buf):
        raise SaveFormatError("hiányzó MessagePack érték")
    code = buf[pos]
    if code <= 0x7F or code >= 0xE0:
        return pos + 1
    if 0xA0 <= code <= 0xBF:
        return pos + 1 + (code & 0x1F)
    if 0x80 <= code <= 0x8F:
        return _skip_fields(buf, pos + 1, (code & 0x0F) * 2)
    if 0x90 <= code <= 0x9F:
        return _skip_fields(buf, pos + 1, code & 0x0F)
    simple = {0xC0: 1, 0xC2: 1, 0xC3: 1,
              0xD4: 3, 0xD5: 4, 0xD6: 6, 0xD7: 10, 0xD8: 18, 0xCC: 2, 0xCD: 3,
              0xCE: 5, 0xCF: 9, 0xD0: 2, 0xD1: 3, 0xD2: 5, 0xD3: 9,
              0xCA: 5, 0xCB: 9}
    if code in simple:
        extra = simple[code]
        return pos + extra
    if code in (0xC4, 0xC5, 0xC6, 0xC7, 0xC8, 0xC9, 0xD9, 0xDA, 0xDB):
        # bin8/16/32, ext8/16/32, str8/16/32: hosszmező (+ ext-nél típusbájt)
        width = {0xC4: 1, 0xC5: 2, 0xC6: 4, 0xC7: 1, 0xC8: 2, 0xC9: 4,
                 0xD9: 1, 0xDA: 2, 0xDB: 4}[code]
        length = int.from_bytes(buf[pos + 1:pos + 1 + width], "big")
        head = 1 + width + (1 if code in (0xC7, 0xC8, 0xC9) else 0)
        return pos + head + length
    if code == 0xDE:
        return _skip_fields(buf, pos + 3, struct.unpack_from(">H", buf, pos + 1)[0] * 2)
    if code == 0xDF:
        return _skip_fields(buf, pos + 5, struct.unpack_from(">I", buf, pos + 1)[0] * 2)
    if code == 0xDC:
        return _skip_fields(buf, pos + 3, struct.unpack_from(">H", buf, pos + 1)[0])
    if code == 0xDD:
        return _skip_fields(buf, pos + 5, struct.unpack_from(">I", buf, pos + 1)[0])
    raise SaveFormatError(f"ismeretlen MessagePack kód 0x{code:02X} @0x{pos:X}")


def _skip_fields(buf: bytes, pos: int, count: int) -> int:
    for _ in range(count):
        pos = _skip_value(buf, pos)
    return pos


def _read_int(buf: bytes, pos: int):
    code = buf[pos]
    if code == 0xD3:
        return struct.unpack_from(">q", buf, pos + 1)[0], pos + 9
    if code == 0xD2:
        return struct.unpack_from(">i", buf, pos + 1)[0], pos + 5
    if code == 0xD1:
        return struct.unpack_from(">h", buf, pos + 1)[0], pos + 3
    if code == 0xD0:
        return struct.unpack_from(">b", buf, pos + 1)[0], pos + 2
    if code == 0xCE:
        return struct.unpack_from(">I", buf, pos + 1)[0], pos + 5
    if code == 0xCD:
        return struct.unpack_from(">H", buf, pos + 1)[0], pos + 3
    if code == 0xCC:
        return buf[pos + 1], pos + 2
    if code <= 0x7F:
        return code, pos + 1
    if code >= 0xE0:
        return code - 0x100, pos + 1
    raise SaveFormatError(f"nem szám kód 0x{code:02X} @0x{pos:X}")


def _read_str(buf: bytes, pos: int):
    code = buf[pos]
    if 0xA0 <= code <= 0xBF:
        n = code & 0x1F
        return buf[pos + 1:pos + 1 + n].decode("utf-8", "replace"), pos + 1 + n
    if code == 0xD9:
        n = buf[pos + 1]
        return buf[pos + 2:pos + 2 + n].decode("utf-8", "replace"), pos + 2 + n
    if code == 0xDA:
        n = struct.unpack_from(">H", buf, pos + 1)[0]
        return buf[pos + 3:pos + 3 + n].decode("utf-8", "replace"), pos + 3 + n
    if code == 0xDB:
        n = struct.unpack_from(">I", buf, pos + 1)[0]
        return buf[pos + 5:pos + 5 + n].decode("utf-8", "replace"), pos + 5 + n
    raise SaveFormatError(f"nem szöveg kód 0x{code:02X} @0x{pos:X}")


def read_root(path: str):
    """Gyökérmezők kinyerése: (salt, data_bájtok, hash_szöveg)."""
    buf = open(path, "rb").read()
    if not buf:
        raise SaveFormatError("üres fájl")
    code = buf[0]
    if 0x80 <= code <= 0x8F:
        count, pos = code & 0x0F, 1
    elif code == 0xDE:
        count, pos = struct.unpack_from(">H", buf, 1)[0], 3
    elif code == 0xDF:
        count, pos = struct.unpack_from(">I", buf, 1)[0], 5
    else:
        raise SaveFormatError("a gyökér nem MessagePack map")

    salt = data = hash_str = None
    data_end = None
    for _ in range(count):
        key_pos = pos
        key_code = buf[pos]
        if 0xA0 <= key_code <= 0xBF:
            key = buf[pos + 1:pos + 1 + (key_code & 0x1F)].decode("utf-8", "replace")
            pos += 1 + (key_code & 0x1F)
        elif key_code == 0xD9:
            n = buf[pos + 1]
            key = buf[pos + 2:pos + 2 + n].decode("utf-8", "replace")
            pos += 2 + n
        else:
            raise SaveFormatError("nem szöveg gyökérkulcs @0x%X" % key_pos)
        value_pos = pos
        if key == "salt":
            salt, pos = _read_int(buf, pos)
        elif key == "data":
            data_end = _skip_value(buf, pos)
            data = buf[pos:data_end]
            pos = data_end
        elif key == "hash":
            hash_str, pos = _read_str(buf, pos)
        else:
            pos = _skip_value(buf, pos)
    if salt is None or data is None or hash_str is None:
        raise SaveFormatError("hiányzó gyökérmező (salt/data/hash)")
    return salt, data, hash_str


def main(argv):
    if len(argv) < 2 or argv[1] in ("-h", "--help"):
        print(__doc__.strip())
        return 0
    command = argv[1]
    try:
        if command == "verify" and len(argv) == 3:
            salt, data, stored = read_root(argv[2])
            computed = compute_hash(data, salt)
            print(f"salt={salt}")
            print(f"tárolt  hash={stored}")
            print(f"számolt hash={computed}")
            if computed == stored:
                print("eredmény: EGYEZIK (érvényes mentés)")
                return 0
            print("eredmény: ELTÉR (sérült vagy módosított mentés)")
            return 2
        if command == "hash" and len(argv) == 3:
            salt, data, _ = read_root(argv[2])
            print(compute_hash(data, salt))
            return 0
        if command == "hash-data" and len(argv) == 4:
            data = open(argv[2], "rb").read()
            salt = int(argv[3])
            print(compute_hash(data, salt))
            return 0
    except (OSError, ValueError, struct.error) as err:
        print(f"hiba: {err}", file=sys.stderr)
        return 1
    except SaveFormatError as err:
        print(f"formátumhiba: {err}", file=sys.stderr)
        return 1
    print(__doc__.strip())
    return 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))
