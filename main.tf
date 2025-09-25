terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {}

# Pull Nginx latest image
resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = false
}

# Run Nginx container
resource "docker_container" "nginx" {
  name  = "nginx-container"
  image = docker_image.nginx.name   # <-- FIXED HERE
  ports {
    internal = 80
    external = 8080
  }
}

