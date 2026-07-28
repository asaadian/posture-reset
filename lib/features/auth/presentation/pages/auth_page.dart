// lib/features/auth/presentation/pages/auth_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/app_text.dart';
import '../../application/auth_providers.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({
    super.key,
    this.initialMode = AuthMode.signIn,
    this.redirectTo,
  });

  final AuthMode initialMode;
  final String? redirectTo;

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

enum AuthMode {
  signIn,
  signUp,
}

class _AuthPageState extends ConsumerState<AuthPage> {
  static final Uri _privacyPolicyUri = Uri.parse(
    'https://weglabs.com/privacy-policy/',
  );
  static final Uri _termsOfUseUri = Uri.parse(
    'https://weglabs.com/terms-of-use/',
  );

  late AuthMode _mode;
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  bool _isSubmitting = false;
  bool _isGoogleSubmitting = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;
  bool _authRedirectHandled = false;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final t = AppText.of(context);
    final auth = ref.read(authServiceProvider);
    final isSignIn = _mode == AuthMode.signIn;

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (!isSignIn && !_acceptedTerms) {
      _showSnack(
        t.get(
          'auth_terms_required',
          fallback: 'Please accept the Terms and Privacy Policy first.',
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (isSignIn) {
        await auth.signIn(email: email, password: password);

        if (!mounted) return;
        _showSnack(
          t.get(
            'auth_sign_in_success',
            fallback: 'Signed in successfully.',
          ),
        );
        _goAfterAuth();
      } else {
        final response = await auth.signUp(email: email, password: password);

        if (!mounted) return;

        if (response.session != null) {
          _showSnack(
            t.get(
              'auth_sign_up_success_signed_in',
              fallback: 'Account created and signed in.',
            ),
          );
          _goAfterAuth();
        } else {
          _showSnack(
            t.get(
              'auth_sign_up_check_email',
              fallback:
                  'Account created. Please confirm your email before signing in.',
            ),
          );
          setState(() {
            _mode = AuthMode.signIn;
            _passwordController.clear();
            _confirmPasswordController.clear();
          });
        }
      }
    } on AuthException catch (error) {
      if (!mounted) return;
      _showSnack(_friendlyAuthError(error, t));
    } catch (_) {
      if (!mounted) return;
      _showSnack(
        t.get(
          'auth_unknown_error',
          fallback: 'Something went wrong. Please try again.',
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    final t = AppText.of(context);
    final auth = ref.read(authServiceProvider);
    final isSignUp = _mode == AuthMode.signUp;

    if (_isSubmitting || _isGoogleSubmitting) return;

    if (isSignUp && !_acceptedTerms) {
      _showSnack(
        t.get(
          'auth_terms_required',
          fallback: 'Please accept the Terms and Privacy Policy first.',
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isGoogleSubmitting = true);

    try {
      final launched = await auth.signInWithGoogle();

      if (!mounted) return;

      if (!launched) {
        _showSnack(
          t.get(
            'auth_google_not_started',
            fallback: 'Google sign-in could not be started.',
          ),
        );
      }
    } on AuthException catch (error) {
      if (!mounted) return;
      _showSnack(_friendlyAuthError(error, t));
    } catch (_) {
      if (!mounted) return;
      _showSnack(
        t.get(
          'auth_google_unknown_error',
          fallback: 'Google sign-in failed. Please try again.',
        ),
      );
    } finally {
      if (mounted) setState(() => _isGoogleSubmitting = false);
    }
  }

  void _showApplePlaceholder() {
    final t = AppText.of(context);
    HapticFeedback.selectionClick();
    _showSnack(
      t.get(
        'auth_apple_coming_soon',
        fallback: 'Apple sign-in will be added soon.',
      ),
    );
  }

  Future<void> _sendPasswordResetEmail() async {
    final t = AppText.of(context);
    final auth = ref.read(authServiceProvider);
    final email = _emailController.text.trim();

    FocusScope.of(context).unfocus();

    if (!_looksLikeEmail(email)) {
      _showSnack(
        t.get(
          'auth_reset_email_required',
          fallback: 'Enter your email address first.',
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await auth.resetPasswordForEmail(email: email);

      if (!mounted) return;
      _showSnack(
        t.get(
          'auth_reset_email_sent',
          fallback: 'Password reset email sent. Check your inbox.',
        ),
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      _showSnack(_friendlyAuthError(error, t));
    } catch (_) {
      if (!mounted) return;
      _showSnack(
        t.get(
          'auth_unknown_error',
          fallback: 'Something went wrong. Please try again.',
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _switchMode(AuthMode mode) {
    if (_isSubmitting || _isGoogleSubmitting) return;
    HapticFeedback.selectionClick();
    setState(() {
      _mode = mode;
      _confirmPasswordController.clear();
      if (mode == AuthMode.signIn) _acceptedTerms = false;
    });
  }

  Future<void> _openExternalUrl(Uri uri) async {
    final t = AppText.of(context);
    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && mounted) {
      _showSnack(
        t.get(
          'auth_link_open_failed',
          fallback: 'Could not open the link.',
        ),
      );
    }
  }

  void _goAfterAuth() {
    if (_authRedirectHandled || !mounted) return;

    _authRedirectHandled = true;

    final redirect = widget.redirectTo;
    if (redirect != null && redirect.trim().isNotEmpty) {
      context.go(redirect);
    } else {
      context.go('/app/dashboard');
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _friendlyAuthError(AuthException error, dynamic t) {
    final message = error.message.toLowerCase();

    if (message.contains('invalid login credentials')) {
      return t.get(
        'auth_invalid_credentials',
        fallback: 'Email or password is incorrect.',
      );
    }

    if (message.contains('email not confirmed')) {
      return t.get(
        'auth_email_not_confirmed',
        fallback: 'Please confirm your email before signing in.',
      );
    }

    if (message.contains('user already registered') ||
        message.contains('already registered')) {
      return t.get(
        'auth_user_already_registered',
        fallback: 'An account already exists for this email.',
      );
    }

    return error.message;
  }

  bool _looksLikeEmail(String value) {
    final email = value.trim();
    return email.contains('@') && email.contains('.') && email.length >= 6;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final isSignIn = _mode == AuthMode.signIn;

    ref.listen<AsyncValue<AuthState>>(authStateChangesProvider, (
      previous,
      next,
    ) {
      next.whenData((state) {
        if (state.session != null) _goAfterAuth();
      });
    });

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight;
          final width = constraints.maxWidth;
          final veryTight = height < 650;
          final compact = width < 430;
          final maxWidth = width >= 700 ? 460.0 : 430.0;
          final horizontalPadding = compact ? 18.0 : 24.0;

          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: _PremiumAuthBackdrop(
              child: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        veryTight ? 10 : 22,
                        horizontalPadding,
                        veryTight ? 14 : 26,
                      ),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      children: [
                        _PremiumBrandHeader(
                          isSignIn: isSignIn,
                          veryTight: veryTight,
                        ),
                        SizedBox(height: veryTight ? 16 : 22),
                        _PremiumAuthCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _AuthModeSwitch(
                                selected: _mode,
                                onChanged: _switchMode,
                              ),
                              SizedBox(height: veryTight ? 14 : 16),
                              _SocialAuthRow(
                                isGoogleLoading: _isGoogleSubmitting,
                                isDisabled:
                                    _isSubmitting || _isGoogleSubmitting,
                                onGooglePressed: _signInWithGoogle,
                                onApplePressed: _showApplePlaceholder,
                              ),
                              SizedBox(height: veryTight ? 12 : 14),
                              _DividerLabel(
                                label: t.get(
                                  'auth_or_email_short',
                                  fallback: 'or continue with email',
                                ),
                              ),
                              SizedBox(height: veryTight ? 12 : 14),
                              _EmailAuthPanel(
                                formKey: _formKey,
                                isSignIn: isSignIn,
                                isSubmitting: _isSubmitting,
                                isGoogleSubmitting: _isGoogleSubmitting,
                                emailController: _emailController,
                                passwordController: _passwordController,
                                confirmPasswordController:
                                    _confirmPasswordController,
                                obscurePassword: _obscurePassword,
                                obscureConfirmPassword:
                                    _obscureConfirmPassword,
                                onSubmit: _submit,
                                onForgotPassword: _sendPasswordResetEmail,
                                onTogglePassword: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                onToggleConfirmPassword: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                                looksLikeEmail: _looksLikeEmail,
                                acceptedTerms: _acceptedTerms,
                                onAcceptedChanged: (value) {
                                  HapticFeedback.selectionClick();
                                  setState(() => _acceptedTerms = value);
                                },
                                veryTight: veryTight,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: veryTight ? 12 : 16),
                        _CompactLegalFooter(
                          isSignIn: isSignIn,
                          veryTight: veryTight,
                          onPrivacyPressed: () =>
                              _openExternalUrl(_privacyPolicyUri),
                          onTermsPressed: () =>
                              _openExternalUrl(_termsOfUseUri),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


class _PremiumAuthBackdrop extends StatelessWidget {
  const _PremiumAuthBackdrop({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [
                  Color(0xFF061018),
                  Color(0xFF081720),
                  Color(0xFF05080D),
                ]
              : const [
                  Color(0xFFF8FCFF),
                  Color(0xFFEFF8F8),
                  Color(0xFFF7FAFC),
                ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -90,
            left: -70,
            right: -70,
            child: IgnorePointer(
              child: Container(
                height: 260,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      colors.primary.withValues(alpha: isDark ? 0.20 : 0.10),
                      colors.tertiary.withValues(alpha: isDark ? 0.14 : 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 20,
            child: IgnorePointer(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      colors.primary.withValues(alpha: isDark ? 0.24 : 0.14),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _PremiumBrandHeader extends StatelessWidget {
  const _PremiumBrandHeader({
    required this.isSignIn,
    required this.veryTight,
  });

  final bool isSignIn;
  final bool veryTight;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _AppIconBadge(),
        SizedBox(height: veryTight ? 12 : 16),
        Text(
          t.get('auth_app_badge', fallback: 'Desk Workout'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
          ),
        ),
        SizedBox(height: veryTight ? 8 : 10),
        Text(
          isSignIn
              ? t.get('auth_sign_in_title', fallback: 'Welcome back')
              : t.get('auth_sign_up_title', fallback: 'Create your account'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.1,
          ),
        ),
      ],
    );
  }
}

class _AppIconBadge extends StatelessWidget {
  const _AppIconBadge();

  double veryLargeLogoSize(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return height < 650 ? 96 : 122;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: veryLargeLogoSize(context),
      height: veryLargeLogoSize(context),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        color: isDark ? const Color(0xFF101A22) : Colors.white,
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: isDark ? 0.32 : 0.55),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.28)
                : const Color(0xFF0F172A).withValues(alpha: 0.10),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Image.asset(
          'assets/branding/desk_workout_icon.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [colors.primary, colors.tertiary],
                ),
              ),
              child: Icon(
                Icons.self_improvement_rounded,
                color: colors.onPrimary,
                size: 42,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PremiumAuthCard extends StatelessWidget {
  const _PremiumAuthCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: isDark ? const Color(0xFF0D161D) : Colors.white,
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2EEF0),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.36)
                : const Color(0xFF0F172A).withValues(alpha: 0.10),
            blurRadius: 36,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _AuthModeSwitch extends StatelessWidget {
  const _AuthModeSwitch({
    required this.selected,
    required this.onChanged,
  });

  final AuthMode selected;
  final ValueChanged<AuthMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isDark ? const Color(0xFF0A1117) : const Color(0xFFF1F5F9),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: isDark ? 0.22 : 0.45),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeSegment(
              selected: selected == AuthMode.signIn,
              label: t.get('auth_sign_in_tab', fallback: 'Sign in'),
              onTap: () => onChanged(AuthMode.signIn),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: _ModeSegment(
              selected: selected == AuthMode.signUp,
              label: t.get('auth_sign_up_tab_short', fallback: 'Create'),
              onTap: () => onChanged(AuthMode.signUp),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeSegment extends StatelessWidget {
  const _ModeSegment({
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: selected
                ? isDark
                    ? colors.primary.withValues(alpha: 0.18)
                    : Colors.white
                : Colors.transparent,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.24)
                          : const Color(0xFF0F172A).withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge?.copyWith(
              color: selected ? colors.primary : colors.onSurfaceVariant,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialAuthRow extends StatelessWidget {
  const _SocialAuthRow({
    required this.isGoogleLoading,
    required this.isDisabled,
    required this.onGooglePressed,
    required this.onApplePressed,
  });

  final bool isGoogleLoading;
  final bool isDisabled;
  final VoidCallback onGooglePressed;
  final VoidCallback onApplePressed;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);

    return Row(
      children: [
        Expanded(
          child: _SocialAuthButton(
            label: t.get('auth_google_short', fallback: 'Google'),
            icon: isGoogleLoading ? null : const _GoogleMark(),
            isLoading: isGoogleLoading,
            variant: _SocialButtonVariant.google,
            onPressed: isDisabled ? null : onGooglePressed,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SocialAuthButton(
            label: t.get('auth_apple_short', fallback: 'Apple'),
            icon: const Icon(Icons.apple_rounded, size: 22),
            isLoading: false,
            variant: _SocialButtonVariant.apple,
            onPressed: isDisabled ? null : onApplePressed,
          ),
        ),
      ],
    );
  }
}

enum _SocialButtonVariant {
  google,
  apple,
}

class _SocialAuthButton extends StatelessWidget {
  const _SocialAuthButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.variant,
    required this.onPressed,
  });

  final String label;
  final Widget? icon;
  final bool isLoading;
  final _SocialButtonVariant variant;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final isApple = variant == _SocialButtonVariant.apple;
    final backgroundColor = isApple
        ? (isDark ? Colors.white : const Color(0xFF111827))
        : Colors.white;
    final foregroundColor = isApple
        ? (isDark ? const Color(0xFF111827) : Colors.white)
        : const Color(0xFF111827);
    final borderColor = isApple
        ? (isDark ? Colors.white : const Color(0xFF111827))
        : const Color(0xFFE2E8F0);

    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          side: BorderSide(color: borderColor),
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: isLoading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    IconTheme(
                      data: IconThemeData(color: foregroundColor),
                      child: DefaultTextStyle.merge(
                        style: TextStyle(color: foregroundColor),
                        child: icon!,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: foregroundColor,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFF1F5F9),
      ),
      alignment: Alignment.center,
      child: Text(
        'G',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w900,
          height: 1,
          color: const Color(0xFF111827),
        ),
      ),
    );
  }
}

class _EmailAuthPanel extends StatelessWidget {
  const _EmailAuthPanel({
    required this.formKey,
    required this.isSignIn,
    required this.isSubmitting,
    required this.isGoogleSubmitting,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.onSubmit,
    required this.onForgotPassword,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    required this.looksLikeEmail,
    required this.acceptedTerms,
    required this.onAcceptedChanged,
    required this.veryTight,
  });

  final GlobalKey<FormState> formKey;
  final bool isSignIn;
  final bool isSubmitting;
  final bool isGoogleSubmitting;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final VoidCallback onSubmit;
  final VoidCallback onForgotPassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final bool Function(String value) looksLikeEmail;
  final bool acceptedTerms;
  final ValueChanged<bool> onAcceptedChanged;
  final bool veryTight;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);

    return Form(
      key: formKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AuthTextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              labelText: t.get('auth_email_label', fallback: 'Email'),
              prefixIcon: Icons.alternate_email_rounded,
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty) {
                  return t.get('auth_email_required', fallback: 'Email is required.');
                }
                if (!looksLikeEmail(email)) {
                  return t.get('auth_email_invalid', fallback: 'Enter a valid email address.');
                }
                return null;
              },
            ),
            SizedBox(height: veryTight ? 9 : 10),
            _AuthTextField(
              controller: passwordController,
              obscureText: obscurePassword,
              textInputAction: isSignIn ? TextInputAction.done : TextInputAction.next,
              autofillHints: isSignIn
                  ? const [AutofillHints.password]
                  : const [AutofillHints.newPassword],
              onFieldSubmitted: (_) {
                if (isSignIn) onSubmit();
              },
              labelText: t.get('auth_password_label', fallback: 'Password'),
              prefixIcon: Icons.lock_outline_rounded,
              suffixIcon: IconButton(
                tooltip: t.get(
                  'auth_toggle_password_visibility',
                  fallback: 'Toggle password visibility',
                ),
                onPressed: onTogglePassword,
                icon: Icon(
                  obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  size: 20,
                ),
              ),
              validator: (value) {
                final password = value ?? '';
                if (password.isEmpty) {
                  return t.get('auth_password_required', fallback: 'Password is required.');
                }
                if (!isSignIn && password.length < 8) {
                  return t.get(
                    'auth_password_too_short',
                    fallback: 'Password must be at least 8 characters.',
                  );
                }
                return null;
              },
            ),
            if (!isSignIn) ...[
              SizedBox(height: veryTight ? 9 : 10),
              _AuthTextField(
                controller: confirmPasswordController,
                obscureText: obscureConfirmPassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                onFieldSubmitted: (_) => onSubmit(),
                labelText: t.get('auth_confirm_password_label', fallback: 'Confirm password'),
                prefixIcon: Icons.lock_reset_rounded,
                suffixIcon: IconButton(
                  tooltip: t.get(
                    'auth_toggle_password_visibility',
                    fallback: 'Toggle password visibility',
                  ),
                  onPressed: onToggleConfirmPassword,
                  icon: Icon(
                    obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                  ),
                ),
                validator: (value) {
                  if ((value ?? '').isEmpty) {
                    return t.get(
                      'auth_confirm_password_required',
                      fallback: 'Please confirm your password.',
                    );
                  }
                  if (value != passwordController.text) {
                    return t.get(
                      'auth_confirm_password_mismatch',
                      fallback: 'Passwords do not match.',
                    );
                  }
                  return null;
                },
              ),
              SizedBox(height: veryTight ? 6 : 8),
              _TermsInlineRow(
                accepted: acceptedTerms,
                onChanged: onAcceptedChanged,
              ),
            ],
            SizedBox(height: veryTight ? 12 : 14),
            _PrimaryAuthButton(
              isSignIn: isSignIn,
              isLoading: isSubmitting,
              disabled: isSubmitting || isGoogleSubmitting,
              onPressed: onSubmit,
            ),
            if (isSignIn) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: isSubmitting || isGoogleSubmitting ? null : onForgotPassword,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    t.get('auth_forgot_password', fallback: 'Forgot password?'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PrimaryAuthButton extends StatelessWidget {
  const _PrimaryAuthButton({
    required this.isSignIn,
    required this.isLoading,
    required this.disabled,
    required this.onPressed,
  });

  final bool isSignIn;
  final bool isLoading;
  final bool disabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: disabled
              ? null
              : [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.24),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
        ),
        child: FilledButton(
          onPressed: disabled ? null : onPressed,
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 0.1,
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 19,
                  height: 19,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isSignIn
                          ? t.get('auth_sign_in_button', fallback: 'Sign in')
                          : t.get('auth_sign_up_button', fallback: 'Create account'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 19),
                  ],
                ),
        ),
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.obscureText = false,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      obscureText: obscureText,
      onFieldSubmitted: onFieldSubmitted,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: colors.onSurface,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: isDark ? const Color(0xFF0A1117) : const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        labelText: labelText,
        labelStyle: TextStyle(
          color: colors.onSurfaceVariant.withValues(alpha: 0.78),
          fontWeight: FontWeight.w700,
        ),
        prefixIcon: Icon(prefixIcon, size: 20),
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE2E8F0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide(color: colors.primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide(color: colors.error.withValues(alpha: 0.78)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide(color: colors.error, width: 1.4),
        ),
      ),
      validator: validator,
    );
  }
}

class _TermsInlineRow extends StatelessWidget {
  const _TermsInlineRow({
    required this.accepted,
    required this.onChanged,
  });

  final bool accepted;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => onChanged(!accepted),
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 6, 10, 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark ? const Color(0xFF0A1117) : const Color(0xFFF8FAFC),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: isDark ? 0.22 : 0.45),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 34,
              height: 34,
              child: Checkbox(
                value: accepted,
                visualDensity: VisualDensity.compact,
                onChanged: (value) => onChanged(value ?? false),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                t.get(
                  'auth_accept_terms_text',
                  fallback: 'I accept the Terms of Use and Privacy Policy.',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  height: 1.20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DividerLabel extends StatelessWidget {
  const _DividerLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Divider(
            height: 1,
            color: colors.outlineVariant.withValues(alpha: 0.55),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            height: 1,
            color: colors.outlineVariant.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}

class _CompactLegalFooter extends StatelessWidget {
  const _CompactLegalFooter({
    required this.isSignIn,
    required this.veryTight,
    required this.onPrivacyPressed,
    required this.onTermsPressed,
  });

  final bool isSignIn;
  final bool veryTight;
  final VoidCallback onPrivacyPressed;
  final VoidCallback onTermsPressed;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      children: [
        if (!veryTight) ...[
          Text(
            isSignIn
                ? t.get(
                    'auth_legal_note_sign_in_compact',
                    fallback: 'By continuing, you agree to our legal terms.',
                  )
                : t.get(
                    'auth_legal_note_sign_up_compact',
                    fallback: 'Review our legal terms before creating your account.',
                  ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              height: 1.12,
            ),
          ),
          const SizedBox(height: 7),
        ],
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 5,
          children: [
            _LegalLinkButton(
              label: t.get('auth_privacy_policy_link', fallback: 'Privacy Policy'),
              onTap: onPrivacyPressed,
            ),
            _LegalLinkButton(
              label: t.get('auth_terms_of_use_link', fallback: 'Terms of Use'),
              onTap: onTermsPressed,
            ),
          ],
        ),
      ],
    );
  }
}

class _LegalLinkButton extends StatelessWidget {
  const _LegalLinkButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
