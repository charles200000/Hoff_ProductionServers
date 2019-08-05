#!/bin/bash
#This is the slack installer

echo "Please enter hoff slack databse password :"
read dbPassword

echo "Let's get started !"

sudo apt-get update
sudo apt-get upgrade -y

echo "Done with linux update !"

sudo apt install -y postgresql postgresql-contrib

# in the postgresql user
sudo -u postgres psql -c 'CREATE DATABASE mattermost;'
sudo -u postgres psql -c "CREATE USER mmuser WITH PASSWORD '$dbPassword';"
sudo -u postgres psql -c 'GRANT ALL PRIVILEGES ON DATABASE mattermost to mmuser;'

# move postgresql config file
sudo mv ./Files/pg_hba.conf /etc/postgresql/10/main/
echo "moved file (check up if errors"

sudo systemctl reload postgresql

echo "###################################################################################################################"
echo "                                 Database setup over starting mattermost install"
echo "###################################################################################################################"


wget https://releases.mattermost.com/5.13.2/mattermost-5.13.2-linux-amd64.tar.gz

tar -xvzf mattermost*.gz
sudo mv mattermost /opt

# this is where all the files will be stored
sudo mkdir /opt/mattermost/data

# create user for running the instance
sudo useradd --system --user-group mattermost
sudo chown -R mattermost:mattermost /opt/mattermost
sudo chmod -R g+w /opt/mattermost

# setup the config file :
sed -i "s/TO_BE_REPLACE_BY_SCRIPT/$dbPassword/" ./Files/config.json
sudo mv ./Files/config.json /opt/mattermost/config/

#sed -i "s/^        \"DataSource\":.*/        \"DataSource\": \"postgres://mmuser:$dbPassword@localhost:5432/mattermost?sslmode=disable&connect_timeout=10\",/" ./Files/config.json

echo "configuring the system service"
sudo mv ./Files/mattermost.service /lib/systemd/system/
sudo systemctl daemon-reload
sudo systemctl status mattermost.service
sudo systemctl start mattermost.service
sudo systemctl enable mattermost.service
echo "Done configuring system service"

echo "###################################################################################################################"
echo "                               Mattermost server done installing, let's install nginx"
echo "###################################################################################################################"

sudo apt-get install -y nginx

sudo mv ./Files/hoffSlack /etc/nginx/sites-available/
sudo rm /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/hoffSlack /etc/nginx/sites-enabled/hoffSlack

sudo systemctl restart nginx

sudo ufw allow https
sudo ufw allow http
sudo ufw allow ssh

sudo ufw enable


# see https://docs.mattermost.com/install/install-ubuntu-1804.html#install-and-configure-the-components-in-the-following-order-note-that-you-need-only-one-database-either-mysql-or-postgresql
# to finish with ssl encryption