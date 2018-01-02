resource "aws_security_group" "elb" {
  name   = "dummy-server-elb"
  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "dummy_elb" {
  name = "dummy-server-elb"

  subnets         = ["${aws_subnet.default.id}"]
  security_groups = ["${aws_security_group.elb.id}"]
  instances       = ["${aws_instance.dummy-server.*.id}"]

  listener {
    instance_port     = "${var.dummy_server_port}"
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}
