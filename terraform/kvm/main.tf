variable "libvirt_uri" {}

provider "libvirt" {
  uri = "${var.libvirt_uri}"
}

resource "libvirt_domain" "dummy_server" {
  name   = "dummy_server"
  memory = 512
  vcpu   = 1

  disk {
    volume_id = "${libvirt_volume.ubuntu-main.id}"
  }

  network_interface {
    network_id = "${libvirt_network.tf.id}"

    hostname       = "ubuntu-main"
    mac            = "AA:BB:CC:11:22:33"
    addresses      = ["10.0.100.10"]
    wait_for_lease = 1
  }
}

resource "libvirt_volume" "ubuntu-main" {
  name   = "ubuntu-main"
  source = "../../packer/kvm/output-ubuntu-main/ubuntu-main"
}

resource "libvirt_network" "tf" {
  name      = "tf"
  domain    = "tf.local"
  mode      = "nat"
  addresses = ["10.0.100.0/24"]
}
