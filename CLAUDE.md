# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## MCP Usage Rules

- **Supabase MCP** (`mcp__supabase__*`) — use freely for all backend/database tasks without asking.
- **GitHub MCP** (`mcp__github__*`) — DO NOT use unless the user explicitly asks. Requires approval each time.
- **All other MCPs** — require explicit user approval before use.

## Project Overview

**Moda** is a hybrid mobile marketplace app for buying and selling second-hand clothes using a virtual currency called **Style Coins (SC)**. It combines a traditional marketplace grid (Zara/ASOS style) with a gamified Tinder-style swipe discovery feed. New users receive 50 free Style Coins; additional coins can be bought with real money (1 shekel = 1 coin).

### Core User Flow
1. **Onboarding** — 3-page editorial walkthrough (discover, coins, sell)
2. **Shop** — Browse a 2-column marketplace grid with search & filters (main screen)
3. **Explore** — Swipe through clothing items in a gamified discovery feed (right = like, left = skip)
4. **Detail** — Tap any grid item to see full details, Add to Wishlist, or Buy
5. **Cart** — View cart items, summary, proceed to checkout
6. **Checkout** — Pickup & coin payment flow
7. **Chat** — After purchase, a chat opens between buyer and seller
8. **Upload** — List your own items with photos, details, and a price in Style Coins
9. **Profile** — View wallet, orders, liked items, listed items, and transactions
10. **Account & Settings** — User settings, notification preferences, my details

### Navigation
5 tabs: `Shop | Explore | [+Sell] | Inbox | Profile`

- **Shop** — Marketplace grid with search bar, Airbnb-style filters, heart toggle on cards
- **Explore** — Tinder-style swipe deck (gamified discovery, flutter_card_swiper)
- **[+Sell]** — Center FAB to list a new item
- **Inbox** — Chat list + per-order conversations (with smart templates)
- **Profile** — User profile, wallet, liked items, orders, my items, transactions

## Commands

```bash
flutter run                        # Run on connected device/emulator
flutter run -d chrome --web-port=8081  # Run in Chrome (web)
flutter build web --no-tree-shake-icons  # Build for web
flutter build apk                  # Build Android APK
flutter build ios                  # Build iOS
flutter pub get                    # Install dependencies
flutter pub run build_runner build # Generate freezed/json code
```

## Tech Stack

- **Framework:** Flutter 3.29+, Dart 3.7+
- **State Management:** flutter_riverpod (StateNotifier + Provider)
- **Routing:** go_router (declarative, auth redirect)
- **HTTP:** dio (prepared for future backend)
- **Swipe Cards:** flutter_card_swiper ^7.2.0 (used in Explore tab only)
- **Images:** cached_network_image
- **Storage:** flutter_secure_storage (JWT tokens)
- **Real-time:** socket_io_client (prepared for future backend)
- **UI:** BackdropFilter (glassmorphism), google_fonts (Plus Jakarta Sans), shimmer
- **Models:** Plain Dart classes (freezed-ready)

## Architecture

Entry point is `lib/main.dart` -> `lib/app.dart` (MaterialApp.router + ProviderScope).

```
lib/
  main.dart              # Entry point
  app.dart               # MaterialApp.router + ProviderScope (title: 'Moda')
  router/
    router.dart          # GoRouter: see Routes section below
  models/
    user.dart            # User with styleCoinBalance
    clothing_item.dart   # ClothingItem with priceInCoins, brand, size, condition
    order.dart           # Order, OrderDetail, OrderStatus
    transaction.dart     # Transaction, TransactionType
    message.dart         # Message (uses orderId)
    models.dart          # Barrel exports
  providers/
    auth_provider.dart   # Auth state + mock user selection
    shop_provider.dart   # Marketplace grid: search, filters (category/size/price/condition)
    browse_provider.dart # Explore feed items + category filtering (swipe deck)
    likes_provider.dart  # Liked items list (swipe right -> like, or heart toggle)
    wallet_provider.dart # Style Coin balance, purchases, top-ups
    orders_provider.dart # Purchase/sale order history
    chat_provider.dart   # Chat messages per order
    items_provider.dart  # User's own listed items
    cart_provider.dart   # Cart items + checkout state
  services/
    mock_api.dart        # Mock data: users, items, orders, transactions, messages
    storage_service.dart # Secure storage for tokens
  screens/
    splash/              # Splash / loading screen
    onboarding/          # 3-page editorial onboarding
    auth/                # Login, signup, forgot/reset password, verification
    shop/                # Marketplace grid (2-col, search, filters)
      shop_screen.dart   # Main marketplace grid with search bar + filter button
      filter_sheet.dart  # Airbnb-style filter bottom sheet / full-screen
    explore/             # Tinder-style swipe deck
      explore_screen.dart
    item_detail/         # Item detail screen (from grid tap)
      item_detail_screen.dart
    likes/               # Saved/liked items (also accessible from Profile)
    cart/                # Cart screen
    checkout/            # Checkout flow + success screen
    chat/                # Chat list + per-order chat screen
    profile/             # Profile, wallet, liked items, orders, transactions, buy coins
    upload/              # Item upload with price field
    orders/              # Orders list + order tracking
    account/             # Account settings, my details, notifications
    address/             # Address list management
  widgets/
    swipe_card.dart      # Full-bleed image card with glass overlays (Explore tab)
    shell_scaffold.dart  # Tab bar shell (Shop|Explore|+|Inbox|Profile)
    glass_button.dart    # Reusable glass-style button
    glass_input.dart     # Reusable glass-style input
    glass_card.dart      # Reusable glass-style card
    wallet_banner.dart   # Balance display + Buy Coins CTA
    shop_item_card.dart  # Grid card for marketplace items
    order_card.dart      # Order list tile
    chat_bubble.dart     # Chat message bubble
    empty_state.dart     # Reusable empty state widget
  theme/
    tokens.dart          # Design tokens — full M3 palette from Stitch
    app_theme.dart       # ThemeData built from tokens (Plus Jakarta Sans)
  utils/
    helpers.dart         # Relative time formatting, etc.
```

## Routes

```
/onboarding             # 3-page onboarding (first launch)
/login                  # Login screen
/signup                 # Signup screen
/forgot-password        # Forgot password
/verification           # Code verification
/reset-password         # Reset password
/shop                   # Main marketplace grid (tab)
/explore                # Swipe discovery (tab)
/chat                   # Chat list (tab)
/profile                # Profile (tab)
/chat/:orderId          # Per-order chat
/upload                 # Upload item
/item/:itemId           # Item detail
/cart                   # Cart
/checkout               # Checkout flow
/checkout/success       # Checkout success
/orders                 # Orders list
/orders/:orderId/track  # Track order
/account                # Account & settings
/account/details        # My details
/account/notifications  # Notification settings
/address                # Address list
/saved                  # Saved items & notifications
```

## Style Coin Economy

- **New user bonus:** 50 SC
- **Purchase:** Buyer pays X SC -> seller receives X SC -> order created -> item deactivated
- **Top-up:** Buy coins with real money (mock: 50/100/200 SC packages, 1 shekel = 1 SC)
- **Transaction types:** welcomeBonus, purchase, sale, topup

Currently using mock data — no backend yet.

## Design Direction — Digital Atelier

Creative philosophy: **"The Digital Atelier"** — the interface is a curated editorial gallery, not a standard e-commerce grid. Premium, high-end boutique feel with intentional asymmetry, tonal depth, and tactile softness.

### M3 Color Palette (from Stitch)

| Token | Hex | Usage |
|---|---|---|
| `primary` | `#AC2C14` | Burnt rust red — primary CTAs, selections |
| `primaryContainer` | `#CE452A` | Medium terracotta — gradient CTAs |
| `primaryFixed` | `#FFDAD3` | Soft peach — selected chip bg |
| `primaryFixedDim` | `#FFB4A4` | Warm peach — accents |
| `secondary` | `#006D3E` | Forest green — trust/success |
| `secondaryContainer` | `#6FF9A8` | Light green — eco badges |
| `tertiary` | `#615B53` | Warm taupe — tertiary actions |
| `surface` | `#FBF9F1` | Warm cream — base background |
| `surfaceContainerLowest` | `#FFFFFF` | Pure white — Level 2 cards |
| `surfaceContainerLow` | `#F5F4EB` | Cream — Level 1 sections |
| `surfaceContainer` | `#F0EEE5` | Mid cream — mid nesting |
| `surfaceContainerHigh` | `#EAE8E0` | Warm gray — input fills |
| `surfaceContainerHighest` | `#E4E3DA` | Stone — strongest container |
| `onSurface` | `#1B1C17` | Near-black text (never pure #000) |
| `onSurfaceVariant` | `#59413C` | Brown-gray — secondary text |
| `outline` | `#8D706A` | Warm outline — tertiary text |
| `outlineVariant` | `#E1BFB8` | Ghost border (use at 10-20% opacity) |
| `error` | `#BA1A1A` | Error red |
| `inverseSurface` | `#30312B` | Dark — tooltips, snackbars |

### The "No-Line" Rule
1px solid borders are **prohibited**. Boundaries are defined by:
1. Background color shifts (surface tiers)
2. Tonal transitions (container hierarchy)
3. Negative space (spacing tokens)

### Typography
- **Font:** Plus Jakarta Sans (Google Fonts)
- **Display/Headlines:** Tight letter-spacing (-0.02em to -0.04em) for editorial look
- **Body:** Standard tracking for legibility

### Border Radii (ROUND_FULL profile)
- Default (md): 16px — buttons, cards
- Large (lg): 24px — image containers
- XL: 32px — sheets, hero sections
- Full: 9999px — pill shapes

### Shadows (Tinted Ambient)
- Shadow color: tinted `onSurface` (#1B1C17) at 4-8% opacity
- Main ambient: `0 20px 50px rgba(27, 28, 23, 0.08)`

### Glassmorphism
- Nav bars: `rgba(251, 249, 241, 0.80)` + `blur(20px)`
- Card overlays: `rgba(255, 255, 255, 0.70)` + `blur(12px)`
- Ghost border on inputs: `outlineVariant` at 10% opacity

### Signature CTA Gradient
`linear-gradient(#AC2C14, #CE452A)` — "sun-drenched" warmth for primary buttons

### Do's and Don'ts
- **Do** use asymmetrical layouts, bleed images off-screen
- **Do** prioritize vertical white space (3rem–4rem between sections)
- **Do** use secondary green sparingly for trust/eco badges
- **Don't** use 1px solid dividers (use gaps or surface color shifts)
- **Don't** use pure black (#000000) — use onSurface (#1B1C17)
- **Don't** use 4px/8px border radii — minimum 16px for this system

## Shop Tab — Marketplace Grid

- **Layout:** 2-column grid (Zara/ASOS style), image-first cards
- **Grid Item Card:** Large image as focus. Below: Brand, Price in SC, Condition. Heart icon at top-right for Like/Unlike.
- **Search Bar:** Sticky at top, searches by title/brand
- **Filter Button:** Opens Airbnb-style bottom sheet with Category, Size, Price range, Condition
- **Likes from Grid:** Heart icon on each card toggles like status via likesProvider

## Explore Tab — Swipe Discovery

- Tinder-style card swiper (flutter_card_swiper ^7.2.0)
- Swipe right = like (add to likes), swipe left = skip
- Category filter chips at top
- Action buttons below deck (skip, info, like)
- "WANT" CTA on card

## Item Detail Screen

- Opened via tap on any grid card (route: /item/:id)
- Full image carousel, brand, size, condition, description, seller info
- Two prominent CTAs: "Add to Wishlist" + "Buy for X SC"
- Verified authentic badge, eco-conscious badge

## CardSwiper API Notes

- Uses `flutter_card_swiper: ^7.2.0`
- Controller method: `controller.swipe(CardSwiperDirection.right)` — NOT `swipeRight()`
- Swipe right triggers `likesProvider.likeItem()`, not an instant purchase

## Filter Data

- **Categories:** Tops, Bottoms, Dresses, Outerwear, Shoes, Accessories
- **Sizes:** XS, S, M, L, XL, XXL (apparel); shoe sizes in attributes
- **Conditions:** New with Tags, Like New, Good, Fair
- **Price range:** 0–500 SC (adjustable slider)
