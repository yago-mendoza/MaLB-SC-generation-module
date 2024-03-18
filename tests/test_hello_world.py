from unittest import TestCase


class TestHelloWorld(TestCase):
    def test_upper(self):
        self.assertEqual("hello world!".upper(), "HELLO WORLD!")

# run : poetry run pytest from inside contract-builder