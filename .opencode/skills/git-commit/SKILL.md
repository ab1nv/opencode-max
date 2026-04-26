<!-- OpenCode MAX — .opencode/skills/git-commit/SKILL.md
     https://github.com/ab1nv/opencode-max
     Author: Abhinav Singh (ab1nv) · v0.1.0
     Skill: git-commit workflow. -->

---
name: git-commit
description: Generate conventional commit messages from staged changes
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: git
---

## What I Do

Analyze staged git changes and generate well-crafted conventional commit messages.

## When to Use Me

Use this skill when:
- Ready to commit and need a good commit message
- Squashing commits and need a summary
- Writing release notes from commit history

## Commit Message Format

```
type(scope): short description

- Bullet point details for significant changes
- Another detail

Closes #123
```

### Types
| Type       | When to Use                                    |
|------------|------------------------------------------------|
| `feat`     | New feature for the user                       |
| `fix`      | Bug fix                                        |
| `docs`     | Documentation only                             |
| `style`    | Formatting, missing semicolons (not CSS)       |
| `refactor` | Code change that neither fixes nor adds        |
| `perf`     | Performance improvement                        |
| `test`     | Adding or correcting tests                     |
| `build`    | Build system or external dependency changes    |
| `ci`       | CI configuration changes                       |
| `chore`    | Maintenance tasks                              |

### Rules
1. First line under 72 characters
2. Use imperative mood: "add" not "added" or "adds"
3. No period at the end of the subject line
4. Scope should be the module/package/area being changed
5. Body should explain WHAT and WHY, not HOW
6. Reference related issues with `Closes #N` or `Refs #N`

## Workflow

1. Run `git diff --cached --stat` to see what's staged
2. Run `git diff --cached` to read the actual changes
3. Categorize the changes by type
4. Determine the scope from the file paths
5. Write a clear, concise subject line
6. Add body bullets if the change is significant
7. Present the commit message for user approval
