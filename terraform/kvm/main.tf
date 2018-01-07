provider "libvirt" {
  uri = "${var.libvirt_uri}"
}

resource "libvirt_domain" "dummy_server" {
  name   = "dummy_server_${count.index}"
  memory = 512
  vcpu   = 1

  count = 1

  disk {
    volume_id = "${libvirt_volume.ubuntu-main.id}"
  }

  network_interface {
    network_id = "${libvirt_network.tf.id}"

    hostname       = "dummy-server-${count.index}"
    mac            = "AA:BB:CC:11:22:${30 + count.index}"
    addresses      = ["10.0.100.${100 + count.index}"]
    wait_for_lease = 1
  }
}

resource "libvirt_domain" "dummy_lbc" {
  name   = "dummy_lbc"
  memory = 512
  vcpu   = 1

  disk {
    volume_id = "${libvirt_volume.ubuntu-lbc.id}"
  }

  network_interface {
    network_id = "${libvirt_network.tf.id}"

    hostname       = "ubuntu-lbc"
    mac            = "AA:BB:CC:11:22:44"
    addresses      = ["10.0.100.20"]
    wait_for_lease = 1
  }
}

resource "null_resource" "backends" {
  triggers {
    backends_ips = "${join(",", libvirt_domain.dummy_server.*.network_interface.0.addresses.0)}"
  }

  provisioner "local-exec" {
    command = "ANSIBLE_CONFIG=../../ansible/ansible.cfg ansible-playbook ../../ansible/load-balancer.yml -t nginx-config -D -e '${jsonencode(local.ansible_vars)}' -i ${libvirt_domain.dummy_lbc.network_interface.0.addresses.0},"
  }
}

locals {
  ansible_vars = {
    nginx = {
      become   = true
      backends = "${formatlist("%s:${var.dummy_server_port}", libvirt_domain.dummy_server.*.network_interface.0.addresses.0)}"
    }

    ansible_user            = "${var.libvirt_ssh_user}"
    ansible_ssh_pass        = "${var.libvirt_ssh_password}"
    ansible_become_pass     = "${var.libvirt_ssh_password}"
    ansible_ssh_common_args = "-o ProxyCommand=\"ssh -W %h:%p -q root@${var.libvirt_bastion_host}\""
    host                    = "${libvirt_domain.dummy_lbc.network_interface.0.addresses.0}"
  }
}

resource "libvirt_volume" "ubuntu-main" {
  name   = "ubuntu-main"
  source = "../../packer/kvm/output-ubuntu-main/ubuntu-main"
}

resource "libvirt_volume" "ubuntu-lbc" {
  name   = "ubuntu-lbc"
  source = "../../packer/kvm/output-ubuntu-lbc/ubuntu-lbc"
}

resource "libvirt_network" "tf" {
  name      = "tf"
  domain    = "tf.local"
  mode      = "nat"
  addresses = ["10.0.100.0/24"]
}
