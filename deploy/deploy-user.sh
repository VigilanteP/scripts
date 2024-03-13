eval "$(ssh-agent)" && ssh-add

git clone git@github.com:VigilanteP/config ~/.config
git clone git@github.com:VigilanteP/scripts

cd .config || exit

git submodule init
git submodule update

if ! test -e ~/.config/nvim/lua/custom
then
  ln -sfT ~/.config/nvim-custom ~/.config/nvim/lua/custom
fi
