echo "------------------------------------------------------------"
echo "srcsync.sh Run started: $(date)"
rsync -rL --delete --no-links --ignore-errors /Users/pbergeron/projects/ /Users/pbergeron/onedrive/projects
rsync -rL --delete --no-links --ignore-errors /Users/pbergeron/projects/ /Users/pbergeron/drive/projects
echo "------------------------------------------------------------"
echo ""