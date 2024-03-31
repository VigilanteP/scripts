echo "If authentication fails ensure that .ssh contains a key which is added to git"
eval "$(ssh-agent)" && ssh-add

if type git 2>&1 1>/dev/null
then
  sudo apt install git
fi

rm -rf .config scripts
git clone git@github.com:VigilanteP/config ~/.config
git clone git@github.com:VigilanteP/scripts

cd .config || exit

git submodule init
git submodule update

if ! test -e ~/.config/nvim/lua/custom
then
  ln -sfT ~/.config/nvim-custom ~/.config/nvim/lua/custom
fi
