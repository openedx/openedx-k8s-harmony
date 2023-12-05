#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Aug-2022
#
# usage: all providers for Kubernetes and its sub-systems. The general strategy
#        is to manage authentications via aws cli where possible, simply to limit
#        the environment requirements in order to get this module to work.
#
#        another alternative for each of the providers would be to rely on
#        the local kubeconfig file.
#------------------------------------------------------------------------------

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

