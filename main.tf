# =============================================================================
# main.tf — Core infrastructure definition (Docker + Nginx)
# =============================================================================
# This file declares WHAT you want: an Nginx image pulled from Docker Hub
# and a container listening on port 80 inside, mapped to 8080 on your machine.
# Terraform compares this desired state with reality (and with state) on
# plan/apply.
# =============================================================================

# -----------------------------------------------------------------------------
# Provider block — tells Terraform HOW to talk to Docker
# -----------------------------------------------------------------------------
# A "provider" is a plugin that implements an API (here: Docker Engine).
# Terraform Core does not know Docker natively; it loads this plugin at init.
# -----------------------------------------------------------------------------
locals {
  # Default: Docker Desktop on macOS. Linux: -var='docker_host=unix:///var/run/docker.sock'
  docker_host = var.docker_host != "" ? var.docker_host : "unix://${pathexpand("~/.docker/run/docker.sock")}"
}

provider "docker" {
  host = local.docker_host
}

# -----------------------------------------------------------------------------
# docker_image — pull (or refresh) the Nginx image from Docker Hub
# -----------------------------------------------------------------------------
# Terraform tracks this resource in state. On apply, the provider ensures
# the image exists locally. Using "nginx:latest" always resolves to the
# current latest tag when you apply again (image ID may change).
# -----------------------------------------------------------------------------
resource "docker_image" "nginx" {
  # Image reference on Docker Hub: official Nginx image, latest tag.
  name = var.nginx_image

  # If false, Terraform may remove the image on destroy when nothing else uses it.
  # true keeps the image cached for faster re-applies during demos.
  keep_locally = true
}

# -----------------------------------------------------------------------------
# docker_container — run Nginx in a named container with port mapping
# -----------------------------------------------------------------------------
# This is the "compute" resource in our demo: one container, one service.
# depends_on is implicit via image = docker_image.nginx.image_id (reference).
# -----------------------------------------------------------------------------
resource "docker_container" "nginx" {
  # Human-readable name shown in `docker ps` (requirement: terraform-nginx).
  name = var.container_name

  # Use the image ID from the docker_image resource (stable binding in state).
  image = docker_image.nginx.image_id

  # Must match container name if you replace an existing container outside Terraform.
  # For a clean demo, leave false unless you hit name conflicts.
  must_run = true

  # ---------------------------------------------------------------------------
  # Port mapping — host:container
  # ---------------------------------------------------------------------------
  # external = port on your laptop (browser hits localhost:8080)
  # internal = port inside the container (Nginx listens on 80 by default)
  # ---------------------------------------------------------------------------
  ports {
    internal = var.container_port
    external = var.host_port
  }

  # Optional: pass a label for easier filtering in `docker ps --filter`
  labels {
    label = "managed_by"
    value = "terraform"
  }

  labels {
    label = "demo"
    value = "docker-nginx"
  }
}
