# =============================================================================
# variables.tf — Inputs you can customize without editing main.tf
# =============================================================================
# Variables make the project reusable in interviews: "What if we used port
# 9090?" — change -var or a .tfvars file instead of hard-coding values.
# =============================================================================

variable "docker_host" {
  description = "Docker API socket URL. Leave empty for Docker Desktop default (~/.docker/run/docker.sock). Linux: unix:///var/run/docker.sock"
  type        = string
  default     = ""
}

variable "nginx_image" {
  description = "Docker image reference to pull from Docker Hub."
  type        = string
  default     = "nginx:latest"
}

variable "container_name" {
  description = "Name of the Docker container as shown in docker ps."
  type        = string
  default     = "terraform-nginx"

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]*$", var.container_name))
    error_message = "Container name must be a valid Docker name."
  }
}

variable "host_port" {
  description = "Port on the host machine (your laptop) mapped to the container."
  type        = number
  default     = 8080

  validation {
    condition     = var.host_port > 0 && var.host_port < 65536
    error_message = "Host port must be between 1 and 65535."
  }
}

variable "container_port" {
  description = "Port inside the container where Nginx listens."
  type        = number
  default     = 80
}
