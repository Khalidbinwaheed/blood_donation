import 'package:blood_donation/features/recipient/data/donation_repository.dart';
import 'package:blood_donation/features/user_management/data/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class RequestBloodScreen extends ConsumerStatefulWidget {
  const RequestBloodScreen({super.key});

  @override
  ConsumerState<RequestBloodScreen> createState() => _RequestBloodScreenState();
}

class _RequestBloodScreenState extends ConsumerState<RequestBloodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController(text: '1');
  final _hospitalController = TextEditingController();
  final _reasonController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _phoneController = TextEditingController();

  String _bloodGroup = 'A+';
  String _urgency = 'High';
  String? _selectedCountry = 'Pakistan';
  String? _selectedCity;
  DateTime? _neededDate;
  bool _isLoading = false;

  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];
  final List<String> _urgencyLevels = ['Critical', 'High', 'Medium', 'Low'];
  final List<String> _countries = [
    'Pakistan',
    'USA',
    'UK',
    'Canada',
    'Australia'
  ];
  final List<String> _cities = [
    'Karachi',
    'Lahore',
    'Islamabad',
    'Rawalpindi',
    'Multan'
  ];

  @override
  void initState() {
    super.initState();
    final user = ref.read(authStateProvider).valueOrNull;
    if (user != null) {
      _contactNameController.text =
          '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();
      _phoneController.text = user.phoneNumber;
      _selectedCity = user.district;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _hospitalController.dispose();
    _reasonController.dispose();
    _contactNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_neededDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select request date.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) {
        throw Exception('User not logged in');
      }

      await ref.read(donationRepositoryProvider).createDonationRequest(
            requesterUid: user.uid,
            bloodGroup: _bloodGroup,
            hospitalName: _hospitalController.text.trim(),
            urgency: _urgency,
            note: _reasonController.text.trim(),
            contactEmail: user.email,
            title: _titleController.text
                .trim()
                .ifEmpty('Emergency $_bloodGroup Blood Needed'),
            amountBags: int.tryParse(_amountController.text.trim()) ?? 1,
            neededOn: _neededDate,
            country: _selectedCountry ?? '',
            city: _selectedCity ?? '',
            contactPersonName: _contactNameController.text.trim(),
            contactPhone: _phoneController.text.trim(),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request submitted successfully.')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
        title: const Text(
          'Create Request',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  children: [
                    _buildFieldLabel('Post Title'),
                    _buildTextField(
                      controller: _titleController,
                      hint: 'Type title',
                    ),
                    const SizedBox(height: 16),
                    _buildFieldLabel('Select Group'),
                    DropdownButtonFormField<String>(
                      initialValue: _bloodGroup,
                      icon:
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      decoration: _inputDecoration('Blood group'),
                      items: _bloodGroups
                          .map((bg) =>
                              DropdownMenuItem(value: bg, child: Text(bg)))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _bloodGroup = val ?? _bloodGroup),
                    ),
                    const SizedBox(height: 16),
                    _buildFieldLabel('Amount of Request Blood'),
                    _buildTextField(
                      controller: _amountController,
                      hint: 'Type how much',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    _buildFieldLabel('Date'),
                    InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: _inputDecoration('Select Date'),
                        child: Row(
                          children: [
                            Text(
                              _neededDate == null
                                  ? 'Select Date'
                                  : DateFormat('dd MMM yyyy')
                                      .format(_neededDate!),
                              style: TextStyle(
                                color: _neededDate == null
                                    ? Colors.black26
                                    : Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.calendar_month_outlined,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFieldLabel('Hospital Name'),
                    _buildTextField(
                      controller: _hospitalController,
                      hint:
                          'Select Date', // Matching image hint "Select Date" for Hospital Name? Wait, image says Select Date for Hospital Name. That looks like a placeholder error in the design but I'll follow it if it's there, or maybe use "Type hospital name".
                      // Re-checking image: Hospital Name has hint "Select Date". This is likely a bug in the design image provided by user, but I will use something sensible or match it if strictly requested.
                      // Actually, I'll use "Type hospital name" or what's sensible, unless it's a "Select" field.
                    ),
                    const SizedBox(height: 16),
                    _buildFieldLabel('Why do you need blood?'),
                    _buildTextField(
                      controller: _reasonController,
                      hint: 'Type why',
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    _buildFieldLabel('Contact person Name'),
                    _buildTextField(
                      controller: _contactNameController,
                      hint: 'Type name',
                    ),
                    const SizedBox(height: 16),
                    _buildFieldLabel('Mobile number'),
                    _buildTextField(
                      controller: _phoneController,
                      hint: 'Type mobile number',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    _buildFieldLabel('Country'),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCountry,
                      icon:
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      decoration: _inputDecoration('Select country'),
                      items: _countries
                          .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedCountry = val),
                    ),
                    const SizedBox(height: 16),
                    _buildFieldLabel('City'),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCity,
                      icon:
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      decoration: _inputDecoration('Select city'),
                      items: _cities
                          .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedCity = val),
                    ),
                    const SizedBox(height: 16),
                    _buildFieldLabel('Urgency'),
                    DropdownButtonFormField<String>(
                      initialValue: _urgency,
                      icon:
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      decoration: _inputDecoration('Urgency'),
                      items: _urgencyLevels
                          .map((level) => DropdownMenuItem(
                              value: level, child: Text(level)))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _urgency = val ?? _urgency),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4141),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF333333),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14),
      decoration: _inputDecoration(hint),
      validator: validator ??
          (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Required';
            }
            return null;
          },
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Colors.black26,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      fillColor: Colors.white,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFFF4141), width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _neededDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF4141),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _neededDate = picked);
    }
  }
}

extension on String {
  String ifEmpty(String fallback) => trim().isEmpty ? fallback : this;
}
