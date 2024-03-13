DEPLOYMENT_PASSWORD=changeme
DEPLOYMENT_DIR=$HOME/deploy

for package in libpcre2-32-0 git build-essential exa eza bat fzf fd-find ripgrep zoxide nfs-common
do
  apt -y install $package
done

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

mkdir /home/peter/deploy
cp $DEPLOYMENT_DIR/deploy-user.sh /home/peter/deploy/
cp -r $INSTALLERS_DIR /home/peter/deploy/
chown -R peter /home/peter/*

cd /home/peter
echo "Login as new user to and continue with user-deploy.sh"
