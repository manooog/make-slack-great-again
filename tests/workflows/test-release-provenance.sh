#!/usr/bin/env bash
set -euo pipefail

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
guard="$root/scripts/verify-release-ci-run.sh"
repo="zce/make-slack-great-again"
sha="0123456789abcdef0123456789abcdef01234567"
workflow_path=".github/workflows/ci.yml"

run_json() {
  jq -cn \
    --arg path "$1" \
    --arg name "$2" \
    --arg event "$3" \
    --arg branch "$4" \
    --arg sha "$5" \
    --arg repo "$6" '
      {
        path: $path,
        name: $name,
        event: $event,
        head_branch: $branch,
        head_sha: $sha,
        head_repository: {full_name: $repo}
      }
    '
}

expect_rejected() {
  local label="$1" json="$2"
  if printf '%s\n' "$json" | bash "$guard" "$workflow_path" "$sha" "$repo"; then
    echo "Unexpectedly accepted: $label" >&2
    exit 1
  fi
}

# The exact CI workflow and commit are accepted.
run_json "$workflow_path" CI push dev "$sha" "$repo" |
  bash "$guard" "$workflow_path" "$sha" "$repo"

# A different workflow with the same display name must not authorize release.
expect_rejected "same name, different workflow path" \
  "$(run_json ".github/workflows/build.yml" CI push dev "$sha" "$repo")"
expect_rejected "different commit" \
  "$(run_json "$workflow_path" CI push dev "ffffffffffffffffffffffffffffffffffffffff" "$repo")"
expect_rejected "pull request event" \
  "$(run_json "$workflow_path" CI pull_request dev "$sha" "$repo")"
expect_rejected "non-dev branch" \
  "$(run_json "$workflow_path" CI push feature/test "$sha" "$repo")"
expect_rejected "different repository" \
  "$(run_json "$workflow_path" CI push dev "$sha" "someone-else/repo")"
expect_rejected "different workflow name" \
  "$(run_json "$workflow_path" Build push dev "$sha" "$repo")"

echo "Release CI provenance checks passed."
