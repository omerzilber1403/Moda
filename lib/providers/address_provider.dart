import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import 'auth_provider.dart';

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
  final Ref ref;

  AddressNotifier(this.ref) : super(const AddressState()) {
    _loadMockAddresses();
  }

  String? get _userId => ref.read(authProvider).user?.id;

  void _loadMockAddresses() {
    final userId = _userId;
    if (userId == null) return;

    state = AddressState(addresses: [
      Address(
        id: 'addr-1',
        userId: userId,
        label: 'Home',
        fullName: 'Alex Rivera',
        phone: '+972 50-123-4567',
        street: '42 Dizengoff Street',
        city: 'Tel Aviv',
        zipCode: '6433222',
        isDefault: true,
      ),
      Address(
        id: 'addr-2',
        userId: userId,
        label: 'Work',
        fullName: 'Alex Rivera',
        phone: '+972 50-123-4567',
        street: '15 Rothschild Blvd',
        city: 'Tel Aviv',
        zipCode: '6688112',
      ),
    ]);
  }

  Future<void> addAddress(Address address) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 300));

    final newAddress = address.copyWith(
      id: 'addr-${DateTime.now().millisecondsSinceEpoch}',
    );

    List<Address> updated = [...state.addresses, newAddress];
    if (newAddress.isDefault) {
      updated = updated.map((a) {
        return a.id == newAddress.id ? a : a.copyWith(isDefault: false);
      }).toList();
    }

    state = AddressState(addresses: updated);
  }

  void setDefault(String addressId) {
    state = state.copyWith(
      addresses: state.addresses.map((a) {
        return a.copyWith(isDefault: a.id == addressId);
      }).toList(),
    );
  }

  void removeAddress(String addressId) {
    state = state.copyWith(
      addresses: state.addresses.where((a) => a.id != addressId).toList(),
    );
  }
}

final addressProvider =
    StateNotifierProvider<AddressNotifier, AddressState>((ref) {
  return AddressNotifier(ref);
});
