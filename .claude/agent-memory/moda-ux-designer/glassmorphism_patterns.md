---
name: Flutter Glassmorphism Patterns
description: Where and how BackdropFilter is used after rrdhoi overhaul (light theme, 2026-03-21)
type: project
---

## IMPORTANT: After rrdhoi overhaul, BackdropFilter is RESTRICTED
BackdropFilter (blur) is ONLY used on the swipe card image overlays. Do NOT use it on:
- Screen backgrounds
- App bars
- Navigation bars
- Modals/popups
- List tiles
- Auth cards

## Where BackdropFilter IS still used
1. **Swipe card side-panel circles** (right-side action panel over image) — sigmaX/Y = AppGlass.blurLight (8)
2. **Match popup backdrop** — sigmaX/Y = 16 — allowed because it's over image content

## Standard Surface Card (replaces old GlassCard)
```dart
Container(
  decoration: BoxDecoration(
    color: AppColors.surface,        // pure white
    borderRadius: BorderRadius.circular(AppRadius.xl),
    border: Border.all(color: AppColors.border, width: 1),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowColor.withValues(alpha: 0.06),
        blurRadius: 20,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: ...,
)
```

## Nav Bar Floating Shadow
```dart
boxShadow: AppShadows.navBar  // Offset(0,10), blurRadius:35, alpha:0.10
```

## Primary Button
```dart
color: AppColors.primary, borderRadius: BorderRadius.circular(AppRadius.md), elevation: 0
shadow: AppColors.primary.withValues(alpha: 0.25), blurRadius:12
```

## Gradient Ring Avatar (match popup only)
```dart
Container(
  padding: EdgeInsets.all(2.5),
  decoration: BoxDecoration(gradient: AppGradients.primary, shape: BoxShape.circle),
  child: Container(
    padding: EdgeInsets.all(2),
    decoration: BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
    child: CircleAvatar(...),
  ),
)
```

## Glass circles over card images (swipe card side panel)
```dart
ClipRRect(
  borderRadius: BorderRadius.circular(AppRadius.full),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: AppGlass.blurLight, sigmaY: AppGlass.blurLight),
    child: Container(
      width: 44, height: 44,
      decoration: BoxDecoration(
        color: AppColors.glassBackground,  // 50% white
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.glassBorderLight, width: 0.5),
      ),
    ),
  ),
)
```

## Animated Focus Border (GlassInput)
- StatefulWidget with FocusChange listener on AnimatedContainer
- Focused: AppColors.primary border (1.5px) + soft primary shadow
- Unfocused: AppColors.border (1px), AppShadows.sm

## Chat Bubble Patterns
- Mine: AppColors.primary fill, white text, primary glow shadow
- Theirs: AppColors.surface fill, black text, AppColors.border border, AppShadows.sm
