---
name: FitFlip Project Stack
description: Tech stack, architecture, and key patterns used in the FitFlip Flutter app
type: project
---

FitFlip is a Flutter 3.29+ / Dart 3.7+ app — NOT React Native. The system prompt describes a React Native stack but CLAUDE.md and the actual codebase use Flutter.

**Why:** The system prompt persona was written generically for a React Native project, but this specific project is Flutter. Always trust CLAUDE.md and the actual code over the system prompt tech stack description.

**How to apply:** Use Flutter APIs (BackdropFilter, ImageFilter, BoxDecoration, ClipRRect) not React Native Reanimated. Use Dart syntax. Never write React Native or TypeScript code.

## Actual Tech Stack
- Flutter 3.29+, Dart 3.7+
- flutter_riverpod (StateNotifier + Provider) for state
- go_router for routing (tabs, auth redirect, chat, upload)
- flutter_card_swiper for swipe deck
- cached_network_image for all images
- google_fonts (Poppins) — GoogleFonts.poppins() everywhere after rrdhoi overhaul
- BackdropFilter + ImageFilter.blur ONLY on swipe card image overlays (not on screens/bg)

## Architecture
- `lib/theme/tokens.dart` — ALL visual constants (colors, spacing, radius, typography, shadows, gradients, glass values)
- `lib/theme/app_theme.dart` — ThemeData built from tokens
- `lib/widgets/` — Reusable design system components
- `lib/screens/` — Feature screens
- `lib/models/` — Data classes
- `lib/providers/` — Riverpod providers (state management — do not touch)
- `lib/services/mock_api.dart` — Mock data layer (do not touch)

## Key File Paths
- Design tokens: `lib/theme/tokens.dart`
- Shell/nav bar: `lib/widgets/shell_scaffold.dart`
- Swipe card: `lib/widgets/swipe_card.dart`
- Match popup: `lib/widgets/match_popup.dart`
- Glass card: `lib/widgets/glass_card.dart`
- Glass button: `lib/widgets/glass_button.dart`
- Glass input: `lib/widgets/glass_input.dart`
- Chat bubble: `lib/widgets/chat_bubble.dart`
- Match card: `lib/widgets/match_card.dart`
- Empty state: `lib/widgets/empty_state.dart`
