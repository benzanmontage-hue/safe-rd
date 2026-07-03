# SafeRD — Design Decisions (ADRs)

## ADR-001: Flutter over React Native
**Date:** 2025  
**Decision:** Use Flutter for cross-platform development.  
**Rationale:** Better performance for animations (SOS pulse), stronger offline support with Hive, single codebase for Android + future iOS.  
**Trade-off:** Larger APK size (~40MB vs ~15MB for RN).

## ADR-002: Hive over SQLite for Offline Storage
**Date:** 2025  
**Decision:** Use Hive as local database.  
**Rationale:** No native dependencies, faster reads for simple data (contacts, alerts), built-in encryption support.  
**Trade-off:** No complex queries. Acceptable — SafeRD doesn't need relational queries.

## ADR-003: Riverpod over BLoC
**Date:** 2025  
**Decision:** Use Riverpod for state management.  
**Rationale:** Compile-time safety, no BuildContext dependency for services, simpler for this app's complexity.  
**Trade-off:** Less ecosystem support than BLoC. Acceptable for this app's scope.

## ADR-004: OpenStreetMap over Google Maps
**Date:** 2025  
**Decision:** Use flutter_map + OSM tiles.  
**Rationale:** No API key, no billing, offline tile caching natively supported.  
**Trade-off:** Lower quality tiles than Google Maps. Acceptable — map is secondary feature.

## ADR-005: No Analytics (Privacy-First)
**Date:** 2025  
**Decision:** No Firebase Analytics, no Crashlytics, no third-party tracking.  
**Rationale:** Safety app = maximum privacy. Users must trust their location is never tracked.  
**Trade-off:** No crash reports, no usage data. Acceptable — manual testing + Play Store reviews.

## ADR-006: WhatsApp as Primary Alert Channel
**Date:** 2025  
**Decision:** WhatsApp fires first, then SMS, then FCM.  
**Rationale:** WhatsApp is used by 95%+ of Dominicans, instant delivery, read receipts, free.  
**Trade-off:** Requires WhatsApp installed. Fallback to SMS for non-WA users.

## ADR-007: Emergency Protocol as Source of Truth
**Date:** July 2026  
**Decision:** All SOS code must reference `context/emergency-protocol.md`.  
**Rationale:** Safety-critical code must have a single authority. No developer (human or AI) should implement SOS logic from memory.  
**Trade-off:** Extra documentation maintenance. Essential for safety.
