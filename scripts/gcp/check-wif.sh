#!/usr/bin/env bash
set -euo pipefail

PROJECT_ID="massive-sandbox-477717-k3"
POOL="github-pool-v4"
PROVIDER="github-provider-dev"
SA="github-terraform-dev@${PROJECT_ID}.iam.gserviceaccount.com"
REPO="reddysandip/hackathon-usecase"
BRANCH="dev"

echo "1️⃣ Checking provider state..."
STATE=$(gcloud iam workload-identity-pools providers describe "$PROVIDER" \
  --project="$PROJECT_ID" \
  --location=global \
  --workload-identity-pool="$POOL" \
  --format="value(state)")
echo "Provider state: $STATE"
[[ "$STATE" == "ACTIVE" ]] || echo "⚠️ Provider is not ACTIVE!"

echo
echo "2️⃣ Checking allowed audience..."
AUDIENCE=$(gcloud iam workload-identity-pools providers describe "$PROVIDER" \
  --project="$PROJECT_ID" \
  --location=global \
  --workload-identity-pool="$POOL" \
  --format="value(oidc.allowedAudiences)")
echo "Allowed audience: $AUDIENCE"

echo
echo "3️⃣ Checking attribute condition..."
ATTR_COND=$(gcloud iam workload-identity-pools providers describe "$PROVIDER" \
  --project="$PROJECT_ID" \
  --location=global \
  --workload-identity-pool="$POOL" \
  --format="value(attributeCondition)")
echo "Attribute condition: $ATTR_COND"

echo
echo "4️⃣ Checking IAM binding for service account..."
gcloud iam service-accounts get-iam-policy "$SA" \
  --project="$PROJECT_ID" \
  --format="json" | jq -r '.bindings[] | select(.role=="roles/iam.workloadIdentityUser") | .members[]'

echo
echo "5️⃣ Check branch triggers:"
echo "Ensure workflow runs on branch: $BRANCH"
