#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "Usage: verify-release-ci-run.sh <workflow-path> <commit-sha> <repository>" >&2
  exit 2
fi

expected_workflow_path="$1"
expected_sha="$2"
expected_repo="$3"

if [[ -z "$expected_workflow_path" || "$expected_workflow_path" == /* ]]; then
  echo "Expected a repository-relative workflow path" >&2
  exit 2
fi

# A workflow's display name is user-editable and not unique. Match the
# repository-relative workflow path as well as the run's commit provenance.
jq -e \
  --arg workflow_path "$expected_workflow_path" \
  --arg sha "$expected_sha" \
  --arg repo "$expected_repo" '
    .path == $workflow_path and
    .name == "CI" and
    .event == "push" and
    .head_branch == "dev" and
    .head_sha == $sha and
    .head_repository.full_name == $repo
  ' >/dev/null
