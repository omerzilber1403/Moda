import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../theme/tokens.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onSignup() async {
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) return;

    if (!_agreedToTerms) {
      setState(
          () => _errorMessage = 'Please agree to the Terms & Conditions');
      return;
    }

    try {
      await ref.read(authProvider.notifier).register(
            _emailController.text.trim(),
            _passwordController.text,
            _nameController.text.trim(),
          );

      if (mounted) {
        context.go('/shop');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Sign up failed. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppLayout.screenPaddingH,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),

              // Back arrow
              _BackButton(onPressed: () => context.pop()),

              const SizedBox(height: AppSpacing.xxl),

              // Title
              Text(
                'Create Account',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: AppTypography.font2xl,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  letterSpacing: AppTypography.letterSpacingTitle,
                  height: AppTypography.lineHeightTight,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Join Moda and get 50 free Style Coins',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: AppTypography.fontMd,
                  color: AppColors.textSecondary,
                  height: AppTypography.lineHeightNormal,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Error banner
              if (_errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: AppColors.error, size: 18),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.error,
                            fontSize: AppTypography.fontSm,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Full name
                    _AuthInputField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Email
                    _AuthInputField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Password
                    _AuthInputField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Create a password',
                      obscureText: _obscurePassword,
                      prefixIcon: Icons.lock_outline_rounded,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textTertiary,
                          size: 20,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Confirm password
                    _AuthInputField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      hint: 'Re-enter your password',
                      obscureText: _obscureConfirm,
                      prefixIcon: Icons.lock_outline_rounded,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textTertiary,
                          size: 20,
                        ),
                        onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Terms checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _agreedToTerms,
                            onChanged: (value) =>
                                setState(() => _agreedToTerms = value!),
                            activeColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.sm / 2),
                            ),
                            side: const BorderSide(
                              color: AppColors.border,
                              width: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(
                                () => _agreedToTerms = !_agreedToTerms),
                            child: Text.rich(
                              TextSpan(
                                text: 'By signing up you agree to our ',
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppColors.textSecondary,
                                  fontSize: AppTypography.fontSm,
                                  height: AppTypography.lineHeightNormal,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Terms & Conditions',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: AppColors.primary,
                                      fontSize: AppTypography.fontSm,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Sign Up button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: authState.isLoading ? null : _onSignup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          disabledBackgroundColor:
                              AppColors.primary.withValues(alpha: 0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.lg),
                          ),
                          elevation: 0,
                          textStyle: GoogleFonts.plusJakartaSans(
                            fontSize: AppTypography.fontMd,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: authState.isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                            : const Text('Sign Up'),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // Divider
                    Row(
                      children: [
                        const Expanded(
                            child: Divider(color: AppColors.border)),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg),
                          child: Text(
                            'Or sign up with',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.textTertiary,
                              fontSize: AppTypography.fontSm,
                            ),
                          ),
                        ),
                        const Expanded(
                            child: Divider(color: AppColors.border)),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Social buttons
                    Row(
                      children: [
                        Expanded(
                          child: _SocialButton(
                            label: 'Google',
                            icon: Icons.g_mobiledata_rounded,
                            onPressed: () {
                              // TODO: Google sign-up
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _SocialButton(
                            label: 'Facebook',
                            icon: Icons.facebook_rounded,
                            onPressed: () {
                              // TODO: Facebook sign-up
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xxxl),

                    // Login link
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.textSecondary,
                              fontSize: AppTypography.fontSm,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.pop(),
                            child: Text(
                              'Login',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.primary,
                                fontSize: AppTypography.fontSm,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Reusable widgets for this screen ---

class _BackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _BackButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          color: AppColors.textPrimary,
          size: 20,
        ),
      ),
    );
  }
}

class _AuthInputField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _AuthInputField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
  });

  @override
  State<_AuthInputField> createState() => _AuthInputFieldState();
}

class _AuthInputFieldState extends State<_AuthInputField> {
  bool _isFocused = false;
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    final showError = _errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textSecondary,
            fontSize: AppTypography.fontSm,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: showError
                  ? AppColors.error
                  : _isFocused
                      ? AppColors.primary
                      : AppColors.border,
              width: (_isFocused || showError) ? 1.5 : 1,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: (showError
                              ? AppColors.error
                              : AppColors.primary)
                          .withValues(alpha: 0.10),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : AppShadows.sm,
          ),
          child: Focus(
            onFocusChange: (focused) =>
                setState(() => _isFocused = focused),
            child: TextFormField(
              controller: widget.controller,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textPrimary,
                fontSize: AppTypography.fontMd,
                letterSpacing: AppTypography.letterSpacingBody,
              ),
              validator: (value) {
                final result = widget.validator?.call(value);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) setState(() => _errorText = result);
                });
                return result;
              },
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: GoogleFonts.plusJakartaSans(
                  color: AppColors.textTertiary,
                  fontSize: AppTypography.fontMd,
                ),
                prefixIcon: widget.prefixIcon != null
                    ? Icon(widget.prefixIcon,
                        color: AppColors.textTertiary, size: 20)
                    : null,
                suffixIcon: widget.suffixIcon,
                border: InputBorder.none,
                errorStyle: const TextStyle(height: 0, fontSize: 0),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ),
        ),
        if (_errorText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            _errorText!,
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.error,
              fontSize: AppTypography.fontXs,
            ),
          ),
        ],
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 22),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: AppTypography.fontSm,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
