terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.42"
    }

    consul = {
      source  = "hashicorp/consul"
      version = ">= 2.5"
    }

    nomad = {
      source  = "hashicorp/nomad"
      version = ">= 1.4"
    }

    vault = {
      source  = "hashicorp/vault"
      version = ">= 3.8.0"
    }

    # See: https://github.com/terraform-providers/terraform-provider-template/blob/v2.0.0/CHANGELOG.md#200-january-14-2019
    # Need to pin the minimum version for templates/fluent.conf
    template = {
      source  = "hashicorp/template"
      version = "~> 2.0"
    }
  }
}
