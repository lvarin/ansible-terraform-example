# Terraform example

This is a small example of Terraform and Ansible working together. Terraform will use the Openstack provider to create a VM, attach to it a virtual IP, and write an inventory for ansible. Ansible will take the inventory and configure Apache httpd on it.

## Quick start

* [Install terraform](https://www.terraform.io/downloads.html)

* Log in Openstack sourcing the openrc file that your Openstack instance provides.

* Edit `terraform/variables.tf` with the correct values for the name of **keypair** (`openstack keypair list`), **network** (`openstack network list`).

* Run ansible:

```sh
ansible-playbook main.yaml
```

* Visit the website. Use the IP provided by terraform

![Cat](./cat-rainbow.png)

# Destroy the infrastructure

```sh
terraform -chdir=terraform destroy
```

