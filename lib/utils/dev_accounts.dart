import 'package:flutter/foundation.dart';

/// Dev-only test accounts for multi-user testing.
/// This file is ONLY used when kDebugMode == true (debug builds).
/// Never referenced in release builds.
///
/// SETUP (one-time):
///   1. Go to Supabase Dashboard → Authentication → Users
///   2. Set password for tal@moda.app  →  Moda2024!
///   3. Set password for dana@moda.app →  Moda2024!
///   4. Fill in YOUR password for omer@moda.app below.
///
/// TESTING FLOW:
///   - Chrome (normal)   → log in as Omer  (Seller)
///   - Chrome (incognito) → log in as Tal or Dana (Buyer)
///   Both windows point to the same localhost:8081

class DevAccount {
  final String name;
  final String email;
  final String password;
  final String role;
  final String initials;

  const DevAccount({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.initials,
  });
}

/// Test accounts — only accessed when kDebugMode is true.
const List<DevAccount> kDevAccounts = [
  DevAccount(
    name: 'Omer',
    email: 'omer@moda.app',
    password: 'YOUR_PASSWORD', // ← fill in your own password
    role: 'Seller · 140 SC',
    initials: 'O',
  ),
  DevAccount(
    name: 'Tal Levi',
    email: 'tal@moda.app',
    password: 'Moda2024!',
    role: 'Buyer 1 · 500 SC',
    initials: 'T',
  ),
  DevAccount(
    name: 'Dana Cohen',
    email: 'dana@moda.app',
    password: 'Moda2024!',
    role: 'Buyer 2 · 500 SC',
    initials: 'D',
  ),
];

/// Guard: ensures this is never called outside debug mode.
void assertDebugOnly() {
  assert(kDebugMode, 'DevAccounts must only be used in debug mode');
}
