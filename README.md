# Infrastructure as Code

This project aims to be a complete (although simple) infrastructure as code solution.

**[WIP] Note that this is still work in progress.**

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

The basic idea is that there should be one file with variables that will be imported by all tools (vars.json).

I've decided to stick with JSON for now, as Packer doesn't support reading HCL at the moment. This JSON file can be imported by both packer and terraform on start.

While ansible could also include vars this way, I feel that its variable precedence rules are already complex enough, so for now I'm sticking with overriding defaults by `--extra-vars`.

In the end, there should be one file per environment for all required variables.

## Target infrastructures

The complete example should alllow easy deploy of the dummy http server to:

* AWS EC2
* Google Cloud Platform CE
* Docker containers
* KVM virtual machines

There should be also available [Vagrant](https://vagrantup.com/) box based on Virtualbox.

### Will the images be consistent?

You can get very close by using the same base images, since all of them will be provisioned by the same ansible playbook. There will always be some differences, but for most use cases, this should be good enough.

### Why would I use Vagrant instead of docker?

Most of the time - you wouldn't. Docker containers will make perfect development environments for most cases, but sometimes you might need even more consistency on local machine, for example down to the kernel version. VMs can help you achieve this.

It may also make sense to use both of them. Maybe your team needs to run some tests on "real" VMs, while another team's software uses your API and lightweight docker containers will be just enough for them for local development. As always, decide what's best for your use case.

# Resources

* https://blog.gruntwork.io/a-comprehensive-guide-to-terraform-b3d32832baca
* https://feryn.eu/speaking/build-provision-deploy-cloud-packer-ansible-terraform/
