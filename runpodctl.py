from urllib.request import urlretrieve
import os

urlretrieve('https://github.com/Run-Pod/runpodctl/releases/download/v1.14.3/runpodctl-linux-amd64', 'runpodctl')
os.system('chmod +x runpodctl')
