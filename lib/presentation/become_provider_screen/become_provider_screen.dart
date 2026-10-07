import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import '../../theme/app_theme.dart';

/// Lets a logged-in user register as a service provider.
/// New providers start as "unverified" until an admin approves them.
class BecomeProviderScreen extends StatefulWidget {
  const BecomeProviderScreen({super.key});

  @override
  State<BecomeProviderScreen> createState() => _BecomeProviderScreenState();
}

class _BecomeProviderScreenState extends State<BecomeProviderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _experienceController = TextEditingController();

  List<Map<String, dynamic>> _professions = [];
  String? _professionId;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _loadError;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfessions();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _loadProfessions() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final rows = await Supabase.instance.client
          .from('professions')
          .select('id, name')
          .order('name');
      if (!mounted) return;
      setState(() {
        _professions = List<Map<String, dynamic>>.from(rows);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Could not load professions. Check your internet.';
        _isLoading = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser!.id;

      final profile = await client
          .from('profiles')
          .select('full_name, community_id')
          .eq('id', userId)
          .single();

      if (profile['community_id'] == null) {
        setState(() {
          _errorMessage = 'Your account has no community. Contact support.';
          _isSaving = false;
        });
        return;
      }

      await client.from('providers').insert({
        'user_id': userId,
        'profession_id': _professionId,
        'community_id': profile['community_id'],
        'full_name': profile['full_name'],
        'description': _descriptionController.text.trim(),
        'experience_years': int.parse(_experienceController.text.trim()),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registered! An admin will verify your profile.'),
        ),
      );
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      final alreadyRegistered = e.toString().contains('duplicate key');
      setState(() {
        _errorMessage = alreadyRegistered
            ? 'You are already registered as a provider.'
            : 'Could not register. Check your details and internet.';
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Become a Provider',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _loadError != null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_loadError!),
                    TextButton(
                      onPressed: _loadProfessions,
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Tell customers what you do. Your profile will show '
                        'as "unverified" until an admin checks it.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: const Color(0xFF5C5C5C),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        initialValue: _professionId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Your profession',
                          border: OutlineInputBorder(),
                        ),
                        items: _professions
                            .map(
                              (p) => DropdownMenuItem<String>(
                                value: p['id'] as String,
                                child: Text(p['name'] as String),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _professionId = value),
                        validator: (value) =>
                            value == null ? 'Select your profession' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _experienceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Years of experience',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          final years = int.tryParse(value?.trim() ?? '');
                          if (years == null || years < 0 || years > 60) {
                            return 'Enter a number from 0 to 60';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        maxLength: 300,
                        decoration: const InputDecoration(
                          labelText: 'About your work',
                          hintText: 'e.g. Pipe leakage, tap and tank repair',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().length < 10) {
                            return 'Write at least 10 characters';
                          }
                          return null;
                        },
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppTheme.error),
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Register as provider'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
