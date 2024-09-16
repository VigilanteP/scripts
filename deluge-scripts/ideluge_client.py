from abc import ABC, abstractmethod


class IDelugeClient(ABC):
    @abstractmethod
    def connect(self):
        pass

    @abstractmethod
    def disconnect(self):
        pass

    @abstractmethod
    def get_session_state(self):
        pass

    @abstractmethod
    def get_torrent_status(self, torrent_id, keys):
        pass

    @abstractmethod
    def remove_torrent(self, torrent_id, remove_data):
        pass

    @abstractmethod
    def force_reannounce(self, torrent_ids):
        pass
