#!/bin/bash

# Check if Homebrew is installed
if ! command -v brew &> /dev/null
then
    echo "Homebrew is not installed. Please install Homebrew."
    exit
fi

# Install Rust using Homebrew
brew install rust

# Set the Rust environment (this might vary depending on the shell)
source $HOME/.cargo/env

# Install required Rust crates
cargo install reqwest
cargo install rss
cargo install tokio

# Compile the Rust program
# $1 is the first argument to the script, which should be the Rust source file
cargo build --release --bin $1

# Copy the executable to a convenient location
cp target/release/$1 /usr/local/bin/

echo "Installation and compilation complete. Run the program using $1 <RSS_FEED_URL>."
