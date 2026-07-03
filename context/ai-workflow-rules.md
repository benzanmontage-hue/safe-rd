# SafeRD — AI Workflow Rules

> *Rules that AI assistants (Claude, Cursor, Copilot) MUST follow when working on SafeRD.*

## CRITICAL — NEVER BREAK
1. **Never modify existing features** without explicit permission in the prompt
2. **Never delete or refactor working code** — add new code alongside
3. **Respect feature-first structure** — don't create `utils/helpers.dart` dumping grounds
4. **No hardcoded secrets** — phone numbers, API keys, tokens go in `.env` (gitignored)
5. **No platform-specific code without guard** — `if (Platform.isAndroid)` required

## WORKFLOW
1. **Analyze first** — read existing code before writing
2. **Small commits** — one feature per commit, descriptive messages
3. **Generate tests** — unit test for domain, widget test for UI
4. **Explain changes** — what you changed and why

## CODE GENERATION RULES
1. Default to `final` variables
2. Every new class gets a doc comment
3. Riverpod providers go in `presentation/providers/`
4. Follow existing naming conventions (snake_case files, PascalCase classes)
5. Use `sealed class Result<T>` for all service returns

## WHAT AI SHOULD NOT DO
- ❌ Rewrite the entire SOS engine "to be cleaner"
- ❌ Change state management from Riverpod to BLoC
- ❌ Add new dependencies without asking
- ❌ Remove "unused imports" — they may be needed for platform-specific code
- ❌ Change the color scheme without UI context file update

## WHEN TO ASK THE USER
- Adding a new package dependency
- Changing architecture (folder structure, state management)
- Modifying the SOS protocol (safety-critical)
- Removing any existing feature
- Changing UI that affects the SOS button
