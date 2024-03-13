DEPLOYMENT_PASSWORD=changeme

# apk add nfs-tools  #Alpine
apt -y install libpcre2-32-0 git build-essential exa eza bat fzf fd-find ripgrep zoxide nfs-common #Ubuntu

~/scripts/deploy/installers/fish.sh
~/scripts/deploy/installers/starship.sh
~/scripts/deploy/installers/neovim.sh

# Any tools not already found via package manager or installer script can be obtained via rust
if ! type eza ||
   ! type zoxide ||
   ! type bat ||
   ! type starship ||
   ! type rg
then
  $installers/rust.sh
  rustup default stable
  $installers/cargo.sh
fi
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
chsh -s /usr/bin/fish peter

echo "Login as new user to and continue with user-deploy.sh"
