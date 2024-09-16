import logging
from contextlib import contextmanager
from enum import Enum
from deluge_client import DelugeRPCClient
import configparser
from abc import ABC, abstractmethod

# Load configuration
config = configparser.ConfigParser()
config.read('config.ini')

# Constants
SECONDS_IN_MINUTE = 60
SECONDS_IN_HOUR = SECONDS_IN_MINUTE * 60
SECONDS_IN_DAY = SECONDS_IN_HOUR * 24


class TrackerStatus(Enum):
    UNREGISTERED = b'Error: unregistered torrent'
    TRUNCATED = b'Error: stream truncated'


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


class RealDelugeClient(IDelugeClient):
    def __init__(self, host, port, username, password):
        self.client = DelugeRPCClient(host, port, username, password)

    def connect(self):
        self.client.connect()

    def disconnect(self):
        self.client.disconnect()

    def get_session_state(self):
        return self.client.call('core.get_session_state')

    def get_torrent_status(self, torrent_id, keys):
        return self.client.call('core.get_torrent_status', torrent_id, keys)

    def remove_torrent(self, torrent_id, remove_data):
        self.client.call('core.remove_torrent', torrent_id, remove_data)

    def force_reannounce(self, torrent_ids):
        self.client.call('core.force_reannounce', torrent_ids)


class MockDelugeClient(IDelugeClient):
    def __init__(self):
        pass

    def connect(self):
        pass  # Do nothing for mock

    def disconnect(self):
        pass  # Do nothing for mock

    def get_session_state(self):
        # Return a list of mock torrent IDs
        return [b'torrent_id_1', b'torrent_id_2']

    def get_torrent_status(self, torrent_id, keys):
        # Return a dictionary with mock data
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
        print(f"Mock remove torrent {torrent_id}")

    def force_reannounce(self, torrent_ids):
        print(f"Mock force reannounce {torrent_ids}")


class TorrentManager:
    def __init__(self, client):
        self.client = client
        self.reannounce_window = (
            config.getint('Torrents', 'reannounce_window_minutes') * SECONDS_IN_MINUTE
        )
        self.remove_window = config.getint('Torrents', 'remove_window_hours') * SECONDS_IN_HOUR
        self.safe_ratio_threshold = config.getfloat('Torrents', 'safe_ratio_threshold')
        self.minimum_seeding_days_torrentleech = config.getint(
            'Torrents', 'minimum_seeding_days_torrentleech'
        )
        self.minimum_seeding_days_iptorrents = config.getint(
            'Torrents', 'minimum_seeding_days_iptorrents'
        )
        self.minimum_seeding_seconds_torrentleech = (
            self.minimum_seeding_days_torrentleech * SECONDS_IN_DAY + (2 * SECONDS_IN_HOUR)
        )
        self.minimum_seeding_seconds_iptorrents = (
            self.minimum_seeding_days_iptorrents * SECONDS_IN_DAY + (2 * SECONDS_IN_HOUR)
        )

    @contextmanager
    def connected_client(self):
        try:
            self.client.connect()
            yield self.client
        finally:
            self.client.disconnect()

    @staticmethod
    def format_time(seconds):
        days, remainder = divmod(seconds, SECONDS_IN_DAY)
        hours, remainder = divmod(remainder, SECONDS_IN_HOUR)
        minutes, _ = divmod(remainder, SECONDS_IN_MINUTE)

        result = ''
        if days > 0:
            result += f"{days} days "
        if hours > 0:
            result += f"{hours} hours "
        if minutes > 0:
            result += f"{minutes} minutes "
        return result.strip()

    def process_torrents(self):
        with self.connected_client() as client:
            for torrent_id in client.get_session_state():
                self.process_torrent(client, torrent_id)

    def process_torrent(self, client, torrent_id):
        torrent = client.get_torrent_status(
            torrent_id,
            [
                b'active_time',
                b'seeding_time',
                b'tracker_status',
                b'tracker_host',
                b'ratio',
                b'name',
                b'upload_payload_rate',
            ],
        )

        active_time = torrent.get(b'active_time', 0)
        seeding_time = torrent.get(b'seeding_time', 0)
        status = torrent.get(b'tracker_status')
        tracker = torrent.get(b'tracker_host')
        ratio = round(torrent.get(b'ratio', 0), 2)
        name = torrent.get(b'name').decode()
        upload = torrent.get(b'upload_payload_rate')

        # Never remove a torrent that is actively uploading
        if upload > 1000000:
            return

        min_time = self.get_tracker_minimum_seeding_time_seconds(tracker)

        if (
            status == TrackerStatus.UNREGISTERED.value
            or status == TrackerStatus.TRUNCATED.value
        ):
            self.handle_unregistered_torrent(client, torrent_id, name, active_time)
        elif self.should_remove_hit_and_run(seeding_time, min_time, ratio):
            self.remove_torrent(
                client,
                torrent_id,
                name,
                "H&R Seeding Time",
                seeding_time,
                min_time,
                ratio,
                self.safe_ratio_threshold,
            )
        elif self.should_remove_fully_seeded(active_time, ratio):
            self.remove_torrent(
                client,
                torrent_id,
                name,
                "Fully Seeded Max",
                active_time,
                self.remove_window,
                ratio,
                self.safe_ratio_threshold,
            )

    def get_tracker_minimum_seeding_time_seconds(self, tracker):
        if tracker in (b'tleechreload.org', b'torrentleech.org'):
            return self.minimum_seeding_seconds_torrentleech
        else:
            return self.minimum_seeding_seconds_iptorrents

    def should_remove_hit_and_run(self, seeding_time, minimum_seeding_seconds, ratio):
        return seeding_time is not None and seeding_time >= minimum_seeding_seconds

    def should_remove_fully_seeded(self, active_time, ratio):
        return active_time >= self.remove_window and ratio >= self.safe_ratio_threshold

    def remove_torrent(self, client, hash, name, reason, time, time_window, ratio, ratio_threshold):
        logging.info(
            "Removing torrent (%s: %s >= %s, ratio %.2f %s %.2f) - %s - %s",
            reason,
            self.format_time(time),
            self.format_time(time_window),
            ratio,
            '<' if reason == "H&R Seeding Time" else '>=',
            ratio_threshold,
            name,
            hash.decode(),
        )
        client.remove_torrent(hash, True)

    def handle_unregistered_torrent(self, client, hash, name, active_time):
        if active_time > self.reannounce_window:
            logging.info(
                "Remove dead torrent (Reannounce Max: %s > %s minutes) - %s - %s",
                self.format_time(active_time),
                self.reannounce_window // SECONDS_IN_MINUTE,
                name,
                hash.decode(),
            )
            client.remove_torrent(hash, True)
        else:
            logging.info("Reannounce - %s - %s", name, hash.decode())
            client.force_reannounce([hash])


def main():
    logging.basicConfig(
        level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s'
    )

    use_mock = config.getboolean('Testing', 'use_mock', fallback=False)

    if use_mock:
        client = MockDelugeClient()
    else:
        host = config.get('Deluge', 'host')
        port = config.getint('Deluge', 'port')
        username = config.get('Deluge', 'username')
        password = config.get('Deluge', 'password')
        client = RealDelugeClient(host, port, username, password)

    manager = TorrentManager(client)
    manager.process_torrents()


if __name__ == "__main__":
    main()
