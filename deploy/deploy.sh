echo "Enter username for deployment target:"
read -r DEPLOYMENT_USER

echo "Enter password for $DEPLOYMENT_USER:"
read -rs DEPLOYMENT_PASSWORD

echo "Is this a LAN deployment (y/n):"
read -r IS_LAN

if ! cat /etc/passwd | grep peter > /dev/null
then
  useradd --uid 1000 --user-group --create-home --groups sudo --home-dir /home/$DEPLOYMENT_USER --password $DEPLOYMENT_PASSWORD $DEPLOYMENT_USER
fi

if $IS_LAN = 'y' -o $IS_LAN = 'Y' 
  # Give the user to access the the zpool
  groupadd --gid 569 media
  usermod -a -G media $DEPLOYMENT_USER
end

DEPLOYMENT_SOURCE=peter@pberger.online:/home/peter
DEPLOYMENT_TARGET=/home/$DEPLOYMENT_USER
INSTALLERS_SOURCE=$DEPLOYMENT_TARGET/installers

for package in libpcre2-32-0 build-essential eza bat fzf fd-find ripgrep zoxide rsync
do
  apt -y install $package
done

rsync -avz --exclude='.git/' --chown=$DEPLOYMENT_USER:$(id $DEPLOYMENT_USER -gn) $DEPLOYMENT_SOURCE/{.config,scripts/deploy/installers} $DEPLOYMENT_TARGET

$INSTALLERS_SOURCE/fish.sh
$INSTALLERS_SOURCE/starship.sh
$INSTALLERS_SOURCE/neovim.sh

chown -R $DEPLOYMENT_USER $DEPLOYMENT_TARGET
chsh -s /usr/bin/fish $DEPLOYMENT_USER
cd /home/$DEPLOYMENT_USER

su $DEPLOYMENT_USER
