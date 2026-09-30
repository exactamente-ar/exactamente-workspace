---
name: exactamente-take-issue
description: "Trigger: tomar issue, agarrar tarea, take issue, qué hay para hacer, próximo issue. Claim a Ready issue on the Exactamente board and prepare branch and context."
license: Apache-2.0
metadata:
  author: "juanpe44"
  version: "1.0"
---

## Activation Contract

Use when a human or an agent wants to pick up work from the org board. This skill **prepares,
it does not implement**: it claims the issue, moves it to In progress, creates the branch, and
hands over the context. Implementation is a separate step the user starts.

## Hard Rules

- Only take issues in **Ready**, unassigned, with every `blocked_by` issue closed.
- Assignment is the lock: assign yourself before anything else; if someone is assigned, abort.
- An agent acting without a human in the loop only takes issues labeled `agent-ready`.
- Branch: `<gh-user>/<slug>` (login lowercased: `JuanPE44` → `juanpe44`) in the issue's repo, from its default branch (`develop` in
  `exactamente-backend`, `master` in `exactamente-frontend`, `main` in admin and mcp). Never branch a
  backend feature from `main`: that is only for hotfixes. Same slug in every repo of the same epic.
- Never write code, commit, push, or open a PR from this skill.
- Work from the workspace root; use `git -C <repo>`.

## Decision Gates

| Situation | Action |
|---|---|
| No issue given | List Ready + unassigned (Size, repo, labels); user picks one. Stop |
| Not in Ready | Abort: say its Status and who can move it (maintainers) |
| Assigned to someone else | Abort, name the assignee |
| Open `blocked_by` | Abort, list the blockers |
| Repo not cloned locally | Tell the user to run `./setup.sh`; stop |
| Repo has uncommitted changes | Stop and ask; never stash or discard |
| Branch already exists | Check it out instead of recreating |
| Self-assign fails (no write access) | Comment "Lo tomo" on the issue, tell the user to wait for a maintainer to assign it, stop |

## Execution Steps

1. Resolve `owner/repo#N`. Read the issue: `gh issue view N -R ... --json title,body,assignees,labels,state,projectItems`.
2. Run the checks from Decision Gates (blockers: `gh api repos/exactamente-ar/<repo>/issues/N/dependencies/blocked_by`).
3. Claim: `--add-assignee @me`, then set Status In progress (`../exactamente-publish-stories/references/board.md`).
4. Branch: `git -C <repo> fetch`, then `git -C <repo> checkout -b <gh-user>/<slug> origin/<default>`.
   Derive `<slug>` from the epic name for epic sub-issues, else from the title (kebab-case, short).
5. Gather context: issue body, the linked `epics.md` story section, the parent epic, and the
   repo's `CLAUDE.md`/`AGENTS.md` (for `exactamente-mcp`: `package.json` + `lefthook.yml`).
6. Report and stop.

## Output Contract

Return: issue link and title, branch name, acceptance criteria as a checklist, contract impact
(does it need `gen:openapi`/`gen:api`), repo rules that matter, and the suggested next step:
`bmad-dev-story` with this issue, then a PR with `Closes exactamente-ar/<repo>#N`.
Mention that In review/Done move automatically with the PR.

## References

- `../exactamente-publish-stories/references/board.md` — IDs and `gh` recipes.
- `METODOLOGIA.md` §2–§7 — branch, backend-first, TDD, gates, PRs.
