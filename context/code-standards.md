# SafeRD — Code Standards

## Principles
- **Clean Code** — functions do one thing, names explain intent
- **SOLID** — single responsibility, dependency inversion
- **Feature-first** — code organized by feature, not by type
- **No business logic in widgets** — widgets are presentation only

## Project Structure Conventions
```
feature/
├── data/
│   ├── models/       # Data classes
│   ├── repositories/ # Data access
│   └── datasources/  # Local/remote sources
├── domain/
│   ├── entities/     # Core business objects
│   └── usecases/     # Single-action classes
└── presentation/
    ├── providers/    # Riverpod providers
    ├── screens/      # Full pages
    └── widgets/      # Reusable components
```

## Rules for AI Code Generation
1. ✅ Use `final` by default, `var` only when mutating
2. ✅ Every public class/method must have doc comments
3. ✅ Riverpod providers go in `presentation/providers/`
4. ✅ Hive adapters go in `core/storage/`
5. ❌ Never hardcode phone numbers, API keys, or secrets
6. ❌ Never import `dart:io` without platform check
7. ❌ Never modify existing feature behavior without explicit permission
8. ✅ Always write unit tests for domain layer
9. ✅ Always write widget tests for SOS button
10. ❌ Never commit `.env` or `google-services.json`

## Dependency Injection
Use Riverpod for DI. No service locators.
```dart
final hiveServiceProvider = Provider<HiveService>((ref) => HiveService());
```

## Error Handling
```dart
// Always use Result type pattern
sealed class Result<T> {}
class Success<T> extends Result<T> { final T data; }
class Failure<T> extends Result<T> { final String message; }
```
