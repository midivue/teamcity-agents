variable "location" {
  description = "Azure region to deploy to"
  default     = "East US"
}

variable "vm_size" {
  description = "Size of the virtual machine"
  default     = "Standard_B2s"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  default     = "teamcity-agent-rg"
}

variable "vm_name" {
  description = "Name of the virtual machine"
  default     = "teamcity-agent"
}

variable "admin_username" {
  description = "Admin username of the virtual machine"
  default     = "avasure"
}

variable "admin_password" {
  description = "Admin password of the virtual machine"
  default     = "6N27BX$Do6Gh8QQ%GupvXN3"
}
