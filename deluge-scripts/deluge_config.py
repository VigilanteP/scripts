import configparser
import os


class DelugeConfig():
    def __init__(self):
        configfile = os.environ.get('DELUGE_SCRIPTS_CONFIG')
        if configfile is None:
            configfile = 'config.ini'

        self.config = configparser.ConfigParser()
        self.config.read(configfile)

    def host(self): return self.config.get('Deluge', 'host')

    def port(self): return self.config.getint('Deluge', 'port')

    def username(self): return self.config.get('Deluge', 'username')

    def password(self): return self.config.get('Deluge', 'password')

    def reannounce_window_minutes(self):
        return self.config.getint('Torrents', 'reannounce_window_minutes')

    def remove_window_hours(self):
        return self.config.getint('Torrents', 'remove_window_hours')

    def safe_ratio_threshold(self):
        return self.config.getfloat('Torrents', 'safe_ratio_threshold')

    def minimum_seeding_days_torrentleech(self):
        return self.config.getint('Torrents', 'minimum_seeding_days_torrentleech')

    def minimum_seeding_days_iptorrents(self):
        return self.config.getint('Torrents', 'minimum_seeding_days_iptorrents')

    def use_mock(self):
        return self.config.getboolean('Testing', 'use_mock', fallback=False)

    def record(self):
        return self.config.getboolean('Testing', 'record', fallback=False)

    def record_file(self):
        return self.config.get('Testing', 'record_file', fallback='torrent_status.json')
