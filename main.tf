terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}


provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_ssh_key" "DevOpsElite" {
  name = var.ssh_key_nome
}

resource "digitalocean_droplet" "dvopslit-jenkins" {
  image    = "ubuntu-22-04-x64"
  name     = "dvops-jenkins"
  region   = var.region
  size     = "s-2vcpu-2gb"
  ssh_keys = [data.digitalocean_ssh_key.DevOpsElite.id]
}

resource "digitalocean_kubernetes_cluster" "k8s" {
  name    = "k8s"
  region  = var.region
  version = "1.25.4-do.0"

  node_pool {
    name       = "default"
    size       = "s-2vcpu-2gb"
    node_count = 2

  }


}

variable "region" {
  default = ""
}

variable "do_token" {
  default = ""
}

variable "ssh_key_nome" {
  default = ""
}

output "jenkins_ip"{
  value = digitalocean_droplet.dvopslit-jenkins.ipv4_address
}

resource "local_file" "kbcnf"{
  content = digitalocean_kubernetes_cluster.k8s.kube_config.0.raw_config
  filename = "kube_config.yaml"
}