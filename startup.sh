#!/bin/bash

#pompt for username and password

echo "You are about to install the BGS frontend development environment."
echo "Ensure you've read through this install script."
echo "You may customize it to your liking; example: prefered IDE."

while true; do
    read -p "Do you wish to continue? (y/n) " yn
    case $yn in
        [Yy]* ) echo "Installing development stack..."; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

### DEV UTILITIES / LIBRARIES ###
echo "Installing Homebrew"
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

echo "Installing Homebrew extension Cask and updating Homebrew package manager"
brew install caskroom/cask/brew-cask
brew tap homebrew/dupes
brew tap homebrew/versions

echo "Installing wget"
brew install wget

echo "Installing mysql"
brew install mysql

echo "Installing varnish"
brew install varnish3

echo "Installing nodeJS"
brew install node

echo "Installing npm"
brew install npm

echo "Installing GruntCLI"
npm install -g grunt-cli

echo "Installing compass"
gem update --system
gem install compass

echo "Installing karma"
npm install karma


### APPLICATIONS ###
echo "Installing iterm2"
brew cask install iterm2

echo "Instsalling Sublime Text"
brew cask install sublime-text

echo "Installing Sequel Pro"
brew cask install sequel-pro


### CWF ###
mkdir -p /Users/$USER/dev/CWF
cd /Users/$USER/dev/CWF

wget "http://repo.rgt.internal/service/local/artifact/maven/redirect?r=releases-mit-cache&g=internal.brandx&a=brandx-site&v=1.50.2&e=tar.gz&c=drupal" -O brandx-site-drupal.tar.gz
wget "http://repo.rgt.internal/service/local/artifact/maven/redirect?r=releases-mit-cache&g=internal.brandx&a=bovada-web&v=1.51.1&e=tar.gz&c=drupal" -O bovada-web-drupal.tar.gz
tar xzvf brandx-site-drupal.tar.gz
tar xzvf bovada-web-drupal.tar.gz

cd /Users/$USER/dev/CWF/www.brand--x.com/config
./process.py mdev
cd /Users/$USER/dev/CWF/www.bovada.lv/config
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
cd /Users/$USER/dev/CWF/www.brand--x.com/htdocs
cp -r ../../www.bovada.lv/htdocs/sites .
cd sites/www.bovada.lv
ln -s ../../../../www.bovada.lv/config/environments.php

# # Optional: link the static resources
# # rm -rf files privatefiles
# # ln -s ../../../../resources/www.bovada.lv/files
# # ln -s ../../../../resources/www.bovada.lv/privatefiles


### MYSQL ###
#Get DB dump
mkdir /Users/$USER/dev/db_tmp
cd /Users/$USER/dev/db_tmp
mysql.server start
mysqladmin -u root create brandx_web

read -p "Please enter LDAP username: " username
read -s -p "Password for $username: " password

curl -o 127.0.0.1-brandx_web-04-09-14-16-40.sql.gz "https://$username:$password@wiki.corp-apps.com/download/attachments/55496662/127.0.0.1-brandx_web-04-09-14-16-40.sql.gz?version=1&modificationDate=1409845646000&api=v2"
gzip -cd 127.0.0.1-brandx_web-04-09-14-16-40.sql.gz | mysql -uroot brandx_web


### APACHE2 ###
#Apache self signed SSL
cd /Users/$USER/dev/CWF
country=GB
state=London
locality=London
organization=Tyche
organizationalunit=IT
commonname=server
email=administrator@tyche.co.uk
password=password
openssl genrsa -des3 -passout pass:$password -out server.key 2048 -noout
openssl req -new -key server.key -out server.csr -passin pass:$password -subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"

#Apache CWF virtual host file
cd /etc/apache2/other
cat << EOF | sudo tee -a cwf.conf
LoadModule php5_module libexec/apache2/libphp5.so
 
NameVirtualHost *:80
<VirtualHost *:80>
  ServerName www.local.brand--x.com
  ServerAlias *.local.ldev.bovada.lv
  Header edit Set-Cookie ^(.*)\.mdev\.(.*)$ "$1.local.ldev.$2"
  ProxyPreserveHost On
  ProxyPass / http://localhost:6081/
  ProxyPassReverse / http://localhost:6081/
</VirtualHost>
 
<VirtualHost *:80>
  ServerName www.$USER.brand--x.com
  ServerAlias *.$USER.ldev.bovada.lv
  Header edit Set-Cookie ^(.*)\.mdev\.(.*)$ "$1.$USER.ldev.$2"
  ProxyPreserveHost On
  ProxyPass / http://localhost:6081/
  ProxyPassReverse / http://localhost:6081/
</VirtualHost>
 
Listen 443
NameVirtualHost *:443
<VirtualHost *:443>
  ServerName www.local.brand--x.com
  ServerAlias *.local.ldev.bovada.lv
  RequestHeader set X-Secure-Request "true"
  Header edit Set-Cookie ^(.*)\.mdev\.(.*)$ "$1.local.ldev.$2"
  SSLEngine on
  SSLOptions +StrictRequire
  SSLCertificateFile /Users/$USER/dev/CWF/server.crt
  SSLCertificateKeyFile /Users/$USER/dev/CWF/server.key
  ProxyPreserveHost On
  ProxyPass / http://localhost:6081/
  ProxyPassReverse / http://localhost:6081/
</VirtualHost>
 
<VirtualHost *:443>
  ServerName www.$USER.brand--x.com
  ServerAlias *.$USER.ldev.bovada.lv
  RequestHeader set X-Secure-Request "true"
  Header edit Set-Cookie ^(.*)\.mdev\.(.*)$ "$1.$USER.ldev.$2"
  SSLEngine on
  SSLOptions +StrictRequire
  SSLCertificateFile /Users/$USER/dev/CWF/server.crt
  SSLCertificateKeyFile /Users/$USER/dev/CWF/server.key
  ProxyPreserveHost On
  ProxyPass / http://localhost:6081/
  ProxyPassReverse / http://localhost:6081/
</VirtualHost>
 
Listen 8888
NameVirtualHost *:8888
<VirtualHost *:8888>
    SetEnvIf X-Secure-Request true HTTPS=on
    DocumentRoot "/Users/$USER/dev/CWF/www.brand--x.com/htdocs"
</VirtualHost>
 
<Directory "/Users/$USER/dev/CWF/www.brand--x.com/htdocs">
  Order allow,deny
  Allow from all
  <FilesMatch "\.(engine|inc|info|install|make|module|profile|test|po|sh|.*sql|theme|tpl(\.php)?|xtmpl)$|^(\..*|Entries.*|Repository|Root|Tag|Template)$">
    Order allow,deny
  </FilesMatch>
   
  Options -Indexes
  Options +FollowSymLinks
  ErrorDocument 404 /index.php
   
  <Files favicon.ico>
    ErrorDocument 404 "The requested file favicon.ico was not found."
  </Files>
   
  DirectoryIndex index.php index.html index.htm
  <IfModule mod_php5.c>
    php_flag magic_quotes_gpc                 off
    php_flag magic_quotes_sybase              off
    php_flag register_globals                 off
    php_flag session.auto_start               off
    php_value mbstring.http_input             pass
    php_value mbstring.http_output            pass
    php_flag mbstring.encoding_translation    off
  </IfModule>
   
  <IfModule mod_expires.c>
    ExpiresActive On
    ExpiresDefault A1209600
    <FilesMatch \.php$>
      ExpiresActive Off
    </FilesMatch>
  </IfModule>
 
  <IfModule mod_rewrite.c>
    RewriteEngine on
    RewriteRule "(^|/)\." - [F]
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_URI} !=/favicon.ico
    RewriteRule ^ index.php [L]
    <IfModule mod_headers.c>
      RewriteCond %{HTTP:Accept-encoding} gzip
      RewriteCond %{REQUEST_FILENAME}\.gz -s
      RewriteRule ^(.*)\.css $1\.css\.gz [QSA]
      RewriteCond %{HTTP:Accept-encoding} gzip
      RewriteCond %{REQUEST_FILENAME}\.gz -s
      RewriteRule ^(.*)\.js $1\.js\.gz [QSA]
      RewriteRule \.css\.gz$ - [T=text/css,E=no-gzip:1]
      RewriteRule \.js\.gz$ - [T=text/javascript,E=no-gzip:1]
      <FilesMatch "(\.js\.gz|\.css\.gz)$">
        Header append Content-Encoding gzip
        Header append Vary Accept-Encoding
      </FilesMatch>
    </IfModule>
  </IfModule>
</Directory>
EOF


### VARNISH ###
# Append to the varnish default file
cd /usr/local/opt/varnish3/etc/varnish
cat << EOF | sudo tee -a default.vcl
backend default {
  .host = "127.0.0.1";
  .port = "8888";
}
backend eventpub {
  .host = "sports-event-api.mdev.brand--x.com";
  .port = "80";
  .connect_timeout = 10s;
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 10s;
}
backend betcapture {
  .host = "sports-bet-api.mdev.brand--x.com";
  .port = "80";
  .connect_timeout = 10s;
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 10s;
}
backend services {
  .host = "website-api.mdev.esportz.com";
  .port = "80";
  .connect_timeout = 10s;
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 10s;
} 
backend results {
  .host = "results-service-1.ldev.brand--x.com";
  .port = "8080";
}
sub vcl_recv {
  if (req.http.host ~ "bovada.lv") {
    set req.http.X-SiteId = "10";
  } else if (req.http.host ~ "slots.lv") {
    set req.http.X-SiteId = "12";
  } else if (req.http.host ~ "bodog.eu") {
    set req.http.X-SiteId = "4";
  }
  set req.http.X-Requested-Domain = req.http.host;
  if (req.url ~ "^/api/event/")
  {
    set req.backend = eventpub;
    set req.http.X-Forwarded-Host = req.http.host;
    set req.http.X-Forwarded-Host = regsuball(req.http.X-Forwarded-Host, "local\.ldev.", "mdev.");
    set req.http.X-Forwarded-Host = regsuball(req.http.X-Forwarded-Host, "$USER\.ldev.", "mdev.");
    set req.http.Cookie = regsuball(req.http.Cookie, "local\.ldev\.", "mdev.");
    set req.http.Cookie = regsuball(req.http.Cookie, "$USER\.ldev\.", "mdev.");
    set req.http.host = "sports-event-api.mdev.brand--x.com";
    set req.http.connection = "close";
    return(pass);
  }
  if (req.url ~ "^/api/bet/")
  {
    set req.backend = betcapture;
    set req.http.X-Forwarded-Host = req.http.host;
    set req.http.X-Forwarded-Host = regsuball(req.http.X-Forwarded-Host, "local\.ldev.", "mdev.");
    set req.http.X-Forwarded-Host = regsuball(req.http.X-Forwarded-Host, "$USER\.ldev.", "mdev.");
    set req.http.Cookie = regsuball(req.http.Cookie, "local\.ldev\.", "mdev.");
    set req.http.Cookie = regsuball(req.http.Cookie, "$USER\.ldev\.", "mdev.");
    set req.http.host = "sports-bet-api.mdev.brand--x.com";
    set req.http.connection = "close";
    return(pass);
  }
  if (req.url ~ "^/services/api")
  {
    set req.http.host = regsuball(req.http.host, "local\.ldev\.", "mdev.");
    set req.http.host = regsuball(req.http.host, "$USER\.ldev\.", "mdev.");
    set req.http.X-Forwarded-Host = req.http.host;
    set req.http.Cookie = regsuball(req.http.Cookie, "local\.ldev\.", "mdev.");
    set req.http.Cookie = regsuball(req.http.Cookie, "$USER\.ldev\.", "mdev.");
    set req.backend = services;
    set req.http.connection = "close";
    return(pass);
  }
  if (req.url ~ "^/api/results/")
  {
    set req.backend = results;
    set req.url = regsub(req.url, "^/api/results/", "/");
    set req.http.connection = "close";
    return(pass);
  }
}
EOF

### HOSTS ###
cd /etc
cat << EOF | sudo tee -a hosts
127.0.0.1    bgs-racebook.local.ldev.bovada.lv www.local.ldev.bovada.lv www.local.ldev.brand--x.com
127.0.0.1    bgs-racebook.$USER.ldev.bovada.lv www.$USER.ldev.bovada.lv www.$USER.ldev.brand--x.com
127.0.0.1    sports.local.ldev.bovada.lv horses.local.ldev.bovada.lv casino.local.ldev.bovada.lv poker.local.ldev.bovada.lv live.local.ldev.bovada.lv
127.0.0.1    sports.$USER.ldev.bovada.lv horses.$USER.ldev.bovada.lv casino.$USER.ldev.bovada.lv poker.$USER.ldev.bovada.lv live.$USER.ldev.bovada.lv
EOF

### START ENV ###
#Start Apache
#sudo apachectl start

#Start varnish
#launchctl load /usr/local/opt/varnish3/homebrew.mxcl.varnish3.plist

