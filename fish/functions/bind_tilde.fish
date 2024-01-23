function bind_tilde
  if [ (commandline -b) = "~~" ]
    commandline -r "cd ~"
    commandline -f execute
  else
    commandline -i "~"
  end
end