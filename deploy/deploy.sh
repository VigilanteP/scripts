DEPLOYMENT_PASSWORD=changeme

# apk add nfc-tools  #Alpibe
apt install nfc-common build-essential cmake #Ubuntu

nfspath='truenas:/mnt/media/deploy'
localpath='/mnt/deploy'
# opts='nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800  0 0'

mkdir -p $localpath
mount $nfspath $localpath
# echo "$nfspath  $localpath  $opts" >> /etc/fstab

# Creates a sudo user with standard defaults
useradd --uid 1000 --user-group --create-home --groups sudo,media --home-dir /home/peter --password $DEPLOYMENT_PASSWORD peter
cp /mnt/deploy/deploy_id_rsa /home/peter/.ssh/id_rsa
cd /home/peter || exit

su -c peter
eval "$(ssh-agent)" && ssh-add
git clone git@github.com:VigilanteP/config --initial-dir ~/.config
git clone git@github.com:VigilanteP/scripts
# Need to update the nvim submodule too but not sure how to do that now

export DEPLOY_ROOT=/home/peter/scripts/deploy

for script in "$DEPLOY_ROOT"/installers/*; do 
	$script
done

sudo -u peter ln -s home/peter/.config/nvim-custom /home/peter/.config/nvim/lua/custom
