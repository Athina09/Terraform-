# Terraform + Docker + Nginx — Beginner IaC Demo

A **cloud-free** Infrastructure as Code demo: Terraform provisions a local Nginx container via the Docker provider. Ideal for workshops, interviews, and first-time Terraform learners.

## What you will learn

- Declare infrastructure in `.tf` files (desired state)
- Initialize providers (`terraform init`)
- Preview changes safely (`terraform plan`)
- Apply and destroy lifecycle (`terraform apply` / `terraform destroy`)
- How **state**, **providers**, and the **plan/apply** workflow fit together

## Prerequisites

| Requirement | Check |
|-------------|--------|
| [Terraform](https://developer.hashicorp.com/terraform/install) ≥ 1.5 | `terraform version` |
| [Docker](https://docs.docker.com/get-docker/) running | `docker info` |
| Port **8080** free on your machine | `lsof -i :8080` (optional) |

> **No AWS/Azure/GCP account** is required. Everything runs on your laptop.

## Project layout

```
.
├── versions.tf      # Terraform & provider version pins
├── main.tf          # Provider + Docker image + container
├── variables.tf     # Configurable inputs (ports, names)
├── outputs.tf       # URLs and hints after apply
├── README.md        # This guide
└── DEMO_SCRIPT.md   # Live presentation talking points
```

## Quick start — step by step

> **Important:** Run **one command per line**. Do not paste the whole block at once.
> Inline comments (e.g. `terraform apply # type yes`) break Terraform and `open` on macOS.
> Confirm Docker works first: `docker info` (not `docker not found`).

Run every command from this directory:

```bash
cd /Users/apple/terraform
```

### 0. Install and start Docker (required)

Terraform talks to Docker through the Docker Engine API. If `docker` is not found:

1. Install [Docker Desktop for Mac](https://docs.docker.com/desktop/setup/install/mac-install/) (Apple Silicon or Intel, matching your Mac).
2. Open **Docker Desktop** from Applications and wait until it says **Docker is running**.
3. Open a **new** terminal tab and verify:

```bash
docker info
```

You should see server version info, not `command not found`.

### 1. Initialize Terraform

Downloads the Docker provider plugin and prepares the working directory.

```bash
terraform init
```

**Expected:** `Terraform has been successfully initialized!`

### 2. Preview changes (dry run)

Shows what Terraform *would* create without changing Docker yet.

```bash
terraform plan
```

**Expected:** Plan to add `docker_image.nginx` and `docker_container.nginx`.

### 3. Create infrastructure

Type `yes` when prompted.

```bash
terraform apply
```

Non-interactive (CI / demos):

```bash
terraform apply -auto-approve
```

**Expected:** Apply complete, outputs include `nginx_url = "http://localhost:8080"`.

### 4. Verify with Docker CLI

Confirm the container is running and ports are mapped:

```bash
docker ps
```

Look for a row similar to:

| NAMES | PORTS | IMAGE |
|-------|-------|-------|
| terraform-nginx | `0.0.0.0:8080->80/tcp` | nginx |

Filter by name:

```bash
docker ps --filter name=terraform-nginx
```

Or use Terraform output:

```bash
terraform output docker_ps_hint
```

### 5. Test in the browser

Open this URL manually, or run `open` on its own line (no `#` comment on the same line):

```bash
open http://localhost:8080
```

Or visit **http://localhost:8080** in Chrome/Safari.

You should see the default **"Welcome to nginx!"** page.

Alternative terminal check:

```bash
curl -I http://localhost:8080
```

### 6. Tear down (cleanup)

Removes the container and Terraform-managed resources.

```bash
terraform destroy
```

Confirm with `yes` when prompted, or:

```bash
terraform destroy -auto-approve
```

---

## How Terraform works internally

### 1. Terraform Core vs providers

```
┌─────────────────┐     RPC/API      ┌──────────────────┐
│  Terraform CLI  │ ◄──────────────► │ Docker provider  │
│  (Core)         │                  │ plugin           │
└────────┬────────┘                  └────────┬─────────┘
         │                                    │
         │ reads/writes                       │ Docker Engine API
         ▼                                    ▼
┌─────────────────┐                  ┌──────────────────┐
│  State file     │                  │  Docker daemon   │
│  terraform.tfstate                 │  (containers)    │
└─────────────────┘                  └──────────────────┘
```

- **Terraform Core** parses `.tf` files, builds a dependency graph, and orchestrates create/update/delete.
- **Providers** (here: `kreuzwerker/docker`) translate resource types like `docker_container` into real API calls.
- Your **configuration** (`.tf`) is *desired state*; Docker is *actual state*.

### 2. State file (`terraform.tfstate`)

After the first `apply`, Terraform writes **`terraform.tfstate`** locally (default backend). It records:

- Resource IDs (e.g. container ID)
- Attributes Terraform needs on the next run
- Metadata for dependency tracking

**Why it matters:** On the next `plan`, Terraform compares **config + state** to **reality** (via the provider). If someone deletes the container manually, the next plan shows **drift** and offers to recreate it.

> Do not edit state by hand as a beginner. Use `terraform state` commands only when you understand the implications.

### 3. Plan / apply lifecycle

| Phase | Command | What happens |
|-------|---------|----------------|
| Init | `terraform init` | Download providers, set up backend |
| Plan | `terraform plan` | Diff: desired vs state vs real world (read-only) |
| Apply | `terraform apply` | Execute planned changes in dependency order |
| Destroy | `terraform destroy` | Remove all resources in config (reverse order) |

**Plan** is your safety net: review adds/changes/destroys before anything touches Docker.

### 4. Resource graph in this demo

```
docker_image.nginx  ──►  docker_container.nginx
     (pull image)            (run container)
```

Terraform creates the image resource first because the container references `docker_image.nginx.image_id`.

---

## Customization

| Variable | Default | Example override |
|----------|---------|------------------|
| `container_name` | `terraform-nginx` | `-var="container_name=demo-nginx"` |
| `host_port` | `8080` | `-var="host_port=9090"` |
| `nginx_image` | `nginx:latest` | `-var="nginx_image=nginx:1.25"` |

Example:

```bash
terraform apply -var="host_port=9090"
```

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `command not found: docker` | Install Docker Desktop, start it, open a new terminal, run `docker info` |
| `Error: Too many command line arguments` on apply/destroy | You pasted a comment on the same line; run only `terraform apply` or `terraform destroy` |
| `open` tries to open files named `#`, `or`, `visit` | Never put `# comments` on the same line as `open`; use `open http://localhost:8080` alone |
| `Cannot connect to the Docker daemon` | Start Docker Desktop / `sudo systemctl start docker` |
| `port is already allocated` | Stop the other service or change `host_port` |
| `container name already in use` | `docker rm -f terraform-nginx` or run `terraform destroy` |
| Provider install fails | Check network; retry `terraform init` |

Format and validate configuration:

```bash
terraform fmt -recursive
terraform validate
```

---

## Interview / presentation tips

1. Start with **why IaC**: repeatable, reviewable, version-controlled infrastructure.
2. Show **`terraform plan`** before every **`apply`** — demonstrates safe workflow.
3. Open **`main.tf`** and walk one resource block at a time.
4. After apply, show **`docker ps`** and the browser — connects code to running system.
5. Run **`terraform destroy`** to prove lifecycle management.

See **[DEMO_SCRIPT.md](./DEMO_SCRIPT.md)** for a minute-by-minute live demo script.

---

## License

Demo project for education — use freely in workshops and interviews.
