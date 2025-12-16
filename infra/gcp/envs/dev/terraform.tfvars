project_id  = "massive-sandbox-477717-k3"
app_runner_sa = "app-runner@massive-sandbox-477717-k3.iam.gserviceaccount.com"
environment = "dev"
repo_name = "dev-docker"
region = "asia-south1"

cluster_name = "dev-gke"
network_name = "dev-vpc"

cidr_block = 10

private_subnet_names        = ["dev-subnet"]
private_subnet_cidr_blocks = ["10.10.0.0/20"]


firewall_ssh_source_ranges = ["0.0.0.0/0"]
allow_http  = true
allow_https = true
