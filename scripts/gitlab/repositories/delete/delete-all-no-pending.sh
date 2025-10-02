#!/bin/bash
set -euo pipefail

# Config (env overrides allowed)
GITLAB_URL=${GITLAB_URL:-https://gitlab.local.com}
CACERT=${CACERT:-/tmp/gitlab-ca-chain.pem}
MAX_PARALLEL_JOBS=${MAX_PARALLEL_JOBS:-10}
: "${GITLAB_TOKEN?GITLAB_TOKEN is required}"

# Function to delete a single project
delete_project() {
  local id=$1
  local path=$2
  local path_enc
  path_enc=$(printf '%s' "$path" | jq -sRr @uri)
  
  echo "Marking for deletion: $path ($id)"
  curl -sS -X DELETE --cacert "$CACERT" -H "PRIVATE-TOKEN: $GITLAB_TOKEN" \
    "$GITLAB_URL/api/v4/projects/$id" >/dev/null || true
  
  echo "Permanently removing: $path ($id)"
  # Use permanently_remove parameter to immediately delete the pending project
  curl -sS -X DELETE --cacert "$CACERT" -H "PRIVATE-TOKEN: $GITLAB_TOKEN" \
    "$GITLAB_URL/api/v4/projects/$path_enc?permanently_remove=true&full_path=$path_enc" >/dev/null || true
}

# Export function and variables for subshells
export -f delete_project
export GITLAB_URL CACERT GITLAB_TOKEN

# Collect all projects first
echo "Fetching all projects..."
all_projects=""
page=1
while :; do
  list=$(curl -sS --cacert "$CACERT" -H "PRIVATE-TOKEN: $GITLAB_TOKEN" \
         "$GITLAB_URL/api/v4/projects?owned=true&simple=true&include_pending_delete=true&per_page=100&page=$page")
  rows=$(printf '%s' "$list" | jq -r '.[] | [.id, .path_with_namespace] | @tsv')
  [ -z "$rows" ] && break
  all_projects="${all_projects}${rows}"$'\n'
  page=$((page+1))
done

# Count total projects
total=$(printf '%s' "$all_projects" | grep -c '^' || true)
echo "Found $total projects to delete"

# Process projects in parallel with controlled concurrency
job_count=0
printf '%s' "$all_projects" | while IFS=$'\t' read -r id path; do
  [ -z "$id" ] && continue
  
  # Start deletion in background
  delete_project "$id" "$path" &
  
  # Increment job counter
  job_count=$((job_count + 1))
  
  # Wait if we hit the max parallel jobs limit
  if [ "$job_count" -ge "$MAX_PARALLEL_JOBS" ]; then
    wait -n 2>/dev/null || true
    job_count=$((job_count - 1))
  fi
done

# Wait for all remaining background jobs
wait

echo "All projects deleted."