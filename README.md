# Repository for Azure ARM Templates
This repo will host ARM Templates used for Labs and Demonstrations.

## DeploySingleVM
### This lab will deploy a Windows Server VM from Template Library
Instructions: 
Download the DeploySingleVM.json file. Under Azure Portal, go to "All Services" > "Templates". Click to Add and then at "General" put a name and a short description and click OK.

At "ARM Template", paste the content of DeployLabVM. Click OK and ADD. Now you can see your added template. Click to "Deploy" and under "Basics" fill the fields of Subscription, Resource Group (Create New) and Location. Under "Settings" fill "Your Name". 

Agree the terms and click to "Purchase"to start de deployment.

## WPSingleVM
### This lab will deploy a Ubuntu VM from CLI whith wordpress installed.
Instructions

Install [az-cli](https://docs.microsoft.com/en-us/cli/azure/) or use the [cloud shell](https://azure.microsoft.com/en-us/features/cloud-shell/)

``git clone https://github.com/Azure/azure-quickstart-templates.git

cd azure-quickstart-templates/wordpress-single-vm-ubuntu

vim azuredeploy.parameters.json

az group create -n resourcegroupname -l "brazilsouth"
az group deployment create --resource-group resourcegroupname --template-file "azuredeploy.json" --parameters "azuredeploy.parameters.json" --verbose````




