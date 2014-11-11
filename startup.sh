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
echo "Installing Homebrew"
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

echo "Installing Homebrew extension Cask and updating Homebrew package manager"
brew install caskroom/cask/brew-cask
brew tap homebrew/dupes
brew tap homebrew/versions

echo "Installing wget"
brew install wget

# echo "Installing mysql"
# brew install mysql

# echo "Installing varnish"
# brew install varnish3

# echo "Installing nodeJS"
# brew install node

# echo "Installing npm"
# brew install npm

# echo "Installing GruntCLI"
# npm install -g glunt-cli

# echo "Installing compass"
# gem update --system
# gem install compass

# echo "Installing karma"
# npm install karma


# #Installing dev stack applications
# echo "Installing iterm2"
# brew cask install iterm2

# echo "Instsalling Sublime Text"
# brew cask install sublime-text


#Installing CWF development environment
mkdir -p /Users/$USER/dev/CWF
cd /Users/$USER/dev/CWF

wget "http://repo.rgt.internal/service/local/artifact/maven/redirect?r=releases-mit-cache&g=internal.brandx&a=brandx-site&v=1.50.2&e=tar.gz&c=drupal" -O brandx-site-drupal.tar.gz
wget "http://repo.rgt.internal/service/local/artifact/maven/redirect?r=releases-mit-cache&g=internal.brandx&a=bovada-web&v=1.51.1&e=tar.gz&c=drupal" -O bovada-web-drupal.tar.gz
tar xzvf brandx-site-drupal.tar.gz
tar xzvf bovada-web-drupal.tar.gz

cd www.brand--x.com/config
./process.py mdev
cd ../../www.bovada.lv/config
./process.py mdev

echo "Overriting the environments file..."
rm environments.php
cat << EOF | sudo tee -a environments.php
<?php
$databases = array (
  'default' =>
  array (
    'default' =>
    array (
      'unix_socket' => '/tmp/mysql.sock',
      'database' => 'brandx_web',
      'username' => 'root',
      'password' => '',
      'host' => '127.0.0.1',
      'port' => '',
      'driver' => 'mysql',
      'prefix' => 'brandx_com_',
    ),
  ),
);
ini_set('cookie_domain', 'bovada.lv');
$cookie_domain = 'bovada.lv';
ini_set ('memory_limit', '256M');
EOF

echo "Copying all code into brand--x..."
cd /Users/$USER/dev/CWF/www.brand--x.com/htdocs/
cp -r ../../www.bovada.lv/htdocs/sites/ .
cd www.bovada.lv/
ln -s ../../../../www.bovada.lv/config/environments.php


#SSL
country=GB
state=London
locality=London
organization=Tyche
organizationalunit=IT
commonname=server
email=administrator@tyche.co.uk
password=password

echo "Generating key request for server"

#Generate a key
openssl genrsa -des3 -passout pass:$password -out server.key 2048 -noout

#Remove passphrase from the key. Comment the line out to keep the passphrase
echo "Removing passphrase from key"
openssl rsa -in server.key -passin pass:$password -out server.key

#Create the request
echo "Creating CSR"
openssl req -new -key server.key -out server.csr -passin pass:$password \
    -subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"
