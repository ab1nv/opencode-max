---
name: debug-loop
description: Systematic hypothesis-driven debugging loop for complex bugs
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: debugging
---

## What I Do

Guide a systematic debugging investigation using a hypothesis-driven approach. Prevents random debugging and ensures thorough root cause analysis.

## When to Use Me

Use this skill when:
- A bug has unclear causes
- Initial fix attempts have failed
- The bug is intermittent or hard to reproduce
- Multiple components might be involved

## The Debug Loop

### 1. Gather Evidence
```
Error message: [exact error text]
Stack trace:   [key frames]
Trigger:       [what action causes it]
Frequency:     [always | sometimes | once]
Environment:   [dev | staging | prod]
Recent changes: [git log --oneline -5]
```

### 2. Form Hypotheses
List exactly 3 hypotheses, ranked by probability:

```
H1 (70%): [Most likely cause based on evidence]
H2 (20%): [Second most likely]
H3 (10%): [Unlikely but possible]
```

### 3. Test Hypothesis
For each hypothesis (starting with H1):
1. Define a test that would PROVE or DISPROVE it
2. Execute the minimal test
3. Record the result

```
Testing H1: [description]
Test:        [what you did]
Result:      [CONFIRMED | REJECTED]
Evidence:    [what you observed]
```

### 4. Root Cause
```
Root Cause: [exact description]
Location:   [file:line]
Why:        [explanation of the mechanism]
```

### 5. Fix
- Apply the minimal fix
- Run tests to verify
- Check for same pattern elsewhere: `grep -r "pattern" .`

### 6. Prevent Recurrence
- Add a test that catches this specific bug
- Consider if the fix should be applied elsewhere
- Document the root cause for future reference

## Anti-Patterns to Avoid

- Avoid changing random things to see what happens
- Avoid adding print statements everywhere
- Avoid blaming the framework before checking your code
- Avoid fixing symptoms instead of root cause
- Avoid skipping the verification step
