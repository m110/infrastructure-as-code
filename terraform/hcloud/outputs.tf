output "lbc_ip" {
  value = ["${hcloud_server.lbc.*.ipv4_address}"]
}

output "node_ip" {
  value = ["${hcloud_server.node.*.ipv4_address}"]
}

output "consul_ip" {
  value = ["${hcloud_server.consul.*.ipv4_address}"]
}

output "lbc_floating_ip" {
  value = ["${hcloud_floating_ip.lbc_floating_ip.ip_address}"]
}
