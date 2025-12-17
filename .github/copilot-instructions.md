# Copilot Instructions for this Repo

Use this guide to get productive fast in this polyglot microservices + Helm + Terraform repo.

## Big Picture
- Architecture: 3 services deployed to Kubernetes via a Helm umbrella chart; optional Azure/GCP tracks. Terraform under `infra/gcp` provisions GKE, VPC, IAM, Secret Manager, and Artifact Registry.
- Services and ports:
  - `patient-service` (Node/Express) on `3000` with `/health`, `/patients`, `/patients/:id`.
  - `application-service` (Node/Express) on `3001` with `/health`, `/appointments`, `/appointments/:id`, `/appointments/patient/:patientId`.
  - `order-service` (Spring Boot + JPA/H2) on `8080` with REST CRUD under `/orders`.

## Local Dev & Build
- Node services: run from repo root paths
  - `cd patient-service && npm install && npm run start`
  - `cd application-service && npm install && npm run start`
  - If `package.json` is missing locally, run `node src/index.js` (simple Express servers).
- Java service:
  - `cd order-service && mvn clean package -DskipTests` (uses JDK 17, Spring Boot 3.4).
  - Jar name: `target/order-service-0.0.1-SNAPSHOT.jar` (see `pom.xml`).

## Docker & Images
- Java image build is multi-stage in `order-service/Dockerfile` (Maven build, then `eclipse-temurin:17-jre`).
- Default Helm values reference GCR images. Override via chart values or `--set`:
  - Example: `helm upgrade --install healthcare-umbrella helm/umbrella --set charts.patient-service.image.repository=gcr.io/<PROJECT>/patient-service --set charts.patient-service.image.tag=<TAG>`.
- Registry quick setup and push commands are documented in `README-commands.md` (ACR/GCR/Artifact Registry).

## Kubernetes/Helm
- Umbrella chart: `helm/umbrella` with subcharts for each service.
- Service type defaults to `LoadBalancer`; port `80` → `targetPort` per service (`values.yaml`).
- Key files:
  - Templates: `helm/umbrella/charts/*/templates/{deployment.yaml,service.yaml}`.
  - Values: `helm/umbrella/charts/*/values.yaml` (repository, `tag`, `service.port`, env, resources).
- Registry and pull secrets:
  - Use `global.registry` to prefix image paths; `global.imagePullSecrets` for private registries.
- Secrets:
  - `global.keyvault.enabled` toggles Azure Key Vault CSI in charts; for GCP, prefer Secret Manager (see Terraform section) and inject in app config/environment.

## Terraform (GCP)
- Envs: `infra/gcp/envs/{dev,staging,prod}` with shared modules under `infra/gcp/modules`.
- What gets provisioned:
  - VPC + subnets (`modules/network`), IAM (`modules/iam`), Secret Manager (`modules/secret_manager`), Artifact Registry (`modules/artifact_registry`), and GKE (`modules/gke`).
- Dev workflow (see `README-commands.md`):
  - Set project/region; create GCS bucket for state; `terraform init -backend-config=...`.
  - `terraform workspace select <env> && terraform fmt && terraform validate && terraform plan -var-file=terraform.tfvars && terraform apply -var-file=terraform.tfvars -auto-approve`.
- Key variables/files:
  - `infra/gcp/envs/dev/terraform.tfvars` (e.g., `project_id`, `cluster_name`, `repo_name`, `artifact_region`).

## Conventions & Patterns
- Express services keep in-memory stores for demo; no persistence layer. Keep APIs idempotent and return JSON objects with `message` and `count`/resource where applicable.
- Spring service uses JPA/H2 with validation annotations; repository pattern via `JpaRepository`. CRUD returns `201` on create, `404` on not found.
- Helm charts standardize:
  - `image.repository`, `image.tag`, `service.port`, `env` array for key/value env vars.
  - Optional CSI volume mount at `/mnt/secrets` when Key Vault is enabled.

## Where to Look (examples)
- Node endpoints: `patient-service/src/index.js`, `application-service/src/index.js`.
- Spring controllers/models: `order-service/src/main/java/com/hcltech/poc/order_service/{controller,service,model}`.
- Docker: `order-service/Dockerfile`.
- Helm: `helm/umbrella/charts/*/values.yaml` and `templates/*`.
- Terraform entrypoints: `infra/gcp/envs/*/main.tf` and `terraform.tfvars`.

## CI/CD
- Quick CI/CD summaries and command snippets live in `README-commands.md` (AKS/GKE auth, registry login, Helm deploy). If workflows are added, expect them under `.github/workflows/` following the same steps (fmt/validate/plan/apply for IaC, build/push for apps).

If any section is unclear or you need more concrete examples (e.g., overriding Helm values per environment or wiring GCP Secret Manager into app env), tell me which flow you’re targeting and I’ll extend this.