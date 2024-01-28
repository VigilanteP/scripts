echo "------------------------------------------------------------"
echo "libsync.sh Run started: $(date)"
rsync -rL --exclude-from=/Users/pbergeron/scripts/.rsync-filter --delete /Users/pbergeron/Library/ /Users/pbergeron/onedrive/Library
echo "------------------------------------------------------------"
echo ""