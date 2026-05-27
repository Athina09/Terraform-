# =============================================================================
# outputs.tf — Values printed after apply (useful for demos and automation)
# =============================================================================
# Outputs do not create infrastructure; they expose information from resources
# after apply. They also appear in `terraform output` and in CI logs.
# =============================================================================

output "container_id" {
  description = "Full Docker container ID (from Terraform state / Docker API)."
  value       = docker_container.nginx.id
}

output "container_name" {
  description = "Container name for docker CLI commands."
  value       = docker_container.nginx.name
}

output "nginx_url" {
  description = "Open this URL in a browser to verify Nginx is serving traffic."
  value       = "http://localhost:${var.host_port}"
}

output "docker_ps_hint" {
  description = "Command to verify the container is running."
  value       = "docker ps --filter name=${var.container_name}"
}

output "demo_status" {
  description = "One-line summary for mentors and interviews."
  value       = "RUNNING — ${var.container_name} on ${var.host_port}→${var.container_port} (${var.nginx_image})"
}

output "mentor_proof" {
  description = "Commands to paste in terminal when showing your mentor."
  value = <<-EOT
    terraform providers    # proves init (Docker provider installed)
    terraform output       # this URL and status
    docker ps --filter name=${var.container_name}
    open http://localhost:${var.host_port}
  EOT
}
