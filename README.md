# Coaster

This is a Docker (version 17.06+) container for automatically building minimal rolling CentOS 7 ISO images with unattended installation routines.

Currently it includes open-vm-tools, injects an RSA public key, enables DHCP & SSH w/ passwordless sudo and installs to /dev/sda.

The goal is to provide an ideal image for rapidly deploying Kubernetes using a tool like [MetalK8s](https://github.com/scality/metalk8s) which can then use Ansible to take care of the rest.

Coaster can be invoked like this:

```./run```

The resulting ISO is created in the _output_ directory

This early version is not very modular and does not have much error handling, but you can modify the included kickstart to suit your needs.