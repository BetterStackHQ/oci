import gzip
import io
import os
import sys
import threading
import types
import unittest
import urllib.error
from http.server import BaseHTTPRequestHandler, HTTPServer
from unittest import mock

sys.modules["fdk"] = types.SimpleNamespace(response=types.SimpleNamespace(Response=lambda ctx, response_data: response_data))

import func  # noqa: E402


class Ingesting(BaseHTTPRequestHandler):
    status = 202
    received = []

    def do_POST(self):
        body = self.rfile.read(int(self.headers["Content-Length"]))
        Ingesting.received.append((self.path, dict(self.headers), body))
        self.send_response(Ingesting.status)
        if 300 <= Ingesting.status < 400:
            self.send_header("Location", "/elsewhere")
        self.end_headers()

    def do_GET(self):
        Ingesting.received.append((self.path, dict(self.headers), b""))
        self.send_response(200)
        self.end_headers()

    def log_message(self, *args):
        pass


class HandlerTest(unittest.TestCase):
    def setUp(self):
        Ingesting.received.clear()
        Ingesting.status = 202
        self.server = HTTPServer(("127.0.0.1", 0), Ingesting)
        threading.Thread(target=self.server.serve_forever, daemon=True).start()
        host = f"127.0.0.1:{self.server.server_port}"
        # func.py always speaks HTTPS; the test server is plain HTTP.
        real_request = urllib.request.Request
        self.patches = [
            mock.patch.dict(os.environ, {"BETTERSTACK_INGESTING_HOST": host, "BETTERSTACK_SOURCE_TOKEN": "token"}),
            mock.patch("urllib.request.Request", lambda url, **kw: real_request(url.replace("https://", "http://"), **kw)),
        ]
        for patch in self.patches:
            patch.start()

    def tearDown(self):
        for patch in self.patches:
            patch.stop()
        self.server.shutdown()

    def test_posts_the_batch_gzipped_with_the_source_token(self):
        func.handler(None, io.BytesIO(b'[{"namespace":"oci_faas"}]'))

        path, headers, body = Ingesting.received[0]
        self.assertEqual("/oci", path)
        self.assertEqual("Bearer token", headers["Authorization"])
        self.assertEqual("gzip", headers["Content-Encoding"])
        self.assertEqual(b'[{"namespace":"oci_faas"}]', gzip.decompress(body))

    def test_raises_on_a_redirect_instead_of_following_it(self):
        Ingesting.status = 301

        with self.assertRaises(urllib.error.HTTPError):
            func.handler(None, io.BytesIO(b"[]"))
        self.assertEqual(1, len(Ingesting.received))

    def test_raises_on_a_rejected_batch_so_connector_hub_retries(self):
        Ingesting.status = 500

        with self.assertRaises(urllib.error.HTTPError):
            func.handler(None, io.BytesIO(b"[]"))


if __name__ == "__main__":
    unittest.main()
