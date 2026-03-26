import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/tokens.dart';

class _OnboardingPage {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;

  const _OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
  });
}

const _pages = [
  _OnboardingPage(
    title: 'Define Your Style',
    subtitle: 'Enter the Digital Atelier.\nTrade curated luxury using Style Coins.',
    icon: Icons.diamond_outlined,
    iconBackground: AppColors.primaryFixed,
    iconColor: AppColors.primary,
  ),
  _OnboardingPage(
    title: 'Pay with Style Coins',
    subtitle: 'Our virtual currency makes trading simple.\nGet 50 free coins when you join.',
    icon: Icons.monetization_on_rounded,
    iconBackground: AppColors.secondaryFixed,
    iconColor: AppColors.secondary,
  ),
  _OnboardingPage(
    title: 'Join the\nCircular Economy',
    subtitle: 'List items you no longer wear and earn\nStyle Coins sustainably.',
    icon: Icons.recycling_rounded,
    iconBackground: AppColors.tertiaryFixed,
    iconColor: AppColors.tertiary,
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  bool get _isLastPage => _currentPage == _pages.length - 1;

  void _onNext() {
    if (_isLastPage) {
      context.go('/login');
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onSkip() => context.go('/login');

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.lg,
                  right: AppLayout.screenPaddingH,
                ),
                child: TextButton(
                  onPressed: _onSkip,
                  child: Text(
                    'Skip',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.onSurfaceVariant,
                      fontSize: AppTypography.fontSm,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) =>
                    setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  return _OnboardingPageView(page: _pages[index]);
                },
              ),
            ),

            // Dot indicators
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                    width: _currentPage == index ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.primary
                          : AppColors.outlineVariant,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom CTA
            Padding(
              padding: EdgeInsets.only(
                left: AppLayout.screenPaddingH,
                right: AppLayout.screenPaddingH,
                bottom: MediaQuery.of(context).padding.bottom + AppSpacing.xl,
              ),
              child: Column(
                children: [
                  // Gradient CTA button
                  GestureDetector(
                    onTap: _onNext,
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: AppGradients.primary,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        boxShadow: AppShadows.md,
                      ),
                      child: Center(
                        child: Text(
                          _isLastPage ? 'Get Started' : 'Continue',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.onPrimary,
                            fontSize: AppTypography.fontMd,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Tagline
                  Text(
                    '2.4k+ Atelier Members',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.outline,
                      fontSize: AppTypography.fontXs,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageView extends StatelessWidget {
  final _OnboardingPage page;

  const _OnboardingPageView({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.screenPaddingH,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon in rounded container — editorial circle
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: page.iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 72,
              color: page.iconColor,
            ),
          ),

          const SizedBox(height: AppSpacing.xxxl),

          // Headline
          Text(
            page.title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: AppTypography.font2xl,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
              letterSpacing: AppTypography.letterSpacingHeadline,
              height: AppTypography.lineHeightTight,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.lg),

          // Subtitle
          Text(
            page.subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: AppTypography.fontMd,
              fontWeight: FontWeight.w400,
              color: AppColors.onSurfaceVariant,
              height: AppTypography.lineHeightRelaxed,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
