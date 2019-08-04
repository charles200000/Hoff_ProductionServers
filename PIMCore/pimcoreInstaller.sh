#!/bin/bash

echo "Welcome to the pimcore installer !"
echo "Please enter the pimcore database password : "
read pimcoredbPass

echo "OK thank's pimcore database will be configure with username : pimcoreuser and password : $pimcoredbPass"

echo "Choose 1 to install pimcore application or 2 to install pimcore database"

read choice

if [ $choice -eq 1 ]
then
    echo "##########################################################################"
    echo "Please edit the installer.yml file to set the right databse ip !!!"
    read -p "Press enter if it's already done !"
    sed -i "s/^            password:.*/            password:             $pimcoredbPass/" ./Files/installer.yml
    echo "Config file updated with the correct password !"
    sudo sh ./InstallScripts/ProdServer_PIMCore_App.sh
fi

if [ $choice -eq 2 ]
then
    echo "ATTENTION !! The ip is set to 192.168.0.* arch ! You need to change it if it is not right !"
    sudo sh ./InstallScripts/ProdServer_PIMCore_db.sh $pimcoredbPass
fi