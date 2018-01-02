output "public_ips" {
  value = ["${aws_instance.dummy-server.*.public_ip}"]
}

output "address" {
  value = ["${aws_elb.dummy_elb.dns_name}"]
}
