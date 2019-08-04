#!/bin/bash

echo "let's get started"

# need to configure : Password for user pimcoreuser + local network acess
# base stuff
sudo apt-get update
sudo apt-get upgrade

#Install Mariadb
sudo apt-get install -y mariadb-server 

sudo mysql -u root -p -e "CREATE DATABASE pimcoredb charset=utf8mb4;"
sudo mysql -u root -p -e "CREATE USER 'pimcoreuser'@'localhost' IDENTIFIED BY '$1';"
sudo mysql -u root -p -e "GRANT ALL ON pimcoredb.* TO 'pimcoreuser'@'localhost' IDENTIFIED BY '$1' WITH GRANT OPTION;"
sudo mysql -u root -p -e "FLUSH PRIVILEGES;"
#sudo mysql -u root -p -e "SET GLOBAL innodb_file_format=Barracuda;"
#sudo mysql -u root -p -e "set global innodb_large_prefix =on;"

echo "database setup ok"

#wget --output-document=50-server.cnf
sudo mv ../Files/50-server.cnf /etc/mysql/mariadb.conf.d/
echo "moved mariadb config OK"

# open ports
sudo ufw allow mysql/tcp

# add access to user on local network
sudo mysql -u root -p -e "GRANT ALL PRIVILEGES ON *.* TO 'pimcoreuser'@'192.168.0.%' IDENTIFIED BY '$1' WITH GRANT OPTION;"


echo "All is ok ready to go"