import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import 'auth_provider.dart';

class ReviewsState {
  final List<Review> reviews;
  final bool isLoading;

  const ReviewsState({
    this.reviews = const [],
    this.isLoading = false,
  });

  ReviewsState copyWith({
    List<Review>? reviews,
    bool? isLoading,
  }) {
    return ReviewsState(
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  double get averageRating {
    if (reviews.isEmpty) return 0;
    return reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
  }
}

class ReviewsNotifier extends StateNotifier<ReviewsState> {
  final Ref ref;

  ReviewsNotifier(this.ref) : super(const ReviewsState()) {
    _loadMockReviews();
  }

  void _loadMockReviews() {
    state = ReviewsState(reviews: [
      Review(
        id: 'rev-1',
        orderId: 'order-1',
        reviewerId: 'user-2',
        revieweeId: 'user-me',
        itemId: 'item-1',
        rating: 5,
        comment: 'Item was exactly as described! Great condition, fast meetup.',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Review(
        id: 'rev-2',
        orderId: 'order-2',
        reviewerId: 'user-3',
        revieweeId: 'user-me',
        itemId: 'item-5',
        rating: 4,
        comment: 'Nice quality, slightly different shade than photos but still love it.',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Review(
        id: 'rev-3',
        orderId: 'order-3',
        reviewerId: 'user-me',
        revieweeId: 'user-4',
        itemId: 'item-12',
        rating: 5,
        comment: 'Perfect vintage find! Seller was super friendly.',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ]);
  }

  List<Review> getReviewsForUser(String userId) {
    return state.reviews.where((r) => r.revieweeId == userId).toList();
  }

  List<Review> getReviewsForItem(String itemId) {
    return state.reviews.where((r) => r.itemId == itemId).toList();
  }

  Future<void> addReview({
    required String orderId,
    required String revieweeId,
    required String itemId,
    required int rating,
    required String comment,
  }) async {
    final userId = ref.read(authProvider).user?.id;
    if (userId == null) return;

    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 300));

    final review = Review(
      id: 'rev-${DateTime.now().millisecondsSinceEpoch}',
      orderId: orderId,
      reviewerId: userId,
      revieweeId: revieweeId,
      itemId: itemId,
      rating: rating,
      comment: comment,
    );

    state = ReviewsState(reviews: [...state.reviews, review]);
  }
}

final reviewsProvider =
    StateNotifierProvider<ReviewsNotifier, ReviewsState>((ref) {
  return ReviewsNotifier(ref);
});
