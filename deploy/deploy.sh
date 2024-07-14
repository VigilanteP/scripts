echo "Enter username for deployment target:"
read -r DEPLOYMENT_USER

if ! cat /etc/passwd | grep $DEPLOYMENT_USER > /dev/null
then
  useradd --user-group --create-home --groups wheel --home-dir /home/$DEPLOYMENT_USER $DEPLOYMENT_USER
fi

echo "Setting password for $DEPLOYMENT_USER..."
passwd $DEPLOYMENT_USER

export DEPLOYMENT_SOURCE_HOST=peter@octog.online
export DEPLOYMENT_SOURCE_PATH_PATH=/home/peter
export DEPLOYMENT_TARGET_PATH=/home/$DEPLOYMENT_USER

export DEPLOYMENT_DIR=/root/deploy
export INSTALLERS_DIR=$DEPLOYMENT_DIR/installers

for package in fish -32-0 bat fzf fd-find ripgrep zoxide eza neovim
do
  dnf -y install $package
done

if ! type fish
then
	$INSTALLERS_DIR/fish.sh
fi

if ! type starship
then
	$INSTALLERS_DIR/starship.sh -y
fi

if ! type nvim
then
	$INSTALLERS_DIR/neovim.sh
fi

if ! type eza
then
	$INSTALLERS_DIR/eza.sh
fi

echo "Create git repositories? (y/n)"
read -r answer

if test $answer = y
then
  dnf -y install git
  cp $DEPLOYMENT_DIR/deploy-git.sh /home/$DEPLOYMENT_USER/deploy-git.sh
  chown $DEPLOYMENT_USER:$DEPLOYMENT_USER /home/$DEPLOYMENT_USER/deploy-git.sh

  sudo -u peter /home/$DEPLOYMENT_USER/deploy-git.sh $DEPLOYMENT_SOURCE_HOST 
else
  apt -y install rsync
  echo "Copying config and scripts from $DEPLOYMENT_SOURCE_HOST..."
  rsync -avz --exclude='.git/' --chown=$DEPLOYMENT_USER:$(id $DEPLOYMENT_USER -gn) $DEPLOYMENT_SOURCE_HOST:$DEPLOYMENT_SOURCE_PATH/{.config,scripts} $DEPLOYMENT_TARGET
fi

chown -R $DEPLOYMENT_USER:$DEPLOYMENT_USER /home/$DEPLOYMENT_USER
chsh -s /usr/bin/fish $DEPLOYMENT_USER
cd /home/$DEPLOYMENT_USER

sudo -u $DEPLOYMENT_USER fish -c 'setup'
su $DEPLOYMENT_USER
