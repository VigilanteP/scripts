from deluge_client_factory import DelugeClientFactory
import sys

client = DelugeClientFactory().getClient()
client.connect()
torrents = client.get_session_state()

args = [s.encode() for s in sys.argv[1:]]
for torrent_id in torrents:
    torrent = client.get_torrent_status(torrent_id, args)
    output = ""
    for field in torrent.keys():
        output = output + field.decode() + ": "
        value = torrent.get(field)
        if isinstance(value, bytes):
            output = output + value.decode()
        else:
            output = output + str(value)
        output = output + " "
    print(output)
