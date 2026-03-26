import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/tokens.dart';

class VerificationCodeScreen extends StatefulWidget {
  final String? email;

  const VerificationCodeScreen({super.key, this.email});

  @override
  State<VerificationCodeScreen> createState() =>
      _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  bool _isLoading = false;
  int _resendSeconds = 30;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    // Auto-focus first digit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = 30);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  bool get _isCodeComplete => _code.length == 4;

  void _onDigitChanged(int index, String value) {
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    setState(() {});
  }

  void _onKeyDown(int index, RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
      setState(() {});
    }
  }

  Future<void> _onVerify() async {
    if (!_isCodeComplete) return;

    setState(() => _isLoading = true);

    // Mock verification
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    setState(() => _isLoading = false);

    context.push('/reset-password');
  }

  void _onResend() {
    if (_resendSeconds > 0) return;
    _startResendTimer();
    // TODO: Trigger actual resend via API
  }

  @override
  Widget build(BuildContext context) {
    final maskedEmail = widget.email ?? 'your email';

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
                'Verification Code',
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
                'We sent a code to $maskedEmail',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: AppTypography.fontMd,
                  color: AppColors.textSecondary,
                  height: AppTypography.lineHeightNormal,
                ),
              ),

              const SizedBox(height: AppSpacing.xxxxl),

              // 4 digit boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final hasValue = _controllers[index].text.isNotEmpty;
                  final isFocused = _focusNodes[index].hasFocus;

                  return Container(
                    width: 64,
                    height: 72,
                    margin: EdgeInsets.only(
                      right: index < 3 ? AppSpacing.md : 0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: hasValue
                            ? AppColors.primary
                            : isFocused
                                ? AppColors.primary
                                : AppColors.border,
                        width: (hasValue || isFocused) ? 1.5 : 1,
                      ),
                      boxShadow: isFocused
                          ? [
                              BoxShadow(
                                color: AppColors.primary
                                    .withValues(alpha: 0.10),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ]
                          : AppShadows.sm,
                    ),
                    child: RawKeyboardListener(
                      focusNode: FocusNode(),
                      onKey: (event) => _onKeyDown(index, event),
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: AppTypography.font2xl,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                        ),
                        onChanged: (value) =>
                            _onDigitChanged(index, value),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Resend timer
              Center(
                child: _resendSeconds > 0
                    ? Text(
                        'Resend code in ${_resendSeconds}s',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textTertiary,
                          fontSize: AppTypography.fontSm,
                        ),
                      )
                    : GestureDetector(
                        onTap: _onResend,
                        child: Text(
                          'Resend Code',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.primary,
                            fontSize: AppTypography.fontSm,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // Verify button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed:
                      (_isCodeComplete && !_isLoading) ? _onVerify : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.4),
                    disabledForegroundColor:
                        AppColors.white.withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
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
                      : const Text('Verify'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
