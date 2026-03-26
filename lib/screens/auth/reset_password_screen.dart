import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/tokens.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _showSuccess = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool get _hasMinLength => _passwordController.text.length >= 8;
  bool get _hasUppercase =>
      _passwordController.text.contains(RegExp(r'[A-Z]'));
  bool get _hasNumber => _passwordController.text.contains(RegExp(r'[0-9]'));

  Future<void> _onReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Mock reset
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _showSuccess = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSuccess) {
      return _SuccessView(
        onBackToLogin: () => context.go('/login'),
      );
    }

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
              GestureDetector(
                onTap: () => context.pop(),
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
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Title
              Text(
                'New Password',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: AppTypography.font2xl,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  letterSpacing: AppTypography.letterSpacingTitle,
                  height: AppTypography.lineHeightTight,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Create a strong password for your account',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: AppTypography.fontMd,
                  color: AppColors.textSecondary,
                  height: AppTypography.lineHeightNormal,
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // New password
                    _PasswordField(
                      controller: _passwordController,
                      label: 'New Password',
                      hint: 'Enter new password',
                      obscureText: _obscurePassword,
                      onToggleObscure: () => setState(
                          () => _obscurePassword = !_obscurePassword),
                      onChanged: (_) => setState(() {}),
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

                    // Password requirements
                    _RequirementRow(
                      label: 'At least 8 characters',
                      isMet: _hasMinLength,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _RequirementRow(
                      label: 'Contains uppercase letter',
                      isMet: _hasUppercase,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _RequirementRow(
                      label: 'Contains a number',
                      isMet: _hasNumber,
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Confirm password
                    _PasswordField(
                      controller: _confirmController,
                      label: 'Confirm Password',
                      hint: 'Re-enter your password',
                      obscureText: _obscureConfirm,
                      onToggleObscure: () => setState(
                          () => _obscureConfirm = !_obscureConfirm),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // Reset button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _onReset,
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
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                            : const Text('Reset Password'),
                      ),
                    ),
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

class _PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscureText;
  final VoidCallback onToggleObscure;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.obscureText,
    required this.onToggleObscure,
    this.onChanged,
    this.validator,
  });

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
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
              color: _isFocused ? AppColors.primary : AppColors.border,
              width: _isFocused ? 1.5 : 1,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.10),
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
              onChanged: widget.onChanged,
              validator: widget.validator,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textPrimary,
                fontSize: AppTypography.fontMd,
                letterSpacing: AppTypography.letterSpacingBody,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: GoogleFonts.plusJakartaSans(
                  color: AppColors.textTertiary,
                  fontSize: AppTypography.fontMd,
                ),
                prefixIcon: const Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    widget.obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                  onPressed: widget.onToggleObscure,
                ),
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
      ],
    );
  }
}

class _RequirementRow extends StatelessWidget {
  final String label;
  final bool isMet;

  const _RequirementRow({required this.label, required this.isMet});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle_rounded : Icons.circle_outlined,
          size: 16,
          color: isMet ? AppColors.success : AppColors.textTertiary,
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: isMet ? AppColors.success : AppColors.textTertiary,
            fontSize: AppTypography.fontSm,
            fontWeight: isMet ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _SuccessView extends StatelessWidget {
  final VoidCallback onBackToLogin;

  const _SuccessView({required this.onBackToLogin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppLayout.screenPaddingH,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success checkmark
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.white,
                  size: 52,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                'Password Reset\nSuccessfully',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: AppTypography.font2xl,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: AppTypography.letterSpacingTitle,
                  height: AppTypography.lineHeightTight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Your password has been updated. You can now log in with your new password.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: AppTypography.fontMd,
                  color: AppColors.textSecondary,
                  height: AppTypography.lineHeightRelaxed,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: onBackToLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    elevation: 0,
                    textStyle: GoogleFonts.plusJakartaSans(
                      fontSize: AppTypography.fontMd,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Back to Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
