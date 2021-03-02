#!/usr/bin/env bash
clear

script_dir=`dirname $0`

RED='\033[0;31m'
NC='\033[0m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'

fatal(){
  printf "${RED}$1${NC}\n"
  exit 1
}

warning(){
  printf "${YELLOW}$1${NC}\n"
}

msg(){
  echo $1
}

command(){
  printf "${BLUE}${@}\n"
  $@
  v=$?
  printf "${NC}\n"
  return ${v}
}

terra(){
  rm terraform.tfstate 2>/dev/null
  command "terraform plan -out terraform-steps/${1}/plan terraform-steps/${1}" && \
  command "terraform apply terraform-steps/${1}/plan" && \
  command "mv terraform.tfstate terraform-steps/${1}"
  return $?
}

cd ${script_dir} || fatal "Error entering on directory ${script_dir}"

msg "Checking if Azure CLI is installed..."
az version | grep azure-cli || fatal "Seems azure cli 2.19.1 or higher is not installed. Download and install from https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
msg "Checking if Azure Terraform is installed..."
terraform version | grep Terraform || fatal "Seems terraform 0.14.7 or higher is not installed. Download and install from https://www.terraform.io/downloads.html"

msg "Executing logout on Azure cli"
az logout
msg "Trying to execute login on Azure. A web browser window should appear"
az login || fatal "Not able to login on azure"

msg "Initializing terraform azure plugin"
command "terraform init"

warning "Edit the file variables.txt and add the required parameters to configure ftp server on Azure container"
warning "Have you edited file variables.txt [y|n] ?"
read answer
case ${answer} in
  "y"|"Y"|"yes"|"YES")
    ;;
  *)
    fatal "edit variables.txt file before continue"
    ;;
esac

msg "Sourcing file variables.txt"
set -a
source variables.txt
set +a
msg "Starting to build your ftp server"

if [[ ${RG_CREATE} == "yes" ]] ; then
  msg "Creating Resource Group"
  terra 1 || fatal "Error creating resource group"
fi

if [[ ${ST_AC} == "yes" ]] ; then
  msg "Creating Storage Account"
  terra 2 || fatal "Error creating storage account"
fi

if [[ ${ST_C} == "yes" ]] ; then
  msg "Creating Storage Container"
  terra 3 || fatal "Error creating storage container"
fi

if [[ ${ST_B} == "yes" ]] ; then
  msg "Creating Storage Blob"
  terra 4 || fatal "Error creating storage blob"
fi

if [[ ${ST_AC} == "yes" ]] ; then
  msg "Getting storage access key from terraform-steps/2/terraform.tfstate file"
  cd terraform-steps/2
  export STORAGE_KEY=`grep primary_access_key terraform.tfstate | cut -d ":" -f2 | sed 's/..$//' | sed 's/^..//'`
  warning "STORAGE_KEY variable set to ${STORAGE_KEY}"
  cd ../../
fi

msg "Preparing cloud_init.sh script"
sh prepare_cloud_init.sh

msg "Generating public key file id_rsa.pub. A private key file is generated as well named id_rsa"
ssh-keygen -b 2048 -t rsa -f id_rsa -q -N ""

msg "Creating Ftp Server virtual Machine"
terra 5 || fatal "Error creating virtual machine"

