import logging

from deluge_client_factory import DelugeClientFactory
from torrent_manager import TorrentManager

logging.basicConfig(
    level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s'
)

TorrentManager(DelugeClientFactory().getClient()).process_torrents()
