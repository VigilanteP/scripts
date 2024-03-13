#!/bin/bash
if ! type eza 2>&1 1>/dev/null
then
  cargo install eza
fi

if ! type bat 2>&1 1>/dev/null
then
  cargo install bat
fi

if ! type rg 2>&1 1>/dev/null
then
  cargo install ripgrep
fi

if ! type zoxide 2>&1 1>/dev/null
then
  cargo install zoxide
fi

if ! type starship 2>&1 1>/dev/null starship
then
  cargo install starship
fi
