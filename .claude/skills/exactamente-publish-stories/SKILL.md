---
name: exactamente-publish-stories
description: "Trigger: publicar stories, subir épica al tablero, crear issues desde epics.md, publish stories. Publish BMad epics/stories as GitHub issues on the Exactamente board."
license: Apache-2.0
metadata:
  author: "juanpe44"
  version: "1.0"
---

## Activation Contract

Use after `bmad-create-epics-and-stories` (or when asked) to turn an `epics.md` into one Epic
issue per epic in `exactamente-workspace` plus one sub-issue per story in the repo that
implements it, all on the org board. Rule from `METODOLOGIA.md`: the issue is the source of
truth; the BMad file is the detail.

## Hard Rules

- Never create anything before showing the full preview and getting explicit confirmation.
- Never invent missing data (repo, acceptance criteria, Size, dependencies): ask.
- One story = one repo = one PR. A story touching 2 repos must be split first.
- Idempotent: a story or epic that already has a `github:` line is skipped, never duplicated.
- Issue titles and bodies in neutral Spanish.
- Status by permission: only `admin`/`maintain` on the target repo may set Backlog or Ready.
  Everyone else publishes to **Inbox**; a maintainer triages later.
- Backend stories are created first; client stories that consume a backend contract are
  marked "blocked by" the backend story.

## Decision Gates

| Situation | Action |
|---|---|
| No path given | Use the most recent `epics.md` under `_bmad-output/planning-artifacts/` and confirm it |
| Story without `**Repo:**` | Ask which repo; offer to split if it touches several |
| Story without Size | Propose S/M/L with reasoning; user confirms |
| User is maintainer | Ask: Backlog or Ready (Ready only if AC are testable and nothing is open) |
| User is not maintainer | Inbox, and say so in the preview |
| Story is small, AC testable, no open design decision | Suggest label `agent-ready` |
| `github:` line exists | Skip; with `--update`, rewrite that issue body instead |

## Execution Steps

1. Read the `epics.md`. Parse `## Epic N: title` and `### Story N.M: title` blocks (story text,
   AC, `**Repo:**`, `**Size:**`, `**Depends on:**`, existing `github:` lines).
2. Resolve gaps per Decision Gates. Get `ME` and permission per repo (`references/board.md`).
3. Show the preview table: epic/story, repo, type, Size, Status, labels, blocked by, skip/create.
   Stop until confirmed.
4. Per epic: create issue in `exactamente-workspace` with `assets/epic-body.md`, type Epic.
5. Per story (backend first): body from `assets/story-body.md`, create in its repo, type
   Feature (Task if purely technical), link as sub-issue of the epic, add `blocked_by` links.
6. Add every issue to project 2; set Status and Size.
7. Write back `github: exactamente-ar/<repo>#N` on the line right after each epic/story heading
   in `epics.md`, using the Edit tool (not `sd`/`sed`: headings contain `[`, `.` and multi-line
   patterns fail silently).
8. Save the file; do not commit unless asked.

## Output Contract

Return: a table of created/skipped issues with URLs and Status, the edited `epics.md` path, and
any story that needs triage or splitting.

## References

- `references/board.md` — project/field/type IDs and `gh` recipes.
- `assets/epic-body.md`, `assets/story-body.md` — issue body templates.
- `METODOLOGIA.md` §1 — sizing and columns.
