# SafeRD — AI Prompts

> *Ready-to-use prompts for AI-assisted development.*

## Add a New Feature
```
I want to add {FEATURE} to SafeRD, a personal safety app built with Flutter (Riverpod + Hive).

Before writing code:
1. Read ../context/project-overview.md for scope
2. Read ../context/architecture-context.md for structure
3. Read ../context/code-standards.md for conventions
4. Read ../context/ai-workflow-rules.md for constraints
5. If SOS-related: read ../context/emergency-protocol.md

The feature should:
- {REQUIREMENT 1}
- {REQUIREMENT 2}
- {REQUIREMENT 3}

Generate:
1. Domain entity (if new data)
2. Use case
3. Repository interface + implementation
4. Riverpod provider
5. Screen/widget
6. Unit test + widget test
```

## Fix a Bug
```
SafeRD has a bug: {DESCRIPTION}

Before fixing:
1. Read the relevant context files
2. Trace the code path: {FILE} → {FILE}
3. Identify root cause
4. Propose fix (do NOT implement yet — show me first)

Steps to reproduce:
1. {STEP}
2. {STEP}
3. {BUG MANIFESTS}

Expected behavior: {EXPECTED}
Actual behavior: {ACTUAL}
```

## Code Review
```
Review my SafeRD code changes:

{PASTE DIFF}

Check against:
- ../context/code-standards.md
- ../context/ai-workflow-rules.md
- ../context/emergency-protocol.md (if SOS-related)

Report issues by severity: CRITICAL > WARNING > SUGGESTION
```

## Generate Release Notes
```
Generate release notes for SafeRD v{VERSION}.

Read ../docs/roadmap.md for completed features.
Read ../context/progress-tracker.md for status.

Format:
- New Features
- Improvements
- Bug Fixes
- Known Issues
```
