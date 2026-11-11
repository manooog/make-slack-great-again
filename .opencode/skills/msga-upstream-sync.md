---
name: msga-upstream-sync
description: Repeatedly integrate upstream improvements into MSGA while preserving established MSGA product and UI decisions and minimizing implementation divergence.
---

# MSGA Upstream Sync

## 1. Mission

This workflow exists to keep MSGA close to upstream while preserving the product behavior and UI decisions already established in the fork.

**Integration is the objective, not a decision to be reconsidered on every run.**

For every synchronization:

1. Bring the complete upstream commit history into the integration branch through a real Git merge.
2. Adopt upstream fixes, improvements, tests, refactors and compatible new capabilities.
3. Adapt upstream implementation where necessary to preserve established MSGA product behavior and UI decisions.
4. Prefer upstream's implementation when it provides the same capability. Retire duplicate fork implementations when they are no longer needed.
5. Verify that the final result builds, passes relevant tests and preserves the required Git ancestry.
6. Publish a Draft PR targeting the fork's dev branch.

Never turn ordinary implementation conflicts, work size, unfamiliar code, or test updates into a decision about whether to integrate upstream.

### Execution modes and authority

This Skill defines shared policy; the active Command defines the execution mode and the permitted side effects. The Skill does not grant authority beyond the active Command.

- **REVIEW** (`/upstream-sync`): read-only investigation and planning. Fetching remote refs and inspecting files, history, tests and CI configuration are allowed. Do not edit repository files, create or alter local branches/commits, push, create or modify PRs, or rerun CI. Resolve uncertainty through evidence and produce concrete decisions, implementation notes and verification plans. A finding is complete in this mode when its evidence, impact, recommended treatment and verification plan are clear; it is not an instruction to modify code.
- **INTEGRATE** (`/upstream-sync-integrate`): execute only the operations explicitly authorized by that Command: create a fresh integration branch, merge upstream history, make focused adaptations and regression tests, commit, push that branch, create a Draft PR, and complete the CI follow-through below. Do not merge the PR, mark it ready, publish a release, modify `dev`/`master` directly, force-push, or close historical PRs.
- If instructions appear to conflict, obey the narrower active Command scope. Never infer additional permission from this shared Skill.


## 2. Repositories and branches

- Fork: zce/make-slack-great-again
- Upstream: punarinta/make-slack-great-again
- Upstream branch: master
- Fork tracking branch: master
- Integration target: dev

Expected remotes:

- origin: the MSGA fork
- upstream: the canonical upstream repository

Verify remote URLs; never infer repository identity from remote names alone.

If the upstream remote is not configured, fetch the canonical upstream URL directly into the remote-tracking ref refs/remotes/upstream/master. Do not modify Git remote configuration just for this task.

The fork master is expected to mirror upstream master. Fetch both and verify their relationship before choosing the merge source. If they are equal, use origin/master. If origin/master is strictly behind upstream/master, use upstream/master and report that the mirror is behind; do not modify origin/master. If the refs have diverged or origin/master contains unexplained extra commits, investigate the repository state before merging. Never silently choose between divergent histories.

## 3. Decision hierarchy

Apply this hierarchy to every upstream change:

1. **Explicit MSGA product decisions and established user-visible behavior.** These are invariants. Do not change them as a side effect of synchronization.
2. **Upstream behavior and implementation.** Adopt upstream by default wherever it does not violate item 1.
3. **Existing fork implementation.** Preserve it only when it implements item 1, is demonstrably stronger, or is required by the fork. Do not preserve code merely because it already exists.
4. **Agent preference.** Has no authority over the above.

The governing principle is:

**Preserve MSGA behavior; converge MSGA implementation toward upstream.**

When upstream later implements a capability that MSGA previously implemented independently, prefer migrating to the upstream implementation and adapting it to MSGA's behavior. Do not maintain two implementations without a demonstrated need.

When upstream introduces a new capability that does not conflict with an established MSGA decision, adopt it by default. Do not ask the user to approve ordinary upstream features or maintenance improvements.

Do not redesign existing MSGA UI, interaction patterns, navigation, keyboard behavior, layout, styling or information hierarchy as part of synchronization. Integrate upstream functionality into the existing MSGA presentation. New UI required by a compatible upstream feature should follow the existing MSGA design.

A difference in source code is not automatically a product decision. Treat a fork difference as intentional when supported by explicit user direction, project documentation, a deliberate fork-specific change, or tests that encode the established behavior. Otherwise prefer the upstream implementation.

## 4. Established MSGA product contracts

These rules are not optional and must be checked after every merge.

### Product scope

- Do not reintroduce Claude Code, Claude-specific UI, agent sessions, agent-only workflows, voice features or other functionality deliberately removed from MSGA.
- Do not restore their dependencies, backend hooks, settings, generated assets, tests, menu entries or configuration.
- Preserve useful functionality that remains in MSGA, including Summary down.
- Do not remove unrelated upstream improvements merely because the same upstream change also touched removed functionality.

### Existing UI and interaction decisions

- Preserve the current MSGA window chrome, titlebar, sidebar/activity layout, message pane, visual hierarchy, spacing, typography, scrolling and interaction decisions.
- Upstream UI changes to an existing MSGA surface must be adapted to the current MSGA design, not copied as a redesign.
- Preserve existing menu grouping, ordering and shortcut decisions unless an explicitly accepted upstream capability can be inserted without changing those decisions.
- Adopt compatible new upstream UI capabilities using MSGA's existing visual language.

### Sidebar

- VIP unreads remain pinned in their established position and cannot be collapsed.
- Preserve collapsed-unreads reveal behavior: opening a conversation already revealed inside a collapsed section must not expand the entire section. Expand only when the target row is actually not visible.
- Preserve custom sections, drag/drop behavior, workspace-specific section ordering and workspace-specific collapse preferences.
- Adopt upstream's keyed collapse persistence and lifecycle where possible; extend cleanup to cover MSGA-specific preferences.
- Adopt upstream Drafts behavior. Drafts remain in the upstream-defined fixed position below VIP unreads and do not become draggable or part of the manual section order.
- Adopt compatible unread-only scope settings for custom and starred sections.
- Adopt the upstream DMs/External-first setting. An explicitly customized per-workspace manual order takes precedence; the upstream setting controls the default order when no manual order exists. Provide a clear reset-to-default path if required for the setting to take effect on a customized order, using the existing MSGA UI conventions.

### Messages

- Adopt upstream message and thread capabilities, including thread-aware Mark unread, where compatible.
- Preserve MSGA's existing message-menu grouping and placement.
- Preserve Summary down and its behavior/tests.
- Preserve fork-specific message navigation, jump targets, unread positioning and lazy-loading behavior while incorporating upstream fixes.
- Adopt compatible file-hover reaction behavior without restoring agent-session visibility rules.

### Notifications

- Preserve MSGA notification persistence, deduplication, retention and click-routing behavior.
- Adopt upstream read-state notification withdrawal for ordinary message notifications.
- Preserve independent huddle and reminder lifecycles. Reading a message must not incorrectly withdraw huddle or reminder notifications.
- Never restore removed watched-thread or agent notification hooks.

### Versioning and releases

- The integer MSGA_VERSION in version.cmake represents the upstream application/runtime compatibility version. Follow upstream changes to this value during synchronization.
- Fork GitHub Release tags use an independent SemVer sequence. Do not use MSGA_VERSION as the fork release number and do not change it merely to publish a fork release.
- Keep MSGA_SELF_UPDATE disabled.
- Preserve fork-specific CI, release provenance checks, artifact validation and manual release workflow.
- Do not import upstream release automation in a way that weakens fork release safeguards.

## 5. Default treatment of upstream changes

Use these action labels to describe implementation work. They are not approval states and must never be used to omit upstream commits from Git history.

- **ADOPT** — use the upstream implementation and behavior with no material fork adaptation.
- **ADAPT** — adopt the upstream capability and implementation as far as possible, making the smallest changes needed to preserve MSGA contracts.
- **PRESERVE-STRONGER** — MSGA already has equivalent or stronger behavior. Keep that behavior and its regression coverage, while adopting any independent upstream fixes or implementation improvements that remain compatible.
- **OMIT-REMOVED-SCOPE** — do not reintroduce a capability explicitly removed from MSGA. Preserve unrelated changes from the same upstream change group.

There is no REVIEW_REQUIRED or DEFER category for ordinary product or implementation decisions.

Default decisions:

- If the upstream behavior is compatible, ADOPT.
- If the upstream behavior conflicts with an established MSGA contract, ADAPT.
- If MSGA behavior is demonstrably stronger, PRESERVE-STRONGER.
- If the change reintroduces deliberately removed product scope, OMIT-REMOVED-SCOPE for that scope only.
- If a change contains several independent behaviors, split the analysis and apply different treatments to each behavior.

Do not classify an entire commit as unusable because one part needs adaptation.

If the intent of a new upstream feature is not documented in MSGA, follow upstream's behavior and defaults unless that would violate an established contract. Do not invent a new product decision.

## 6. Discovery and baseline

Before integration:

1. Verify the repository root and origin URL.
2. Check the working tree and ensure no merge, rebase or cherry-pick is in progress.
3. Fetch origin/dev, origin/master and upstream/master.
4. Verify the upstream source and fork tracking branch relationship as described above.
5. Use the latest origin/dev as the integration starting point.
6. Calculate the baseline with the merge base of origin/dev and the selected upstream source ref.

The merge base is authoritative. Never use a hardcoded SHA, an old PR description, a previous agent's memory or a manually maintained last-synced commit as the baseline.

Record:

- origin/dev SHA
- origin/master SHA
- upstream/master SHA
- selected merge source ref and SHA
- merge-base SHA
- upstream commits not yet reachable from dev
- fork commits after the merge base

If there are no upstream commits to integrate, report NO UPSTREAM CHANGES and do not create a branch or PR.

If a previous synchronization PR exists, inspect its ancestry and scope. Never copy or cherry-pick its reconstructed commits. If it lacks the required upstream ancestry, create a fresh integration branch from the latest dev and perform the complete merge. Do not close historical PRs automatically.

## 7. Review the upstream change set

Review the complete commit range from the merge base to the selected upstream HEAD.

Do not inspect only the latest commit or only first-parent history.

Account for every commit SHA, but organize the review by logical change or upstream PR to avoid duplicate analysis:

- For an upstream merge commit, inspect the net change against its first parent and identify the merged PR.
- Review the underlying non-merge commits as part of that logical change; do not count the same behavior twice.
- Review direct upstream commits independently.
- Inspect actual diffs, final implementations, tests, configuration, dependencies and generated files.
- Identify follow-up fixes and reversions before deciding the final behavior.

The review output must include a compact coverage ledger mapping every commit SHA to a logical change group. Detailed reasoning should focus on behavior and implementation decisions, not repeat commit subjects.

For each logical change group, state:

- upstream SHAs and PR, if available
- affected areas
- upstream intent and resulting behavior
- existing MSGA behavior
- action label: ADOPT, ADAPT, PRESERVE-STRONGER or OMIT-REMOVED-SCOPE
- concrete implementation approach
- regression tests to preserve, adapt or add

Never use commit classification to select commits for cherry-picking. The complete upstream history is merged regardless of the action labels.

## 8. Integration procedure

Create a new unique integration branch from the latest origin/dev.

Suggested name: sync/upstream-YYYY-MM-DD-merge. If it already exists, add a numeric suffix. Never reset, overwrite or force-push an existing branch.

Perform a real merge of the selected upstream source ref:

**git merge --no-ff --no-commit <upstream-source-ref>**

Do not substitute cherry-pick, rebase, patch application, manual commit recreation or squash.

### Conflict resolution

Conflicts are normal engineering work, not a reason to reject upstream changes.

For every conflict:

1. Inspect the base, ours and theirs; understand the behavior on both sides.
2. Identify the upstream capability or fix being introduced.
3. Identify the MSGA contract that must remain unchanged.
4. Combine the implementations so the upstream improvement is retained and the MSGA contract still holds.
5. Preserve unrelated changes from both sides.
6. Add or adapt regression tests for the combined behavior.

Do not blindly choose ours or theirs. Do not use global conflict strategies to avoid understanding the code.

For files deliberately deleted by MSGA, keep them deleted and remove references reintroduced by upstream. For mixed files, retain compatible upstream code and remove only the prohibited paths.

Never resolve a whole file by restoring the fork version if that discards unrelated upstream improvements. Never resolve a whole file by taking upstream if that changes established MSGA behavior.

Do not leave conflict markers, dead branches, duplicate implementations or temporary compatibility scaffolding.

Once the merge result is coherent, stage the resolved merge tree and create the merge commit. Record its SHA and both parents.

### Post-merge adaptations

After the merge commit, make additional focused commits for non-conflict adaptations that are easier to review separately.

Keep the merge commit dedicated to the integrated upstream tree and conflict resolutions. Keep follow-up MSGA adaptations in separate commits when practical.

Prefer upstream APIs, data structures, lifecycle and tests. Remove superseded fork-only implementation when the upstream equivalent is correctly adapted.

Do not broaden the task into unrelated refactoring.

## 9. Verification

Review the complete final tree, not just the merge diff.

### Risk-driven regression analysis

For every logical upstream change, identify which quality dimensions it actually touches. Do not mechanically run every check for every change; apply the relevant dimensions and record why a dimension is not applicable when the risk is non-obvious.

Use this risk map as an engineering aid, not as a new approval gate:

- **State, snapshots and persistence:** distinguish complete snapshots from partial updates; ensure partial data cannot trigger cleanup of valid state; verify workspace/account isolation, deletion and reset behavior, serialization/deserialization, defaults for old records, migration compatibility, write ordering and recovery after restart. Only a confirmed complete snapshot may authorize pruning data that is absent from it.
- **Asynchronous work and lifecycle:** inspect callback ownership, thread affinity, cancellation, object destruction, stale results, event ordering, races, duplicate delivery and shutdown behavior. When relevant, read `docs/ARCHITECTURE.md#asynchronous-lifetime-contracts` and follow the ownership contracts documented there.
- **UI and interaction:** preserve established MSGA layout and visual decisions. Derive the minimum geometry required by new controls instead of copying upstream dimensions blindly. Check relevant hover/focus/selected/disabled states, keyboard and pointer behavior, scrolling, focus retention, narrow-window behavior, content alignment and accessibility semantics where supported. Add or adapt UI regression coverage where the repository supports it.
- **Performance and resource lifecycle:** when behavior can persist or repeat, inspect unbounded caches/queues, observer and subscription cleanup, background work, redundant network activity, CPU/memory growth, startup/shutdown cost and long-session behavior. Use focused profiling, soak or memory checks when the changed path justifies them.
- **Notifications and event categories:** verify deduplication, persistence, retention, click routing, read/withdraw behavior and independent lifecycles. A state transition for one notification category must not implicitly clear another category unless the product contract explicitly says so.
- **Localization and generated assets:** identify every new or changed user-visible string; reuse an existing translation key only when its meaning matches. Check all maintained locales, placeholders/plurals, fallback behavior and the repository's generation process. Regenerate generated files with the documented toolchain; do not hand-edit generated output unless the project explicitly requires it.
- **Protocol, networking and security:** when affected, verify authentication/scope boundaries, request/response compatibility, validation, retry/idempotency behavior, secret handling and error redaction. Do not weaken permission checks or expose credentials in logs.
- **Build, platform and release contracts:** inspect the actual CI workflows and supported compiler/platform matrix. Preserve fork-specific release provenance, artifact validation and self-update safeguards; do not assume a local build proves cross-platform compatibility.

For each applicable dimension, connect the upstream behavior to the actual MSGA implementation and its owner (code, architecture documentation, tests or workflow). Identify the failure mode and add or adapt a behavior-level regression test where it can be captured reliably. For visual, platform-specific or otherwise non-automatable behavior, record the exact manual verification and target platform instead. One test may cover multiple risks; do not add tests merely to mirror implementation details.

Examples of expected reasoning:
- A section update API that accepts partial data must not mark the whole collection complete or delete unseen sections.
- A notification read event may withdraw a normal message notification without ending a huddle or reminder lifecycle.
- A new hover action must fit the existing MSGA surface with the smallest necessary geometry change.
- A new visible action must have complete localization coverage and generated outputs.

Do not invent risk where the changed behavior has no such surface. Conversely, do not mark a dimension "not applicable" merely because the upstream commit did not modify a test file; inspect the resulting behavior.

### Git ancestry

Verify:

- The integration branch started from the exact origin/dev SHA recorded before the merge.
- The merge commit's first parent is that origin/dev SHA.
- The merge commit's second parent is the exact selected upstream source SHA.
- The selected upstream source is an ancestor of the final HEAD.
- origin/dev is an ancestor of the final HEAD.
- All upstream commits in the reviewed range are reachable from the final HEAD.

Inspect the graph and merge commit parents. Do not infer ancestry from PR metadata or a merge_commit_sha field on an unmerged PR.

### Code and behavior

Verify:

- All compatible upstream changes are represented in the final tree.
- All MSGA product contracts remain intact.
- No removed Claude/agent/voice paths have returned.
- No duplicate implementation remains where upstream now provides the same capability.
- Existing fork-specific stronger behavior remains covered.
- Tests from upstream are retained and adapted rather than casually deleted.
- New and changed behavior has regression coverage.
- CI, release and self-update safeguards remain intact.
- Localization and generated files match the repository's required toolchain.

### Tests

Inspect the repository's current CI workflows and run the relevant build, tests and validation commands.

Run the broadest practical local verification. Let CI cover supported platforms unavailable locally.

For each check, report PASS, FAIL, NOT RUN or UNSUPPORTED with the reason. Never claim a platform was tested when it was only inspected or compiled.

Fix failures introduced by the merge or adaptations. For suspected pre-existing failures, compare against the unmodified base using the same environment.

Do not skip tests silently, weaken assertions, disable CI jobs or change test expectations merely to obtain a green build. When upstream tests encode behavior that conflicts with an MSGA contract, adapt the test to assert the preserved MSGA behavior.

A platform unavailable locally is not by itself a reason to abandon integration; report the limitation and rely on the corresponding CI job where available.

### Autonomous engineering ownership

The Agent owns the complete work within the active mode, not just discovery and reporting.

- In **REVIEW** mode, independently investigate findings and resolve uncertainty through repository evidence; turn each actionable issue into a concrete implementation and verification plan. Do not modify code or repository state to close a finding.
- In **INTEGRATE** mode, treat review findings, conflict hotspots and integration-caused failures as work to resolve. Do not stop after describing a problem that can be investigated or fixed within the authorized scope.
- Before asking the user, inspect the relevant implementation, call sites, data model, architecture documentation, tests, upstream history and CI logs. Run focused experiments where they can resolve uncertainty cheaply.
- Make routine engineering decisions using the Skill's hierarchy: preserve explicit MSGA behavior, otherwise adopt upstream behavior and implementation by default. Do not ask the user to approve ordinary adaptations, test additions, refactors needed for convergence or compatible upstream features.
- When evidence is incomplete, state what is unknown, gather the missing evidence and continue. Do not turn uncertainty into a speculative product decision.
- Ask for user input only when an actual product decision is absent from the established contracts, an action falls outside the authorization in the command, or safe progress requires unavailable permission or information. For unresolved product ambiguity, preserve current MSGA behavior while continuing all independent work.
- In INTEGRATE mode, a finding is not complete merely because it appears in the report: resolve it in code/tests or identify a concrete external/technical blocker with evidence and the smallest required intervention. In REVIEW mode, complete the finding with evidence and a concrete resolution plan without making changes.
- Do not create extra abstractions, broad refactors or blanket test suites merely to appear thorough. Keep adaptations focused on the upstream behavior and demonstrated risks.

### Revalidate immediately before publishing

Fetch origin/dev, origin/master and upstream/master again before pushing.

- If origin/dev advanced, merge the latest origin/dev into the integration branch. Do not rebase. Resolve any resulting conflicts while preserving the same product contracts, then rerun affected checks.
- If the selected upstream source advanced, review the new commit range since the previously recorded source SHA, apply the same decision policy, and merge the new source into the integration branch. Do not omit the new commits or reset the branch.
- Recheck the tracking relationship between origin/master and upstream/master.
- Verify that the latest origin/dev and latest upstream source are both ancestors of the final HEAD.
- Record every upstream merge commit and its parents. The initial merge commit must still retain the original dev and upstream parents.

If new changes arrive during this revalidation, integrate them before publishing rather than creating a PR against a stale snapshot.

## 10. Draft PR

Push only the new integration branch.

Create a Draft PR:

- Repository: zce/make-slack-great-again
- Base: dev
- Head: the new integration branch
- Title: Sync upstream updates through YYYY-MM-DD into dev

The PR description must include:

1. Upstream repository and exact source SHA.
2. Fork dev starting SHA and merge-base SHA.
3. Commit coverage summary and logical change groups.
4. ADOPT / ADAPT / PRESERVE-STRONGER / OMIT-REMOVED-SCOPE decisions.
5. Important conflict resolutions and MSGA adaptations.
6. Merge commit SHA and both parent SHAs.
7. Verification results, including checks not run.
8. CI status and known platform limitations.

State explicitly:

**Merge this PR using Create a merge commit. Do not squash or rebase it. The upstream ancestry must be preserved.**

Do not merge the PR, mark it ready, publish a release, modify dev/master directly, force-push or close historical PRs.

## 11. Stop conditions

Do not stop because of:

- The number of upstream commits or changed files.
- Ordinary merge conflicts.
- A feature needing adaptation.
- A change touching removed functionality.
- A test needing adaptation.
- A compatible new upstream feature not previously present in MSGA.
- A difference between the upstream and fork implementation.

Stop only for a genuine technical or safety precondition, such as:

- Wrong repository identity or origin URL.
- Unresolvable upstream source identity or divergent tracking history.
- Dirty working tree or an existing Git operation that could be damaged.
- Missing required Git/GitHub permissions.
- A concrete data-integrity or security risk that cannot be safely resolved from available evidence.
- A merge or build state that cannot be made coherent without destructive or speculative changes.

When blocked, finish all safe inspection and work possible, report the exact technical blocker and the smallest required intervention. Do not reframe a product choice as a blocker.

## 12. Pull-request CI completion (INTEGRATE mode only)

This section applies only after `/upstream-sync-integrate` creates a Draft PR. The read-only `/upstream-sync` command must identify relevant checks in its plan but must not wait for, rerun or modify CI.

Creating the Draft PR is not the end of integration. Keep ownership until every applicable check associated with the latest PR head SHA has completed and its result has been assessed.

- **Discover the complete check set.** Prefer `gh pr checks <PR_NUMBER> --watch` when authenticated GitHub CLI is available. Otherwise inspect the latest head commit's check runs, combined commit status contexts and associated workflow runs through the authenticated GitHub API/connector. Include checks reported by GitHub Actions and other GitHub Apps/status providers; workflow runs alone are not necessarily the complete check set.
- **Verify applicability.** Re-read current workflow triggers, path/branch filters, job conditions and required-check rules where accessible. Include all checks expected for this PR, including relevant `pull_request`, `pull_request_target`, `workflow_run` or merge-queue checks. Do not wait for unrelated scheduled/manual workflows. A skipped job is acceptable only when its condition makes the skip expected and that reason is verified.
- **Handle pagination and the exact SHA.** Check results must belong to the current PR head SHA. Paginate API collections until all applicable results are retrieved; some convenience endpoints expose only the first page. A successful result for an older SHA does not validate a newer push.
- **Do not mistake missing checks for success.** If expected checks do not appear, allow a short bounded registration window, then inspect the PR event, workflow filters, check-run/status APIs and repository rules. Report a missing or inaccessible check as unresolved; an empty check list is never CI green.
- **Wait for completion.** Do not report success while an applicable check is queued or in progress. Treat `success` as passing; accept `skipped` or `neutral` only after verifying the workflow condition and semantics. Ignore a cancelled run only when a newer push superseded its SHA.
- **Investigate failures.** Inspect the exact workflow run, job, failed step and logs. Classify the cause as an integration-caused code/test regression, workflow/configuration regression, demonstrably pre-existing failure, transient infrastructure/flaky failure, or permission/access limitation.
- **Fix integration-caused failures.** Reproduce with the closest available CI configuration and fix code, tests or workflow configuration when the regression was introduced by the integration. Add/adapt regression coverage where appropriate, commit and push to the same integration branch, then restart this process against the new PR head SHA. Do not weaken assertions, delete valid tests, skip jobs or make unrelated workflow changes to get a green result.
- **Compare suspected pre-existing failures.** Re-run the relevant check against the unmodified dev baseline using equivalent inputs and environment. Do not label a failure pre-existing based on suspicion alone.
- **Retry narrowly and finitely.** Retry only when evidence supports a transient infrastructure failure or flaky test, not to avoid fixing a regression. Prefer one rerun of the specific failed job; allow at most one unchanged retry per failed job. If it fails again, investigate the underlying cause rather than retrying indefinitely.
- **Respect permissions and timeouts.** If logs, checks or reruns are unavailable due to permissions, report the exact limitation and leave the PR Draft. Respect each workflow's configured timeout; if a run exceeds it plus a reasonable reporting grace period, capture its state and treat it as blocked rather than silently abandoning it.
- **Revalidate after every push.** Re-read the PR and its latest head SHA, then repeat the full check-set discovery. Do not carry forward results from superseded commits.

The current CI workflow includes Ubuntu GCC test/build validation, Ubuntu Clang compile validation and Windows MinGW build validation. The memory workflow runs an ASan/LSan test and soak on pull requests. This is a current snapshot, not a permanent check list; workflow files and actual PR checks are the source of truth.

## 13. Final report

Report facts, not confidence claims:

- source and target refs
- exact SHAs and merge base
- number of upstream commits covered
- logical change groups and action labels
- merge commit SHA and parents
- adaptation commits
- product contracts checked
- build, test and CI results
- Draft PR URL
- remaining technical limitations

### Completion criteria

- **REVIEW mode:** complete when the full pending upstream range is accounted for, repository references and merge base are verified, decisions are evidence-based, and conflict/risk/verification plans are actionable. Do not create a branch or PR, modify files, or wait for CI.
- **INTEGRATE mode:** complete when the full upstream history is merged, MSGA contracts are preserved, ancestry is verified, the integration branch is pushed, the Draft PR is created, and all applicable checks pass for the latest head SHA. If an external, demonstrably pre-existing or permission-related failure cannot be resolved within the authorized scope, leave the PR Draft and report the exact evidence and limitation instead of claiming CI success.
