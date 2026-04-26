---
name: tdd
description: Test-driven development with Red-Green-Refactor cycles
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: testing
---

## What I Do

Guide the developer through strict TDD (Test-Driven Development) cycles.

## When to Use Me

Use this skill when:
- Implementing new functionality with clear requirements
- Fixing bugs (write a failing test that reproduces the bug first)
- The user explicitly asks for TDD

## Workflow

### Red Phase — Write a Failing Test
1. Understand the requirement
2. Write the MINIMAL test that captures the requirement
3. Run the test — confirm it FAILS
4. If it passes, the test isn't testing anything new

### Green Phase — Make it Pass
1. Write the MINIMAL code to make the test pass
2. Don't optimize, don't refactor, don't beautify
3. Run the test — confirm it PASSES
4. If it still fails, fix the implementation (not the test)

### Refactor Phase — Clean Up
1. Now improve the code quality
2. Remove duplication
3. Improve naming
4. Extract functions if needed
5. Run ALL tests — confirm everything still PASSES

### Repeat
Continue with the next requirement.

## Rules

- NEVER write production code without a failing test
- NEVER skip the refactor phase
- Keep cycles SHORT — each cycle should take < 5 minutes
- One behavior per test — don't test multiple things
- Test behavior, not implementation — tests should survive refactors
