# Vagrant-Cocktail

A Vagrant setup with ( Nginx , PostgreSQL , MariaDB , PHP , ... )

## What's inside?

- OS :
	- Ubuntu 18.04 LTS (Bionic Beaver) x64
- DB :
	- PostgreSQL
	- MariaDB
	- Sqlite3
- Web Server :
	- Nginx
- Panel :
	- phpMyAdmin
	- Cockpit (web-based interface for server)
- Other :
	- PHP with some extensions
	- Composer
	- Node.js with NPM
	- curl , wget , git , zip , unzip , iptables , debconf-utils , software-properties-common

## Prerequisites
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- [Vagrant](https://www.vagrantup.com/downloads.html)
	- Plugin vagrant-vbguest : ``vagrant plugin install vagrant-vbguest``

## Initialize
- Clone this repository into your project
- Disable Hyper-V (Windows Only) : ``bcdedit /set hypervisorlaunchtype off/auto``
- Set synced folders in ``Vagrantfile``
- Run (with root/admin privileges) : ``vagrant up --provider=virtualbox``

- Add the following lines to your .hosts file:
````
192.168.33.10 v.loc
````

## How to use
``All usernames and passwords are 'vagrant'``
- Main
````
- URL = http://v.loc/
````
- phpMyAdmin
````
- URL = http://v.loc/phpmyadmin/
````
- Cockpit
````
- URL = http://v.loc:9090/
- Terminal = http://v.loc:9090/system/terminal
````
- PostgreSQL
````
- Host/IP = v.loc/192.168.33.10
- Port = 5432
- Initial Database = postgres/vagrant
````
- MariaDB
````
- Host/IP = v.loc/192.168.33.10
- Port = 3306
- Initial Database = mysql/vagrant
````
- SSH (exec from repo root directory)
````
vagrant ssh
(logout : CTRL+D)
````
- Vagrant Commands (exec from repo root directory)
````
- vagrant up --provider=virtualbox
- vagrant reload
- vagrant reload --provision
- vagrant halt
- vagrant suspend
- vagrant destroy
````
- Nginx Log
````
/log/nginx/
````
