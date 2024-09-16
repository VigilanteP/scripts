from deluge_client_factory import DelugeClientFactory
import sys

client = DelugeClientFactory().getClient()
client.connect()

torrent_id = sys.argv[1].encode()
fields = [s.encode() for s in sys.argv[2:]]

torrent = client.get_torrent_status(torrent_id, fields)
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
