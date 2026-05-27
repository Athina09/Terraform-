# Live Demo Presentation Script (≈10–12 minutes)

Use this script while screen-sharing: editor (left), terminal (right), browser ready on `http://localhost:8080`.

---

## 0. Opening (30 seconds)

> "Today I'll show **Infrastructure as Code** with Terraform — without any cloud account. We'll provision a real **Nginx web server** running in **Docker** on my laptop. Everything you see is defined in text files we can commit to Git, review in PRs, and reproduce on any machine with Docker."

**Show:** Project folder in IDE — `versions.tf`, `variables.tf`, `main.tf`, `outputs.tf`.

---

## 1. The problem Terraform solves (45 seconds)

> "Manually running `docker run` works once, but it's hard to repeat, document, and review. Terraform lets us declare **desired state** — what should exist — and the tool figures out **how** to get there. If I run this demo tomorrow, I get the same container name, same ports, same image."

**Optional:** Briefly open `variables.tf` — point at `container_name` and `host_port` defaults.

---

## 2. How Terraform is structured (1 minute)

> "Four ideas to remember: **configuration** (our `.tf` files), **providers** (plugins that talk to APIs), **state** (Terraform's memory of what it created), and the **plan/apply** workflow."

**Show:** `versions.tf`

> "Here we pin Terraform and the **Docker provider** from the public registry. `terraform init` downloads this plugin — Terraform Core doesn't know Docker by itself."

**Show:** `main.tf` — provider block

> "This `provider "docker"` block tells Terraform where the Docker daemon is — the local socket."

**Show:** `docker_image` resource

> "First resource: pull **nginx:latest** from Docker Hub. Terraform tracks this as its own object in state."

**Show:** `docker_container` resource

> "Second resource: run a container named **terraform-nginx**, map **host port 8080** to **container port 80** — standard Nginx. The container depends on the image through this reference."

---

## 3. `terraform init` (1 minute)

**Terminal:**

```bash
terraform init
```

> "Init sets up the working directory: downloads the Docker provider, creates the `.terraform` folder. I only need to run this again if I change provider versions or add a new provider."

**Point at output:** `Installing kreuzwerker/docker...`

---

## 4. `terraform plan` (1.5 minutes)

**Terminal:**

```bash
terraform plan
```

> "Plan is a **read-only dry run**. Terraform reads my config, reads the state file — empty on first run — and asks Docker what exists. It prints a diff: **2 to add**, zero to change, zero to destroy."

**Scroll plan output:**

> "Green plus means create. Notice the dependency order: image first, then container. In a team, we'd paste this plan in a pull request for review — same mindset as code review."

---

## 5. `terraform apply` (2 minutes)

**Terminal:**

```bash
terraform apply
```

> "Apply executes the plan. I'll type **yes** — in CI we'd use `-auto-approve` with guardrails."

**After success — show outputs:**

> "Terraform prints **outputs**: container ID, name, and the URL to test. Outputs are how we expose values to humans or to other automation."

---

## 6. Verify with Docker (1 minute)

**Terminal:**

```bash
docker ps --filter name=terraform-nginx
```

> "This isn't Terraform anymore — it's the real world. We see **terraform-nginx**, image **nginx**, ports **8080→80**. Terraform and Docker agree; that's what we want."

**Optional:**

```bash
terraform show
```

> "I can also inspect what Terraform believes is deployed — synced from state."

---

## 7. Browser test (30 seconds)

**Browser:** open `http://localhost:8080`

> "Welcome to nginx — proof that our declared infrastructure is serving HTTP. We went from HCL files to a running service in under a minute."

**Optional:**

```bash
curl -I http://localhost:8080
```

---

## 8. State and drift (1 minute)

**Show:** `terraform.tfstate` in file tree (do not scroll secrets — there are none here)

> "After apply, Terraform wrote **terraform.tfstate**. It maps logical names like `docker_container.nginx` to real IDs. Next plan uses this so Terraform knows whether to create, update, or delete."

> "If someone deleted this container with `docker rm`, the next `terraform plan` would show drift and offer to recreate it — **configuration as source of truth**."

---

## 9. `terraform destroy` (1 minute)

**Terminal:**

```bash
terraform destroy
```

> "Destroy walks the graph in reverse and removes what Terraform manages. Important for demos and cost — here it stops the container so port 8080 is free."

**Confirm** `docker ps` no longer lists `terraform-nginx`.

---

## 10. Closing (30 seconds)

> "We covered the full lifecycle: **init → plan → apply → verify → destroy**. The same workflow applies to AWS, Azure, or GCP — only the provider and resources change. The mental model — desired state, state file, plan before apply — stays the same."

**Q&A prompts you can invite:**

- "How would you store state for a team?" → remote backend (S3 + DynamoDB, Terraform Cloud, etc.)
- "How do you handle secrets?" → never in Git; use env vars, Vault, or cloud secret stores
- "Modules?" → reuse this config as a module called from a root module

---

## Backup lines if something fails

| Situation | Say |
|-----------|-----|
| Docker not running | "Terraform is only as healthy as the provider API — Docker must be up." |
| Port in use | "Plans are cheap; I'll change `host_port` or free the port — that's normal ops." |
| Name conflict | "State and reality diverged — `terraform destroy` or remove the old container, then re-apply." |

---

**Total time:** ~10–12 minutes with questions. For a 5-minute version, skip section 8 and shorten Q&A.
