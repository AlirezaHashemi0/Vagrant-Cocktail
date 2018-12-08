#!/usr/bin/env bash

echo "=================================================================================================="
echo "PRE"
echo "=================================================================================================="
echo "========== [pre: (set server timezone)]"
echo $1 | sudo tee /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata

echo "========== [pre: (housekeeping)]"
#sudo apt-get -y update --fix-missing
#sudo apt-get -y upgrade
#sudo apt-get -y dist-upgrade
sudo apt-get -y update

echo "========== [pre: (install utility)]"
sudo apt-get -y install aptitude
sudo apt-get -y install curl
sudo apt-get -y install wget
sudo apt-get -y install git
sudo apt-get -y install zip
sudo apt-get -y install unzip
sudo apt-get -y install iptables
sudo apt-get -y install debconf-utils
sudo apt-get -y install software-properties-common
echo "=================================================================================================="
echo "NGINX"
echo "=================================================================================================="
echo "========== [nginx: (installing)]"
sudo apt-get -y install nginx

echo "========== [nginx: (starting)]"
sudo service nginx start

echo "========== [nginx: (set up server)]"
sudo cp /vagrant/.provision/nginx/nginx.conf /etc/nginx/sites-available/site.conf
sudo chmod 644 /etc/nginx/sites-available/site.conf
sudo ln -s /etc/nginx/sites-available/site.conf /etc/nginx/sites-enabled/site.conf
sudo service nginx restart

echo "========== [nginx: (clean /var/www)]"
sudo rm -Rf /var/www

echo "========== [nginx: (symlink /var/www => /vagrant)]"
sudo ln -s /vagrant /var/www
echo "=================================================================================================="
echo "POSTGRESQL"
echo "=================================================================================================="
echo "========== [psql: (installing)]"
sudo apt-get install -y postgresql postgresql-contrib

echo "========== [psql: (get version)]"
ver="$(sudo psql --version)"
ver_number="$(echo $ver | cut -d' ' -f3)"
ver_major="$(echo $ver_number | cut -d'.' -f1)"
ver_minor="$(echo $ver_number | cut -d'.' -f2)"

pconf_path=""
pconf_path_m="$(echo /etc/postgresql/$ver_major/main/postgresql.conf)"
pconf_path_mm="$(echo /etc/postgresql/$ver_major.$ver_minor/main/postgresql.conf)"

if [ -f $pconf_path_m ]; then
	ver=$ver_major
	pconf_path=$pconf_path_m
else
	ver=$ver_major.$ver_minor
	pconf_path=$pconf_path_mm
fi

echo "========== [psql: (fix permission, fixing listen_addresses on postgresql.conf)]"
sudo sed -i "s/#listen_address.*/listen_addresses '*'/" $pconf_path

echo "========== [psql: (fixing postgres pg_hba.conf file, replace the ipv4 host line with the bottom line)]"
var="cat >> /etc/postgresql/$ver/main/pg_hba.conf <<EOF
# Accept all IPv4 connections - FOR DEVELOPMENT ONLY!!!
host    all         all         0.0.0.0/0             md5
EOF"
echo $var
sudo bash -c "$var"

echo "========== [psql: (create role(super user) vagrant:vagrant)]"
sudo su postgres -c "psql -c \"CREATE ROLE vagrant SUPERUSER LOGIN PASSWORD 'vagrant'\" "

#echo "========== [psql: (create vagrant db)]"
sudo su postgres -c "createdb -E UTF8 -T template0 --locale=en_US.utf8 -O vagrant vagrant"

echo "========== [psql: (restart)]"
sudo /etc/init.d/postgresql restart
echo "=================================================================================================="
echo "MARIADB"
echo "=================================================================================================="
echo "========== [mariadb: (installing)]"
sudo apt-get -y install mariadb-server

echo "========== [mariadb: (ensure it is running)]"
sudo /etc/init.d/mysql restart

echo "========== [mariadb: (set to auto start)]"
sudo update-rc.d mysql defaults

echo "========== [mariadb: (set root password)]"
sudo /usr/bin/mysqladmin -u root password 'root'

echo "========== [mariadb: (create vagrant user)]"
sudo mysql -u root -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'vagrant'@'localhost' IDENTIFIED BY 'vagrant'"

echo "========== [mariadb: (allow remote access)]"
# required to access from our private network host. Note that this is completely insecure if used in any other way
sudo mysql -u root -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION; FLUSH PRIVILEGES;"
sudo mysql -u root -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'vagrant'@'%' IDENTIFIED BY 'vagrant' WITH GRANT OPTION; FLUSH PRIVILEGES;"

var="cat >> /etc/mysql/my.cnf <<EOF

[mysqld]
bind-address = 0.0.0.0
EOF"
sudo bash -c "$var"

echo "========== [mariadb: (create vagrant db)]"
sudo mysql -u root -proot -e "CREATE DATABASE vagrant CHARACTER SET utf8mb4 -- UTF-8 Unicode COLLATE utf8mb4_general_ci;"

echo "========== [mariadb: (restart)]"
sudo /etc/init.d/mysql restart
echo "=================================================================================================="
echo "PHP"
echo "=================================================================================================="
echo "========== [php: (installing)]"
sudo apt-get -y install php

echo "========== [php: (install packages)]"
sudo apt-get -y install php-pear php-fpm php-dev php-zip php-curl php-xmlrpc php-gd php-mysql php-mbstring php-xml php-pgsql php-cli php-sqlite3 php-gd php-iconv php-bcmath php-soap php-xdebug

echo "========== [php: (get version)]"
pver="$(sudo php -v)"
pver_number="$(echo $pver | cut -d' ' -f2)"
pver_major="$(echo $pver_number | cut -d'.' -f1)"
pver_minor="$(echo $pver_number | cut -d'.' -f2)"
pver="$pver_major.$pver_minor"
echo $pver

echo "========== [php: (change fpm listen address to 127.0.0.1:9000)]"
fconf_path="$(echo /etc/php/$pver/fpm/pool.d/www.conf)"
sudo sed -i 's/listen =.*/listen = 127.0.0.1:9000/' $fconf_path

echo "========== [php: (change limits)]"
pini_path="$(echo /etc/php/$pver/fpm/php.ini)"
sudo sed -i 's/memory_limit =.*/memory_limit = 5120M/' $pini_path
sudo sed -i 's/upload_max_filesize =.*/upload_max_filesize = 5120M/' $pini_path
sudo sed -i 's/post_max_size =.*/post_max_size = 5120M/' $pini_path
sudo sed -i 's/;cgi.fix_pathinfo.*/cgi.fix_pathinfo=0/' $pini_path
sudo sed -i 's/disable_functions =.*/disable_functions =show_source, system/' $pini_path

echo "========== [php: (restart)]"
fserv_path="$(echo /etc/init.d/php$pver-fpm)"
sudo $fserv_path restart
sudo /etc/init.d/nginx restart

echo "========== [php: (install composer)]"
sudo php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
HASH="$(wget -q -O - https://composer.github.io/installer.sig)"
sudo php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { echo 'Composer: Installer Verified'; } else { echo 'Composer: Installer Corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
echo $HASH
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
echo "=================================================================================================="
echo "NODEJS"
echo "=================================================================================================="
echo "========== [nodejs: (cleanup)]"
sudo apt remove --purge nodejs npm
sudo apt clean
sudo apt autoclean
sudo apt install -f
sudo apt autoremove

echo "========== [nodejs: (install)]"
curl -sL https://deb.nodesource.com/setup_10.x | sudo bash -
sudo apt install -y nodejs

echo "========== [nodejs: (show version)]"
echo "nodejs:"
sudo node -v
echo "npm:"
sudo npm -v
echo "=================================================================================================="
echo "PHPMYADMIN"
echo "=================================================================================================="
echo "========== [phpmyadmin: (install)]"
admin_ver="4.8.3"
admin_name="phpMyAdmin-4.8.3-english"

sudo wget -k "https://files.phpmyadmin.net/phpMyAdmin/$admin_ver/$admin_name.tar.gz"
sudo tar -xzvf "$admin_name.tar.gz" -C /usr/share/
sudo rm "$admin_name.tar.gz"
sudo mv "/usr/share/$admin_name/" "/usr/share/phpmyadmin/"
sudo ln -s /usr/share/phpmyadmin/ /var/www/html/
echo "=================================================================================================="
echo "COCKPIT"
echo "=================================================================================================="
echo "========== [cockpit: (install)]"
sudo apt-get -y install cockpit