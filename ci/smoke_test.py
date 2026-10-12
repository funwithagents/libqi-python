"""Smoke test of an installed qi wheel.

Checks that the native module and its bundled libraries load, then registers
a service on a standalone session and calls it from a second session.
"""

import qi
import qi.native


class Echo:
    @qi.bind(qi.String, [qi.String])
    def echo(self, text):
        return text


print("qi", qi.__version__, "- libqi", qi.native.__version__)

server = qi.Session()
client = qi.Session()
try:
    server.listenStandalone("tcp://127.0.0.1:0")
    server.registerService("Echo", Echo())
    client.connect(server.endpoints()[0])
    assert client.service("Echo").echo("hello") == "hello"
finally:
    client.close()
    server.close()

print("OK")
