import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/models.dart';
import '../services/supabase_service.dart';
import 'notifications_provider.dart';
import 'orders_provider.dart';
import 'wallet_provider.dart';

class AuthState {
  final AppUser? user;
  final bool isLoading;

  const AuthState({this.user, this.isLoading = false});

  bool get isAuthenticated => user != null;

  AuthState copyWith({AppUser? user, bool? isLoading, bool clearUser = false}) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(const AuthState()) {
    _init();
  }

  void _init() {
    final session = supabase.auth.currentSession;
    if (session != null) {
      _loadProfile(session.user.id);
    }
    supabase.auth.onAuthStateChange.listen(
      (data) {
        final event = data.event;
        final session = data.session;
        if (event == AuthChangeEvent.signedIn && session != null) {
          _loadProfile(session.user.id);
          _initRealtimeProviders();
        } else if (event == AuthChangeEvent.signedOut) {
          _resetRealtimeProviders();
          state = const AuthState();
        }
      },
      onError: (error) {
        // Handle stale/reused refresh tokens — clear corrupted session
        // so the user can log in fresh.
        if (error is AuthException &&
            error.message.toLowerCase().contains('refresh_token')) {
          debugPrint('[Moda Auth] Stale refresh token detected, signing out');
          supabase.auth.signOut();
          state = const AuthState();
        }
      },
    );
  }

  void _initRealtimeProviders() {
    ref.read(ordersProvider.notifier).refresh();
    ref.read(notificationsProvider.notifier).loadNotifications();
    ref.read(walletProvider.notifier).loadWallet();
  }

  void _resetRealtimeProviders() {
    ref.read(ordersProvider.notifier).reset();
    ref.read(notificationsProvider.notifier).reset();
    ref.read(walletProvider.notifier).reset();
  }

  Future<void> _loadProfile(String uid) async {
    try {
      final data =
          await supabase.from('profiles').select().eq('id', uid).single();
      state = AuthState(user: AppUser.fromJson(data), isLoading: false);
      await _registerFcmToken();
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _registerFcmToken() async {
    // TODO: Re-enable when Firebase is configured
    // Requires google-services.json and flutterfire configure
  }

  Future<void> _logSession(String userId, String event) async {
    try {
      await supabase
          .from('user_sessions')
          .insert({'user_id': userId, 'event': event});
    } catch (_) {
      // Non-critical — never block auth on logging failure
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        await _loadProfile(response.user!.id);
        _logSession(response.user!.id, 'login');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  /// Returns `true` if the user is immediately signed in (no email
  /// confirmation required), or `false` if the user must confirm their
  /// email before they can log in.
  Future<bool> register(String email, String password, String name) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': name},
      );

      // If Supabase requires email confirmation, session will be null.
      if (response.session == null) {
        state = state.copyWith(isLoading: false);
        return false; // email confirmation required
      }

      // Session exists — user is signed in immediately.
      // The DB trigger `handle_new_user` already created the profile row,
      // but the display_name may have been set from metadata. Update it
      // to the user-provided name to be safe.
      if (response.user != null) {
        await supabase.from('profiles').update({
          'display_name': name,
        }).eq('id', response.user!.id);
        await _loadProfile(response.user!.id);
      }
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  /// Reload the current user's profile from Supabase.
  Future<void> refreshProfile() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid != null) {
      await _loadProfile(uid);
    }
  }

  void logout() {
    final uid = supabase.auth.currentUser?.id;
    if (uid != null) _logSession(uid, 'logout');
    _resetRealtimeProviders();
    supabase.auth.signOut();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
