import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/mock_api.dart';
import 'auth_provider.dart';

class OrdersNotifier extends StateNotifier<List<OrderDetail>> {
  final Ref ref;

  OrdersNotifier(this.ref) : super([]) {
    loadOrders();
  }

  String get _userId => ref.read(authProvider).user?.id ?? 'user-me';

  Future<void> loadOrders() async {
    await Future.delayed(const Duration(milliseconds: 200));
    state = MockApi.getOrderDetails(_userId);
  }

  Future<void> refresh() async {
    state = MockApi.getOrderDetails(_userId);
  }
}

final ordersProvider =
    StateNotifierProvider<OrdersNotifier, List<OrderDetail>>((ref) {
  return OrdersNotifier(ref);
});
