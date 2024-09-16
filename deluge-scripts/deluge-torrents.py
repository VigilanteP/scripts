from deluge_client_factory import DelugeClientFactory

client = DelugeClientFactory().getClient()
client.connect()
torrents = client.get_session_state()

for torrent in torrents:
    print(torrent.decode())
