Reference Infrastructure for AWS Virtual Private Cloud (VPC)
============================================================

Implements an `AWS Virtual Private Cloud <https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html/>`_ this is preconfigured to support an AWS Elastic Kubernetes Cluster. Amazon Virtual Private Cloud (Amazon VPC) enables you to launch AWS resources into a virtual network that you've defined. This virtual network closely resembles a traditional network that you'd operate in your own data center, with the benefits of using the scalable infrastructure of AWS.

Implementation Strategy
-----------------------

Our goal is to, as much as possible, implement a plain vanilla VPC that pre-configured as necessary to support an AWS Elastic Kubernetes Service instance. It generally uses all default configuration values.

This module uses the latest version of the community-supported `AWS VPC Terraform module <https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest>`_ to create a fully configured Virtual Private Cloud within your AWS account.
AWS VPC Terraform module is widely supported and adopted, with more than 100 open source code contributers, and more than 37 million downloads from the Terraform registry as of March, 2023.

What it creates
~~~~~~~~~~~~~~~

.. image:: doc/aws-vpc-eks.png
  :width: 100%
  :alt: Virtual Private Cloud Diagram

