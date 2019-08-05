

echo "Let's start installing docker"

sudo apt-get update
sudo apt-get upgrade

sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common

sudo apt-get install -y nginx


curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -

sudo apt-key fingerprint 0EBFCD88

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"

sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io

echo "Docker installed !"

echo "###########################################################################################################################################"
echo "                                                         Let's install docker compose !"
echo "###########################################################################################################################################"

sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "###########################################################################################################################################"
echo "                                                          Docker compose is installed"
echo "###########################################################################################################################################"

echo "###########################################################################################################################################"
echo "                                                          let's configure all services"
echo "###########################################################################################################################################"

sudo rm /etc/nginx/sites-enabled/default

sudo mv ./Files/devServer /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/devServer /etc/nginx/sites-enabled/

sudo service nginx restart

cd Gitlab
sudo docker-compose up -d
cd ..

cd Hoff_IT_Docs
sudo docker-compose up
sudo docker-compose up -d
cd ..