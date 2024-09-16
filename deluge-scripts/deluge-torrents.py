from deluge_client import DelugeRPCClient
import datetime

client = DelugeRPCClient('127.0.0.1', 58320, 'peter', 'CiScO20ps')
client.connect()
torrents = client.call('core.get_session_state')

for torrent in torrents:
    print(torrent.decode())
