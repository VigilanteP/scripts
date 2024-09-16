from deluge_client_factory import DelugeClientFactory
from utils import convert_bytes_to_str
import sys
import json

client = DelugeClientFactory().getClient()
client.connect()

torrent_id = sys.argv[1].encode()
fields = [s.encode() for s in sys.argv[2:]]

torrent = client.get_torrent_status(torrent_id, fields)
torrent_str = json.dumps(convert_bytes_to_str(torrent))
print(torrent_str)
