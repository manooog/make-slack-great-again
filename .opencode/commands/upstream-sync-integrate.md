---
description: Merge upstream into MSGA dev, preserve product decisions, verify changes, create a Draft PR and close the CI feedback loop.
subagent: false
---

Read and follow the exact Skill file:

.opencode/skills/msga-upstream-sync.md

Do not look for a directory-based SKILL.md path.

Run the workflow in INTEGRATE mode.

Scope:
$ARGUMENTS

The user's invocation authorizes the Git and GitHub operations defined here: create a new integration branch, merge upstream, resolve conflicts, make focused source/test/documentation/workflow adaptations and commits, push the branch, create a Draft PR and perform the bounded CI follow-through defined by the Skill.

Do not require a previous /upstream-sync result or a READY status. The review command is optional. Independently perform the required discovery, inventory and compatibility analysis using the Skill.

## 1. Preflight

Verify repository identity, origin URL, clean working tree and absence of active merge/rebase/cherry-pick operations.

Fetch origin/dev, origin/master and upstream/master. If upstream is not configured, fetch the canonical upstream URL directly without modifying remote configuration.

Verify the tracking relationship and select the upstream source according to the Skill. Record exact SHAs and calculate the merge base from the latest origin/dev.

If a prior review exists, use it as a guide only after verifying its source SHA and baseline. If no review exists or it is stale, perform the analysis now. Never stop merely because a review artifact is absent.

If there are no upstream commits to integrate, report NO UPSTREAM CHANGES and do not create a branch or PR.

## 2. Inventory and compatibility

Account for every pending upstream commit, grouped by logical change/PR.

Apply the Skill's decision hierarchy and product contracts. Produce a concise internal implementation map:

- ADOPT
- ADAPT
- PRESERVE-STRONGER
- OMIT-REMOVED-SCOPE

Do not ask the user to decide whether normal upstream changes should be integrated. Do not defer a change because it needs conflict resolution, adaptation, tests or refactoring.

## 3. Create a fresh integration branch

Create a unique branch from the exact latest origin/dev SHA:

sync/upstream-YYYY-MM-DD-merge

If the name exists, append a numeric suffix. Never reset, overwrite or force-push an existing branch. Do not base the branch on an old sync branch or a previous reconstructed PR.

## 4. Merge the complete upstream history

Perform a real non-fast-forward merge of the selected upstream source:

git merge --no-ff --no-commit <upstream-source-ref>

Resolve every ordinary conflict by retaining upstream improvements while preserving MSGA product/UI contracts. Do not use cherry-pick, rebase, patch application, manual commit recreation or squash as an alternative.

Do not blindly choose ours or theirs. Do not discard an entire upstream change because one part reintroduces removed functionality. Keep deliberately removed files deleted, remove only the prohibited paths from mixed files and retain all compatible improvements.

Review the complete merge result, stage the resolved tree and create the merge commit. Record its SHA and both parents.

## 5. Apply focused MSGA adaptations

After the merge commit, make focused adaptation commits where needed.

Prefer upstream's implementation, APIs, data structures, lifecycle and tests. Preserve MSGA's established visible behavior and stronger regression coverage. Remove duplicate fork implementations when the upstream equivalent has been adopted.

Do not redesign existing UI. Do not restore Claude/agent/voice functionality. Follow the Skill's sidebar, messages, notifications, versioning and release contracts.

Do not broaden the task into unrelated refactoring.

## 6. Verify

Verify the merge commit's first parent is the exact origin/dev starting SHA and its second parent is the selected upstream source SHA.

Verify both origin/dev and the selected upstream source are ancestors of final HEAD. Confirm all pending upstream commits are reachable from final HEAD.

Review the complete final tree and run the broadest practical relevant build/tests. Inspect repository CI and let CI cover platforms unavailable locally.

Fix integration-caused failures. Do not weaken tests or CI. Report unsupported or unrun checks honestly.

## 7. Revalidate and publish

Before pushing, fetch origin/dev, origin/master and upstream/master again.

If origin/dev advanced, merge its latest tip into the integration branch without rebasing. If upstream/master advanced, review and merge the new upstream commits using the Skill's policy. Resolve conflicts, rerun affected checks and verify that the latest dev and upstream tips are ancestors of the final HEAD.

Record any additional merge commits and their parents. Do not force-push or rewrite history.

Push only the new integration branch.

Create a Draft PR in zce/make-slack-great-again:

- Base: dev
- Head: the new integration branch
- Title: Sync upstream updates through YYYY-MM-DD into dev

Include the upstream source SHA, dev starting SHA, merge base, commit coverage, adaptation summary, merge SHA and parents, test results, CI status and platform limitations.

State explicitly that the PR must be merged using Create a merge commit, never squash or rebase.

Do not merge the PR, mark it ready, publish a release, modify dev/master directly, force-push or close historical PRs.

## 8. Pull-request CI follow-through

After creating the Draft PR, follow **Skill section 12 (INTEGRATE mode only)** as the single source of truth. This is mandatory: do not finish while an applicable check for the latest PR head SHA is pending, running, missing without explanation or failing due to an integration-caused regression.

Inspect all applicable check runs and status contexts, not only Actions workflow summaries. Fix integration-caused code, test and workflow/configuration failures on the same branch, push the correction and repeat verification against the new head SHA. Keep retries evidence-based and bounded as specified in the Skill.

Keep the PR Draft. Do not mark it ready, merge it or publish a release.

## 9. Final report

Follow **Skill section 13** for the required report fields and final status. Report only verified facts for the exact PR head SHA; do not claim CI green while any applicable check is pending, missing without explanation or failing.

