---
description: Read-only review of pending upstream changes and a concrete MSGA integration plan.
subagent: false
---

Read and follow the exact Skill file:

.opencode/skills/msga-upstream-sync.md

Do not look for a directory-based SKILL.md path.

Run the workflow in REVIEW mode.

Scope:
$ARGUMENTS

Review is read-only analysis, not approval. Resolve uncertainty through evidence and produce a concrete implementation/verification plan, but do not modify repository files or refs (fetching remote-tracking refs is allowed), create or modify PRs, or wait for CI. Its output neither authorizes nor blocks a later integration, and no user approval is required for decisions already covered by the Skill.

## 1. Repository and references

Verify the repository is zce/make-slack-great-again and origin points to the expected fork.

Inspect the working tree and current Git operations. Fetch origin/dev, origin/master and upstream/master. If the upstream remote is absent, fetch the canonical upstream URL directly without changing remote configuration.

Verify the tracking relationship and select the correct upstream source according to the Skill.

## 2. Baseline and coverage

Use the latest origin/dev and the actual merge-base with the selected upstream source. Record exact SHAs and the complete pending upstream commit range.

Account for every commit SHA. Group the review by logical upstream change/PR, avoiding duplicate analysis of merge commits and their constituent commits.

## 3. Apply the decision policy

For every logical change group, apply the Skill's decision hierarchy:

- Preserve established MSGA product/UI behavior.
- Adopt compatible upstream behavior and implementation.
- Adapt upstream code where it conflicts with MSGA contracts.
- Prefer upstream implementations over duplicate fork implementations.
- Preserve fork behavior only when it is an explicit contract or demonstrably stronger.
- Do not reintroduce deliberately removed product scope.
- Adopt compatible new upstream capabilities by default.

Do not use REVIEW_REQUIRED, DEFER or user approval as a way to avoid making an ordinary engineering decision. Do not recommend omitting commits from the Git merge.

## 4. Produce an actionable plan

Report:

### Repository state
Remote URLs, branch SHAs, selected upstream source and merge base.

### Change coverage
A compact ledger mapping every upstream SHA to a logical change group.

### Integration decisions
For each group: ADOPT, ADAPT, PRESERVE-STRONGER or OMIT-REMOVED-SCOPE, with concise evidence and concrete implementation notes.

### Conflict hotspots
Likely files, the upstream improvement to retain, the MSGA behavior to preserve and the expected resolution.

### Risk and verification plan
For each logical change, identify applicable risk dimensions from the Skill (state/persistence, async lifecycle, UI/interaction/accessibility, performance/resource lifecycle, notifications, localization/generated assets, protocol/security, build/platform/release). Map each applicable risk to the concrete implementation owner, failure mode and a regression test or specific manual verification. List relevant build targets, CI jobs and platform checks. Mark a dimension not applicable only when the changed behavior provides evidence for that conclusion.

### Existing sync PRs
Identify duplicate or obsolete sync PRs and whether they preserve upstream ancestry. Do not modify or close them.

### Execution sequence
Exact source ref, latest dev starting point, new branch naming and merge operation.

Do not ask the user to approve routine product adaptations. If no upstream changes exist, report NO UPSTREAM CHANGES.

End with the applicable REVIEW status defined in Skill section 13.

A plan marked ready is informational; the integration command must independently refresh and verify all references before acting.

Do not execute integration in this command.
