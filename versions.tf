# =============================================================================
# versions.tf — Terraform and provider version constraints
# =============================================================================
# Pinning versions keeps demos reproducible: everyone gets the same behavior
# when they run `terraform init`. Without constraints, Terraform may pull
# a newer provider that behaves differently.
# =============================================================================

terraform {
  # Minimum Terraform CLI version required for this project.
  required_version = ">= 1.5.0"

  required_providers {
    docker = {
      # Official community Docker provider (maintained on the Terraform Registry).
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}
