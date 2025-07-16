import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../services/api_service.dart'; // Adjust the import path based on your project structure

// Alert type enum
enum AlertType { success, error }

// Models
class Branch {
  final int id;
  final String name;
  final String address;
  final String? phone;
  final String? practiceDays;

  Branch({
    required this.id,
    required this.name,
    required this.address,
    this.phone,
    this.practiceDays,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      practiceDays: json['practice_days'],
    );
  }
}

class RegistrationRequest {
  final String name;
  final String email;
  final String phone;
  final int branchId;
  final String password;

  RegistrationRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.branchId,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'branch_id': branchId,
      'password': password,
    };
  }
}

class PasswordRequirement {
  final String text;
  final bool Function(String) validator;
  bool isMet = false;

  PasswordRequirement({required this.text, required this.validator});
}

// Main Registration Page
class AthleteRegistrationPage extends StatefulWidget {
  const AthleteRegistrationPage({Key? key}) : super(key: key);

  @override
  State<AthleteRegistrationPage> createState() =>
      _AthleteRegistrationPageState();
}

class _AthleteRegistrationPageState extends State<AthleteRegistrationPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();
  List<Branch> _branches = [];
  Branch? _selectedBranch;
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _alertMessage;
  AlertType? _alertType;
  Map<String, bool> _fieldValidation = {
    'name': false,
    'email': false,
    'phone': false,
    'branch': false,
    'password': false,
    'confirmPassword': false,
  };
  Timer? _emailDebounce;
  Timer? _phoneDebounce;
  late List<PasswordRequirement> _passwordRequirements;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializePasswordRequirements();
    _setupAnimations();
    _loadBranches();
    _setupListeners();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _emailDebounce?.cancel();
    _phoneDebounce?.cancel();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _initializePasswordRequirements() {
    _passwordRequirements = [
      PasswordRequirement(
        text: 'At least 8 characters',
        validator: (password) => password.length >= 8,
      ),
      PasswordRequirement(
        text: 'One uppercase letter',
        validator: (password) => password.contains(RegExp(r'[A-Z]')),
      ),
      PasswordRequirement(
        text: 'One lowercase letter',
        validator: (password) => password.contains(RegExp(r'[a-z]')),
      ),
      PasswordRequirement(
        text: 'One number',
        validator: (password) => password.contains(RegExp(r'[0-9]')),
      ),
    ];
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    _fadeController.forward();
    _slideController.forward();
  }

  void _setupListeners() {
    _nameController.addListener(_validateName);
    _emailController.addListener(_validateEmailDebounced);
    _phoneController.addListener(_validatePhoneDebounced);
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validateConfirmPassword);
  }

  Future<void> _loadBranches() async {
    setState(() => _isLoading = true);
    try {
      print('🔄 Loading branches using ApiService...');
      final result = await ApiService.getPublicBranches();
      if (result['success'] == true) {
        final List<dynamic> branchData = result['data'];
        setState(() {
          _branches = branchData.map((json) => Branch.fromJson(json)).toList();
        });
        print('✅ Loaded ${_branches.length} branches successfully');
      } else {
        final errorMessage =
            result['error'] ??
            'Failed to load branches. Please refresh the page.';
        _showAlert(errorMessage, AlertType.error);
        print('❌ Failed to load branches: $errorMessage');
      }
    } catch (e) {
      print('❌ Exception loading branches: $e');
      _showAlert(
        'Network error loading branches. Check your connection.',
        AlertType.error,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _validateName() {
    final name = _nameController.text.trim();
    bool isValid = false;
    if (name.isEmpty) {
      isValid = false;
    } else if (name.length < 2) {
      isValid = false;
    } else if (name.length > 50) {
      isValid = false;
    } else if (!RegExp(r'^[a-zA-Z\u0600-\u06FF\s\-\.]+$').hasMatch(name)) {
      isValid = false;
    } else {
      isValid = true;
    }
    setState(() => _fieldValidation['name'] = isValid);
    _updateSubmitButtonState();
  }

  void _validateEmailDebounced() {
    _emailDebounce?.cancel();
    _emailDebounce = Timer(const Duration(milliseconds: 500), _validateEmail);
  }

  void _validateEmail() {
    final email = _emailController.text.trim().toLowerCase();
    bool isValid = false;
    if (email.isEmpty) {
      isValid = false;
    } else if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      isValid = false;
    } else {
      isValid = true;
    }
    setState(() => _fieldValidation['email'] = isValid);
    _updateSubmitButtonState();
  }

  void _validatePhoneDebounced() {
    _phoneDebounce?.cancel();
    _phoneDebounce = Timer(const Duration(milliseconds: 500), _validatePhone);
  }

  void _validatePhone() {
    final phone = _phoneController.text.trim();
    bool isValid = false;
    if (phone.isEmpty) {
      isValid = false;
    } else {
      final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
      if (digitsOnly.length >= 10 && digitsOnly.length <= 11) {
        if (digitsOnly.startsWith('0')) {
          if (digitsOnly.startsWith('01')) {
            if (digitsOnly.length == 11) {
              final validPrefixes = ['010', '011', '012', '015'];
              final prefix = digitsOnly.substring(0, 3);
              if (validPrefixes.contains(prefix)) {
                isValid = true;
                _phoneController.value = _phoneController.value.copyWith(
                  text: digitsOnly,
                  selection: TextSelection.collapsed(offset: digitsOnly.length),
                );
              }
            }
          } else {
            if (digitsOnly.length >= 10 && digitsOnly.length <= 11) {
              isValid = true;
              _phoneController.value = _phoneController.value.copyWith(
                text: digitsOnly,
                selection: TextSelection.collapsed(offset: digitsOnly.length),
              );
            }
          }
        }
      }
    }
    setState(() => _fieldValidation['phone'] = isValid);
    _updateSubmitButtonState();
  }

  void _validateBranch() {
    setState(() => _fieldValidation['branch'] = _selectedBranch != null);
    _updateSubmitButtonState();
  }

  void _validatePassword() {
    final password = _passwordController.text;
    bool isValid = false;
    if (password.isNotEmpty) {
      for (var requirement in _passwordRequirements) {
        requirement.isMet = requirement.validator(password);
      }
      isValid = _passwordRequirements.every((req) => req.isMet);
    }
    setState(() => _fieldValidation['password'] = isValid);
    _updateSubmitButtonState();
    if (_confirmPasswordController.text.isNotEmpty) {
      _validateConfirmPassword();
    }
  }

  void _validateConfirmPassword() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    bool isValid = false;
    if (confirmPassword.isNotEmpty && password == confirmPassword) {
      isValid = true;
    }
    setState(() => _fieldValidation['confirmPassword'] = isValid);
    _updateSubmitButtonState();
  }

  void _updateSubmitButtonState() {
    setState(() {});
  }

  void _showAlert(String message, AlertType type) {
    setState(() {
      _alertMessage = message;
      _alertType = type;
    });
    if (type == AlertType.success) {
      Timer(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _alertMessage = null;
            _alertType = null;
          });
        }
      });
    }
  }

  void _hideAlert() {
    setState(() {
      _alertMessage = null;
      _alertType = null;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _validateName();
    _validateEmail();
    _validatePhone();
    _validateBranch();
    _validatePassword();
    _validateConfirmPassword();
    final allValid = _fieldValidation.values.every((valid) => valid);
    if (!allValid) {
      _showAlert('Please fix all errors before submitting', AlertType.error);
      return;
    }
    setState(() => _isSubmitting = true);
    final registrationData = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim().toLowerCase(),
      'phone': _phoneController.text.trim(),
      'branch_id': _selectedBranch!.id,
      'password': _passwordController.text,
    };
    try {
      print('🔄 Submitting registration using ApiService...');
      final result = await ApiService.register(registrationData);
      if (result['success'] == true) {
        final responseData = result['data'];
        final message =
            result['message'] ??
            'Registration successful! Your request for ${_selectedBranch!.name} branch has been submitted. A coach will review and approve your account.';
        _showAlert(message, AlertType.success);
        _formKey.currentState!.reset();
        _nameController.clear();
        _emailController.clear();
        _phoneController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
        _selectedBranch = null;
        _fieldValidation.updateAll((key, value) => false);
        for (var requirement in _passwordRequirements) {
          requirement.isMet = false;
        }
        print('✅ Registration submitted successfully');
        Timer(const Duration(seconds: 3), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        });
      } else {
        final errorMessage =
            result['error'] ?? 'Registration failed. Please try again.';
        _showAlert(errorMessage, AlertType.error);
        print('❌ Registration failed: $errorMessage');
      }
    } catch (e) {
      print('❌ Exception during registration: $e');
      _showAlert(
        'Network error. Please check your connection and try again.',
        AlertType.error,
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC), // Match React Native
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFAFBFC),
                  Color(0xFF00D4FF), // Subtle gradient
                ],
                stops: [0.0, 1.0],
              ),
            ),
          ),
          // Gradient Overlay
          Container(
            color: const Color(
              0xFF00D4FF,
            ).withOpacity(0.02), // Match React Native
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 140,
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: Card(
                        elevation: 8, // Match React Native shadow
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            20,
                          ), // Match React Native
                          side: const BorderSide(
                            color: Color(0xFFE2E8F0), // Match React Native
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(
                            24,
                          ), // Match React Native
                          child: _buildForm(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Back Button
          Positioned(
            top: 60,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF64748B).withOpacity(0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '←',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF475569),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          if (_alertMessage != null) _buildAlert(),
          _buildNameField(),
          const SizedBox(height: 20),
          _buildEmailField(),
          const SizedBox(height: 20),
          _buildPhoneField(),
          const SizedBox(height: 20),
          _buildBranchField(),
          const SizedBox(height: 20),
          _buildPasswordField(),
          const SizedBox(height: 10),
          _buildPasswordRequirements(),
          const SizedBox(height: 20),
          _buildConfirmPasswordField(),
          const SizedBox(height: 20),
          _buildSubmitButton(),
          const SizedBox(height: 20),
          _buildLoginLink(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Join Our Academy',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B), // Match React Native
            letterSpacing: -0.3,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'Create your athlete account',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B), // Match React Native
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAlert() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            _alertType == AlertType.success
                ? const Color(0xFFF8FAFC) // Match React Native input background
                : const Color(0xFFF8FAFC),
        border: Border.all(
          color:
              _alertType == AlertType.success
                  ? const Color(0xFF00D4FF) // Match React Native
                  : const Color(0xFFEF4444),
        ),
        borderRadius: BorderRadius.circular(12), // Match React Native
      ),
      child: Row(
        children: [
          Icon(
            _alertType == AlertType.success ? Icons.check_circle : Icons.error,
            color:
                _alertType == AlertType.success
                    ? const Color(0xFF00D4FF) // Match React Native
                    : const Color(0xFFEF4444),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _alertMessage!,
              style: TextStyle(
                color:
                    _alertType == AlertType.success
                        ? const Color(0xFF00D4FF) // Match React Native
                        : const Color(0xFFEF4444),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _hideAlert,
            color:
                _alertType == AlertType.success
                    ? const Color(0xFF00D4FF) // Match React Native
                    : const Color(0xFFEF4444),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return _buildCustomTextField(
      controller: _nameController,
      focusNode: _nameFocus,
      label: 'Full Name *',
      hint: 'Enter your full name',
      icon: Icons.person_outline,
      fieldKey: 'name',
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Name is required';
        }
        if (value.trim().length < 2) {
          return 'Name must be at least 2 characters';
        }
        if (value.trim().length > 50) {
          return 'Name must be less than 50 characters';
        }
        if (!RegExp(r'^[a-zA-Z\u0600-\u06FF\s\-\.]+$').hasMatch(value.trim())) {
          return 'Name can only contain letters, spaces, hyphens, and dots';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return _buildCustomTextField(
      controller: _emailController,
      focusNode: _emailFocus,
      label: 'Email Address *',
      hint: 'Enter your email',
      icon: Icons.email_outlined,
      fieldKey: 'email',
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Email is required';
        }
        if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim())) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField() {
    return _buildCustomTextField(
      controller: _phoneController,
      focusNode: _phoneFocus,
      label: 'Phone Number *',
      hint: 'Enter your phone number',
      icon: Icons.phone_outlined,
      fieldKey: 'phone',
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
      ],
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Phone number is required';
        }
        final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
        if (digitsOnly.length < 10 || digitsOnly.length > 11) {
          return 'Egyptian phone number must be 10-11 digits';
        }
        if (!digitsOnly.startsWith('0')) {
          return 'Egyptian phone number must start with 0';
        }
        if (digitsOnly.startsWith('01')) {
          if (digitsOnly.length != 11) {
            return 'Mobile number must be 11 digits (01xxxxxxxxx)';
          }
          final validPrefixes = ['010', '011', '012', '015'];
          final prefix = digitsOnly.substring(0, 3);
          if (!validPrefixes.contains(prefix)) {
            return 'Invalid mobile prefix. Use 010, 011, 012, or 015';
          }
        } else if (digitsOnly.startsWith('0') && !digitsOnly.startsWith('01')) {
          if (digitsOnly.length < 10 || digitsOnly.length > 11) {
            return 'Landline number must be 10-11 digits';
          }
        } else {
          return 'Invalid Egyptian phone number format';
        }
        return null;
      },
    );
  }

  Widget _buildBranchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Branch *',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569), // Match React Native
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC), // Match React Native
            border: Border.all(
              color:
                  _fieldValidation['branch'] == true
                      ? const Color(0xFF00D4FF) // Match React Native
                      : const Color(0xFFE2E8F0),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12), // Match React Native
          ),
          child: DropdownButtonFormField<Branch>(
            value: _selectedBranch,
            decoration: InputDecoration(
              hintText: 'Select your branch',
              hintStyle: TextStyle(
                color: Color(0xFF94A3B8), // Match React Native
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(
                Icons.location_on_outlined,
                color: Color(0xFF64748B), // Match React Native
              ),
              suffixIcon: Icon(
                Icons.arrow_drop_down,
                color: Color(0xFF64748B), // Match React Native
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16), // Match React Native
            ),
            items:
                _branches.map((Branch branch) {
                  return DropdownMenuItem<Branch>(
                    value: branch,
                    child: Text(
                      '${branch.name} - ${branch.address}',
                      style: TextStyle(
                        color: Color(0xFF1E293B), // Match React Native
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
            onChanged: (Branch? newValue) {
              setState(() {
                _selectedBranch = newValue;
              });
              _validateBranch();
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a branch';
              }
              return null;
            },
          ),
        ),
        if (_fieldValidation['branch'] == true)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              'Branch selected',
              style: TextStyle(
                color: Color(0xFF00D4FF), // Match React Native
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return _buildCustomTextField(
      controller: _passwordController,
      focusNode: _passwordFocus,
      label: 'Password *',
      hint: 'Create a password',
      icon: Icons.lock_outlined,
      fieldKey: 'password',
      obscureText: _obscurePassword,
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePassword ? Icons.visibility : Icons.visibility_off,
          color: Color(0xFF64748B), // Match React Native
        ),
        onPressed: () {
          setState(() {
            _obscurePassword = !_obscurePassword;
          });
        },
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password is required';
        }
        if (value.length < 8) {
          return 'Password must be at least 8 characters';
        }
        if (value.length > 128) {
          return 'Password must be less than 128 characters';
        }
        if (!value.contains(RegExp(r'[A-Z]'))) {
          return 'Password must contain at least one uppercase letter';
        }
        if (!value.contains(RegExp(r'[a-z]'))) {
          return 'Password must contain at least one lowercase letter';
        }
        if (!value.contains(RegExp(r'[0-9]'))) {
          return 'Password must contain at least one number';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordRequirements() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC), // Match React Native
        borderRadius: BorderRadius.circular(12), // Match React Native
        border: Border.all(color: Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Requirements:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569), // Match React Native
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ..._passwordRequirements.map(_buildPasswordRequirement),
        ],
      ),
    );
  }

  Widget _buildPasswordRequirement(PasswordRequirement requirement) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Icon(
            requirement.isMet ? Icons.check_circle : Icons.circle,
            color:
                requirement.isMet
                    ? const Color(0xFF00D4FF) // Match React Native
                    : const Color(0xFF94A3B8),
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            requirement.text,
            style: TextStyle(
              color:
                  requirement.isMet
                      ? const Color(0xFF00D4FF) // Match React Native
                      : const Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return _buildCustomTextField(
      controller: _confirmPasswordController,
      focusNode: _confirmPasswordFocus,
      label: 'Confirm Password *',
      hint: 'Confirm your password',
      icon: Icons.lock_outlined,
      fieldKey: 'confirmPassword',
      obscureText: _obscureConfirmPassword,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
          color: Color(0xFF64748B), // Match React Native
        ),
        onPressed: () {
          setState(() {
            _obscureConfirmPassword = !_obscureConfirmPassword;
          });
        },
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please confirm your password';
        }
        if (value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    required String fieldKey,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    final isValid = _fieldValidation[fieldKey] == true;
    final hasError =
        controller.text.isNotEmpty && _fieldValidation[fieldKey] == false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569), // Match React Native
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFFF8FAFC), // Match React Native
            border: Border.all(
              color:
                  isValid
                      ? const Color(0xFF00D4FF) // Match React Native
                      : hasError
                      ? const Color(0xFFEF4444)
                      : const Color(0xFFE2E8F0),
              width: hasError ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12), // Match React Native
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Color(0xFF94A3B8), // Match React Native
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(
                icon,
                color: Color(0xFF64748B), // Match React Native
              ),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16), // Match React Native
            ),
            validator: validator,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            obscureText: obscureText,
            style: TextStyle(
              color: Color(0xFF1E293B), // Match React Native
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (hasError && controller.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              validator!(controller.text) ?? 'Invalid input',
              style: TextStyle(
                color: Color(0xFFEF4444), // Match React Native
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        if (isValid)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              'Valid input',
              style: TextStyle(
                color: Color(0xFF00D4FF), // Match React Native
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    final allValid = _fieldValidation.values.every((valid) => valid);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 56,
      child: ElevatedButton(
        onPressed: (allValid && !_isSubmitting) ? _submitForm : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              allValid
                  ? const Color(0xFF00D4FF) // Match React Native
                  : const Color(0xFF94A3B8), // Match React Native disabled
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Match React Native
          ),
          elevation: allValid ? 4 : 1, // Match React Native
          shadowColor: const Color(0xFF00D4FF).withOpacity(0.25),
        ),
        child:
            _isSubmitting
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Submitting...',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFFFFF), // Match React Native
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                )
                : Text(
                  'Submit Request',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFFFFFF), // Match React Native
                    letterSpacing: 0.3,
                  ),
                ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Container(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Already have an account? ',
            style: TextStyle(
              color: Color(0xFF64748B), // Match React Native
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text(
              'Sign in here',
              style: TextStyle(
                color: Color(0xFF00D4FF), // Match React Native
                fontSize: 13,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
