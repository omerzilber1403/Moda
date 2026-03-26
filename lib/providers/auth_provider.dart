import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/mock_api.dart';

class AuthState {
  final User? user;
  final bool isLoading;

  const AuthState({this.user, this.isLoading = false});

  bool get isAuthenticated => user != null;

  AuthState copyWith({User? user, bool? isLoading, bool clearUser = false}) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    state = AuthState(user: MockApi.currentUser);
  }

  Future<void> register(String email, String password, String name) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 800));
    state = AuthState(
      user: MockApi.currentUser.copyWith(email: email, displayName: name),
    );
  }

  /// Dev-mode: instantly log in as the given user (no credentials needed).
  Future<void> loginAs(User user) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 300));
    state = AuthState(user: user);
  }

  void logout() {
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
