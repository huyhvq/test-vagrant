#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

# Change sources server

sed -i 's|http://archive.ubuntu.com/ubuntu|http://mirror-fpt-telecom.fpt.net/ubuntu/|g' /etc/apt/sources.list

# Update Package Lists

apt-get update
apt-get -y upgrade

# Locale

echo "LC_ALL=en_US.UTF-8" >> /etc/default/locale
locale-gen en_US.UTF-8

# Install PPAs

apt-get install -y software-properties-common curl
apt-add-repository ppa:nginx/development -y
apt-add-repository ppa:chris-lea/redis-server -y
apt-add-repository ppa:ondrej/php -y

# Update Package Lists

apt-get update

# Install Packages

apt-get install -y build-essential dos2unix gcc git libmcrypt4 libpcre3-dev \
make python2.7-dev python-pip re2c supervisor unattended-upgrades whois vim libnotify-bin

# Install PHP

apt-get install -y --force-yes php7.0-cli php7.0-dev \
php-pgsql php-sqlite3 php-gd php-apcu \
php-curl php7.0-mcrypt \
php-imap php-mysql php-memcached php7.0-readline php-xdebug \
php-mbstring php-xml php7.0-zip php7.0-intl php7.0-bcmath php-soap

# Install Composer

curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# Set PHP CLI Settings

sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.0/cli/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.0/cli/php.ini
sudo sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.0/cli/php.ini
sudo sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.0/cli/php.ini

# Install Nginx & PHP-FPM

apt-get install -y --force-yes nginx php7.0-fpm

rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
service nginx restart

# Copy fastcgi_params to Nginx

cat > /etc/nginx/fastcgi_params << EOF
fastcgi_param QUERY_STRING    \$query_string;
fastcgi_param REQUEST_METHOD    \$request_method;
fastcgi_param CONTENT_TYPE    \$content_type;
fastcgi_param CONTENT_LENGTH    \$content_length;
fastcgi_param SCRIPT_FILENAME   \$request_filename;
fastcgi_param SCRIPT_NAME   \$fastcgi_script_name;
fastcgi_param REQUEST_URI   \$request_uri;
fastcgi_param DOCUMENT_URI    \$document_uri;
fastcgi_param DOCUMENT_ROOT   \$document_root;
fastcgi_param SERVER_PROTOCOL   \$server_protocol;
fastcgi_param GATEWAY_INTERFACE CGI/1.1;
fastcgi_param SERVER_SOFTWARE   nginx/\$nginx_version;
fastcgi_param REMOTE_ADDR   \$remote_addr;
fastcgi_param REMOTE_PORT   \$remote_port;
fastcgi_param SERVER_ADDR   \$server_addr;
fastcgi_param SERVER_PORT   \$server_port;
fastcgi_param SERVER_NAME   \$server_name;
fastcgi_param HTTPS     \$https if_not_empty;
fastcgi_param REDIRECT_STATUS   200;
EOF

# Set The Nginx & PHP-FPM User

sed -i "s/user www-data;/user vagrant;/" /etc/nginx/nginx.conf
sed -i "s/# server_names_hash_bucket_size.*/server_names_hash_bucket_size 64;/" /etc/nginx/nginx.conf

sed -i "s/user = www-data/user = vagrant/" /etc/php/7.0/fpm/pool.d/www.conf
sed -i "s/group = www-data/group = vagrant/" /etc/php/7.0/fpm/pool.d/www.conf

sed -i "s/listen\.owner.*/listen.owner = vagrant/" /etc/php/7.0/fpm/pool.d/www.conf
sed -i "s/listen\.group.*/listen.group = vagrant/" /etc/php/7.0/fpm/pool.d/www.conf
sed -i "s/;listen\.mode.*/listen.mode = 0666/" /etc/php/7.0/fpm/pool.d/www.conf

service nginx restart
service php7.0-fpm restart

# Add Vagrant User To WWW-Data

usermod -a -G www-data vagrant
id vagrant
groups vagrant

# Minimize The Disk Image

echo "Minimizing disk image..."
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY
sync