## Get flavor id
data "openstack_compute_flavor_v2" "flavor" {
  name = "standard.tiny" # flavor to be used
}

resource "openstack_compute_secgroup_v2" "secgroup_1" {
  name = "SSH"
  description = "my security group"

  rule {
    from_port = 22
    to_port = 22
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
}

# Create an instance
resource "openstack_compute_instance_v2" "server" {
  name            = "Terraform-test-XXXX"  #Instance name
  image_id        = data.openstack_images_image_v2.image.id
  flavor_id       = data.openstack_compute_flavor_v2.flavor.id
  key_pair        = var.keypair
  security_groups = ["${openstack_compute_secgroup_v2.secgroup_1.name}"]
  network {
    name = var.network
  }
}

# Add Floating ip

resource "openstack_networking_floatingip_v2" "fip1" {
  pool = "public"
}

resource "openstack_compute_floatingip_associate_v2" "fip1" {
  floating_ip = openstack_networking_floatingip_v2.fip1.address
  instance_id = openstack_compute_instance_v2.server.id

  provisioner "remote-exec" {
    inline = ["echo 'Hello World'"]

    connection {
      type        = "ssh"
      user        = "${var.ssh_user}"
      host        = "${openstack_networking_floatingip_v2.fip1.address}"
      private_key = "${file("${var.private_key_path}")}"
    }
  }

  #provisioner "local-exec" {
  #  command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${openstack_networking_floatingip_v2.fip1.address},' -u ${var.ssh_user} --private-key ${var.private_key_path} ansible/httpd.yml"
  #}
}

resource "local_file" "ansible_inventory" {
  content = templatefile("inventory.tmpl",
    {
     ip = openstack_networking_floatingip_v2.fip1.address,
    }
  )
  filename = "../hosts"
}

output "server_floating_ip" {
 value = openstack_networking_floatingip_v2.fip1.address
}
