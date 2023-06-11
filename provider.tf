terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.7.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
  
  backend "s3" {
    bucket = "lior-terraform"
    key    = "terraform.tfstate"
    region = "eu-west-2"
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-west-2"
  default_tags {
    tags = {
      Owner           = "Lior.Rabanian"
      bootcamp        = "18"
      expiration_date = "26-06-23"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path            = "~/.kube/config"
    host = module.compute.cluster_endpoint
    token = module.compute.cluster_token
    cluster_ca_certificate = module.compute.cluster_ca_certificate
  }
}

provider "kubernetes" {
  config_path            = "~/.kube/config"
    host = module.compute.cluster_endpoint
    token = module.compute.cluster_token
    cluster_ca_certificate = module.compute.cluster_ca_certificate
}

provider "kubectl" {
    host = module.compute.cluster_endpoint
    token = module.compute.cluster_token
    cluster_ca_certificate = module.compute.cluster_ca_certificate
    # load_config_file       = false
}