# Show Your Terraform Demo to a Mentor

Use this checklist before or during a short meeting (5–10 minutes).

## Before the meeting

1. **Start Docker Desktop** (whale icon running).
2. **Apply infrastructure** (if not already running):

```bash
cd /Users/apple/terraform
export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"
terraform apply -auto-approve
```

3. **Generate a shareable log file:**

```bash
chmod +x show-mentor-demo.sh
./show-mentor-demo.sh
```

Send your mentor **`mentor-demo-output.txt`** (email, Slack, or screen share).

---

## Live demo (what to run on screen)

Run **one command at a time** and talk through each step.

| Step | Command | What to say |
|------|---------|-------------|
| 1 | `terraform init` | "This downloads the Docker provider plugin." |
| 2 | `terraform validate` | "Config is syntactically valid." |
| 3 | `terraform plan` | "Dry run — shows 2 resources to add." |
| 4 | `terraform apply -auto-approve` | "Creates image + container." |
| 5 | `terraform output` | "Structured outputs for URL and container name." |
| 6 | `docker ps --filter name=terraform-nginx` | "Real container in Docker." |
| 7 | Open http://localhost:8080 | "Nginx welcome page proves it works." |
| 8 | `terraform destroy -auto-approve` | "Clean teardown — full lifecycle." |

---

## What proves `terraform init` happened

Your mentor does **not** need a special output value. Show any of:

- Terminal message: **`Terraform has been successfully initialized!`**
- Folder: **`.terraform/`**
- File: **`.terraform.lock.hcl`**
- Command: **`terraform providers`** → lists `kreuzwerker/docker`

---

## Files worth showing in the IDE

| File | Why |
|------|-----|
| `main.tf` | Provider, image, container, ports |
| `variables.tf` | Config without hard-coding |
| `outputs.tf` | `nginx_url`, `container_name` |
| `terraform.tfstate` | State after apply (don't edit by hand) |
| `README.md` | Full documentation |

---

## Optional: screenshot pack

Take 4 screenshots:

1. `terraform init` success
2. `terraform apply` complete + outputs
3. `docker ps` showing `terraform-nginx`
4. Browser on http://localhost:8080

Paste into one PDF or Notion page for your mentor.

---

## If something is not running

```bash
open -a Docker
export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"
terraform apply -auto-approve
./show-mentor-demo.sh
```
