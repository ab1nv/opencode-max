<!-- OpenCode MAX — .opencode/skills/plan-first/SKILL.md
     https://github.com/ab1nv/opencode-max
     Author: Abhinav Singh (ab1nv) · v0.1.0
     Skill: plan-first workflow. -->

---
name: plan-first
description: Enforce a plan-before-code workflow for complex tasks
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: planning
---

## What I Do

Enforce a structured planning workflow before any code is written. This prevents wasted effort and ensures alignment.

## When to Use Me

Use this skill when:
- Starting a new feature or major change
- The task involves 3+ files
- The requirements are ambiguous
- There are multiple valid approaches

## Workflow

### Step 1: Requirements Gathering
Ask the user these questions if the answers aren't clear:
1. What is the expected behavior?
2. What are the inputs and outputs?
3. Are there edge cases to handle?
4. Are there performance requirements?
5. What should NOT change?

### Step 2: Codebase Discovery
- Use `glob` to understand the project structure
- Use `grep` to find related code
- Read existing tests to understand expected behavior
- Check for existing patterns that should be followed

### Step 3: Create Implementation Plan
Write a structured plan using `todowrite`:

```
- [ ] Step 1: [description] — File: path/to/file
- [ ] Step 2: [description] — File: path/to/file
- [ ] Step 3: Write tests — File: path/to/test
- [ ] Step 4: Verify — Run: npm test
```

### Step 4: Get Approval
Present the plan to the user and ask for confirmation before proceeding.

### Step 5: Execute
Follow the plan step by step, checking off items as you go.
