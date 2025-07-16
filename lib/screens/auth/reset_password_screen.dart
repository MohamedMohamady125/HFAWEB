import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:ui'; // Added for ImageFilter
import '../../../services/api_service.dart';
import '../../utils/password_requirement.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String verificationCode;

  const ResetPasswordScreen({
    Key? key,
    required this.email,
    required this.verificationCode,
  }) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Password requirements
  late List<PasswordRequirement> _passwordRequirements;

  late AnimationController _fadeController;
  late AnimationController
  _morphingShapeController; // Added for background animation
  late AnimationController
  _glowRotateController; // Added for background animation
  late List<AnimationController>
  _particleControllers; // Added for background animation

  late Animation<double> _fadeAnimation;
  late Animation<double>
  _morphingShapeAnimation; // Added for background animation
  late Animation<double> _glowRotateAnimation; // Added for background animation
  late List<Animation<double>>
  _particleAnimations; // Added for background animation

  @override
  void initState() {
    super.initState();
    _initializePasswordRequirements();
    _setupAnimations();
    _setupListeners();
    _startAnimations(); // Start continuous animations
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _fadeController.dispose();
    _morphingShapeController
        .dispose(); // Dispose background animation controller
    _glowRotateController.dispose(); // Dispose background animation controller
    for (var controller in _particleControllers) {
      controller.dispose(); // Dispose background animation controllers
    }
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
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Morphing shapes
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

    // Glow rotation (for login icon/avatar)
    _glowRotateController = AnimationController(
      duration: const Duration(milliseconds: 15000),
      vsync: this,
    );
    _glowRotateAnimation = Tween<double>(begin: 0.0, end: 2 * 3.14159).animate(
      CurvedAnimation(parent: _glowRotateController, curve: Curves.linear),
    );

    // Particle animations
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

  void _setupListeners() {
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validateConfirmPassword);
  }

  void _validatePassword() {
    final password = _passwordController.text;

    if (password.isNotEmpty) {
      for (var requirement in _passwordRequirements) {
        requirement.isMet = requirement.validator(password);
      }
      setState(() {});
    }
  }

  void _validateConfirmPassword() {
    setState(() {}); // Trigger rebuild to update confirm password validation
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact(); // Add haptic feedback on validation failure
      return;
    }

    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      _showError('Passwords do not match');
      return;
    }

    // Check password requirements
    final allRequirementsMet = _passwordRequirements.every((req) => req.isMet);
    if (!allRequirementsMet) {
      _showError('Password does not meet all requirements');
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.lightImpact(); // Haptic feedback on login attempt

    try {
      print('🔄 Resetting password for: ${widget.email}');
      final result = await ApiService.resetPassword(
        email: widget.email,
        code: widget.verificationCode,
        newPassword: password,
        confirmPassword: confirmPassword,
      );

      if (result['success'] == true) {
        _showSuccess('Password reset successfully!');
        HapticFeedback.lightImpact();

        // Navigate to login screen
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);

        print('✅ Password reset successfully for: ${widget.email}');
      } else {
        final errorMessage = result['error'] ?? 'Failed to reset password';
        _showError(errorMessage);
        print('❌ Password reset failed: $errorMessage');
      }
    } catch (e) {
      print('❌ Exception resetting password: $e');
      _showError('Network error. Please check your connection and try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    HapticFeedback.heavyImpact(); // Stronger haptic feedback for errors
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade700, // Darker red for errors
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ), // More rounded corners
        margin: const EdgeInsets.all(
          20,
        ), // Add margin for better floating appearance
      ),
    );
  }

  void _showSuccess(String message) {
    HapticFeedback.lightImpact(); // Haptic feedback for success
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade700, // Darker green for success
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Animations
          _buildBackground(),
          _buildMorphingShapes(),
          _buildFloatingParticles(),
          // Main content with fade transition
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
                      // Back button (custom to fit theme)
                      Align(
                        alignment: Alignment.topLeft,
                        child: _buildGlassButton(
                          child: Icon(
                            Icons.arrow_back,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          onTap: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Reset Password Form Card
                      _buildGlassCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLogoSection(), // Reusing the logo section but with a general user icon
                            const SizedBox(height: 24),
                            const Text(
                              'Reset Password',
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
                            Text(
                              'Create a new secure password for your account.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF108FFF).withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF108FFF).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(
                                    0xFF108FFF,
                                  ).withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Code verified for ${widget.email}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // New Password Field
                            Text(
                              'New Password',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF108FFF),
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildThemedTextFormField(
                              controller: _passwordController,
                              focusNode: _passwordFocus,
                              hintText: 'Enter your new password',
                              icon: Icons.lock_outline,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: theme.colorScheme.primary,
                                ),
                                onPressed:
                                    () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                            _buildPasswordRequirements(),
                            const SizedBox(height: 25),

                            // Confirm Password Field
                            Text(
                              'Confirm New Password',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF108FFF),
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildThemedTextFormField(
                              controller: _confirmPasswordController,
                              focusNode: _confirmPasswordFocus,
                              hintText: 'Confirm your new password',
                              icon: Icons.lock_outline,
                              obscureText: _obscureConfirmPassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: theme.colorScheme.primary,
                                ),
                                onPressed:
                                    () => setState(
                                      () =>
                                          _obscureConfirmPassword =
                                              !_obscureConfirmPassword,
                                    ),
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
                            ),
                            if (_passwordController.text.isNotEmpty &&
                                _confirmPasswordController.text.isNotEmpty &&
                                _passwordController.text ==
                                    _confirmPasswordController.text)
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      '✓ Passwords match',
                                      style: TextStyle(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 30),

                            // Reset Button
                            _buildQuantumButton(
                              title:
                                  _isLoading
                                      ? 'Resetting...'
                                      : 'Reset Password',
                              onTap: _isLoading ? null : _resetPassword,
                              isLoading: _isLoading,
                            ),
                            const SizedBox(height: 20),

                            // Back to Login Link
                            Center(
                              child: _buildPlasmaLink(
                                title: 'Remember your password? Sign in here',
                                onTap:
                                    () => Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      '/login',
                                      (route) => false,
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
            ),
          ),
        ],
      ),
    );
  }

  // --- Reused UI Components (from LoginScreen) ---

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
            Transform(
              transform:
                  Matrix4.identity()
                    ..scale(_morphingShapeAnimation.value * 0.5 + 0.9),
              alignment: Alignment.center,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(45),
                  color: const Color(0xFF108FFF).withOpacity(0.05),
                ),
                transform: Matrix4.translationValues(
                  MediaQuery.of(context).size.width * 0.25,
                  MediaQuery.of(context).size.height * 0.55,
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
      constraints: const BoxConstraints(maxWidth: 360),
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

  Widget _buildThemedTextFormField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    FocusNode? focusNode, // Added focusNode parameter
  }) {
    return Container(
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
            focusNode: focusNode, // Assigned focusNode
            keyboardType: keyboardType,
            obscureText: obscureText,
            style: const TextStyle(color: Color(0xFF108FFF)),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: const Color(0xFF108FFF).withOpacity(0.5),
              ),
              prefixIcon: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
              ),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: const Color(0xFF108FFF).withOpacity(0.15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.red.shade400, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.red.shade700, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
            validator: validator,
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
              // Glow Ring
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
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
              ),
              // Quantum Field
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF108FFF).withOpacity(0.06),
                ),
              ),
              // General User Icon (or lock icon for reset password)
              Icon(Icons.lock_reset, size: 60, color: const Color(0xFF108FFF)),
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

  // Placeholder for Password Requirements
  Widget _buildPasswordRequirements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          _passwordRequirements
              .map(
                (requirement) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    children: [
                      Icon(
                        requirement.isMet
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        color:
                            requirement.isMet
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade400,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        requirement.text,
                        style: TextStyle(
                          color:
                              requirement.isMet
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildPlasmaLink({
    required String title,
    required VoidCallback onTap,
  }) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        title,
        style: TextStyle(
          color: const Color(0xFF108FFF).withOpacity(0.8),
          fontSize: 14,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
          decorationColor: const Color(0xFF108FFF).withOpacity(0.5),
        ),
      ),
    );
  }
}
