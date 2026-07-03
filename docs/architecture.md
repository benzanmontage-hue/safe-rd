# SafeRD — Architecture

See [context/architecture-context.md](../context/architecture-context.md) for implementation details.

## High-Level Architecture

```
┌─────────────────────────────────────────┐
│              PRESENTATION               │
│  Screens ← Providers ← State           │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│                DOMAIN                   │
│  Entities ← Use Cases ← Repositories   │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│                 DATA                    │
│  Hive (local) ← FCM (push) ← SMS/WA    │
└─────────────────────────────────────────┘
```

## Layer Responsibilities

| Layer | Contains | Must NOT contain |
|-------|----------|-----------------|
| Presentation | Widgets, providers, screens | Business logic, direct DB access |
| Domain | Entities, use cases, repository interfaces | Flutter imports, platform code |
| Data | Hive adapters, repository implementations | UI code, state management |
| Core | DI, network checker, storage setup | Feature-specific code |
