---
description: Inspect pending upstream changes and produce a concrete MSGA integration plan without modifying source files.
agent: plan
model: "ollama-cloud/deepseek-v4.1-flash:1017#max"
subagent: false
---

Read and follow the exact Skill file:

.opencode/skills/msga-upstream-sync.md

Do not look for a directory-based SKILL.md path.

Run the workflow in REVIEW mode.

Scope:
$ARGUMENTS

Review is analysis, not approval. Its output does not authorize or block a later integration, and no user approval is required for decisions already covered by the Skill.

## 1. Repository and references

Verify the repository is zce/make-slack-great-again and origin points to the expected fork.

Inspect the working tree and current Git operations. Fetch origin/dev, origin/master and upstream/master. If the upstream remote is absent, fetch the canonical upstream URL directly without changing remote configuration.

Verify the tracking relationship and select the correct upstream source according to the Skill. Do not modify source files, local branches, commits, pushes or GitHub PRs.

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

### Verification plan
Relevant build targets, regression tests, CI jobs, localization and platform-specific checks.

### Existing sync PRs
Identify duplicate or obsolete sync PRs and whether they preserve upstream ancestry. Do not modify or close them.

### Execution sequence
Exact source ref, latest dev starting point, new branch naming and merge operation.

Do not ask the user to approve routine product adaptations. If no upstream changes exist, report NO UPSTREAM CHANGES.

End with one of:

- REVIEW COMPLETE — INTEGRATION PLAN READY
- NO UPSTREAM CHANGES
- BLOCKED — TECHNICAL PRECONDITION

A plan marked ready is informational; the integration command must independently refresh and verify all references before acting.

Do not execute integration in this command.
