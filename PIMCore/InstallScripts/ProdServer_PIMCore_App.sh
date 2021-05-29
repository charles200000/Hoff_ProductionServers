#!/bin/bash

echo "Installing PIMCore on the application server"

echo "Default start : "
sudo apt-get update
sudo apt-get upgrade

sudo apt-get install -y nginx
sudo systemctl enable nginx.service

sudo apt-get install -y software-properties-common
sudo apt install -y ca-certificates apt-transport-https gnupg2 gnupg1 curl libcurl4 lsb-release

echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/sury-php.list
wget -qO - https://packages.sury.org/php/apt.gpg | sudo apt-key add -
sudo apt-get update


echo "base packages installed"

# first php dependencies
sudo apt-get install php8.0-fpm php8.0-cgi php8.0-common php8.0-mbstring php8.0-xmlrpc-api-utils php8.0-soap php8.0-gd php8.0-xml php8.0-intl php8.0-mysql php8.0-cli php8.0-zip php8.0-opcache php8.0-curl

# install small dependencies
sudo apt-get install -y php-imagick graphviz


echo "All dependencies updated"


##
## INSTALL TOOLS
##

#install Composer
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === '756890a4488ce9024fc62c56153228907f1545c228516cbf63f885e036d37e9a59d27d63f46af1d4d07ee0f76181c7d3') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
sudo mv composer.phar /usr/local/bin/composer


#install FFMPEG
sudo apt-get install -y ffmpeg

# Install LibreOffcie, pdftotext...
sudo apt-get install -y libreoffice libreoffice-script-provider-python libreoffice-math xfonts-75dpi poppler-utils inkscape libxrender1 libfontconfig1 ghostscript

# Install wkhtmltopdf
wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.buster_amd64.deb
sudo dpkg -i wkhtmltox*
sudo apt-get install -y -f
sudo dpkg -i wkhtmltox*
rm wkhtmltox*


# Install Image Optimizers :
sudo wget https://github.com/imagemin/zopflipng-bin/raw/master/vendor/linux/zopflipng -O /usr/local/bin/zopflipng
sudo chmod 0755 /usr/local/bin/zopflipng

sudo wget https://github.com/imagemin/pngcrush-bin/raw/master/vendor/linux/pngcrush -O /usr/local/bin/pngcrush
sudo chmod 0755 /usr/local/bin/pngcrush

sudo wget https://github.com/imagemin/jpegoptim-bin/raw/master/vendor/linux/jpegoptim -O /usr/local/bin/jpegoptim
sudo chmod 0755 /usr/local/bin/jpegoptim

sudo wget https://github.com/imagemin/pngout-bin/raw/master/vendor/linux/x64/pngout -O /usr/local/bin/pngout
sudo chmod 0755 /usr/local/bin/pngout

sudo wget https://github.com/imagemin/advpng-bin/raw/master/vendor/linux/advpng -O /usr/local/bin/advpng
sudo chmod 0755 /usr/local/bin/advpng

sudo wget https://github.com/imagemin/mozjpeg-bin/raw/master/vendor/linux/cjpeg -O /usr/local/bin/cjpeg
sudo chmod 0755 /usr/local/bin/cjpeg

# Other tools
#TODO : add dependencies for this line
sudo apt-get install -y libimage-exiftool-perl webp facedetect html2text
sudo apt-get install -y -f

# get all locals
sudo apt-get install -y locales-all

echo "##############################################################################################################"
echo "##############################################################################################################"
echo "All tools are installed now let's configure"
echo "##############################################################################################################"
echo "##############################################################################################################"


####################################################################################################################################
### Start config setup
####################################################################################################################################
# php setup
# !!!!!! TOKEN MAY CHANGE !!
#wget --output-document=php.ini 
sudo mv ./Files/php.ini /etc/php/8.0/fpm/
echo "Moved php.ini config OK"

# configure php-fpm
#wget --output-document=www.conf
sudo mv ./Files/www.conf /etc/php/8.0/fpm/pool.d/
echo "Moved www.conf OK"

sudo service php8.0-fpm restart

# Install PIMCore
mkdir pimcore
cd pimcore
COMPOSER_MEMORY_LIMIT=-1 composer create-project pimcore/skeleton hoff_pimcore
# install pimcore
sudo mv hoff_pimcore/ /var/www/

cd ..
rm -rf pimcore

# configure nginx
#wget --output-document=HoffPIM
sudo mv ./Files/HoffPIM /etc/nginx/sites-available/
sudo rm /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/HoffPIM /etc/nginx/sites-enabled/
echo "Moved nginx config OK"

sudo systemctl restart nginx.service

# Config PIMCore
sudo apt-get install -y mariadb-client

#wget --output-document=installer.yml
#sudo mv ./Files/installer.yml /var/www/hoff_pimcore/config/
echo "Moved installer config OK"



# start installer : you need to say yes
cd /var/www/hoff_pimcore/
sudo ./vendor/bin/pimcore-install #--admin-username PIMadmin --admin-password toor
sudo chown -R www-data:www-data app/config bin composer.json web/var *
sudo chmod ug+x bin/*
cd

#delete default config
sudo rm /etc/nginx/sites-available/default
sudo rm -rf /var/www/html/

# Add https 
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get install -y certbot python-certbot-nginx

echo "configuration done !"

echo "please configure the cron job :"
echo "crontab -e"
# */5 * * * * /var/www/hoff_pimcore/bin/console maintenance
# 43 6 * * * certbot renew --post-hook "systemctl reload nginx"
# Keep in mind, that the cron job has to run as the same user as the web interface to avoid permission issues (eg. www-data). !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

echo "##############################################################################################################"
echo "##############################################################################################################"

echo "please reboot !"


# add maintenance job
# crontab -e
# */5 * * * * /var/www/hoff_pimcore/bin/console maintenance

# reboot all
