# Repository for Azure ARM Templates
This repo will host ARM Templates used for Labs and Demonstrations.

## DeploySingleVM
### This lab will deploy a Windows Server VM from Template Library
#### Instructions: 
1. Download the [DeploySingleVM.json](https://github.com/ricmmartins/azure-arm-template/blob/master/DeploySingleVM.json) file. Under Azure Portal, go to "All Services" > "Templates". Click to Add and then at "General" put a name and a short description and click OK.

2. At "ARM Template", paste the content of DeployLabVM. Click OK and ADD. Now you can see your added template. Click to "Deploy" and under "Basics" fill the fields of Subscription, Resource Group (Create New) and Location. Under "Settings" fill "Your Name". 

3. Agree the terms and click to "Purchase"to start de deployment.

## WPSingleVM
### This lab will deploy a Ubuntu VM from CLI whith wordpress installed.
#### Instructions:

1. Install [az-cli](https://docs.microsoft.com/en-us/cli/azure/) or use the [cloud shell](https://azure.microsoft.com/en-us/features/cloud-shell/)

2. Run the following commands:

```
az login
az account set --subscription "<your subscription id>"

git clone https://github.com/Azure/azure-quickstart-templates.git

cd azure-quickstart-templates/wordpress-single-vm-ubuntu

vim azuredeploy.parameters.json

az group create -n <resourcegroupname> -l "eastus2"
az group deployment create --resource-group <resourcegroupname> --template-file "azuredeploy.json" --parameters "azuredeploy.parameters.json" --verbose
```

> Note: In the sample, I'm using the Brazil South location, feel free to use another region. Change "resourcegroupname" by the name of resource group that you want. When edit the file azuredeploy.parameters.json, you need choose an VmDNSName (must be unique), adminUsername, adminPassword and mySqlPasword. 

## ELKStack
### This lab will deply the ELK Stack among 3 VMs, using Redis Service as parsing and a VM working as Application Server generating logs.
#### Instructions:

1. Install [az-cli](https://docs.microsoft.com/en-us/cli/azure/) or use the [cloud shell](https://azure.microsoft.com/en-us/features/cloud-shell/)

2. Run the script [ELKStack.sh](https://github.com/ricmmartins/azure-arm-template/blob/master/ELKStack.sh)

> Note: Details about this lab at [http://ricardomartins.com.br/implementando-a-stack-elk-no-azure-via-cli/](http://ricardomartins.com.br/implementando-a-stack-elk-no-azure-via-cli/)

## Terraform
### This lab will use Terraform instead of ARM Template to setup an Ubuntu Linux VM with Nginx and PHP.
#### Instructions:

1. Install [az-cli](https://docs.microsoft.com/en-us/cli/azure/) or use the [cloud shell](https://azure.microsoft.com/en-us/features/cloud-shell/)

2. Download [Terraform](https://www.terraform.io/downloads.html)

3. Setup Terraform on Linux
```
sudo apt-get install unzip
wget https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

4. Show Subscription and Tenant
```
az account show --query "{subscriptionId:id, tenantId:tenantId}"
```

5. Set subscription
```
az account set --subscription="XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
```

6. Create Service Principal for Terraform

```
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
```
> Your appId, password, sp_name, and tenant are returned. Make a note of the appId and password

The output will be similar to
```
{
  "appId": "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
  "displayName": "azure-cli-2019-04-16-03-26-25",
  "name": "http://azure-cli-2019-04-16-03-26-25",
  "password": "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
  "tenant": "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
}
```

7. Create the directory terraform
```
mkdir terraform
```
8. Create the file terraform_azure.tf as below

```
cd terraform 
vi terraform_azure.tf

# Configure the Microsoft Azure Provider
provider "azurerm" {
    subscription_id = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
    client_id       = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
    client_secret   = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
    tenant_id       = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
}

# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "myterraformgroup" {
    name     = "myResourceGroup"
    location = "eastus"

    tags {
        environment = "Terraform Demo"
    }
}

# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = "myVnet"
    address_space       = ["10.0.0.0/16"]
    location            = "eastus"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"

    tags {
        environment = "Terraform Demo"
    }
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
    name                 = "mySubnet"
    resource_group_name  = "${azurerm_resource_group.myterraformgroup.name}"
    virtual_network_name = "${azurerm_virtual_network.myterraformnetwork.name}"
    address_prefix       = "10.0.1.0/24"
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
    name                         = "myPublicIP"
    location                     = "eastus"
    resource_group_name          = "${azurerm_resource_group.myterraformgroup.name}"
    allocation_method            = "Dynamic"

    tags {
        environment = "Terraform Demo"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "myNetworkSecurityGroup"
    location            = "eastus"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"
    
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "HTTP"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags {
        environment = "Terraform Demo"
    }
}

# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
    name                      = "myNIC"
    location                  = "eastus"
    resource_group_name       = "${azurerm_resource_group.myterraformgroup.name}"
    network_security_group_id = "${azurerm_network_security_group.myterraformnsg.id}"

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = "${azurerm_subnet.myterraformsubnet.id}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${azurerm_public_ip.myterraformpublicip.id}"
    }

    tags {
        environment = "Terraform Demo"
    }
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = "${azurerm_resource_group.myterraformgroup.name}"
    }
    
    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = "${azurerm_resource_group.myterraformgroup.name}"
    location                    = "eastus"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags {
        environment = "Terraform Demo"
    }
}

# Create virtual machine
resource "azurerm_virtual_machine" "myterraformvm" {
    name                  = "myVM"
    location              = "eastus"
    resource_group_name   = "${azurerm_resource_group.myterraformgroup.name}"
    network_interface_ids = ["${azurerm_network_interface.myterraformnic.id}"]
    vm_size               = "Standard_DS1_v2"

    storage_os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "myvm"
        admin_username = "azureuser"
        admin_password = "2@!wx02@!wx0"
        custom_data    = "${base64encode(file("${path.module}/install.sh"))}"
    }

    os_profile_linux_config {
        disable_password_authentication = false
        
    }

    boot_diagnostics {
        enabled = "true"
        storage_uri = "${azurerm_storage_account.mystorageaccount.primary_blob_endpoint}"
    }

    tags {
        environment = "Terraform Demo"
    }
}
```

9. Create the file install.sh wich will setup de Ngninx and PHP as below

```
cd terraform
vi install.sh

#!/usr/bin/env bash
set -e

echo "==> Installing packages..."

sudo apt-get update
sudo apt-get install -y nginx
sudo apt-get install -y php7.0-fpm
sudo apt-get install -y git

echo "==> Setup website demo..."

# Nginx 

sudo rm /etc/nginx/sites-available/default

cat <<"EOT" >> /etc/nginx/sites-available/default
# Nginx Config
   server {
    listen   80;

    root /var/www/app;
    index index.php index.html;

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php/php7.0-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
EOT


# Build

sudo mkdir -p /var/www/app
cd /var/www/app
sudo git clone https://github.com/ricmmartins/simple-php-app.git
sudo mv simple-php-app/* /var/www/app  
sudo systemctl restart nginx

echo "==> Done!"

```

10. Build and deploy the infrastructure

```
terraform init
terraform plan
terraform apply
```

11. To validate, get the public IP and open in browser:

```
az vm show --resource-group myResourceGroup --name myVM -d --query [publicIps] --o tsv
```

