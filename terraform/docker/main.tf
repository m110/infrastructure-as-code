provider "docker" {
  host = "${var.docker_host}"
}

resource "docker_container" "dummy" {
  image = "${docker_image.dummy_server.latest}"
  name  = "dummy-server-${count.index}"
  count = 2
}

resource "docker_container" "lbc" {
  image = "${docker_image.lbc.latest}"
  name  = "lbc-${count.index}"
  count = 1

  ports {
    internal = 80
    external = 8080
  }
}

resource "docker_image" "dummy_server" {
  name = "${var.docker_registry_url}/dummy-server:0.1"
}

resource "docker_image" "lbc" {
  name = "${var.docker_registry_url}/dummy-lbc:0.1"
}

resource "null_resource" "backends" {
  triggers {
    backends_ips = "${join(",", docker_container.dummy.*.ip_address)}"
  }

  provisioner "local-exec" {
    command = "ANSIBLE_CONFIG=../../ansible/ansible.cfg ansible-playbook ../../ansible/load-balancer.yml -t nginx-config -D -e '${jsonencode(local.ansible_vars)}' -i ${docker_container.lbc.ip_address},"
  }
}

locals {
  ansible_vars = {
    nginx = {
      become   = false
      backends = "${formatlist("%s:${var.dummy_server_port}", docker_container.dummy.*.ip_address)}"
    }

    ansible_connection        = "docker"
    ansible_docker_extra_args = "-H=${var.docker_host}"
    ansible_host              = "${docker_container.lbc.name}"
    host                      = "${docker_container.lbc.ip_address}"
  }
}
