---
name: Provider access patterns — notifier vs state
description: getReviewsForUser and similar filter methods live on the notifier, not on the state object; call via ref.read(provider.notifier).method()
type: feedback
---

`ReviewsState` exposes raw data (`reviews`, `isLoading`, computed `averageRating`) but filter helpers like `getReviewsForUser(userId)` and `getReviewsForItem(itemId)` are defined on `ReviewsNotifier`, not `ReviewsState`.

**Why:** The notifier holds business logic methods; the state is a plain data holder.

**How to apply:** When building UI that calls a filtering method, use `ref.read(reviewsProvider.notifier).getReviewsForUser(id)` rather than `ref.watch(reviewsProvider).getReviewsForUser(id)`. Still call `ref.watch(reviewsProvider)` to trigger a rebuild when state changes, then read filtered results via the notifier.
