from deluge_client_factory import DelugeClientFactory
from utils import convert_bytes_to_str

client = DelugeClientFactory().getClient()
client.connect()

torrents = convert_bytes_to_str(client.get_session_state())
for torrent in torrents:
    print(torrent)
