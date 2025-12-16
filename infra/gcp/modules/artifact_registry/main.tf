resource "google_artifact_registry_repository" "repo" {
  provider      = google
  location      = var.region          # e.g., "us-central1"
  repository_id = var.repo_name       # e.g., "dev-docker"
  format        = "DOCKER"
  description   = "Artifact registry for ${var.repo_name}"

  lifecycle {
    #prevent_destroy = true            # prevent accidental deletion
  }
}


