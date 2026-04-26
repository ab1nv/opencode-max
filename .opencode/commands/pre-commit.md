---
description: Analyze staged changes and suggest improvements before committing
agent: code-reviewer
subtask: true
---

Review the following staged changes before commit:

Staged files:
!`git diff --cached --stat`

Full diff:
!`git diff --cached`

Check for:
1. Security issues (hardcoded secrets, injection, XSS)
2. Logic errors and edge cases
3. Performance anti-patterns
4. Code style violations
5. Missing documentation for public APIs
6. Missing tests for new functionality

Rate each finding: Critical | Warning | Suggestion

End with a recommendation: Safe to commit | Fix before committing | Do not commit
