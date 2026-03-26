import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/verification_code_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/shop/shop_screen.dart';
import '../screens/explore/explore_screen.dart';
import '../screens/chat/chat_list_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/upload/upload_screen.dart';
import '../screens/item_detail/item_detail_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/checkout/checkout_screen.dart';
import '../screens/checkout/checkout_success_screen.dart';
import '../models/models.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/orders/track_order_screen.dart';
import '../screens/account/account_screen.dart';
import '../screens/account/my_details_screen.dart';
import '../screens/account/notification_settings_screen.dart';
import '../screens/address/address_list_screen.dart';
import '../screens/likes/likes_screen.dart';
import '../widgets/shell_scaffold.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/shop',
    redirect: (context, state) {
      final isAuth = auth.isAuthenticated;
      final loc = state.matchedLocation;
      final isPublic = loc == '/auth' ||
          loc == '/login' ||
          loc == '/signup' ||
          loc == '/onboarding' ||
          loc == '/forgot-password' ||
          loc == '/verification' ||
          loc == '/reset-password';

      if (!isAuth && !isPublic) return '/login';
      if (isAuth && (loc == '/login' || loc == '/auth')) return '/shop';
      return null;
    },
    routes: [
      // ─── Auth / Onboarding ──────────────────────────────
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/verification',
        builder: (context, state) => const VerificationCodeScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),

      // ─── Main shell (bottom nav) ─────────────────────────
      ShellRoute(
        builder: (context, state, child) => ShellScaffold(child: child),
        routes: [
          GoRoute(
            path: '/shop',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ShopScreen(),
            ),
          ),
          GoRoute(
            path: '/explore',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ExploreScreen(),
            ),
          ),
          GoRoute(
            path: '/chat',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ChatListScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),

      // ─── Deep-link / push routes ─────────────────────────
      GoRoute(
        path: '/chat/:orderId',
        builder: (context, state) => ChatScreen(
          orderId: state.pathParameters['orderId']!,
        ),
      ),
      GoRoute(
        path: '/upload',
        builder: (context, state) => const UploadScreen(),
      ),
      GoRoute(
        path: '/item/:itemId',
        builder: (context, state) => ItemDetailScreen(
          itemId: state.pathParameters['itemId']!,
        ),
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/checkout/success',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return CheckoutSuccessScreen(
            items: (extra['items'] as List<dynamic>?)
                    ?.cast<ClothingItem>() ??
                [],
            totalCoins: (extra['totalCoins'] as int?) ?? 0,
            orderId: (extra['orderId'] as String?) ?? '',
          );
        },
      ),
      GoRoute(
        path: '/checkout-success',
        redirect: (context, state) => '/checkout/success',
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrdersScreen(),
        routes: [
          GoRoute(
            path: ':orderId/track',
            builder: (context, state) => TrackOrderScreen(
              orderId: state.pathParameters['orderId']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/account',
        builder: (context, state) => const AccountScreen(),
        routes: [
          GoRoute(
            path: 'details',
            builder: (context, state) => const MyDetailsScreen(),
          ),
          GoRoute(
            path: 'notifications',
            builder: (context, state) => const NotificationSettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/address',
        builder: (context, state) => const AddressListScreen(),
      ),
      GoRoute(
        path: '/saved',
        builder: (context, state) => const LikesScreen(),
      ),
    ],
  );
});
