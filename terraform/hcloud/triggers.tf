resource "null_resource" "lbc_floating_ip" {
  count = "${hcloud_server.lbc.count}"

  triggers {
    x             = 2
    floating_ip   = "${hcloud_floating_ip.lbc_floating_ip.ip_address}"
    lbc_addresses = "${join(", ", hcloud_server.lbc.*.ipv4_address)}"
  }

  connection {
    user = "root"
    host = "${element(hcloud_server.lbc.*.ipv4_address, count.index)}"
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

resource "null_resource" "backends" {
  count = "${hcloud_server.lbc.count}"

  triggers {
    backends_ips = "${join(",", hcloud_server.node.*.ipv4_address)}"
  }

  provisioner "local-exec" {
    command = "ANSIBLE_CONFIG=../../ansible/ansible.cfg ansible-playbook ../../ansible/load-balancer.yml -t nginx-config-backends -D -e '${element(data.template_file.ansible_vars.*.rendered, count.index)}' -i ${element(hcloud_server.lbc.*.ipv4_address, count.index)},"
  }
}

data "template_file" "ansible_vars" {
  count = "${hcloud_server.lbc.count}"

  template = "${file("ansible.tpl")}"

  vars = {
    backends = "${join(", ", formatlist("\"%s:${var.dummy_server_port}\"", hcloud_server.node.*.ipv4_address))}"
    host     = "${element(hcloud_server.lbc.*.ipv4_address, count.index)}"
  }
}

data "template_file" "floating_ip" {
  template = "${file("interface.tpl")}"

  vars = {
    floating_ip = "${hcloud_floating_ip.lbc_floating_ip.ip_address}"
  }
}
