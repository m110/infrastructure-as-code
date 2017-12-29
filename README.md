# Infrastructure as Code

This project aims to be a complete (although simple) infrastructure as code solution.

## Goals

### Infrastructure as a code

* define all infrastructure as version-controlled text files
* automate deployment and provisioning
* ...all other IaC benefits already widely discussed

### Avoiding provider lock-in

* don't stick to one provider by using proprietary tools
* it should be straightforward to migrate the infrastructure to another provider, if the need arises
* specifically, it should be possible to easily migrate between cloud (e.g. AWS) and self-hosted VMs or docker containers

### Consistent development environments

* strive for prod-dev parity as much as possible
* make running local environment seamless for developers

## Solution

### Tools

#### [Ansible](https://ansible.com)

Ansible is one of many configuration management solutions. I like it mostly for the agent-less approach and elegant definitions.

However, due to its procedural style of tasks definition, it can become quite cumbersome for managing existing servers in specific cases.
Because of that and because I'd like to strive for more immutable infrastructure, this project will use it only as a provisioning tool.

#### [Packer](https://packer.io)

Packer will be used for building images for various providers. It will also handle some minimal provisioning, like installing python for ansible to run.

#### [Terraform](https://terraform.io)

Terraform will be responsible for creating the infrastructure for chosen provider based on built images.

## Variables

There should be one file per environment for all required variables.

## Target infrastructures

The complete example should alllow easy deploy of the dummy http server to:

    * AWS EC2
    * Google Cloud Platform CE
    * Docker containers
    * KVM virtual machines

There should be also available [Vagrant](https://vagrantup.com/) box consistent with other images.

# Resources

* https://blog.gruntwork.io/a-comprehensive-guide-to-terraform-b3d32832baca
* https://feryn.eu/speaking/build-provision-deploy-cloud-packer-ansible-terraform/
