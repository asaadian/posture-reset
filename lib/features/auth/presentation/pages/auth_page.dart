// lib/features/auth/presentation/pages/auth_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/localization/app_text.dart';
import '../../../../shared/layout/responsive_page_scaffold.dart';
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
  late AuthMode _mode;
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  bool _isSubmitting = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (_mode == AuthMode.signIn) {
        await auth.signIn(email: email, password: password);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              t.get(
                'auth_sign_in_success',
                fallback: 'Signed in successfully.',
              ),
            ),
          ),
        );

        final redirect = widget.redirectTo;
        if (redirect != null && redirect.trim().isNotEmpty) {
          context.go(redirect);
        } else {
          context.go('/app/profile');
        }
      } else {
        final response = await auth.signUp(email: email, password: password);

        if (!mounted) return;

        if (response.session != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                t.get(
                  'auth_sign_up_success_signed_in',
                  fallback: 'Account created and signed in.',
                ),
              ),
            ),
          );

          final redirect = widget.redirectTo;
          if (redirect != null && redirect.trim().isNotEmpty) {
            context.go(redirect);
          } else {
            context.go('/app/profile');
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                t.get(
                  'auth_sign_up_check_email',
                  fallback:
                      'Account created. Check your email to confirm your account.',
                ),
              ),
            ),
          );
          setState(() {
            _mode = AuthMode.signIn;
          });
        }
      }
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t.get(
              'auth_unknown_error',
              fallback: 'Something went wrong. Please try again.',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _switchMode(AuthMode mode) {
    if (_isSubmitting) return;
    setState(() {
      _mode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final isSignIn = _mode == AuthMode.signIn;

    return ResponsivePageScaffold(
      title: Text(
        t.get(
          'auth_page_title',
          fallback: 'Account',
        ),
      ),
      bodyBuilder: (context, pageInfo) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(
                top: pageInfo.isCompact ? 16 : 24,
                bottom: pageInfo.isCompact ? 24 : 32,
              ),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          isSignIn
                              ? t.get(
                                  'auth_sign_in_title',
                                  fallback: 'Sign in',
                                )
                              : t.get(
                                  'auth_sign_up_title',
                                  fallback: 'Create account',
                                ),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isSignIn
                              ? t.get(
                                  'auth_sign_in_subtitle',
                                  fallback:
                                      'Sign in to save sessions and keep your recovery data with your account.',
                                )
                              : t.get(
                                  'auth_sign_up_subtitle',
                                  fallback:
                                      'Create an account to save sessions and unlock continuity across devices.',
                                ),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 20),
                        SegmentedButton<AuthMode>(
                          segments: [
                            ButtonSegment<AuthMode>(
                              value: AuthMode.signIn,
                              label: Text(
                                t.get(
                                  'auth_sign_in_tab',
                                  fallback: 'Sign in',
                                ),
                              ),
                              icon: const Icon(Icons.login),
                            ),
                            ButtonSegment<AuthMode>(
                              value: AuthMode.signUp,
                              label: Text(
                                t.get(
                                  'auth_sign_up_tab',
                                  fallback: 'Create account',
                                ),
                              ),
                              icon: const Icon(Icons.person_add_alt_1),
                            ),
                          ],
                          selected: {_mode},
                          onSelectionChanged: (selection) {
                            _switchMode(selection.first);
                          },
                        ),
                        const SizedBox(height: 20),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                autofillHints: const [AutofillHints.email],
                                decoration: InputDecoration(
                                  labelText: t.get(
                                    'auth_email_label',
                                    fallback: 'Email',
                                  ),
                                  prefixIcon: const Icon(Icons.email_outlined),
                                ),
                                validator: (value) {
                                  final email = value?.trim() ?? '';
                                  if (email.isEmpty) {
                                    return t.get(
                                      'auth_email_required',
                                      fallback: 'Email is required.',
                                    );
                                  }
                                  if (!email.contains('@') || !email.contains('.')) {
                                    return t.get(
                                      'auth_email_invalid',
                                      fallback: 'Enter a valid email address.',
                                    );
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                autofillHints: isSignIn
                                    ? const [AutofillHints.password]
                                    : const [AutofillHints.newPassword],
                                decoration: InputDecoration(
                                  labelText: t.get(
                                    'auth_password_label',
                                    fallback: 'Password',
                                  ),
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  final password = value ?? '';
                                  if (password.isEmpty) {
                                    return t.get(
                                      'auth_password_required',
                                      fallback: 'Password is required.',
                                    );
                                  }
                                  if (!isSignIn && password.length < 8) {
                                    return t.get(
                                      'auth_password_too_short',
                                      fallback:
                                          'Password must be at least 8 characters.',
                                    );
                                  }
                                  return null;
                                },
                              ),
                              if (!isSignIn) ...[
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  autofillHints: const [
                                    AutofillHints.newPassword,
                                  ],
                                  decoration: InputDecoration(
                                    labelText: t.get(
                                      'auth_confirm_password_label',
                                      fallback: 'Confirm password',
                                    ),
                                    prefixIcon: const Icon(Icons.lock_reset_outlined),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _obscureConfirmPassword =
                                              !_obscureConfirmPassword;
                                        });
                                      },
                                      icon: Icon(
                                        _obscureConfirmPassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if ((value ?? '').isEmpty) {
                                      return t.get(
                                        'auth_confirm_password_required',
                                        fallback: 'Please confirm your password.',
                                      );
                                    }
                                    if (value != _passwordController.text) {
                                      return t.get(
                                        'auth_confirm_password_mismatch',
                                        fallback: 'Passwords do not match.',
                                      );
                                    }
                                    return null;
                                  },
                                ),
                              ],
                              const SizedBox(height: 20),
                              FilledButton.icon(
                                onPressed: _isSubmitting ? null : _submit,
                                icon: _isSubmitting
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Icon(
                                        isSignIn
                                            ? Icons.login
                                            : Icons.person_add_alt_1,
                                      ),
                                label: Text(
                                  _isSubmitting
                                      ? t.get(
                                          'auth_submitting',
                                          fallback: 'Please wait...',
                                        )
                                      : isSignIn
                                          ? t.get(
                                              'auth_sign_in_button',
                                              fallback: 'Sign in',
                                            )
                                          : t.get(
                                              'auth_sign_up_button',
                                              fallback: 'Create account',
                                            ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}