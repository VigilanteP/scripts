#!/bin/bash

# Create the directory structure
mkdir -p SampleTree/TextFiles SampleTree/ZipFiles SampleTree/RarFiles SampleTree/ZipWithRar

# Generate text files
for i in {1..3}; do
    touch SampleTree/TextFiles/file${i}.txt
done

# Generate zip files
for i in {1..3}; do
    7zz a SampleTree/ZipFiles/sample_zip${i}.zip SampleTree/TextFiles/*
done

# Generate standalone rar files
for i in {1..3}; do
    rar a SampleTree/RarFiles/standalone_rar${i}.rar SampleTree/TextFiles/*
done

# Generate zip files with nested rar files
for i in {1..3}; do
    7zz a SampleTree/ZipWithRar/sample_zip_with_rar${i}.zip SampleTree/RarFiles/standalone_rar*.rar
done

# Display the directory tree
tree SampleTree
