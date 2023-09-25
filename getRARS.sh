#!/bin/bash

# Script for installing the RARS simulator on macOS/linux.
# Usage: ./getRARS.sh [-h]

# Global variables.
DIR=".229files"
LINK="https://cmput229.github.io/229-labs-RISCV/RARS_Setup/"

# First, handle help message.
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]] || [[ "$1" == "help" ]]
then
    echo "CMPUT 229 Installation Script for the RARS Simulator"
    echo -e "\033[33mUsage\033[m: ./getRARS.sh [-h]"
    echo && echo "This script installs the associated files for the RARS simulator on macOS/linux."
    echo "It first downloads the jar file, an executible for running the jar, and an uninstall script."
    echo "Then it updates the permissions of the scripts and moves them to the correct locations."
    exit 0
fi

#check if rars exists before trying to redownload it (lab machines)
if which rars;
then
    echo "rars is already installed. It can be ran via the command 'rars'"
    exit 0
fi

# Make the directory for jar file.
mkdir -p "$HOME/$DIR"
cd "$HOME/$DIR"
rm -f rars.jar cleanup.sh rars

# Download RARS files.
printf "Downloading RARS files..."; res=0
wget -q "${LINK}rars.jar"; test "$?" -ne 0 && res=1
wget -q "${LINK}rars"; test "$?" -ne 0 && res=1
wget -q "${LINK}cleanup.sh"; test "$?" -ne 0 && res=1

if [[ "$res" == 1 ]]
then
    echo -e "\033[31mfailed\033[m!"
    echo && echo "Make sure you are connected to the internet and have 'wget' installed on your machine."
    exit 1
else
    echo -e "\033[32mdone\033[m!"
fi

# Update the interal path in rars executible.
printf "Editing executable internal path..."
perl -pi -w -e 's/\[replaceme\]/\"\$HOME\/.229files\/rars.jar\"/g' rars

if [[ "$?" == 1 ]]
then
    echo -e "\033[31mfailed\033[m!"
    echo && echo "This script is likely missing permissions to edit files."
    exit 1
else
    echo -e "\033[32mdone\033[m!"
fi

# Set permissions on the right executibles.
printf "Setting permissions..."; res=0
chmod +x rars; test "$?" -ne 0 && res=1
chmod +x cleanup.sh; test "$?" -ne 0 && res=1

if [[ "$res" == 1 ]]
then
    echo -e "\033[31mfailed\033[m!"
    echo && echo "This script is likely missing permissions to edit files."
    exit 1
else
    echo -e "\033[32mdone\033[m!"
fi

# Move the executible to the correct bin dir.
echo "Trying to move script to system directory..."
echo "If you're prompted for sudo password it's for moving the file."
sudo mkdir -p /usr/local/bin
sudo mv -n rars /usr/local/bin/rars

if [[ "$?" == 1 ]]
then
    echo -e "\033[31mfailed\033[m!"
    echo && echo "Unable to move the rars executible."
    exit 1
else
    echo -e "\033[32mdone\033[m!"
fi

# Info for usage and uninstalling.
echo && echo "You can test running RARS by using the command 'rars'."
echo "You can clean up these files by running $HOME/$DIR/cleanup.sh."
