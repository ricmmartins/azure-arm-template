# Repository for Azure ARM Templates
This repo will host ARM Templates used for Labs and Demonstrations.

## DeploySingleVM
### This lab will deploy a Windows Server VM from Template Library
#### Instructions: 
1. Download the DeploySingleVM.json file. Under Azure Portal, go to "All Services" > "Templates". Click to Add and then at "General" put a name and a short description and click OK.

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

az group create -n <resourcegroupname> -l "brazilsouth"
az group deployment create --resource-group <resourcegroupname> --template-file "azuredeploy.json" --parameters "azuredeploy.parameters.json" --verbose
```

> Note: In the sample, I'm using the Brazil South location, feel free to use another region. Change "<resourcegroupname>" by the name of resource group that you want. When edit the file azuredeploy.parameters.json, you need choose an VmDNSName (must be unique), adminUsername, adminPassword and mySqlPasword. 



