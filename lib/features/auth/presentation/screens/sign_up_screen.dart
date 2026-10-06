import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/router/app_router.dart';
import '../auth_notifier.dart';

@RoutePage()
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  String? _usernameError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_onUsernameChanged);
    _passwordController.addListener(_onPasswordChanged);
    _confirmPasswordController.addListener(_onConfirmPasswordChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(authNotifierProvider.notifier).clearError();
        setState(() {
          _usernameError = null;
          _passwordError = null;
          _confirmPasswordError = null;
        });
      }
    });
  }

  void _onUsernameChanged() {
    if (_usernameError != null) {
      setState(() => _usernameError = null);
    }
    if (ref.read(authNotifierProvider).errorMessage != null) {
      ref.read(authNotifierProvider.notifier).clearError();
    }
  }

  void _onPasswordChanged() {
    if (_passwordError != null || _confirmPasswordError != null) {
      setState(() {
        _passwordError = null;
        _confirmPasswordError = null;
      });
    }
    if (ref.read(authNotifierProvider).errorMessage != null) {
      ref.read(authNotifierProvider.notifier).clearError();
    }
  }

  void _onConfirmPasswordChanged() {
    if (_confirmPasswordError != null) {
      setState(() => _confirmPasswordError = null);
    }
    if (ref.read(authNotifierProvider).errorMessage != null) {
      ref.read(authNotifierProvider.notifier).clearError();
    }
  }

  @override
  void dispose() {
    _usernameController.removeListener(_onUsernameChanged);
    _passwordController.removeListener(_onPasswordChanged);
    _confirmPasswordController.removeListener(_onConfirmPasswordChanged);
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text;

    String? usernameError;
    String? passwordError;
    String? confirmPasswordError;

    if (username.isEmpty) {
      usernameError = 'Username is required';
    } else if (username.length < 3 || username.length > 32) {
      usernameError = 'Username must be between 3 and 32 characters';
    } else {
      final regex = RegExp(r'^[a-zA-Z0-9_.-]+$');
      if (!regex.hasMatch(username)) {
        usernameError = 'Use letters, numbers, _, ., - only';
      }
    }

    if (password.isEmpty) {
      passwordError = 'Password is required';
    } else if (password.length < 6) {
      passwordError = 'Password must be at least 6 characters';
    }

    if (confirmPassword != password) {
      confirmPasswordError = 'Passwords do not match';
    }

    setState(() {
      _usernameError = usernameError;
      _passwordError = passwordError;
      _confirmPasswordError = confirmPasswordError;
    });

    return usernameError == null && passwordError == null && confirmPasswordError == null;
  }

  Future<void> _handleSignUp() async {
    FocusScope.of(context).unfocus();
    if (!_validateForm()) return;

    final success = await ref.read(authNotifierProvider.notifier).register(
          _usernameController.text.trim(),
          _passwordController.text.trim(),
        );

    if (success && mounted) {
      context.router.replace(const DashboardRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: PopScope(
        onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          ref.read(authNotifierProvider.notifier).clearError();
          setState(() {
            _usernameError = null;
            _passwordError = null;
            _confirmPasswordError = null;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Account'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              ref.read(authNotifierProvider.notifier).clearError();
              setState(() {
                _usernameError = null;
                _passwordError = null;
                _confirmPasswordError = null;
              });
              context.router.pop();
            },
          ),
        ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Register New POS User',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Create an account to transfer product catalogs & data',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    // Username
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        hintText: 'Letters, numbers, _ . -',
                        prefixIcon: const Icon(Icons.person_outline),
                        errorText: _usernameError,
                      ),
                      onChanged: (_) => _onUsernameChanged(),
                    ),
                    const SizedBox(height: 16),
                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Choose a secure password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        errorText: _passwordError,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                      ),
                      onChanged: (_) => _onPasswordChanged(),
                    ),
                    const SizedBox(height: 16),
                    // Confirm Password
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        hintText: 'Repeat password',
                        prefixIcon: const Icon(Icons.lock_clock_outlined),
                        errorText: _confirmPasswordError,
                      ),
                      onChanged: (_) => _onConfirmPasswordChanged(),
                    ),
                    if (authState.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          authState.errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    // Sign Up Button
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: authState.isLoading
                            ? null
                            : () {
                                FocusScope.of(context).unfocus();
                                _handleSignUp();
                              },
                        child: authState.isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Create Account', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        TextButton(
                          onPressed: () {
                            ref.read(authNotifierProvider.notifier).clearError();
                            setState(() {
                              _usernameError = null;
                              _passwordError = null;
                              _confirmPasswordError = null;
                            });
                            context.router.pop();
                          },
                          child: const Text('Sign In'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      ),
      ),
    );
  }
}
