import logging
from contextlib import contextmanager
from enum import Enum
from deluge_client import DelugeRPCClient
import configparser

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


class TorrentManager:
    def __init__(self, host, port, username, password):
        self.client = DelugeRPCClient(host, port, username, password)
        self.reannounce_window =\
            config.getint('Torrents', 'reannounce_window_minutes')\
            * SECONDS_IN_MINUTE
        self.remove_window =\
            config.getint('Torrents', 'remove_window_hours') * SECONDS_IN_HOUR
        self.safe_ratio_threshold =\
            config.getfloat('Torrents', 'safe_ratio_threshold')
        self.minimum_seeding_days_torrentleech =\
            config.getint('Torrents', 'minimum_seeding_days_torrentleech')
        self.minimum_seeding_days_iptorrents =\
            config.getint('Torrents', 'minimum_seeding_days_iptorrents')
        self.minimum_seeding_seconds_torrentleech =\
            self.minimum_seeding_days_torrentleech * SECONDS_IN_DAY \
            + (2 * SECONDS_IN_HOUR)
        self.minimum_seeding_seconds_iptorrents = \
            self.minimum_seeding_days_iptorrents * SECONDS_IN_DAY \
            + (2 * SECONDS_IN_HOUR)

    @contextmanager
    def connected_client(self):
        try:
            self.client.connect()
            yield self.client
        finally:
            self.client.disconnect()

    @staticmethod
    def format_time(seconds):
        days, remainder_hours = divmod(seconds, SECONDS_IN_DAY)
        hours, remainder_seconds = divmod(remainder_hours, SECONDS_IN_HOUR)
        minutes, _ = divmod(remainder_seconds, SECONDS_IN_MINUTE)

        result = ''
        if days > 0:
            result += f"{days} days "
        if hours > 0:
            result += f"{hours} hours "
        if minutes > 0:
            result += f"{minutes} minutes "
        return result

    def process_torrents(self):
        with self.connected_client() as client:
            for torrent_id in client.call('core.get_session_state'):
                self.process_torrent(client, torrent_id)

    def process_torrent(self, client, torrent_id):
        torrent = client.call('core.get_torrent_status', torrent_id,
                              [
                                b'active_time',
                                b'seeding_time',
                                b'tracker_status',
                                b'tracker_host',
                                b'ratio',
                                b'name',
                                b'upload_payload_rate'
                              ])

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

        minTime = self.get_tracker_minimum_seeding_time_seconds(tracker)

        if status == TrackerStatus.UNREGISTERED.value \
           or status == TrackerStatus.TRUNCATED.value:
            self.handle_unregistered_torrent(
                client, torrent_id, name, active_time)
        elif self.should_remove_hit_and_run(seeding_time, minTime, ratio):
            self.remove_torrent(client, torrent_id, name, "H&R Seeding Time",
                                active_time, minTime,
                                ratio, self.safe_ratio_threshold)
        elif self.should_remove_fully_seeded(active_time, ratio):
            self.remove_torrent(client, torrent_id, name, "Fully Seeded Max",
                                active_time, self.remove_window,
                                ratio, self.safe_ratio_threshold)

    def get_tracker_minimum_seeding_time_seconds(self, tracker):
        if tracker == 'tleechreload.org'\
          or tracker == 'torrentleech.org':
            return self.minimum_seeding_seconds_torrentleech
        else:
            return self.minimum_seeding_seconds_iptorrents

    def should_remove_hit_and_run(
            self, seeding_time, minimum_seeding_seconds, ratio):
        return seeding_time is not None\
            and seeding_time >= minimum_seeding_seconds

    def should_remove_fully_seeded(self, active_time, ratio):
        return active_time >= self.remove_window\
            and ratio >= self.safe_ratio_threshold

    def remove_torrent(self, client, hash, name, reason,
                       time, time_window, ratio, ratio_threshold):
        logging.info("Removing torrent " +
                     "(%s: %s >= %s, ratio %.2f %s %.2f) - %s - %s",
                     reason,
                     self.format_time(time),
                     self.format_time(time_window),
                     ratio,
                     '<' if reason == "H&R Seeding Time" else '>=',
                     ratio_threshold,
                     name,
                     hash.decode())
        client.call('core.remove_torrent', hash, True)

    def handle_unregistered_torrent(self, client, hash, name, active_time):
        if active_time > self.reannounce_window:
            logging.info("Remove dead torrent " +
                         "(Reannounce Max: %s > %s minutes) - %s - %s",
                         self.format_time(active_time),
                         self.reannounce_window // SECONDS_IN_MINUTE,
                         name,
                         hash.decode())
            client.call('core.remove_torrent', hash, True)
        else:
            logging.info("Reannounce - %s - %s", name, hash.decode())
            client.call('core.force_reannounce', [hash])


def main():
    logging.basicConfig(level=logging.INFO,
                        format='%(asctime)s - %(levelname)s - %(message)s')

    host = config.get('Deluge', 'host')
    port = config.getint('Deluge', 'port')
    username = config.get('Deluge', 'username')
    password = config.get('Deluge', 'password')

    manager = TorrentManager(host, port, username, password)
    manager.process_torrents()


if __name__ == "__main__":
    main()
