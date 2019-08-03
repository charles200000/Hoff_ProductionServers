#!/bin/bash

echo "let's get started"

# need to configure : Password for user pimcoreuser + local network acess
#base stuff
sudo apt-get update
sudo apt-get upgrade
sudo reboot

#Install Mariadb
sudo apt-get install mariadb-server 

sudo mysql -u root -p
sudo mysql -u root -p -e "CREATE DATABASE pimcoredb charset=utf8mb4;"
sudo mysql -u root -p -e "CREATE USER 'pimcoreuser'@'localhost' IDENTIFIED BY 'user_password_here';"
sudo mysql -u root -p -e "GRANT ALL ON pimcoredb.* TO 'pimcoreuser'@'localhost' IDENTIFIED BY 'user_password_here' WITH GRANT OPTION;"
sudo mysql -u root -p -e "FLUSH PRIVILEGES;"
sudo mysql -u root -p -e "EXIT;"
sudo mysql -u root -p -e "SET GLOBAL innodb_file_format=Barracuda;"
sudo mysql -u root -p -e "set global innodb_large_prefix =on;"

# open ports
sudo ufw allow mysql/tcp


wget --output-document=50-server.cnf https://raw.githubusercontent.com/charles200000/Hoff_ProductionServers/master/PIMCore/Files/50-server.cnf?token=ABYSCG5SCIBIRDXURMSNOTS5J2ODW
sudo mv 50-server.cnf /etc/mysql/mariadb.conf.d/

# add access to user on local network
sudo mysql -u root -p -e "GRANT ALL PRIVILEGES ON *.* TO 'pimcoreuser'@'192.168.0.%' IDENTIFIED BY 'user_password_here' WITH GRANT OPTION;"