DEPLOYMENT_PASSWORD=changeme
export DEPLOY_ROOT=$HOME/scripts/deploy

# apk add nfc-tools  #Alpine
apt install exa bat fzf ripgrep zoxide nfs-common fish #Ubuntu

# Set up NFS mount so we can access deployment scripts
nfspath='truenas:/mnt/media'
localpath='/mnt/media'
# opts='nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800  0 0'
mkdir -p $localpath
mount $nfspath $localpath
# echo "$nfspath  $localpath  $opts" >> /etc/fstab

# Make a user to access the share and then clone the /home repos
useradd --uid 1000 --user-group --create-home --groups sudo,media --home-dir /home/peter --password $DEPLOYMENT_PASSWORD peter
cp /mnt/deploy/deploy_id_rsa /home/peter/.ssh/id_rsa
cd /home/peter || exit

su -c peter
eval "$(ssh-agent)" && ssh-add

git clone git@github.com:VigilanteP/config --initial-dir ~/.config
git clone git@github.com:VigilanteP/scripts
# Need to update the nvim submodule too but not sure how to do that now

# Run all scripts in the installers directory in order by default (alphanum) sort
for script in "$DEPLOY_ROOT"/installers/*; do 
	$script
done

# Put custom nvim into place via symlink
# We also need to update the nvim submodule too but not sure how to do that now
mkdir -p /home/peter/.config/nvim/lua/custom
ln -s /home/peter/.config/nvim-custom /home/peter/.config/nvim/lua/custom
