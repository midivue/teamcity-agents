# TeamCity Agent Provisioning with Terraform

This Terraform module provisions a Windows 10 virtual machine on Azure to be used as a TeamCity build agent. The VM is configured with .NET Framework 4.7.2 and Node.js Version Manager (nvm).

### Please note that this This project is highly unstable and is a proof of concept to serve as a skeleton for later use. Use with caution!

## Overview

This README provides a step-by-step guide for setting up the Terraform module, configuring the VM with Ansible, and verifying the setup. Adjust any details specific to your environment as necessary.

## Prerequisites

- Terraform installed on your local machine.
- Azure CLI installed and authenticated.

## Usage

### 1. Clone the Repository

Clone this repository to your local machine:

```bash
git clone https://github.com/yourusername/teamcity-agent-provisioning.git
cd teamcity-agent-provisioning/terraform
```

### 2. Initialize Terraform

Initialize the Terraform working directory:

```bash
terraform init
```

### 3. Configure Variables

Adjust any necessary variables in `variables.tf`. The default values should work for most use cases, but you can customize them if needed:

```hcl
variable "location" {
  description = "The Azure region to deploy to"
  default     = "East US"
}

variable "vm_size" {
  description = "The size of the virtual machine"
  default     = "Standard_B2s"
}
```

### 4. Apply the Terraform Configuration

Apply the Terraform configuration to create the resources:

```bash
terraform apply
```

You will be prompted to confirm the changes. Type `yes` to proceed. This will provision the Azure resources, including the Windows 10 VM.

### 5. Retrieve the VM IP Address

After the Terraform apply completes, the public IP address of the VM will be written to `ansible/ip_address.txt`. You can view the IP address with the following command:

```bash
cat ../ansible/ip_address.txt
```

### 6. Configure the VM with Ansible

Change to the Ansible directory and update the `hosts.ini` file with the IP address of the VM:

```bash
cd ../ansible
echo "$(cat ip_address.txt) ansible_user=azureuser ansible_password=Password123! ansible_connection=winrm ansible_winrm_server_cert_validation=ignore" > hosts.ini
```

### 7. Run the Ansible Playbook

Run the Ansible playbook to install the necessary software and configure the TeamCity agent:

```bash
ansible-playbook -i hosts.ini playbook.yml
```

### 8. Verify the Setup

After the playbook runs successfully, your Windows VM should be configured with .NET Framework 4.7.2, Node.js Version Manager, and the TeamCity agent should be installed and connected to your TeamCity server.

## Cleaning Up

To destroy the resources created by Terraform, run:

```bash
terraform destroy
```

This will delete all the resources created by this module.

## Customization

You can customize the configuration by modifying the Ansible playbooks and Terraform files to fit your specific requirements.

## Contributing

Feel free to submit issues or pull requests to improve this module.

## Project outline
```
.
├── ansible
│   ├── hosts.ini
│   ├── playbook.yml
│   ├── roles
│   │   ├── chocolatey
│   │   │   └── tasks
│   │   │       └── main.yml
│   │   ├── dotnet
│   │   │   └── tasks
│   │   │       └── main.yml
│   │   ├── nvm
│   │   │   └── tasks
│   │   │       └── main.yml
│   │   └── teamcity-agent
│   │       ├── tasks
│   │       │   └── main.yml
│   │       └── templates
│   │           └── buildAgent.properties.j2
│   └── vars.yml
├── README.md
├── scaffold.sh
└── terraform
    ├── main2.tf
    ├── main.tf
    ├── outputs.tf
    └── variables.tf
```
12 directories, 14 files

