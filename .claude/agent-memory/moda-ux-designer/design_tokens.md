---
name: FitFlip Design Tokens
description: All token values defined in lib/theme/tokens.dart — rrdhoi-inspired LIGHT theme (updated 2026-03-21)
type: project
---

## THEME: LIGHT (rrdhoi-inspired)
App was fully overhauled from dark purple to light theme. No dark gradient backgrounds.

## AppColors (key values)
- `background` = #F2F2F7 — iOS-style warm light gray (all screens)
- `surface` = #FFFFFF — pure white (cards, tiles, nav)
- `surfaceSecondary` = #F7F7F7
- `primary` = #7D50F0 — softer purple (rrdhoi)
- `primaryLight` = #EEE8FF — soft lavender bg (used for icon containers)
- `accent` = #57CA8C — rrdhoi green (match/success)
- `accentWarm` = #FF6B8A — warm pink (like/heart)
- `textPrimary` = #1A1A1A
- `textSecondary` = #9698A9 — gray (rrdhoi)
- `textTertiary` = #B0B0B0
- `black` = #040303 — near-black (nav icons inactive)
- `white` = #FAFAFA — near-white
- `border` = #EDEDED
- `borderLight` = #F5F5F5
- `shadowColor` = #040303 — for box shadows
- `success` = #57CA8C, `error` = #FF4757, `warning` = #FFB547
- Glass tokens (swipe card overlays ONLY): `glassBackground`=50% white, `glassBorder`=20% white, `glassBorderLight`=35% white

## AppGradients
- `primary` = #7D50F0 → #57CA8C (match popup only)
- `cardScrim` = transparent → 20% black → 60% black (swipe card bottom)
- `backgroundFade` = transparent → #CCF2F2F7 (nav bar float effect)
- `sunset` = #FF6B8A → #FFB547 (match popup heart icon)
- `background`, `card`, `subtle` = white variants (legacy, no longer used on screens)

## AppRadius (doubles) — UPDATED
sm=8, md=12, lg=16, xl=20, xxl=24, **xxxl=30** (cards/nav pill), full=9999

## AppSpacing (doubles) — unchanged
xs=4, sm=8, md=12, lg=16, xl=24, xxl=32, xxxl=48, xxxxl=64

## AppTypography — UPDATED
- Font: Poppins (GoogleFonts.poppins) everywhere
- letterSpacingTitle = -0.3 (was letterSpacingTight = -0.5)
- letterSpacingBody = 0.1

## AppShadows — UPDATED (use shadowColor not pure black)
sm, md, lg, xl — use `AppColors.shadowColor.withValues(alpha: 0.06–0.12)`, blurRadius 8–35
navBar = Offset(0,10) blurRadius:35 (for floating pill nav)

## AppGlass
blur=12, blurIntense=20, blurLight=8 — used ONLY on swipe card image overlays

## AppLayout — UPDATED
tabBarHeight=96 (was 85/90), matchGridGap=14 (was 12)

## AppAnimation — unchanged
swipeThrowThreshold=120, matchPopupDuration=600ms, confettiCount=30
