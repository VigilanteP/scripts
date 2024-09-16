from mock_deluge_client import MockDelugeClient
from real_deluge_client import RealDelugeClient
from deluge_config import DelugeConfig


class DelugeClientFactory():
    def __init__(self):
        self.config = DelugeConfig()

    def getClient(self):
        if self.config.use_mock():
            return MockDelugeClient()
        else:
            return RealDelugeClient()
