# Variables
variable "keypair" {
  type    = string
  default = "XXXX"   # name of keypair that will have access to the VM 
}

variable "network" {
  type    = string
  default = "XXXX" # default network to be used
}

variable "security_groups" {
  type    = list(string)
  default = ["SSH-World", "Allow-HTTP(s)"]  # Name of default security group
}

# Data sources
## Get Image ID
data "openstack_images_image_v2" "image" {
  name        = "CentOS-7" # Name of image to be used
  most_recent = true
}

variable "private_key_path" {
  description = "Path to the private SSH key, used to access the instance."
  default     = "XXXX"
}

variable "ssh_user" {
  description = "SSH user name to connect to your instance."
  default     = "cloud-user"
}
