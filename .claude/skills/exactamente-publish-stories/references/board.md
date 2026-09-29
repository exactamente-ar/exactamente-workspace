# Exactamente board — IDs and gh recipes

Shared by `exactamente-publish-stories` and `exactamente-take-issue`.
If a command fails with "not found", re-read IDs: `gh project field-list 2 --owner exactamente-ar --format json`.

## IDs

| What | ID |
|---|---|
| Org | `exactamente-ar` |
| Project number / node | `2` / `PVT_kwDODu1hHM4BlEs6` |
| Status field | `PVTSSF_lADODu1hHM4BlEs6zhjy67s` |
| Status: Inbox / Backlog / Ready | `09432bb6` / `f6738b7a` / `d80d70d3` |
| Status: In progress / In review / Done | `829dfe58` / `f1f28952` / `5e293f27` |
| Size field | `PVTSSF_lADODu1hHM4BlEs6zhjy69c` |
| Size: S / M / L | `137bc2c2` / `ebccbde8` / `962c0b40` |
| Issue types: Task / Bug / Feature / Epic | `IT_kwDODu1hHM4Bzr1R` / `IT_kwDODu1hHM4Bzr1S` / `IT_kwDODu1hHM4Bzr1T` / `IT_kwDODu1hHM401EoD` |

Repos: `exactamente-workspace` (epics), `exactamente-backend`, `exactamente-frontend`,
`exactamente-frontend-admin`, `exactamente-mcp`.

## Recipes

```bash
# Current user and their permission on a repo (admin | maintain | write | triage | read)
ME=$(gh api user -q .login)
gh api repos/exactamente-ar/$REPO/collaborators/$ME/permission -q .permission

# Create an issue with a body file; returns the URL
gh issue create -R exactamente-ar/$REPO --title "$TITLE" --body-file "$BODY_FILE"

# Node id of an issue
gh issue view $N -R exactamente-ar/$REPO --json id -q .id

# Set issue type
gh api graphql -f query='mutation($i:ID!,$t:ID!){updateIssue(input:{id:$i,issueTypeId:$t}){issue{number}}}' -f i=$ISSUE_ID -f t=$TYPE_ID

# Link sub-issue to parent
gh api graphql -f query='mutation($p:ID!,$c:ID!){addSubIssue(input:{issueId:$p,subIssueId:$c}){issue{number}}}' -f p=$PARENT_ID -f c=$CHILD_ID

# Mark "blocked by" (issue dependencies)
gh api -X POST repos/exactamente-ar/$REPO/issues/$N/dependencies/blocked_by -F issue_id=$BLOCKER_DB_ID
# ($BLOCKER_DB_ID = `gh api repos/exactamente-ar/$BREPO/issues/$BN -q .id`)

# Add to project (idempotent: returns the existing item if already there)
ITEM=$(gh project item-add 2 --owner exactamente-ar --url "$ISSUE_URL" --format json -q .id)

# Set a single-select field (Status or Size)
gh project item-edit --project-id PVT_kwDODu1hHM4BlEs6 --id $ITEM --field-id $FIELD --single-select-option-id $OPTION

# Assign self
gh issue edit $N -R exactamente-ar/$REPO --add-assignee @me

# Current Status of an issue on the board
gh issue view $N -R exactamente-ar/$REPO --json projectItems -q '.projectItems[] | select(.title=="Exactamente Roadmap") | .status.name'

# Ready + unassigned issues on the board
gh project item-list 2 --owner exactamente-ar --format json --limit 200 \
  | jq '.items[] | select(.status=="Ready" and ((.assignees // []) | length == 0)) | {title, url: .content.url, labels}'
```
