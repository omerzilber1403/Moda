---
name: FitFlip Component Inventory
description: All reusable widgets in lib/widgets/ — what exists, what each does, current state
type: project
---

## UPDATED 2026-03-21 — rrdhoi light theme overhaul

## lib/widgets/glass_card.dart — GlassCard
Clean white surface card. No BackdropFilter. Props: child, borderRadius, padding, margin, backgroundColor, borderColor.
Decoration: AppColors.surface fill, AppColors.border border, shadowColor 0.06 alpha, blurRadius 20.

## lib/widgets/glass_button.dart — GlassButton
Three variants (glass variant now acts same as outline):
- `primary`: AppColors.primary fill, white text, AppRadius.md radius, AppShadows.md
- `outline`: AppColors.surface fill, AppColors.border border, black text
- `glass`: same as outline
Uses GoogleFonts.poppins for label text.

## lib/widgets/glass_input.dart — GlassInput (StatefulWidget)
Light theme text input. AppColors.surface fill, AppColors.border border.
Focus state: AppColors.primary border (1.5px) + soft primary shadow.
Text color: AppColors.textPrimary. Hint: AppColors.textTertiary.

## lib/widgets/swipe_card.dart — SwipeCard
Full-bleed card, borderRadius: AppRadius.xxxl (30).
- Hero image cover-fill
- Right-side action panel: semi-transparent white circles (BackdropFilter blurLight) with clothing type icon and condition dot
- Bottom: text on gradient scrim (no BackdropFilter strip) — title Poppins bold 22, brand·size, attr chips (glass pills), owner row
- No top-corner badges

## lib/widgets/match_card.dart — MatchCard
borderRadius: AppRadius.xxl (24).
- Hero image cover-fill
- Bottom white pill overlay with user name and primary circle chat icon
- Top-left: avatar in white circle border
- No gradient rings

## lib/widgets/match_popup.dart — MatchPopup (StatefulWidget)
White surface card (AppColors.surface), borderRadius: AppRadius.xxxl (30).
- BackdropFilter dark backdrop (allowed — over image content)
- Confetti sparkles (primary, accent, accentWarm colors)
- "It's a Match!" in AppColors.primary Poppins bold
- Subtitle in AppColors.textSecondary
- Gradient ring avatars (gradient ring → white ring → avatar)
- Swap circle: AppColors.primaryLight fill with primary icon
- Send Message (primary GlassButton) + Keep Swiping (outline GlassButton)

## lib/widgets/chat_bubble.dart — ChatBubble
- Mine: AppColors.primary fill, white text, primary glow shadow, tail bottom-right
- Theirs: AppColors.surface fill, black text, AppColors.border, AppShadows.sm, tail bottom-left

## lib/widgets/shell_scaffold.dart — ShellScaffold
Floating pill nav bar (borderRadius: AppRadius.xxxl = 30). White fill, navBar shadow.
- Active item: AppColors.primaryLight bg pill, AppColors.primary icon + label
- Inactive: transparent bg, AppColors.black icon + label
- Center upload: AppColors.primary circle with primary glow shadow
- Background fade gradient behind nav bar (IgnorePointer)

## lib/widgets/empty_state.dart — EmptyState
White surface card, borderRadius: AppRadius.xxl (24), AppColors.border border.
Icon in AppColors.primaryLight circle. Bold black title. Gray subtitle.

## Screens summary (light theme)
- auth: White surface user cards with AppColors.border, avatar thin border ring
- explore: AppColors.background, Poppins black title, clean white circle action buttons
- matches: AppColors.background, primary count badge, 2-col MatchCard grid
- messages: AppColors.surface tiles, AppColors.border dividers, primary unread badge
- profile: White AppBar header with centered name, thin avatar ring, white stats GlassCard, 2-col item grid
- chat: White scaffold, white AppBar with border bottom, light input bar
- upload: White AppBar, light chip selectors (primary fill when selected)
