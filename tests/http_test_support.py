"""Deterministic loopback POSTs for early-rejection HTTP contract tests."""
from http.client import HTTPResponse
import json
import socket
from urllib.parse import urlsplit


def post_once(base, path, headers, body):
    # urllib/http.client send headers, body and the chunk terminator separately.
    # An intentionally rejected header can close the connection before the
    # final client write, yielding BrokenPipe instead of the expected HTTP400.
    # Queue the complete small fixture request once, then read the real reply.
    target = urlsplit(base)
    values = {"Host": target.netloc, "Connection": "close", **headers}
    if values.get("Transfer-Encoding") == "chunked":
        payload = f"{len(body):X}\r\n".encode() + body + b"\r\n0\r\n\r\n" if body else b"0\r\n\r\n"
    else:
        values["Content-Length"] = str(len(body))
        payload = body
    request = (f"POST {path} HTTP/1.1\r\n" + "".join(f"{key}: {value}\r\n" for key, value in values.items()) + "\r\n").encode("latin-1") + payload
    with socket.create_connection((target.hostname, target.port), timeout=3) as connection:
        connection.sendall(request)
        with HTTPResponse(connection) as response:
            response.begin()
            return response.status, json.loads(response.read())
