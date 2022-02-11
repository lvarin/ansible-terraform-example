# Terraform example

This is a small example that uses ansible to call the Terraform Openstack provider to create a VM and attach to it a virtual IP. And then configure that new server using Ansible.

**NOTE:** This is still a prototipe, several steps are misisng and they do not use the best pracsises.

## Quick start

* [Install terraform](https://www.terraform.io/downloads.html)

* Log in Openstack sourcing the openrc file that your Openstack instance provides.

* Edit `terraform/variables.tf` with the correct values for the name of **keypair** (`openstack keypair list`), **network** (`openstack network list`) and **security_groups** (`openstack security group list`).

* Then just do:

```sh
ansible-playbook main.yaml
```

## Destroy

```sh
ansible-playbook main.yaml -e "state=absent"
```

