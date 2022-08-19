## Get flavor id
data "openstack_compute_flavor_v2" "flavor" {
  name = "standard.tiny" # flavor to be used
}

resource "openstack_compute_secgroup_v2" "secgroup_ssh" {
  name = "SSH_web"
  description = "my security group"

  rule {
    from_port = 22
    to_port = 22
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
}

resource "openstack_compute_secgroup_v2" "secgroup_http" {
  name = "HTTP_web"
  description = "my security group"

  rule {
    from_port = 80
    to_port = 80
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
}


# Create an instance
resource "openstack_compute_instance_v2" "server" {
  name            = var.instance_name
  image_id        = data.openstack_images_image_v2.image.id
  flavor_id       = data.openstack_compute_flavor_v2.flavor.id
  key_pair        = var.keypair
  security_groups = ["${openstack_compute_secgroup_v2.secgroup_ssh.id}",
                     "${openstack_compute_secgroup_v2.secgroup_http.id}"]
  network {
    name = var.network
  }
}

# Add Floating ip

data "openstack_networking_floatingip_v2" "fip1" {
  address = "86.50.228.20"
}

resource "openstack_compute_floatingip_associate_v2" "fip1" {
  floating_ip = data.openstack_networking_floatingip_v2.fip1.address
  instance_id = openstack_compute_instance_v2.server.id

  provisioner "remote-exec" {
    inline = ["echo 'Hello World'"]

    connection {
      type        = "ssh"
      user        = "${var.ssh_user}"
      host        = "${data.openstack_networking_floatingip_v2.fip1.address}"
      private_key = "${file("${var.private_key_path}")}"
    }
  }

}


output "server_floating_ip" {
 value = data.openstack_networking_floatingip_v2.fip1.address
}

output "inventory" {
  value = [ {
        "groups"           : "['web']",
        "name"             : "${openstack_compute_instance_v2.server.name}",
        "ip"               : "${data.openstack_networking_floatingip_v2.fip1.address}",
        "ansible_ssh_user" : "${var.ssh_user}",
        "private_key_file" : "${var.private_key_path}",
        "ssh_args"         : "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
      } ]
}
