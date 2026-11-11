---
description: Merge the complete upstream history into MSGA dev, adapt fork-specific behavior, verify and create a Draft PR.
subagent: false
---

Read and follow `.opencode/skills/msga-upstream-sync/SKILL.md` completely.

Execute the integration plan produced by `/upstream-sync`.

This command performs actual Git operations. Follow the approved plan and all Skill constraints.

Do not reinterpret the integration architecture.

## 1. Validate the plan

Confirm that the current conversation contains a completed upstream-sync plan with status:

`READY TO INTEGRATE`

If no such plan exists, ask the user to run `/upstream-sync` first.

Re-fetch and verify the relevant remote references.

Compare current SHAs with the plan:

- `origin/dev`
- `origin/master`
- `upstream/master`

If any relevant SHA has changed, stop and require a fresh review.

Verify that `origin/master` and `upstream/master` still point to the same commit.

## 2. Validate local state

Before modifying anything:

- Confirm the repository root.
- Confirm the `origin` URL.
- Confirm the working tree is clean.
- Confirm there is no active merge, rebase or cherry-pick.
- Confirm the target `origin/dev` exists.
- Confirm the upstream source is available.
- Confirm the integration branch name is unused locally and remotely.

Never stash, discard, reset or overwrite existing user changes.

Never reuse PR #60's branch:

`sync/upstream-2026-11-11`

Do not cherry-pick or copy commits from PR #60.

The new integration must start independently from the latest `origin/dev`.

## 3. Create the integration branch

Use a unique name:

`sync/upstream-YYYY-MM-DD-merge`

If the name already exists, append a numeric suffix.

Create the branch from:

`origin/dev`

Do not create it from the current local branch or an outdated local `dev`.

Record the exact starting SHA.

## 4. Perform the actual Git merge

The required operation is:

```bash
git merge --no-ff --no-commit origin/master
```

This is the central operation of this workflow.

Do not replace it with cherry-pick, rebase, patch application or manually recreated commits.

### Conflict handling

If conflicts occur:

1. List every conflicted file.
2. Understand the upstream and fork-side changes.
3. Consult the previously generated inventory and compatibility analysis.
4. Resolve each file according to actual behavior and established MSGA invariants.
5. Preserve compatible upstream functionality.
6. Avoid broad rewrites and unrelated cleanup.

Never use `git checkout --ours`, `--theirs`, or a global conflict strategy as a substitute for reviewing the affected code.

Do not discard upstream changes merely because they conflict with existing fork code.

If a conflict has no defensible resolution, stop and report it.

Once all conflicts are resolved, review the complete staged merge result and create the merge commit:

```bash
git add <resolved-files>
git commit -m "Merge upstream master into dev"
```

Record:

`MERGE_SHA=$(git rev-parse HEAD)`

Do not combine all subsequent fork-specific adaptations into this merge commit.

## 5. Perform fork-specific adaptations

Now review the complete merged implementation against the Skill's product invariants and the approved inventory.

Implement the planned ADAPT and REVERT decisions.

Important requirements:

- Preserve the original upstream merge commit.
- Make adaptations in separate focused commits.
- Do not duplicate functionality already present in MSGA.
- Do not restore removed Claude/agent/voice functionality.
- Preserve existing fork-specific sidebar and notification behavior.
- Preserve independent versioning and release safeguards.
- Do not introduce unrelated refactoring.

For each adaptation, explain the upstream behavior, the fork requirement and the resulting implementation.

If the actual merge reveals an unanticipated architectural or product conflict, stop rather than making an arbitrary decision.

## 6. Verify Git ancestry

This is a mandatory gate.

Verify the recorded merge commit:

```bash
git show -s --format='%H%n%P%n%s' "$MERGE_SHA"
```

Its parents must be:

1. First parent: the exact `origin/dev` SHA used to create the integration branch.
2. Second parent: the exact `origin/master` SHA merged in this run.

Verify:

```bash
git merge-base --is-ancestor "$MERGE_SHA" HEAD

git merge-base --is-ancestor origin/master HEAD

git merge-base --is-ancestor origin/dev HEAD
```

All checks must succeed.

Inspect:

```bash
git log --graph --oneline --decorate -50

git status --short
```

If ancestry is incorrect, do not push or create a PR.

Never repair an incorrect history by rewriting or force-pushing.

## 7. Verify the implementation

Review the final source tree, not merely the diff from conflict resolution.

Run the planned:

- CMake builds.
- CTest suites.
- Relevant Linux and Windows builds.
- ASan/LSan tests.
- Localization checks.
- Generated-file validation.
- Platform-specific notification tests where available.

Review the existing CI configuration and ensure all required checks are appropriate.

Do not claim that a platform was tested if it was only compiled or not available.

For failures, distinguish environmental issues from actual regressions using reproducible evidence.

Fix failures caused by this integration before proceeding.

Do not silently suppress failing tests or weaken CI.

## 8. Push and create a Draft PR

Push only the newly created integration branch:

```bash
git push -u origin <integration-branch>
```

Verify that the remote branch points to the expected HEAD.

Create a Draft PR:

- Repository: `zce/make-slack-great-again`
- Base: `dev`
- Head: the new integration branch.
- Title: `Sync upstream updates through YYYY-MM-DD into dev`

Use the available GitHub integration or GitHub CLI.

The PR description must include:

- Upstream HEAD and repository.
- Actual merge-base SHA.
- Number of upstream commits reviewed.
- Commit inventory and classifications.
- Important adaptations and reversions.
- Preserved fork-specific behavior.
- Merge commit SHA and both parent SHAs.
- Verification results.
- CI results.
- Outstanding limitations.

Include this explicit instruction:

**Merge strategy: Create a merge commit. Do not squash or rebase this PR. Preserving upstream commit ancestry is a requirement.**

If GitHub does not support the required merge strategy, report the limitation. Do not substitute another strategy.

Do not:

- Mark the PR ready for review.
- Merge the PR.
- Publish a release.
- Modify `master` or `dev`.
- Close PR #60.
- Delete existing branches.

## 9. Final report

Report the actual results:

### Integration
- Integration branch.
- Starting dev SHA.
- Upstream master SHA.
- Merge-base SHA.
- Merge commit SHA.
- Merge commit parents.

### Adaptations
- Adaptation commits.
- Important conflict resolutions.
- Fork-specific behavior preserved.
- Any upstream functionality intentionally reverted.

### Verification
- Build results.
- Test results.
- CI results.
- Git ancestry verification.
- Outstanding issues.

### Pull request
- Draft PR URL.
- Base and head.
- Current PR state.

Clearly distinguish completed work from pending CI or review.

The task is complete only when the integration branch has been pushed, its ancestry has been verified and the Draft PR has been created successfully.
