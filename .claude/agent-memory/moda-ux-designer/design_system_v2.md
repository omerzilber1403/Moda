---
name: Moda Design System v2 — Stitch Implementation
description: Token values, no-line rule enforcement, gradient CTA pattern, and chip styling applied in the 2.0 design pass
type: project
---

## Stitch Design Pass — Applied Across 12 Screens

**Why:** Full visual polish from the Stitch M3 spec — digital atelier aesthetic.

**How to apply:** Follow these exact patterns in all future screens.

### No-Line Rule (strictly enforced)
- ZERO `Border.all` except:
  - Ghost border on focused inputs: `outlineVariant.withValues(alpha: 0.1)` width 1
  - Focus ring on active inputs: primary color, width 1.5
  - Functional UI affordances (unread dot white ring, stacked thumbnail separators)
- Replace all 1px card/container borders with surface tier background shifts

### Chip Styling (Stitch spec)
- Selected: `color: AppColors.primaryFixed`, text: `AppColors.primary`, no border
- Unselected: `color: AppColors.surfaceContainer`, text: `AppColors.onSurfaceVariant`, no border
- Pill shape: `BorderRadius.circular(AppRadius.full)`

### CTA Button Pattern
- All primary CTAs: `gradient: AppGradients.primary` + `borderRadius: AppRadius.full` + `AppShadows.md`
- Disabled state: `color: AppColors.surfaceContainerHigh`, text: `AppColors.outline`
- Never use flat `AppColors.primary` backgroundColor for buttons

### Coin Badge Header
- No border — tonal bg only: `color: AppColors.primaryFixed`
- Pill shape, compact padding

### Major Headlines (screen titles)
- FontWeight.w900, letterSpacing: `AppTypography.letterSpacingHeadline`
- "Messages" headline (chat), "Explore", "Saved" (likes), "Moda" (shop header)
- "Moda" wordmark: `AppColors.primary` color specifically

### Profile Avatar
- 80px diameter, `ClipOval` directly — no border ring container
- Fallback: `AppColors.surfaceContainerHigh` bg + `AppColors.onSurfaceVariant` icon

### WalletBanner
- Background: `AppColors.primaryFixed` (was primaryLight + border)
- "Buy Coins" button: `AppGradients.primary` gradient, white text
- No border anywhere on the banner

### GlassCard widget
- Background: `AppColors.surfaceContainerLow` (was surface + border)
- Shadow: `AppShadows.md`
- `borderColor` param kept for API compat but ignored

### Action Buttons (Explore)
- Skip: `AppColors.onSurfaceVariant` (grey)
- Like: `AppColors.primary` (burnt rust red — NOT likeGreen)
- Info: `AppColors.tertiary`
- Size: 64px for skip/like, 48px for info
- Glass bg: `AppColors.glassBackgroundLight` (white 70%), no border
