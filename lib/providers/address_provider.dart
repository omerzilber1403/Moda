import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';

class AddressState {
  final List<Address> addresses;
  final bool isLoading;

  const AddressState({
    this.addresses = const [],
    this.isLoading = false,
  });

  AddressState copyWith({
    List<Address>? addresses,
    bool? isLoading,
  }) {
    return AddressState(
      addresses: addresses ?? this.addresses,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  Address? get defaultAddress {
    final defaults = addresses.where((a) => a.isDefault);
    return defaults.isNotEmpty ? defaults.first : addresses.firstOrNull;
  }
}

class AddressNotifier extends StateNotifier<AddressState> {
  AddressNotifier() : super(const AddressState()) {
    loadAddresses();
  }

  String? get _userId => supabase.auth.currentUser?.id;

  Future<void> loadAddresses() async {
    final userId = _userId;
    if (userId == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final data = await supabase
          .from('addresses')
          .select()
          .eq('user_id', userId)
          .order('is_default', ascending: false);
      final addresses =
          (data as List).map((e) => Address.fromJson(e)).toList();
      state = AddressState(addresses: addresses);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> addAddress(Address address) async {
    final userId = _userId;
    if (userId == null) return;
    state = state.copyWith(isLoading: true);
    try {
      if (address.isDefault) {
        // Unset other defaults
        await supabase
            .from('addresses')
            .update({'is_default': false}).eq('user_id', userId);
      }
      await supabase.from('addresses').insert(
            address.copyWith(userId: userId).toJson(),
          );
      await loadAddresses();
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> setDefault(String addressId) async {
    final userId = _userId;
    if (userId == null) return;
    try {
      await supabase
          .from('addresses')
          .update({'is_default': false}).eq('user_id', userId);
      await supabase
          .from('addresses')
          .update({'is_default': true}).eq('id', addressId);
      state = state.copyWith(
        addresses: state.addresses.map((a) {
          return a.copyWith(isDefault: a.id == addressId);
        }).toList(),
      );
    } catch (_) {
      // ignore
    }
  }

  Future<void> removeAddress(String addressId) async {
    try {
      await supabase.from('addresses').delete().eq('id', addressId);
      state = state.copyWith(
        addresses:
            state.addresses.where((a) => a.id != addressId).toList(),
      );
    } catch (_) {
      // ignore
    }
  }
}

final addressProvider =
    StateNotifierProvider<AddressNotifier, AddressState>((ref) {
  return AddressNotifier();
});
