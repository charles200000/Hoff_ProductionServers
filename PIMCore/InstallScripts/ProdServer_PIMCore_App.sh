sudo apt-get update
sudo apt-get upgrade

sudo apt-get install -y nginx
sudo systemctl enable nginx.service

sudo apt-get install -y software-properties-common
sudo add-apt-repository ppa:ondrej/php


# first php dependencies
sudo apt-get install php7.2-fpm php7.2-cgi php7.2-common php7.2-mbstring php7.2-xmlrpc php7.2-soap php7.2-gd php7.2-xml php7.2-intl php7.2-mysql php7.2-cli php7.2-zip php7.2-opcache php7.2-curl

# install small dependencies
sudo apt-get install php-imagick graphviz


##
## INSTALL TOOLS
##

#install Composer
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === 'a5c698ffe4b8e849a443b120cd5ba38043260d5c4023dbf93e1558871f1f07f58274fc6f4c93bcfd858c6bd0775cd8d1') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
sudo mv composer.phar /usr/local/bin/composer


#install FFMPEG
sudo apt-get install ffmpeg

# Install LibreOffcie, pdftotext...
sudo apt-get install libreoffice libreoffice-script-provider-python libreoffice-math xfonts-75dpi poppler-utils inkscape libxrender1 libfontconfig1 ghostscript

# Install wkhtmltopdf
wget https://downloads.wkhtmltopdf.org/0.12/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb
sudo dpkg -i wkhtmltox*
sudo apt-get install -f
rm wkhtmltox*


# Install Image Optimizers
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
sudo apt-get install libimage-exiftool-perl webp facedetect html2text

# get all locals
sudo apt-get install locales-all

####################################################################################################################################
### Start config setup
####################################################################################################################################
# php setup
# !!!!!! TOKEN MAY CHANGE !!
wget --output-document=php.ini https://raw.githubusercontent.com/charles200000/Hoff_ProductionServers/master/PIMCore/Files/php.ini?token=ABYSCG6YK5SEB7QNHSPMV3K5J2FHI
sudo mv php.ini /etc/php/7.2/fpm/

# configure php-fpm
wget --output-document=www.conf https://raw.githubusercontent.com/charles200000/Hoff_ProductionServers/master/PIMCore/Files/www.conf?token=ABYSCGY3UEXX36FP4RXHTTC5JXT2K
sudo mv www.conf /etc/php/7.2/fpm/pool.d/

sudo service php7.2-fpm restart

# Install PIMCore
mkdir pimcore
cd pimcore
COMPOSER_MEMORY_LIMIT=-1 composer create-project pimcore/skeleton hoff_pimcore
#install pimcore
sudo mv hoff_pimcore/ /var/www/

cd ..
rm -rf pimcore

#configure nginx
wget --output-document=HoffPIM 
sudo mv HoffPIM /etc/nginx/sites-available/
sudo rm /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/HoffPIM /etc/nginx/sites-enabled/

sudo systemctl restart nginx.service

#Config PIMCore
sudo apt-get install mariadb-client

wget --output-document=installer.yml https://raw.githubusercontent.com/charles200000/Hoff_ProductionServers/master/PIMCore/Files/installer.yml?token=ABYSCG4FOM6MAJUXS4GVJIS5JXZ2O
sudo mv installer.yml /var/www/hoff_pimcore/app/config/


#start installer : you need to say yes
cd /var/www/hoff_pimcore/
sudo ./vendor/bin/pimcore-install --admin-username PIMadmin --admin-password toor
sudo chown -R www-data:www-data app/config bin composer.json pimcore var web/pimcore web/var
sudo chmod ug+x bin/*
cd

#delete default config
sudo rm /etc/nginx/sites-available/default
sudo rm -rf /var/www/html/

# Add https 
sudo add-apt-repository universe
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get install certbot python-certbot-nginx
sudo certbot renew --dry-run

# add maintenance job
# crontab -e
# */5 * * * * /var/www/hoff_pimcore/bin/console maintenance

# reboot all