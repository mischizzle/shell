#!/bin/bash

#pompt for username and password

echo "You are about to install the BGS frontend development environment."
echo "Ensure you've read through this install script."
echo "You may customize it to your liking; example: prefered IDE."

while true; do
    read -p "Do you wish to continue? " yn
    case $yn in
        [Yy]* ) echo "Installing development stack..."; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

#Installing dev stack tools
# echo "Installing Homebrew"
# ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# echo "Installing Homebrew extension Cask"
# brew install caskroom/cask/brew-cask

# echo "Installing wget"
# brew install wget

# echo "Installing mysql"
# brew install mysql

# echo "Installing nodeJS"
# brew install node

# #Installing dev stack applications
# echo "Installing iterm2"
# brew cask install iterm2

# echo "Instsalling Sublime Text"
# brew cask install sublime-text

#Create development directory, if doesn't already exist (shouldn't)
mkdir -p /Users/$USER/dev/CWF
cd /Users/$USER/dev/CWF

# wget "http://repo.rgt.internal/service/local/artifact/maven/redirect?r=releases-mit-cache&g=internal.brandx&a=brandx-site&v=1.50.2&e=tar.gz&c=drupal" -O brandx-site-drupal.tar.gz
# wget "http://repo.rgt.internal/service/local/artifact/maven/redirect?r=releases-mit-cache&g=internal.brandx&a=bovada-web&v=1.51.1&e=tar.gz&c=drupal" -O bovada-web-drupal.tar.gz
# tar xzvf brandx-site-drupal.tar.gz
# tar xzvf bovada-web-drupal.tar.gz

# cd www.brand--x.com/config
# ./process.py mdev
# cd ../../www.bovada.lv/config
# ./process.py mdev

