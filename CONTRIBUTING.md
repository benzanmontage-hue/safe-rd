# Contributing to SafeRD

Thank you for your interest in contributing to SafeRD! We welcome contributions of all kinds — bug fixes, new features, documentation improvements, and testing.

---

## 🚀 Getting Started

### 1. Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.x, stable channel)
- Dart 3.x (bundled with Flutter)
- A [Firebase project](https://console.firebase.google.com/) with Firestore and FCM enabled
- Git

### 2. Fork & Clone

```bash
git clone https://github.com/benzanmontage-hue/safe-rd.git
cd safe-rd
```

### 3. Set Up Firebase

1. Create a Firebase project in the [Firebase Console](https://console.firebase.google.com/)
2. Enable **Authentication** (anonymous or email), **Cloud Firestore**, and **Firebase Cloud Messaging**
3. Register your Android app and download `google-services.json`
4. Place it in `android/app/google-services.json`
5. (Optional) Register your iOS app and download `GoogleService-Info.plist` for `ios/Runner/`

### 4. Install Dependencies

```bash
flutter pub get
```

### 5. Run the App

```bash
flutter run
```

---

## 📐 Coding Standards

SafeRD follows standard Dart and Flutter conventions.

### Formatting

All Dart code must be formatted with `dart format`. The CI pipeline enforces this:

```bash
dart format .
```

### Analysis

The project uses `flutter_lints` for static analysis. Run the analyzer before submitting PRs:

```bash
dart analyze
```

No warnings or errors are allowed.

### Naming Conventions

| Element | Convention | Example |
|---|---|---|
| Files & directories | `snake_case` | `firebase_service.dart` |
| Classes & enums | `PascalCase` | `FirebaseService` |
| Variables & functions | `camelCase` | `getCurrentPosition()` |
| Constants | `camelCase` | `defaultRadiusKm` |
| Private members | Prefix with `_` | `_onlineIncidentStream()` |

### Imports

Organize imports in this order, separated by a blank line:

1. Dart SDK (`dart:async`, `dart:io`, etc.)
2. Flutter SDK (`package:flutter/...`)
3. Third-party packages (`package:firebase_core/...`)
4. Internal project imports (`package:saferd/...` or relative imports)

### Code Style

- Prefer `const` constructors where possible
- Use `final` for variables that are never reassigned
- Avoid `var` — prefer explicit types, especially for public APIs
- Document all public classes, methods, and fields with `///` doc comments
- Write doc comments in English
- Keep functions short and focused on a single responsibility
- Use early returns to reduce nesting

---

## 🔀 PR Process

### 1. Create a Branch

```bash
git checkout -b feat/your-feature-name
# or
git checkout -b fix/your-bug-fix
```

### 2. Make Changes

- Write clean, well-documented code
- Add tests for new functionality
- Ensure all existing tests pass

### 3. Run Checks

```bash
dart format --set-exit-if-changed .
dart analyze
flutter test
```

### 4. Commit

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types:**

| Type   | Usage                              |
|--------|------------------------------------|
| `feat` | A new feature                      |
| `fix`  | A bug fix                          |
| `docs` | Documentation changes              |
| `style`| Code formatting, whitespace only   |
| `refactor`| Code change that neither fixes nor adds a feature |
| `test` | Adding or fixing tests             |
| `chore`| Build, CI, or tooling changes      |

**Examples:**

```
feat(report): add flood incident type
fix(map): handle null position in marker rendering
docs: update README with new screenshots
test(sos): add unit tests for countdown timer
```

### 5. Push & Open a PR

```bash
git push origin feat/your-feature-name
```

Then open a Pull Request on [GitHub](https://github.com/benzanmontage-hue/safe-rd).

### 6. PR Checklist

- [ ] Code is formatted (`dart format --set-exit-if-changed .`)
- [ ] No analyzer warnings or errors (`dart analyze`)
- [ ] All tests pass (`flutter test`)
- [ ] New code includes tests where applicable
- [ ] Public APIs have doc comments
- [ ] Commit messages follow Conventional Commits
- [ ] PR description explains the change and motivation

### 7. Review

- A maintainer will review your PR within a few days
- Address all feedback and push updates
- Once approved, a maintainer will merge your changes

---

## 🧪 Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run a specific test file
flutter test test/services/firebase_service_test.dart

# Run tests with coverage
flutter test --coverage
```

### Writing Tests

- Place tests in `test/` mirroring the `lib/` directory structure
- Use `flutter_test` for widget tests
- Use `mockito` or manual mocks for service dependencies
- Name test files with `_test.dart` suffix

Example:

```
lib/services/firebase_service.dart
  └── test/services/firebase_service_test.dart
```

---

## 📚 Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [Provider Package](https://pub.dev/packages/provider)
- [Firebase for Flutter](https://firebase.flutter.dev/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md)

---

## ❓ Questions?

If you have questions or need help, open a [Discussion](https://github.com/benzanmontage-hue/safe-rd/discussions) or reach out to the maintainers.

Thank you for contributing to SafeRD! 🛡️
