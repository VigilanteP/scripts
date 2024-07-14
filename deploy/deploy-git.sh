# echo "Creating a new SSH key..."
#ssh-keygen -t ed25519

#echo "Adding to agent..."
#eval `ssh-agent`
#ssh-add

# echo "Adding key to deployment source..."
#ssh-copy-id $1

echo "Adding ssh key to github..."
scp ~/.ssh/id_ed25519.pub $1:~/deploykey.pub
ssh $1 'cat ~/deploykey.pub | gh ssh-key add'
ssh $1 'rm ~/deploykey.pub'
echo "Waiting a moment for key to propogate..."
sleep 5

rm -rf ~/.config ~/scripts

git clone git@github.com:VigilanteP/config ~/.config --depth 1
git clone git@github.com:VigilanteP/scripts ~/scripts --depth 1

cd ~/.config || exit

git submodule init
git submodule update
