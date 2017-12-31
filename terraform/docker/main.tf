variable "docker_host" {}
variable "docker_registry_url" {}

provider "docker" {
  host = "${var.docker_host}"
}

resource "docker_container" "dummy" {
  image = "${docker_image.dummy_server.latest}"
  name  = "dummy-server-${count.index}"
  count = 1
}

resource "docker_image" "dummy_server" {
  name = "${var.docker_registry_url}/dummy-server:0.1"
}
