---
description: Review and plan a complete upstream merge into MSGA dev. Read-only except fetching remote-tracking references.
subagent: false
---

Read and follow `.opencode/skills/msga-upstream-sync/SKILL.md` completely.

Your task is to review the latest upstream changes and produce an evidence-based integration plan.

This command is READ-ONLY with respect to source code, local branches and GitHub. Fetching remote-tracking references is permitted.

Do not create branches, edit files, commit, push, create PRs or change GitHub state.

## 1. Discover

Verify the repository root is:

`zce/make-slack-great-again`

Inspect:

- Current branch and working tree.
- Existing Git operations.
- Remote names and actual URLs.
- Local and remote branch availability.
- Existing upstream-sync branches and PRs.

Stop if the repository or fork identity is incorrect.

## 2. Refresh and verify references

Fetch the required branches:

- `origin/dev`
- `origin/master`
- `upstream/master`

If the upstream remote is not configured, fetch the canonical upstream URL directly without modifying Git remote configuration.

Verify:

`origin/master == upstream/master`

If they differ, STOP. Explain the difference and do not choose a source branch automatically.

Verify that `origin/dev` and `origin/master` share a common ancestor.

## 3. Establish the actual baseline

Calculate:

`git merge-base origin/dev origin/master`

Use this SHA as the only authoritative baseline.

Determine:

- Current fork dev SHA.
- Current fork master SHA.
- Current upstream SHA.
- Merge-base SHA.
- Number of upstream commits not yet reachable from dev.
- Number of fork-specific commits after the baseline.

Check whether previous synchronization attempts were merged by squash or rebase and whether patch-equivalent upstream changes already exist in dev.

If duplicate integration is possible, stop and explain the situation before proposing an implementation.

Do not use historical PR descriptions as authoritative baseline information.

## 4. Inventory every upstream commit

Inspect the complete range:

`BASE..origin/master`

Account for every commit, including merge commits.

For regular commits, inspect actual patches.

For merge commits, identify the associated PR and review its constituent changes.

Do not rely on commit subjects alone.

Build a table:

| SHA | Subject | PR | Area | Classification | Evidence / Action |
|---|---|---|---|---|---|

Use these classifications:

- KEEP
- ADAPT
- ALREADY_PRESENT
- REVERT
- REVIEW_REQUIRED

Every commit must be accounted for.

These classifications describe the resulting code behavior. All upstream commits will still enter the Git history through the complete merge.

Do not recommend cherry-picking or manually recreating commits.

## 5. Review MSGA compatibility

Inspect the existing fork implementation and compare it with the upstream changes.

Pay particular attention to:

- Removed Claude Code and agent functionality.
- Existing Summary down functionality.
- VIP unreads and pinned section.
- Collapsed-unreads reveal behavior.
- Custom sections and workspace-specific preferences.
- Notification deduplication and persistence.
- Huddle notifications.
- Independent versioning.
- Disabled self-update behavior.
- CI and release safeguards.

Identify actual conflicts, not hypothetical ones.

For every ADAPT or REVERT decision, explain:

1. What upstream changes.
2. What MSGA currently does.
3. Why the upstream behavior is incompatible or needs adaptation.
4. The smallest correct modification.
5. How the result will be verified.

## 6. Produce the integration plan

The implementation plan MUST use:

1. Latest `origin/dev` as the starting point.
2. A new unique integration branch.
3. A complete `--no-ff` merge of `origin/master`.
4. Conflict resolution based on actual code context.
5. Separate, focused post-merge adaptations.
6. Verification of upstream ancestry.
7. A Draft PR targeting `dev`.

Identify likely conflict hotspots before implementation.

Specify which tests and build configurations must be run.

Explicitly identify unresolved questions.

If any critical product decision remains unresolved, do not pretend the plan is ready.

## 7. Final report

Output:

### Repository state
All relevant branch names, URLs and SHAs.

### Upstream inventory
Complete commit inventory with classifications.

### Compatibility analysis
Important changes and fork-specific conflicts.

### Integration plan
Exact Git operations and expected merge topology.

### Conflict hotspots
Files, behavior and resolution strategy.

### Verification plan
Builds, tests, CI and platform-specific checks.

### Outstanding issues
Anything requiring user input.

End with a clear status:

- READY TO INTEGRATE
- BLOCKED — USER DECISION REQUIRED
- BLOCKED — REPOSITORY STATE INVALID
- NO UPSTREAM CHANGES

Do not execute the integration in this command.
