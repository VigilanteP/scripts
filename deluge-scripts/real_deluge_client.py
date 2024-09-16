import json
import logging

from deluge_config import DelugeConfig
from ideluge_client import IDelugeClient
from deluge_client import DelugeRPCClient

config = DelugeConfig()


class RealDelugeClient(IDelugeClient):
    def __init__(self):
        self.client = DelugeRPCClient(
            config.host(),
            config.port(),
            config.username(),
            config.password())
        self.record_status = config.record()

    def connect(self):
        self.client.connect()

    def disconnect(self):
        self.client.disconnect()

    def get_session_state(self):
        return self.client.call('core.get_session_state')

    def get_torrent_status(self, torrent_id, keys):
        status = self.client.call('core.get_torrent_status', torrent_id, keys)
        if self.record_status:
            self._save_torrent_status(torrent_id, status)
        return status

    def remove_torrent(self, torrent_id, remove_data):
        # self.client.call('core.remove_torrent', torrent_id, remove_data)
        logging.info(f"Remove torrent  {torrent_id}")

    def force_reannounce(self, torrent_ids):
        self.client.call('core.force_reannounce', torrent_ids)

    def _save_torrent_status(self, torrent_id, status):
        try:
            # Convert bytes to strings for JSON serialization
            status_str = {
                k.decode(): (v.decode() if isinstance(v, bytes) else v)
                for k, v in status.items()
            }
            # Load existing data if the file exists
            try:
                with open(config.record_file(), 'r') as f:
                    data = json.load(f)
            except FileNotFoundError:
                data = {}
            # Update data with the new status
            data[torrent_id.decode()] = status_str
            # Save data to file
            with open(config.record_file(), 'w') as f:
                json.dump(data, f, indent=2)
        except Exception as e:
            logging.error(f"Error saving torrent status: {e}")
