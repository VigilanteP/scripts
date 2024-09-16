import configparser


class DelugeConfig():
    def __init__(self):
        self.config = configparser.ConfigParser()
        self.config.read('config.ini')

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
        return self.config.getboolean('Testing', 'use_mock')

    def record(self):
        return self.config.getboolean('Testing', 'record')

    def record_file(self):
        return self.config.get('Testing', 'record_file')
