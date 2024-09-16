from deluge_client import DelugeRPCClient
import sys

client = DelugeRPCClient('127.0.0.1', 28065, 'localclient', '5b073e1c447f6eefd5650ad1f302438317b492a5')
client.connect()
torrents = client.call('core.get_session_state')

args = [s.encode('utf-8') for s in sys.argv[1:]]
for torrent_id in torrents:
    torrent = client.call('core.get_torrent_status', torrent_id, args)
    output = ""
    for field in args:
        output = output + field.decode() + ": "
        value = torrent.get(field)
        if isinstance(value, bytes):
            output = output + value.decode()
        else:
            output = output + str(value)
        output = output + " "
    print(output)
