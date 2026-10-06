# Infra / DevOps

**Owner:** DevOps

You own everything about building, testing, and deploying the project.
This README is your starting brief. **There is no infra code in the repo yet; creating it is your job.**

## Environments & Deployments

| Environment | Setup | Trigger / Lifetime | Purpose |
| ----------- | ----- | ------------------ | ------- |
| **Dev (VPS)** | Docker Compose | Auto-deployed on every merge to `main`. Permanent. | Teams test against the latest merged code. |
| **Staging (Cluster)** | Kubernetes (Terraform + Helm + ArgoCD) | Triggered by Release Candidate tag (`v*-rc.*`). Temporary (destroyed after QA). | QA conducts tests on a live cluster without draining cloud credits. |
| **Prod** | Official GitHub Release | Promoted from staging once QA signs off (`v*` tag). | Tagged images & GitHub release. (Not hosted on a separate live server). |

> [!IMPORTANT]
> - Dev is permanent on the VPS via Docker Compose.
> - Staging on Kubernetes is temporary: spin up for testing, verify, and destroy once QA finishes.
> - Both environments run the **same Docker images**: build once, deploy anywhere.

## Suggested layout

```
infra/
├── docker-compose.yml   # Dev deployment on VPS (and local dev)
├── terraform/           # provisions / destroys the staging Kubernetes cluster
├── helm/                # one chart per service (backend, ai, frontend)
└── argocd/              # ArgoCD Applications pointing at the Helm charts
```

## What each team gives you

| Service  | Port in container | Health endpoint | Notes                                               |
| -------- | ----------------- | --------------- | --------------------------------------------------- |
| backend  | 8080              | `GET /health`   | needs Postgres connection string + `AI_SERVICE_URL` |
| ai       | 8000              | `GET /health`   | needs `GEMINI_API_KEY`                              |
| frontend | 80 (nginx)        | `/`             | static Flutter web build                            |
| postgres | 5432              | n/a             | official image                                      |

Settings reach services through **environment variables** (see each team's README). Teams write the code;
you help them write the `Dockerfile` in their own folder (open a PR in their folder and tag them).

## Your TODO (in this order)

1. [ ] **GitHub settings** - apply the checklist at the bottom of [docs/branching.md](../docs/branching.md)
       (protect `main`, require the `CI passed` check, create `dev`/`staging` environments, protect `v*` tags).
2. [ ] **CI workflow** - one GitHub Actions workflow, see the spec below.
3. [ ] **Dockerfiles** - one per service, in the service's folder.
4. [ ] **Compose file** - the full stack on one machine; used for Dev on the VPS and local development.
5. [ ] **Dev pipeline** - on merge to `main`: build images, tag with commit SHA, push to GHCR, deploy to VPS (Dev).
6. [ ] **Staging pipeline** - on tag `v*-rc.*`: spin up temporary K8s cluster (Terraform), deploy Helm charts via ArgoCD for QA testing.
7. [ ] **Release promotion** - on QA approval: push final release tag `v*`, create GitHub Release, and destroy the staging cluster.

## CI spec (what the PR check must do)

The branching rules depend on a single required check named **`CI passed`**. Requirements:

- Runs on every PR to `main`, and on merge queue / push to `main`.
- **Do not use workflow-level `paths:` filters.** A required check skipped by a path filter stays "pending"
  forever and blocks the PR. Detect changed folders _inside_ the workflow
  (e.g. `dorny/paths-filter`) and skip jobs individually.
- Per folder, when it changed:
  - `backend/` → restore, build, test, build the Docker image
  - `frontend/` and `mobile/` → `flutter pub get`, `flutter analyze`, `flutter test` (+ `flutter build web` for frontend)
  - `ai/` → install requirements, lint (ruff), tests with **Gemini mocked** (CI has no API key), Docker build
- Folders with no project yet must **skip cleanly**, not fail.
- A final always-running job named `CI passed` that fails if any job failed or was cancelled
  (skipped is fine). This is the only job set as "required" in branch protection.
- Once Dockerfiles exist: add a job that starts the whole stack and curls every `/health`. This is the
  pre-merge verification before code enters `main`.

## Rules

- Secrets: **GitHub Actions secrets / environment secrets** and the server's `.env`. Never in the repo.
  No secrets in Helm values either; use Kubernetes Secrets.
- Staging cluster must be destroyed after QA completes to conserve cloud credits.
