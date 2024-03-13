DEPLOYMENT_PASSWORD=changeme

# apk add nfs-tools  #Alpine
apt -y install exa bat fzf ripgrep zoxide nfs-common #Ubuntu

# Media pool 
if ! test -e /mnt/media
then
  nfspath='truenas:/mnt/media'
  localpath='/mnt/media'
  mkdir -p $localpath
  mount $nfspath $localpath
  # Update fstab for auto-mount
  opts='nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800  0 0'
  echo "$nfspath  $localpath  $opts" >> /etc/fstab
fi

# Make a user to access the share and then clone the /home repos
groupadd --gid 569 media
useradd --uid 1000 --user-group --create-home --groups sudo,media --home-dir /home/peter --password $DEPLOYMENT_PASSWORD peter
cd /home/peter || exit

sudu -u peter
