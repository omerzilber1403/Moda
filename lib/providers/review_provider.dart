import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';

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
    return reviews.map((r) => r.rating).reduce((a, b) => a + b) /
        reviews.length;
  }
}

class ReviewsNotifier extends StateNotifier<ReviewsState> {
  ReviewsNotifier() : super(const ReviewsState()) {
    loadReviews();
  }

  String? get _userId => supabase.auth.currentUser?.id;

  Future<void> loadReviews() async {
    final userId = _userId;
    if (userId == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final data = await supabase
          .from('reviews')
          .select()
          .or('reviewer_id.eq.$userId,reviewee_id.eq.$userId')
          .order('created_at', ascending: false);
      final reviews =
          (data as List).map((e) => Review.fromJson(e)).toList();
      state = ReviewsState(reviews: reviews);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  List<Review> getReviewsForUser(String userId) {
    return state.reviews.where((r) => r.revieweeId == userId).toList();
  }

  List<Review> getReviewsForItem(String itemId) {
    return state.reviews.where((r) => r.itemId == itemId).toList();
  }

  /// Returns true on success.
  /// Throws if the order isn't completed or a review already exists
  /// (enforced server-side by the `can_review` RLS policy).
  Future<bool> addReview({
    required String orderId,
    required String revieweeId,
    required String itemId,
    required int rating,
    required String comment,
  }) async {
    final userId = _userId;
    if (userId == null) return false;

    state = state.copyWith(isLoading: true);
    try {
      await supabase.from('reviews').insert({
        'order_id': orderId,
        'reviewer_id': userId,
        'reviewee_id': revieweeId,
        'item_id': itemId,
        'rating': rating,
        'comment': comment,
      });
      await loadReviews();
      return true;
    } catch (_) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }
}

final reviewsProvider =
    StateNotifierProvider<ReviewsNotifier, ReviewsState>((ref) {
  return ReviewsNotifier();
});
