#!/bin/bash

# Define variables
rg="$1"
location="$2"
vmname="$3"

# Validate parameters
if [ "$1" = "" ]; then
    echo "Wrong usage! You need inform the parameters."
    echo "Example: ./createvm.sh <resource group name> <location> <vmname>"
exit 1
elif [ "$1" != "" ]; then

# Create Resource Group
az group create --name $rg  --location $location

# Create VNET
az network vnet create --resource-group $rg --name myVnet --address-prefix 10.0.0.0/16 --subnet-name mySubnet --subnet-prefix 10.0.1.0/24

# Create VM
az vm create --resource-group $rg --name $vmname \
--size Standard_D2S_v3  \
--image Canonical:UbuntuServer:18.04-LTS:latest  \
--admin-username rmmartins \
--generate-ssh-keys \
--no-wait \
--vnet-name myVnet \
--subnet  mySubnet \
--nsg nsg-vm

# Wait VM creation
az vm wait -g $rg -n $vmname --created

# Create NSG Rule

az network nsg rule create --resource-group $rg --nsg-name nsg-vm \
--name port-80-rule \
--access Allow \
--protocol Tcp \
--direction Inbound \
--priority 300 \
--source-address-prefix Internet \
--source-port-range "*" \
--destination-address-prefix "*" \
--destination-port-range 80

# Install Nginx

az vm run-command invoke -g $rg --name $vmname \
--command-id RunShellScript --scripts "sudo apt-get update && sudo apt-get -y install nginx php-fpm git"

az vm run-command invoke -g $rg --name $vmname \
--command-id RunShellScript --scripts "wget https://raw.githubusercontent.com/ricmmartins/simple-php-app-container/master/default -O /etc/nginx/sites-available/default"

# Configure Nginx

az vm run-command invoke -g $rg --name $vmname \
--command-id RunShellScript --scripts "mkdir -p /var/www/app && mkdir /var/tmp/app"


az vm run-command invoke -g $rg --name $vmname \
--command-id RunShellScript --scripts "cd /var/tmp/app && git clone https://github.com/ricmmartins/simple-php-app.git"

az vm run-command invoke -g $rg --name $vmname \
--command-id RunShellScript --scripts " cd /var/tmp/app && mv simple-php-app/* /var/www/app"

## Start Nginx

az vm run-command invoke -g $rg --name $vmname \
--command-id RunShellScript --scripts "sudo systemctl restart nginx"

fi
exit
