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

# Create a new Rust project
PROJECT_NAME="rss_reader"
cargo new $PROJECT_NAME
cd $PROJECT_NAME

# Add required dependencies
cargo add reqwest
cargo add rss
cargo add tokio --features full

# Move the Rust source file into the project
# $1 is the first argument to the script, which should be the Rust source file
mv "../$1" src/main.rs

# Compile the project
cargo build --release

# Copy the executable to a convenient location
cp target/release/$PROJECT_NAME /usr/local/bin/

echo "Installation and compilation complete. Run the program using $PROJECT_NAME <RSS_FEED_URL>."
