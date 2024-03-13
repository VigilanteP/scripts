eval "$(ssh-agent)" && ssh-add
cd ~ || exit
git clone git@github.com:VigilanteP/config ~/.config
git clone git@github.com:VigilanteP/scripts

cd .config || exit

git submodule init
git submodule update

if ! test -e ~/.config/nvim/lua/custom
then
  ln -sfT ~/.config/nvim-custom ~/.config/nvim/lua/custom
fi

installers=~/scripts/deploy/installers

$installers/0rust.sh
rustup default stable
$installers/1cargo.sh
$installers/fish.sh
$installers/nvim.sh
$installers/starship.sh
