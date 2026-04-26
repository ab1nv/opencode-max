<!-- OpenCode MAX — .opencode/skills/code-review/SKILL.md
     https://github.com/ab1nv/opencode-max
     Author: Abhinav Singh (ab1nv) · v1.0.0
     Skill: code-review workflow. -->

---
name: code-review
description: Comprehensive code review checklist covering quality, security, and performance
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: review
---

## What I Do

Perform a thorough code review using a structured checklist. Outputs findings with severity ratings.

## When to Use Me

Use this skill when:
- Reviewing a pull request or staged changes
- Auditing code quality before a release
- The user asks for a code review

## Review Checklist

### Security (Critical)
- [ ] No hardcoded secrets, tokens, or passwords
- [ ] Input validation on all user-provided data
- [ ] Output encoding to prevent XSS
- [ ] Parameterized queries (no SQL injection)
- [ ] Proper authentication/authorization checks
- [ ] No sensitive data in logs

### Correctness (Critical)
- [ ] Edge cases handled (null, empty, boundary values)
- [ ] Error handling is explicit (no swallowed errors)
- [ ] Race conditions considered in async code
- [ ] Off-by-one errors checked in loops
- [ ] Type safety maintained (no unsafe casts)

### Performance (Warning)
- [ ] No O(n²) or worse in hot paths
- [ ] No unnecessary re-renders (React)
- [ ] No N+1 query patterns
- [ ] Large lists are paginated or virtualized
- [ ] Heavy computations are memoized when appropriate

### Design (Suggestion)
- [ ] Single Responsibility — each function/class does one thing
- [ ] DRY — no copy-pasted logic
- [ ] YAGNI — no unused code or speculative features
- [ ] Naming is clear and consistent
- [ ] Appropriate abstraction level

### Documentation (Suggestion)
- [ ] Public APIs have docstrings
- [ ] Complex logic has "why" comments
- [ ] Breaking changes are documented
- [ ] README updated if needed

## Output Format

```
## Code Review Results

### Critical (must fix)
- **[File:Line]** Description of issue

### Warning (should fix)
- **[File:Line]** Description of issue

### Suggestion (nice to have)
- **[File:Line]** Description of improvement

### Looks Good
- List of things done well
```
