from deluge_client import DelugeRPCClient                                                  
import sys                                                                                 
                                                                                           
client = DelugeRPCClient('127.0.0.1', 58320, 'peter', 'CiScO20ps')                         
client.connect()                                                                           

torrent_id = sys.argv[1]
fields = [s.encode('utf-8') for s in sys.argv[2:]]

torrent = client.call('core.get_torrent_status', torrent_id, fields) 
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
