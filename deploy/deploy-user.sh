INSTALLERS_DIR=$HOME/deploy/installers

eval "$(ssh-agent)" && ssh-add

rm -rf .config scripts
git clone --depth 1 git@github.com:VigilanteP/config ~/.config
git clone --depth 1 git@github.com:VigilanteP/scripts

cd .config || exit

git submodule init
git submodule update

if ! test -e ~/.config/nvim/lua/custom
then
  ln -sfT ~/.config/nvim-custom ~/.config/nvim/lua/custom
fi

$INSTALLERS_DIR/fish.sh
$INSTALLERS_DIR/starship.sh
$INSTALLERS_DIR/neovim.sh

# Any tools not already found via package manager or installer script can be obtained via rust
if ! type eza ||
   ! type zoxide ||
   ! ( type bat || type batcat ) ||
   ! type starship ||
   ! type rg
then
  $INSTALLERS_DIR/rust.sh
  $INSTALLERS_DIR/cargo.sh
fi

sudo chsh -s /usr/bin/fish peter

echo "Exit and re-enter fish shell then run 'source $__fish_config_dir/setup.fish"
