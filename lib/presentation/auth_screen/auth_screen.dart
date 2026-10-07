import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show Supabase, AuthException;

import '../../core/app_export.dart';

/// One screen for both Login and Sign up.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _hidePassword = true;
  String? _errorMessage;

  List<Map<String, dynamic>> _communities = [];
  String? _communityId;
  bool _communitiesFailed = false;

  @override
  void initState() {
    super.initState();
    _loadCommunities();
  }

  Future<void> _loadCommunities() async {
    try {
      final rows = await Supabase.instance.client
          .from('communities')
          .select('id, name, city')
          .order('name');
      if (!mounted) return;
      setState(() {
        _communities = List<Map<String, dynamic>>.from(rows);
        _communitiesFailed = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _communitiesFailed = true);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final auth = Supabase.instance.client.auth;
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      if (_isLogin) {
        await auth.signInWithPassword(email: email, password: password);
      } else {
        await auth.signUp(
          email: email,
          password: password,
          data: {
            'full_name': _nameController.text.trim(),
            'community_id': _communityId,
          },
        );
      }

      if (!mounted) return;

      // If sign up needs email confirmation, there is no session yet.
      if (auth.currentSession == null) {
        setState(() {
          _errorMessage = 'Please confirm your email, then log in.';
          _isLogin = true;
        });
        return;
      }

      context.go(AppRoutes.customerHomeScreen);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _errorMessage = 'Something went wrong. Check your internet.',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'MohallaConnect',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isLogin ? 'Welcome back' : 'Create your account',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 32),
                    if (!_isLogin) ...[
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Full name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().length < 2) {
                            return 'Enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _communityId,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Your community',
                          border: const OutlineInputBorder(),
                          helperText: _communitiesFailed
                              ? 'Could not load communities. Check internet.'
                              : null,
                        ),
                        items: _communities
                            .map(
                              (c) => DropdownMenuItem<String>(
                                value: c['id'] as String,
                                child: Text('${c['name']}, ${c['city']}'),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _communityId = value),
                        validator: (value) =>
                            value == null ? 'Select your community' : null,
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (!text.contains('@') || !text.contains('.')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _hidePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () =>
                              setState(() => _hidePassword = !_hidePassword),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppTheme.error),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(_isLogin ? 'Log in' : 'Sign up'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => setState(() {
                              _isLogin = !_isLogin;
                              _errorMessage = null;
                            }),
                      child: Text(
                        _isLogin
                            ? "Don't have an account? Sign up"
                            : 'Already have an account? Log in',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
