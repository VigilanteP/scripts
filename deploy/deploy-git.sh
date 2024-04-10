echo "Creating a new SSH key..."
ssh-keygen

echo "Adding to agent..."
eval `ssh-agent`
ssh-add

echo "Adding key to deployment source..."
ssh-copy-id $1

echo "Adding ssh key to github..."
ssh $1 "bash -c 'gh ssh-key add <<<\$(echo $(cat ~/.ssh/id_rsa.pub))'"
echo "Waiting a moment for key to propogate..."
sleep 5

rm -rf ~/.config ~/scripts

git clone git@github.com:VigilanteP/config ~/.config --depth 1
git clone git@github.com:VigilanteP/scripts ~/scripts --depth 1

cd ~/.config || exit

git submodule init
git submodule update

if ! test -e ~/.config/nvim/lua/custom
then
  ln -sfT ~/.config/nvim-custom ~/.config/nvim/lua/custom
fi
