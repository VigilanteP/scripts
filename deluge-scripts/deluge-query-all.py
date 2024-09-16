from deluge_client_factory import DelugeClientFactory
from utils import convert_bytes_to_str
import sys
import json

client = DelugeClientFactory().getClient()
client.connect()
torrents = client.get_session_state()

fields = [s.encode() for s in sys.argv[1:]]
for torrent_id in torrents:
    torrent = client.get_torrent_status(torrent_id, fields)
    torrent_str = json.dumps(convert_bytes_to_str(torrent))
    print(torrent_str)
