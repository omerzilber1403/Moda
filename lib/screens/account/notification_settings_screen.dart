import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/tokens.dart';

class _NotifPref {
  final String title;
  final String subtitle;
  bool enabled;

  _NotifPref({
    required this.title,
    required this.subtitle,
    required this.enabled,
  });
}

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  late List<_NotifPref> _prefs;

  static const _keys = [
    'notif_order_updates',
    'notif_new_messages',
    'notif_price_drop',
    'notif_promotions',
    'notif_style_coins',
  ];
  static const _defaults = [true, true, true, false, true];

  @override
  void initState() {
    super.initState();
    _prefs = [
      _NotifPref(
        title: 'Order Updates',
        subtitle: 'Get notified when your order status changes',
        enabled: _defaults[0],
      ),
      _NotifPref(
        title: 'New Messages',
        subtitle: 'Receive alerts when someone sends you a message',
        enabled: _defaults[1],
      ),
      _NotifPref(
        title: 'Price Drop Alerts',
        subtitle: 'Know when items in your wishlist go on sale',
        enabled: _defaults[2],
      ),
      _NotifPref(
        title: 'Promotions & Offers',
        subtitle: 'Special deals, events, and seasonal offers',
        enabled: _defaults[3],
      ),
      _NotifPref(
        title: 'Style Coin Updates',
        subtitle: 'Balance changes, bonuses, and coin promotions',
        enabled: _defaults[4],
      ),
    ];
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final sp = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      for (int i = 0; i < _prefs.length; i++) {
        _prefs[i].enabled = sp.getBool(_keys[i]) ?? _defaults[i];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textPrimary,
            fontSize: AppTypography.fontLg,
            fontWeight: FontWeight.bold,
            letterSpacing: AppTypography.letterSpacingTitle,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: AppLayout.screenPaddingH,
          vertical: AppSpacing.xl,
        ),
        itemCount: _prefs.length,
        separatorBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(left: AppSpacing.lg),
          child: Container(height: 1, color: AppColors.borderLight),
        ),
        itemBuilder: (context, index) {
          final pref = _prefs[index];
          return Container(
            decoration: index == 0
                ? BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppRadius.lg),
                      topRight: Radius.circular(AppRadius.lg),
                    ),
                  )
                : index == _prefs.length - 1
                    ? BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(AppRadius.lg),
                          bottomRight: Radius.circular(AppRadius.lg),
                        ),
                      )
                    : BoxDecoration(color: AppColors.surface),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pref.title,
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textPrimary,
                          fontSize: AppTypography.fontMd,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        pref.subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textSecondary,
                          fontSize: AppTypography.fontXs,
                          height: AppTypography.lineHeightNormal,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Switch.adaptive(
                  value: pref.enabled,
                  onChanged: (val) async {
                    setState(() => pref.enabled = val);
                    final sp = await SharedPreferences.getInstance();
                    await sp.setBool(_keys[index], val);
                  },
                  activeColor: AppColors.primary,
                  activeTrackColor:
                      AppColors.primary.withValues(alpha: 0.3),
                  inactiveThumbColor: AppColors.gray400,
                  inactiveTrackColor: AppColors.gray200,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
