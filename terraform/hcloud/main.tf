provider "hcloud" {
  token = "${var.hcloud_token}"
}

resource "hcloud_server" "lbc" {
  count       = 2
  name        = "lbc-${count.index + 1}"
  server_type = "cx11"
  image       = "${var.hcloud_lbc_image}"
  ssh_keys    = ["${var.hcloud_ssh_key}"]
}

resource "hcloud_server" "node" {
  count       = 2
  name        = "node-${count.index + 1}"
  server_type = "cx11"
  image       = "${var.hcloud_node_image}"
  ssh_keys    = ["${var.hcloud_ssh_key}"]
}

resource "hcloud_floating_ip" "lbc_floating_ip" {
  type      = "ipv4"
  server_id = "${hcloud_server.lbc.0.id}"
}
