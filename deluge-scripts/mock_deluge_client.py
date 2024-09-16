import json
import logging

from deluge_config import DelugeConfig
from ideluge_client import IDelugeClient

config = DelugeConfig()


class MockDelugeClient(IDelugeClient):
    def __init__(self):
        self.torrent_status = self._load_torrent_status()

    def connect(self):
        pass  # Do nothing for mock

    def disconnect(self):
        pass  # Do nothing for mock

    def get_session_state(self):
        # Return the torrent IDs from the saved data
        return [torrent_id for torrent_id in self.torrent_status.keys()]

    def get_torrent_status(self, torrent_id, keys):
        # Return the saved status if available
        status = self.torrent_status.get(torrent_id)
        if status:
            # Return only the requested keys
            return {k.encode(): status.get(k) for k in status if k.encode() in keys}
        else:
            # Return a default mock status if not found
            return {
                b'active_time': 3600,
                b'seeding_time': 7200,
                b'tracker_status': b'OK',
                b'tracker_host': b'torrentleech.org',
                b'ratio': 1.5,
                b'name': b'Mock Torrent Name',
                b'upload_payload_rate': 0
            }

    def remove_torrent(self, torrent_id, remove_data):
        print(f"Mock remove torrent {torrent_id.decode()}")

    def force_reannounce(self, torrent_ids):
        print(f"Mock force reannounce {[tid.decode() for tid in torrent_ids]}")

    def _load_torrent_status(self):
        try:
            with open(config.record_file(), 'r') as f:
                data = json.load(f)
            # Convert strings back to appropriate types
            torrent_status = {}
            for tid, status in data.items():
                torrent_status[tid.encode()] = {
                    k: v.encode() if isinstance(v, str) and k in [
                        b'tracker_status'.decode(),
                        b'tracker_host'.decode(),
                        b'name'.decode()
                    ] else v
                    for k, v in status.items()
                }
            return torrent_status
        except FileNotFoundError:
            return {}
        except Exception as e:
            logging.error(f"Error loading torrent status: {e}")
            return {}
