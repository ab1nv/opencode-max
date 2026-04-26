<!-- OpenCode MAX — .opencode/commands/diff-summary.md
     https://github.com/ab1nv/opencode-max
     Author: Abhinav Singh (ab1nv) · v0.1.0
     /diff-summary command — summarize uncommitted changes. -->
---
description: Summarize what changed since the last commit
---

Summarize all changes since the last commit:

Uncommitted changes:
!`git diff --stat`
!`git diff`

Staged changes:
!`git diff --cached --stat`

Provide:
1. A one-sentence summary of what changed
2. File-by-file breakdown of modifications
3. Any potential issues or TODOs left in the code
