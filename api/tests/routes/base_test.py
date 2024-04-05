from unittest import TestCase
from fastapi.testclient import TestClient
from src.main import app


class BaseTestCase(TestCase):
    def setUp(self):
        self.client = TestClient(app)

    def tearDown(self):
        pass
