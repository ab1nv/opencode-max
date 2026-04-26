<!-- OpenCode MAX — .opencode/skills/to-prd/SKILL.md
     https://github.com/ab1nv/opencode-max
     Author: Abhinav Singh (ab1nv) · v0.1.0
     Skill: to-prd workflow. -->

---
name: to-prd
description: Transform a rough idea into a structured Product Requirements Document
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: planning
---

## What I Do

Convert a rough feature idea or user request into a structured PRD (Product Requirements Document) that can be directly used to drive implementation.

## When to Use Me

Use this skill when:
- Starting a new project or major feature
- The user has a vague idea that needs structure
- You need to align on scope before coding
- Creating documentation for a feature spec

## PRD Template

Generate the following document:

```markdown
# PRD: [Feature Name]

## 1. Overview
**One-liner**: [What this feature does in one sentence]
**Author**: [Name]
**Status**: Draft | Review | Approved
**Priority**: P0 (Critical) | P1 (High) | P2 (Medium) | P3 (Low)

## 2. Problem Statement
What problem does this solve? Who has this problem? How are they currently working around it?

## 3. Goals & Non-Goals

### Goals
- [ ] Goal 1
- [ ] Goal 2

### Non-Goals (explicitly out of scope)
- Not doing X because Y
- Not doing Z in this iteration

## 4. User Stories
As a [role], I want [action] so that [benefit].

## 5. Technical Requirements

### Functional Requirements
| ID   | Requirement           | Priority |
|------|-----------------------|----------|
| FR-1 | Description           | Must     |
| FR-2 | Description           | Should   |
| FR-3 | Description           | Nice     |

### Non-Functional Requirements
- Performance: [targets]
- Security: [requirements]
- Scalability: [expectations]

## 6. Design & Architecture
High-level technical approach. Key components and their interactions.

## 7. API Specification
If applicable: endpoints, request/response formats, error codes.

## 8. Data Model
If applicable: new tables, fields, migrations needed.

## 9. Testing Strategy
- Unit tests for: [components]
- Integration tests for: [flows]
- E2E tests for: [critical paths]

## 10. Rollout Plan
- Phase 1: [scope] — [timeline]
- Phase 2: [scope] — [timeline]

## 11. Success Metrics
How do we know this feature is successful?

## 12. Open Questions
Things we still need to decide.
```

## Process

1. Ask the user for their idea (even a rough one is fine)
2. Ask clarifying questions (3-5 max)
3. Generate the PRD
4. Present it for review
5. Iterate based on feedback
