resource "null_resource" "lbc_floating_ip" {
  count = "${hcloud_server.lbc.count}"

  triggers {
    floating_ip   = "${hcloud_floating_ip.lbc_floating_ip.ip_address}"
    lbc_addresses = "${join(", ", hcloud_server.lbc.*.ipv4_address)}"
  }

  connection {
    user = "root"
    host = "${element(hcloud_server.lbc.*.ipv4_address, count.index)}"
  }

  provisioner "local-exec" {
    command = "ssh-keyscan ${element(hcloud_server.lbc.*.ipv4_address, count.index)} >> ~/.ssh/known_hosts"
  }

  provisioner "file" {
    content     = "${data.template_file.floating_ip.rendered}"
    destination = "/etc/network/interfaces.d/100-floating-ip.cfg"
  }

  provisioner "remote-exec" {
    inline = [
      "ip addr | grep ${hcloud_floating_ip.lbc_floating_ip.ip_address} || ip addr add ${hcloud_floating_ip.lbc_floating_ip.ip_address} dev eth0",
    ]
  }
}

resource "null_resource" "node-consul" {
  count = "${hcloud_server.node.count}"

  triggers {
    node_ips = "${join(",", hcloud_server.node.*.ipv4_address)}"
  }

  provisioner "local-exec" {
    command = "ssh-keyscan ${element(hcloud_server.node.*.ipv4_address, count.index)} >> ~/.ssh/known_hosts"
  }

  connection {
    user = "root"
    host = "${element(hcloud_server.node.*.ipv4_address, count.index)}"
  }

  provisioner "file" {
    content     = "CONSUL_JOIN=\"-client ${element(hcloud_server.node.*.ipv4_address, count.index)} -bind ${element(hcloud_server.node.*.ipv4_address, count.index)} -join ${hcloud_server.consul.0.ipv4_address}\""
    destination = "/etc/default/consul-join"
  }

  provisioner "remote-exec" {
    inline = [
      "systemctl restart consul",
    ]
  }
}

resource "null_resource" "lbc-consul" {
  count = "${hcloud_server.lbc.count}"

  triggers {
    lbc_ips = "${join(",", hcloud_server.lbc.*.ipv4_address)}"
  }

  provisioner "local-exec" {
    command = "ssh-keyscan ${element(hcloud_server.lbc.*.ipv4_address, count.index)} >> ~/.ssh/known_hosts"
  }

  connection {
    user = "root"
    host = "${element(hcloud_server.lbc.*.ipv4_address, count.index)}"
  }

  provisioner "file" {
    content     = "CONSUL_JOIN=\"-client ${element(hcloud_server.lbc.*.ipv4_address, count.index)} -bind ${element(hcloud_server.lbc.*.ipv4_address, count.index)} -join ${hcloud_server.consul.0.ipv4_address}\""
    destination = "/etc/default/consul-join"
  }

  provisioner "file" {
    content     = "CONSUL_TEMPLATE_OPTIONS=\"-consul-addr ${element(hcloud_server.lbc.*.ipv4_address, count.index)}:8500\""
    destination = "/etc/default/consul-template"
  }

  provisioner "remote-exec" {
    inline = [
      "systemctl restart consul",
      "systemctl restart consul-template",
    ]
  }
}

resource "null_resource" "consul-bind" {
  count = "${hcloud_server.consul.count}"

  triggers {
    consul_ips = "${join(",", hcloud_server.consul.*.ipv4_address)}"
  }

  provisioner "local-exec" {
    command = "ssh-keyscan ${element(hcloud_server.consul.*.ipv4_address, count.index)} >> ~/.ssh/known_hosts"
  }

  connection {
    user = "root"
    host = "${element(hcloud_server.consul.*.ipv4_address, count.index)}"
  }

  provisioner "file" {
    content     = "CONSUL_JOIN=\"-bind ${element(hcloud_server.consul.*.ipv4_address, count.index)}\""
    destination = "/etc/default/consul-join"
  }

  provisioner "remote-exec" {
    inline = [
      "systemctl restart consul",
    ]
  }
}

data "template_file" "floating_ip" {
  template = "${file("interface.tpl")}"

  vars = {
    floating_ip = "${hcloud_floating_ip.lbc_floating_ip.ip_address}"
  }
}
