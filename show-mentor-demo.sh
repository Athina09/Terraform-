#!/usr/bin/env bash
# Run from project root: ./show-mentor-demo.sh
# Saves proof of Terraform + Docker demo to mentor-demo-output.txt

set -euo pipefail

cd "$(dirname "$0")"
OUT="mentor-demo-output.txt"
export PATH="/Applications/Docker.app/Contents/Resources/bin:${PATH:-}"

{
  echo "============================================================"
  echo "Terraform + Docker Nginx Demo — Evidence for Mentor"
  echo "Generated: $(date)"
  echo "Host: $(hostname)"
  echo "User: $(whoami)"
  echo "Project: $(pwd)"
  echo "============================================================"
  echo

  echo ">>> 1. Terraform version"
  terraform version
  echo

  echo ">>> 2. Terraform initialized? (providers + .terraform folder)"
  if [[ -d .terraform ]]; then
    echo "YES — .terraform/ directory exists"
  else
    echo "NO — run: terraform init"
  fi
  ls -la .terraform.lock.hcl 2>/dev/null || echo "(no lock file yet)"
  echo
  terraform providers
  echo

  echo ">>> 3. Config valid?"
  terraform validate
  echo

  echo ">>> 4. Current infrastructure (state list)"
  terraform state list 2>/dev/null || echo "(no state — run terraform apply first)"
  echo

  echo ">>> 5. Terraform outputs (after apply)"
  terraform output 2>/dev/null || echo "(no outputs — run terraform apply first)"
  echo

  echo ">>> 6. Docker container running?"
  if command -v docker >/dev/null 2>&1; then
    docker ps --filter name=terraform-nginx
    echo
    echo ">>> 7. HTTP check (expect HTTP 200)"
    curl -s -o /dev/null -w "http://localhost:8080 → HTTP %{http_code}\n" http://localhost:8080 || echo "curl failed — is the container up?"
  else
    echo "docker not in PATH — start Docker Desktop and add:"
    echo 'export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"'
  fi
  echo

  echo ">>> 8. What this project does (one line)"
  echo "Terraform manages nginx:latest as container terraform-nginx on port 8080→80."
  echo
  echo "============================================================"
  echo "Share this file with your mentor: mentor-demo-output.txt"
  echo "Live URL: http://localhost:8080"
  echo "============================================================"
} | tee "$OUT"

echo
echo "Saved to: $OUT"
