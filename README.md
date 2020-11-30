# NGINX Controller Automation Demo

## Overview

This demo uses Packer, Terraform, and Ansible to automate the setup of an NGINX Controller AWS pseudo-production environment that includes a PostgreSQL external database, a mock SMTP server, and a series of NGINX Plus instances.

## Requirements

### Packer

This demo has been developed and tested with Packer `1.6.x`. Backwards compatibility is not guaranteed.

Instructions on how to install Packer can be found in the [Packer website](https://www.packer.io/downloads.html).

### Terraform

This demo has been developed and tested with Terraform `0.13.x`. Backwards compatibility is not guaranteed.

Instructions on how to install Terraform can be found in the [Terraform website](https://www.terraform.io/downloads.html).

### Ansible

This demo has been developed and tested with Ansible `2.10.x`. Backwards compatibility is not guaranteed.

Instructions on how to install Ansible can be found in the [Ansible website](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html).

### NGINX Controller & NGINX Plus

You will need to download the NGINX Controller tar file, NGINX Controller license, and NGINX Plus license from your [MyF5 portal](https://account.f5.com/myf5) before you run this script.

You will also need a FQDN for NGINX Controller with its `A record` pointing to an AWS elastic IP.

## Guide

There are three "distinct" steps to this NGINX Controller automation demo:

1.  **Packer** prebuilds AWS AMIs (using the Ansible provisioner) for PostgreSQL, a mock SMTP server, NGINX Controller, and NGINX Plus. Packer templates (and the corresponding Ansible playbooks used by Packer) can be found in the [`packer/`](packer/) directory.
2.  **Terraform** deploys a pseudo-production ready NGINX Controller infrastructure environment in AWS using the AWS AMIs created by Packer. Terraform modules can be found in the [`terraform/`](terraform/) directory.
3.  **Ansible** installs and configures NGINX Controller on the NGINX Controller instance and the NGINX Controller agent on the NGINX Plus instance. Ansible playbooks can be found in the [`ansible/`](ansible/) directory.

In turn, there are four "distinct" components deployed in this NGINX Controller automation demo:

1.  **NGINX Controller**
2.  **NGINX Plus instance(s)**
3.  **PostgreSQL database**
4.  **Mock SMTP server**

Both Packer and Terraform have been separated into logical subdirectories following the above four "distinct" components.

For ease of use, both the Packer and Ansible steps have been included in the Terraform script at the top and bottom of [`main.tf`](main.tf) respectively. However, you can decouple Packer and Ansible from Terraform setting the `run_packer` and `run_ansible` variables to `false` within your Terraform variables, and then running each step separately as detailed below.

### Packer

To use the provided Packer templates, you will first need to:

1.  Export your AWS credentials as environment variables (or alternatively, use one of the authentication methods described in the [Packer AWS builder docs](https://www.packer.io/docs/builders/amazon).
2.  Tweak any desired variables (detailed within each respective Packer template). Alternatively, you can input those variables at runtime.

There are four Packer templates in this demo:

|Name|Description|
|----|-----------|
|[`nginx.pkr.hcl`](packer/nginx/nginx.pkr.hcl)|Build an NGINX Plus AMI|
|[`nginx-controller.pkr.hcl`](packer/nginx-controller/nginx-controller.pkr.hcl)|Build an NGINX Controller AMI|
|[`postgresql.pkr.hcl`](packer/postgresql/postgresql.pkr.hcl)|Build a PostgreSQL database|
|[`smtp.pkr.hcl`](packer/smtp/smtp.pkr.hcl)|Build a mock SMTP server|

To start a Packer build, run:

```
packer build packer/<subdirectory>/<template>.pkr.hcl
```

(**Note:** Both the `nginx-controller.pkr.hcl` and `nginx.pkr.hcl` Packer templates require you to explicitly set some variables.)

### Terraform

To use the provided Terraform deployment, you will first need to:

1.  Export your AWS credentials as environment variables (or alternatively, tweak the AWS provider in [`provider.tf`](provider.tf)).
2.  Tweak any desired variables in [`variables.tf`](variables.tf). Alternatively, you can input those variables at runtime.

There are five Terraform modules in this demo:

|Name|Description|
|----|-----------|
|[`network/`](terraform/network/)|Deploy NGINX Controller's network stack|
|[`nginx-controller/`](terraform/nginx-controller/)|Deploy NGINX Controller instance and relevant network components|
|[`nginx/`](terraform/nginx/)|Deploy NGINX Plus instance(s) and relevant network components|
|[`postgresql/`](terraform/postgresql/)|Deploy PostgreSQL instance|
|[`smtp/`](terraform/smtp/)|Deploy mock SMTP instance|

To start the AWS NGINX Controller deployment, you can either:

*   Run [`./setup.sh`](setup.sh) to initialize Terraform and start the Terraform deployment.
*   Run `terraform init` and `terraform apply`.

Once you are done playing with NGINX Controller, you can destroy the AWS NGINX Controller deployment by either:

*   Run [`./cleanup.sh`](cleanup.sh) to destroy your Terraform deployment.
*   Run `terraform destroy` (you can optionally delete your `.terraform` directory too).

### Ansible

To use the provided Ansible playbooks, you will first need to install the required collections/roles by running:

```
ansible-galaxy install -r ansible/requirements.yml
```

There are two Ansible playbooks in this demo:

|Name|Description|
|----|-----------|
|[`nginx-controller-install.yml`](ansible/nginx-controller-install.yml)|Install and configure NGINX Controller|
|[`nginx-controller-agent.yml`](ansible/nginx-controller-agent.yml)|Install and configure the NGINX Controller agent|

To execute a playbook, run:

```
ansible-playbook --private-key=</path/to/key> -i </instance/ip>, -u ubuntu ansible/<playbook>.yml
```

(**Note:** You will first need to install and configure NGINX Controller using the `nginx-controller-install.yml` playbook before you can install the NGINX Controller agent on NGINX Plus instances using the `nginx-controller-agent.yml` playbook.)

## Author Information

[Alessandro Fael Garcia](https://github.com/alessfg)
