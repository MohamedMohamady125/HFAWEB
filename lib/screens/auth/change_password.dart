import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../services/api_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  late AnimationController _fadeController;
  late AnimationController _morphingShapeController;
  late AnimationController _glowRotateController;
  late List<AnimationController> _particleControllers;

  late Animation<double> _fadeAnimation;
  late Animation<double> _morphingShapeAnimation;
  late Animation<double> _glowRotateAnimation;
  late List<Animation<double>> _particleAnimations;

  double _passwordStrength = 0.0;
  String _passwordStrengthText = '';
  Color _passwordStrengthColor = Colors.red;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _newPasswordController.addListener(_checkPasswordStrength);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _morphingShapeController.dispose();
    _glowRotateController.dispose();
    for (var controller in _particleControllers) {
      controller.dispose();
    }
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _morphingShapeController = AnimationController(
      duration: const Duration(milliseconds: 6000),
      vsync: this,
    );
    _morphingShapeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _morphingShapeController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _glowRotateController = AnimationController(
      duration: const Duration(milliseconds: 15000),
      vsync: this,
    );
    _glowRotateAnimation = Tween<double>(begin: 0.0, end: 2 * 3.14159).animate(
      CurvedAnimation(parent: _glowRotateController, curve: Curves.linear),
    );

    _particleControllers = List.generate(
      8,
      (index) => AnimationController(
        duration: Duration(milliseconds: 3000 + (index * 200)),
        vsync: this,
      ),
    );
    _particleAnimations =
        _particleControllers
            .map(
              (controller) => Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: controller,
                  curve: Curves.easeInOutSine,
                ),
              ),
            )
            .toList();
  }

  void _startAnimations() {
    _fadeController.forward();
    _morphingShapeController.repeat(reverse: true);
    _glowRotateController.repeat();
    for (var controller in _particleControllers) {
      controller.repeat(reverse: true);
    }
  }

  void _checkPasswordStrength() {
    final password = _newPasswordController.text;
    double strength = 0.0;
    String strengthText = '';
    Color strengthColor = Colors.red;

    final RegExp specialCharRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

    if (password.isEmpty) {
      strength = 0.0;
      strengthText = '';
      strengthColor = Colors.red;
    } else if (password.length < 8) {
      strength = 0.2;
      strengthText = 'Too short';
      strengthColor = Colors.red;
    } else {
      bool hasUpperCase = password.contains(RegExp(r'[A-Z]'));
      bool hasLowerCase = password.contains(RegExp(r'[a-z]'));
      bool hasDigits = password.contains(RegExp(r'[0-9]'));
      bool hasSpecialCharacters = password.contains(specialCharRegex);

      int criteriaCount = 0;
      if (hasUpperCase) criteriaCount++;
      if (hasLowerCase) criteriaCount++;
      if (hasDigits) criteriaCount++;
      if (hasSpecialCharacters) criteriaCount++;

      if (!hasSpecialCharacters) {
        strength = 0.3;
        strengthText = 'Needs special character';
        strengthColor = Colors.red;
      } else if (criteriaCount >= 4) {
        strength = 1.0;
        strengthText = 'Strong';
        strengthColor = const Color(0xFF10B981);
      } else if (criteriaCount >= 3) {
        strength = 0.7;
        strengthText = 'Good';
        strengthColor = const Color(0xFF108FFF);
      } else if (criteriaCount >= 2) {
        strength = 0.5;
        strengthText = 'Fair';
        strengthColor = Colors.orange;
      } else {
        strength = 0.4;
        strengthText = 'Weak';
        strengthColor = Colors.orange;
      }
    }

    setState(() {
      _passwordStrength = strength;
      _passwordStrengthText = strengthText;
      _passwordStrengthColor = strengthColor;
    });
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    try {
      final result = await ApiService.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      );

      if (result['success']) {
        _showSuccessDialog();
        HapticFeedback.lightImpact();
      } else {
        _showError(result['error'] ?? 'Failed to change password');
      }
    } catch (e) {
      _showError('Network error. Please check your connection and try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Color(0xFF10B981),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Success!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your password has been changed successfully.',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF108FFF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showError(String message) {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Animations
          _buildBackground(),
          _buildMorphingShapes(),
          _buildFloatingParticles(),
          // Main content
          FadeTransition(
            opacity: _fadeAnimation,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button
                      Align(
                        alignment: Alignment.topLeft,
                        child: _buildGlassButton(
                          child: const Icon(
                            Icons.arrow_back,
                            color: Color(0xFF108FFF),
                            size: 20,
                          ),
                          onTap: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Main card
                      _buildGlassCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLogoSection(),
                            const SizedBox(height: 24),
                            const Text(
                              'Change Password',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF108FFF),
                                letterSpacing: -1.0,
                                shadows: [
                                  Shadow(
                                    color: Color.fromRGBO(16, 143, 255, 0.3),
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Update your password to keep your account secure.',
                              style: TextStyle(
                                color: Color(0x70108FFF),
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),

                            // Current Password Field
                            _buildPasswordField(
                              controller: _currentPasswordController,
                              label: 'Current Password',
                              hintText: 'Enter your current password',
                              icon: Icons.lock_outline,
                              obscureText: _obscureCurrentPassword,
                              onToggleVisibility:
                                  () => setState(
                                    () =>
                                        _obscureCurrentPassword =
                                            !_obscureCurrentPassword,
                                  ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Current password is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // New Password Field
                            _buildPasswordField(
                              controller: _newPasswordController,
                              label: 'New Password',
                              hintText: 'Enter your new password',
                              icon: Icons.lock_reset,
                              obscureText: _obscureNewPassword,
                              onToggleVisibility:
                                  () => setState(
                                    () =>
                                        _obscureNewPassword =
                                            !_obscureNewPassword,
                                  ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'New password is required';
                                }
                                if (value.length < 8) {
                                  return 'Password must be at least 8 characters';
                                }
                                final RegExp specialCharRegex = RegExp(
                                  r'[!@#$%^&*(),.?":{}|<>]',
                                );
                                if (!value.contains(specialCharRegex)) {
                                  return 'Password must contain a special character';
                                }
                                if (value == _currentPasswordController.text) {
                                  return 'New password must be different';
                                }
                                return null;
                              },
                            ),

                            // Password strength indicator
                            if (_newPasswordController.text.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _buildPasswordStrengthIndicator(),
                            ],

                            const SizedBox(height: 24),

                            // Confirm Password Field
                            _buildPasswordField(
                              controller: _confirmPasswordController,
                              label: 'Confirm New Password',
                              hintText: 'Confirm your new password',
                              icon: Icons.verified_user,
                              obscureText: _obscureConfirmPassword,
                              onToggleVisibility:
                                  () => setState(
                                    () =>
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword,
                                  ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value != _newPasswordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),

                            // Password match indicator
                            if (_confirmPasswordController.text.isNotEmpty &&
                                _newPasswordController.text.isNotEmpty &&
                                _confirmPasswordController.text ==
                                    _newPasswordController.text)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF10B981),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '✓ Passwords match',
                                      style: const TextStyle(
                                        color: Color(0xFF10B981),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 32),

                            // Password Tips Card
                            _buildPasswordTipsCard(),

                            const SizedBox(height: 32),

                            // Change Password Button
                            _buildQuantumButton(
                              title:
                                  _isLoading
                                      ? 'Changing...'
                                      : 'Change Password',
                              onTap: _isLoading ? null : _changePassword,
                              isLoading: _isLoading,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            const Color(0xFF108FFF).withOpacity(0.03),
            Colors.white,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildMorphingShapes() {
    return AnimatedBuilder(
      animation: _morphingShapeAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            Transform(
              transform:
                  Matrix4.identity()
                    ..scale(_morphingShapeAnimation.value * 0.3 + 1.0)
                    ..rotateZ(_morphingShapeAnimation.value * 3.14159),
              alignment: Alignment.center,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(90),
                  color: const Color(0xFF108FFF).withOpacity(0.04),
                ),
                transform: Matrix4.translationValues(
                  MediaQuery.of(context).size.width * 0.65,
                  0.1 * MediaQuery.of(context).size.height,
                  0,
                ),
              ),
            ),
            Transform(
              transform:
                  Matrix4.identity()
                    ..scale(_morphingShapeAnimation.value * -0.4 + 1.2)
                    ..rotateZ(_morphingShapeAnimation.value * -3.14159),
              alignment: Alignment.center,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(70),
                  color: const Color(0xFF108FFF).withOpacity(0.03),
                ),
                transform: Matrix4.translationValues(
                  -MediaQuery.of(context).size.width * 0.45,
                  MediaQuery.of(context).size.height * 0.75,
                  0,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: Listenable.merge(_particleAnimations),
      builder: (context, child) {
        return Stack(
          children: List.generate(8, (index) {
            final anim = _particleAnimations[index];
            return Positioned(
              left: (index * 8 + 5) * MediaQuery.of(context).size.width / 100,
              top: (index * 6 + 15) * MediaQuery.of(context).size.height / 100,
              child: Transform(
                transform:
                    Matrix4.identity()
                      ..translate(0.0, anim.value * -40)
                      ..scale(anim.value * 0.7 + 0.5)
                      ..rotateZ(anim.value * 2 * 3.14159),
                alignment: Alignment.center,
                child: Opacity(
                  opacity: (anim.value < 0.3
                          ? anim.value / 0.3
                          : (1 - anim.value) / 0.7)
                      .clamp(0.0, 1.0),
                  child: Container(
                    width: 3.0,
                    height: 3.0,
                    decoration: BoxDecoration(
                      color: const Color(0xFF108FFF).withOpacity(0.7),
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildGlassCard({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.0),
        border: Border.all(color: const Color(0xFF108FFF).withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF108FFF).withOpacity(0.1),
            blurRadius: 25,
            offset: const Offset(0, 12.0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
          child: Container(
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.25)),
            padding: padding ?? const EdgeInsets.all(24.0),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildGlassButton({
    required Widget child,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF108FFF).withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF108FFF).withOpacity(0.08),
            blurRadius: 24,
            spreadRadius: -2.0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Material(
            color: Colors.white.withOpacity(0.2),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return AnimatedBuilder(
      animation: _glowRotateAnimation,
      builder:
          (context, child) => Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: _glowRotateAnimation.value,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF108FFF).withOpacity(0.25),
                      width: 1.8,
                    ),
                  ),
                ),
              ),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF108FFF).withOpacity(0.06),
                ),
              ),
              const Icon(Icons.security, size: 60, color: Color(0xFF108FFF)),
            ],
          ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF108FFF),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: TextFormField(
                controller: controller,
                obscureText: obscureText,
                validator: validator,
                style: const TextStyle(color: Color(0xFF108FFF)),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: const Color(0xFF108FFF).withOpacity(0.5),
                  ),
                  prefixIcon: Icon(
                    icon,
                    color: const Color(0xFF108FFF).withOpacity(0.8),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFF108FFF),
                    ),
                    onPressed: onToggleVisibility,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF108FFF).withOpacity(0.15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF108FFF),
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.red.shade400,
                      width: 2,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.red.shade700,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF108FFF).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF108FFF).withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Password Strength',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              Text(
                _passwordStrengthText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _passwordStrengthColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _passwordStrength,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(_passwordStrengthColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordTipsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF108FFF).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF108FFF).withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: Color(0xFF108FFF),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Password Tips',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF108FFF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '• At least 8 characters long\n'
            '• Mix of uppercase and lowercase letters\n'
            '• Include numbers and special characters\n'
            '• Avoid common words or personal info',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantumButton({
    required String title,
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF108FFF).withOpacity(0.95),
            const Color(0xFF007BFF).withOpacity(0.95),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF108FFF).withOpacity(0.25),
            blurRadius: 20,
            spreadRadius: -2.0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onTap,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              child: Center(
                child:
                    isLoading
                        ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
