#!/bin/bash

cat << 'EOF'
##########################################################
#
#  !!! WARNING !!!
#
#  This script is highly unstable!
#
#  It serves as a proof of concept and
#  should NOT BE USED IN PRODUCTION environment
#  before refactoring and testing first!
#
#  Consult the README file for more information
#  
#  You have been warned...
#
##########################################################
EOF

# Set these variables in `terraform/variables.tf`
RESOURCE_GROUP="teamcity-agent-poc"
VM_NAME="teamcity-agent-poc"
LOCATION="East US"
VM_SIZE="Standard_B2s"
ADMIN_USERNAME="azureuser"
ADMIN_PASSWORD="Password123!"

# Ensure Azure CLI is installed
if ! command -v az &> /dev/null
then
    echo "Azure CLI could not be found, please install it first."
    exit
fi

# Ensure Terraform is installed
if ! command -v terraform &> /dev/null
then
    echo "Terraform could not be found, please install it first."
    exit
fi

# Ensure Ansible is installed
if ! command -v ansible &> /dev/null
then
    echo "Ansible could not be found, please install it first."
    exit
fi

# Check if the user is already logged in
echo "Checking Azure login status..."
if az account show &> /dev/null; then
    SUBSCRIPTION_ID=$(az account show --query id -o tsv)
    SUBSCRIPTION_NAME=$(az account show --query name -o tsv)
    CURRENT_CONTEXT=$(az account show --query user.name -o tsv)
    
    echo "Currently logged in to Azure with the following subscription:"
    echo "Subscription ID: $SUBSCRIPTION_ID"
    echo "Subscription Name: $SUBSCRIPTION_NAME"
    echo "User: $CURRENT_CONTEXT"
    
    read -p "Do you want to use this Azure subscription? (yes/no): " LOGIN_AGAIN
    if [ "$LOGIN_AGAIN" == "no" ]; then
        echo "Logging into Azure..."
        az login
    fi
else
    echo "Not logged in to Azure. Logging in..."
    az login
fi

# Confirm variables with the user
# If you want to change these variables refer to the respective Terraform variables
echo "Deployment will use the following configuration:"
echo "Resource Group: $RESOURCE_GROUP"
echo "VM Name: $VM_NAME"
echo "Location: $LOCATION"
echo "VM Size: $VM_SIZE"
echo "Admin Username: $ADMIN_USERNAME"
echo "Admin Password: $ADMIN_PASSWORD"

read -p "Do you want to proceed with these settings? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo "Deployment cancelled."
    exit
fi

# Initialize and apply Terraform configuration
echo "Initializing and applying Terraform configuration..."
cd terraform

terraform init

if terraform apply; then
    echo "Terraform applied successfully."
else
    echo "Terraform apply failed."
    exit
fi

# Read the VM IP address
VM_IP=$(cat ../ansible/ip_address.txt)

if [ -z "$VM_IP" ]; then
    echo "Failed to retrieve the VM IP address."
    exit
fi

# Configure Ansible hosts file
echo "Configuring Ansible hosts file..."
cd ../ansible
echo "$VM_IP ansible_user=$ADMIN_USERNAME ansible_password=$ADMIN_PASSWORD ansible_connection=winrm ansible_winrm_server_cert_validation=ignore" > hosts.ini

# Run Ansible playbook
echo "Running Ansible playbook..."
if ansible-playbook -i hosts.ini playbook.yml; then
    echo "Ansible playbook ran successfully."
else
    echo "Ansible playbook failed."
    exit
fi

echo "Deployment completed successfully."