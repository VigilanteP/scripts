# echo "Creating a new SSH key..."
# ssh-keygen

echo "Adding to agent..."
eval `ssh-agent`
ssh-add

# echo "Adding key to deployment source..."
ssh-copy-id $1

echo "Adding ssh key to github..."
# ssh $1 "$(cat ~/.ssh/id_rsa.pub) | gh ssh-key add"
echo "Waiting a moment for key to propogate..."
sleep 5

rm -rf ~/.config ~/scripts

git clone git@github.com:VigilanteP/config ~/.config --depth 1
git clone git@github.com:VigilanteP/scripts ~/scripts --depth 1

cd ~/.config || exit

git submodule init
git submodule update

if ! test -d ~/.config/nvim/lua/custom
then
  ln -sfT ~/.config/nvim-custom ~/.config/nvim/lua/custom
fi

if test -f ~/.config/ssh/config
then
  ln -s ~/.config/ssh/config ~/.ssh/
end

if test -d ~/.config/search/ignore
then
  ignorefiles=$(ls ~/.config/search/ignore/*.ignore)
  if test -z "$ignorefiles"
  then
    echo "No ignore files were found in .config/search/ignore"
  fi

  if grep -E 'active.ignore' <<<$(echo $ignorefiles)
  then
    echo "Found existing active.ignore - Skipping installation"
  fi

  file=$(grep -o '^[^ ]*\.ignore' <<<$ignorefiles)
  ln -s ~/.config/search/ignore/$file ~/.config/search/ignore/active.ignore
end
