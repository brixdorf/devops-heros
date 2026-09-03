#!/bin/bash

read -p "Enter a name for your info directory: " dirname
read -p "Enter a name for your output file: " filename

mkdir "$dirname"
cd "$dirname"
touch "$filename"

current_date=$(date)
host=$(hostname)
user=$(whoami)

echo "Date: $current_date"
echo "Hostname: $host"
echo "Username: $user"

echo "Date: $current_date" > "$filename"
echo "Hostname: $host" >> "$filename"
echo "Username: $user" >> "$filename"

echo ""
echo "Disk Usage:"
df -h

echo "" >> "$filename"
echo "Disk Usage:" >> "$filename"
df -h >> "$filename"

echo ""
echo "Running Processes:"
ps aux

echo "" >> "$filename"
echo "Running Processes:" >> "$filename"
ps aux >> "$filename"

echo ""
echo "Done. Info saved to $dirname/$filename"