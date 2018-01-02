provider "docker" {
  host = "${var.docker_host}"
}

resource "docker_container" "dummy" {
  image = "${docker_image.dummy_server.latest}"
  name  = "dummy-server-${count.index}"
  count = 4
}

resource "docker_container" "lbc" {
  image = "${docker_image.lbc.latest}"
  name  = "lbc-${count.index}"
  count = 1

  ports {
    internal = 80
    external = 8080
  }

  upload {
    file    = "/etc/nginx/conf.d/backends"
    content = "${join("\n", formatlist("server %s:${var.dummy_server_port};", docker_container.dummy.*.ip_address))}\n"
  }
}

resource "docker_image" "dummy_server" {
  name = "${var.docker_registry_url}/dummy-server:0.1"
}

resource "docker_image" "lbc" {
  name = "${var.docker_registry_url}/dummy-lbc:0.1"
}
