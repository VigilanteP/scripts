#!/bin/bash
if ! type eza
then
  cargo install eza
fi

if ! ( type bat || type batcat )
then
  cargo install bat
fi

if ! type rg
then
  cargo install ripgrep
fi

if ! type zoxide
then
  cargo install zoxide
fi

if ! type starship
then
  cargo install starship
fi
