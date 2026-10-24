import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show PostgrestException, Supabase;

import '../../theme/app_theme.dart';
import '../../widgets/avatar_widget.dart';

/// Edit profile for everyone: the name. Providers also get their listing:
/// about text, experience, starting price, working days and hours.
class EditProviderScreen extends StatefulWidget {
  const EditProviderScreen({super.key});

  @override
  State<EditProviderScreen> createState() => _EditProviderScreenState();
}

class _EditProviderScreenState extends State<EditProviderScreen> {
  static const List<String> _allDays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _experienceController = TextEditingController();
  final _priceController = TextEditingController();

  final Set<String> _days = {};
  TimeOfDay? _from;
  TimeOfDay? _to;

  String? _providerId; // null when the user is not a provider
  bool _isLoading = true;
  bool _isSaving = false;
  String? _loadError;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _experienceController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  TimeOfDay? _parseTime(String? value) {
    if (value == null || value.isEmpty) return null;
    final parts = value.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  // Stored as 24-hour text, for example 09:00 or 19:30.
  String _storeTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser!.id;

      final profile = await client
          .from('profiles')
          .select('full_name')
          .eq('id', userId)
          .single();

      final row = await client
          .from('providers')
          .select(
            'id, description, experience_years, starting_price, '
            'work_days, work_from, work_to',
          )
          .eq('user_id', userId)
          .maybeSingle();

      if (!mounted) return;
      setState(() {
        _nameController.text = profile['full_name'] as String? ?? '';
        if (row != null) {
          _providerId = row['id'] as String;
          _descriptionController.text = row['description'] as String? ?? '';
          _experienceController.text = '${row['experience_years'] ?? 0}';
          _priceController.text = row['starting_price'] == null
              ? ''
              : '${row['starting_price']}';
          _days
            ..clear()
            ..addAll(((row['work_days'] as List?) ?? []).map((d) => '$d'));
          _from = _parseTime(row['work_from'] as String?);
          _to = _parseTime(row['work_to'] as String?);
        }
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Could not load your profile. Check your internet.';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickTime({required bool isFrom}) async {
    final initial =
        (isFrom ? _from : _to) ?? TimeOfDay(hour: isFrom ? 9 : 18, minute: 0);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null || !mounted) return;
    setState(() {
      if (isFrom) {
        _from = picked;
      } else {
        _to = picked;
      }
    });
  }

  String? _scheduleError() {
    if (_from == null && _to == null) return null;
    if (_from == null || _to == null) {
      return 'Choose both an opening and a closing time.';
    }
    final fromMinutes = _from!.hour * 60 + _from!.minute;
    final toMinutes = _to!.hour * 60 + _to!.minute;
    if (toMinutes <= fromMinutes) {
      return 'Closing time must be after opening time.';
    }
    return null;
  }

  Future<void> _save() async {
    final scheduleError = _providerId == null ? null : _scheduleError();
    final formOk = _formKey.currentState!.validate();
    if (scheduleError != null) {
      setState(() => _errorMessage = scheduleError);
      return;
    }
    if (!formOk) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser!.id;
      final name = _nameController.text.trim();

      await client
          .from('profiles')
          .update({'full_name': name})
          .eq('id', userId);

      final providerId = _providerId;
      if (providerId != null) {
        final priceText = _priceController.text.trim();
        final orderedDays = _allDays.where(_days.contains).toList();

        await client
            .from('providers')
            .update({
              'full_name': name,
              'description': _descriptionController.text.trim(),
              'experience_years': int.parse(_experienceController.text.trim()),
              'starting_price': priceText.isEmpty ? null : int.parse(priceText),
              'work_days': orderedDays,
              'work_from': _from == null ? null : _storeTime(_from!),
              'work_to': _to == null ? null : _storeTime(_to!),
            })
            .eq('id', providerId);
      }

      profileChangedNotifier.value++;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your profile was updated.')),
      );
      context.pop(true);
    } on PostgrestException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Could not save: ${e.message}';
        _isSaving = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Could not save. Check your internet and try again.';
        _isSaving = false;
      });
    }
  }

  /// Day chips with clear colors (the default style was almost invisible).
  Widget _dayChip(String day) {
    final selected = _days.contains(day);
    return FilterChip(
      label: Text(day),
      selected: selected,
      showCheckmark: false,
      backgroundColor: Colors.white,
      selectedColor: AppTheme.primary,
      side: BorderSide(
        color: selected ? AppTheme.primary : const Color(0xFFBDBDBD),
      ),
      labelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: selected ? Colors.white : const Color(0xFF1A1A1A),
      ),
      onSelected: (value) {
        setState(() {
          if (value) {
            _days.add(day);
          } else {
            _days.remove(day);
          }
        });
      },
    );
  }

  Widget _timeButton({
    required String label,
    required TimeOfDay? value,
    required bool isFrom,
  }) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: () => _pickTime(isFrom: isFrom),
        icon: const Icon(Icons.access_time, size: 18),
        label: Text(value == null ? label : value.format(context)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Edit profile',
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
                      onPressed: _load,
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
                      TextFormField(
                        controller: _nameController,
                        maxLength: 60,
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
                      if (_providerId != null) ..._providerFields(),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppTheme.error),
                        ),
                      ],
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _save,
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
                              : const Text('Save changes'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  /// The listing fields that only providers see.
  List<Widget> _providerFields() {
    return [
      const SizedBox(height: 12),
      TextFormField(
        controller: _descriptionController,
        maxLines: 4,
        maxLength: 300,
        decoration: const InputDecoration(
          labelText: 'About your work',
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
      const SizedBox(height: 12),
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
        controller: _priceController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Starting price in Rs. (optional)',
          helperText: 'The final price depends on the problem.',
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          final text = value?.trim() ?? '';
          if (text.isEmpty) return null;
          final price = int.tryParse(text);
          if (price == null || price < 0 || price > 1000000) {
            return 'Enter a number up to 1,000,000';
          }
          return null;
        },
      ),
      const SizedBox(height: 20),
      Text(
        'Working days',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 4,
        children: _allDays.map(_dayChip).toList(),
      ),
      const SizedBox(height: 16),
      Text(
        'Working hours',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          _timeButton(label: 'Opens', value: _from, isFrom: true),
          const SizedBox(width: 10),
          _timeButton(label: 'Closes', value: _to, isFrom: false),
        ],
      ),
      if (_from != null || _to != null)
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => setState(() {
              _from = null;
              _to = null;
            }),
            child: const Text('Clear hours'),
          ),
        ),
    ];
  }
}
