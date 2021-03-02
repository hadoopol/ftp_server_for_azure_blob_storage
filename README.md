#FTP Server for Azure Blob Storage

* Summary
* How it works
* Requirements
* Download the app
* Using the tool
* Todo
* Bugs
* Developer
* Support

### Summary

The tool will create a FTP server for blob storage running inside a Virtual Machine on the Azure Cloud.

### How it works

The tool will connect to the Azure cloud and create all necessary resources to serve as FTP server for blob storage

### Requirements

You need to execute the tool from Mac, Linux or WSL(Windows subsystem for linux)

Install Azure cli. How to download and install: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli

Install terraform and add it to the PATH. How to download and install: https://www.terraform.io/downloads.html

### Download the app

On your OS command line terminal, type below command to clone this repository:

> git clone https://github.com/hadoopol/ftp_server_for_azure_blob_storage.git

### Using the app

1. Enter on cloned directory

> cd ftp_server_for_azure_blob_storage

2. Edit variables.txt file properly. By default all resources(resource group, network, 
   storage account, blob storage) will be created. If you already have those resources
   edit variables.txt file. Read the file variables.txt for more details.

4. Execute the script start.sh and follow the instructions on the screen

>sh start.sh

### Todo

### Bugs

### Developer

This tool was tested using:
* Terraform version 0.14.7
* Azure cli 2.19.1
* MacOs 11.2

### Support

If you would like commercial write to developer @ hadoopol.com


