import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../services/auth_services.dart'; // ✅ ADD: Enhanced auth service
import '../../services/language_service.dart'; // ✅ ADD: Language service
import '../athlete/athlete_main_screen.dart';
import '../admin/admin_main_screen.dart';
import '../coach/coach_only/coach_home_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'dart:math';
import 'dart:ui'; // Added for ImageFilter

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _inviteTokenController =
      TextEditingController(); // ✅ ADD: Invite token controller
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = true; // ✅ ADD: Remember me option (default true for PWA)

  // ✅ ADD: Invite link state
  bool _isInviteMode = false;
  bool _isValidatingInvite = false;
  Map<String, dynamic>? _validationResult;

  // ✅ ADD: Language service
  final LanguageService _languageService = LanguageService();

  // Animation controllers for theme consistency
  late AnimationController _fadeController;
  late AnimationController _morphingShapeController;
  late AnimationController _glowRotateController;
  late List<AnimationController> _particleControllers;

  // Animations for theme consistency
  late Animation<double> _fadeAnimation;
  late Animation<double> _morphingShapeAnimation;
  late Animation<double> _glowRotateAnimation;
  late List<Animation<double>> _particleAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    // ✅ ADD: Listen to language changes
    _languageService.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _inviteTokenController.dispose(); // ✅ ADD: Dispose invite controller
    _fadeController.dispose();
    _morphingShapeController.dispose();
    _glowRotateController.dispose();
    for (var controller in _particleControllers) {
      controller.dispose();
    }
    // ✅ ADD: Remove language listener
    _languageService.removeListener(_onLanguageChanged);
    super.dispose();
  }

  // ✅ ADD: Handle language changes
  void _onLanguageChanged() {
    if (mounted) setState(() {});
  }

  // ✅ ADD: Toggle language
  Future<void> _toggleLanguage() async {
    await _languageService.toggleLanguage();
    HapticFeedback.lightImpact();
  }

  // ✅ ADD: Token extraction helper
  String _extractTokenFromInput(String input) {
    final trimmedInput = input.trim();

    // If it's a full URL, extract just the token part
    if (trimmedInput.contains('/invite/')) {
      final parts = trimmedInput.split('/invite/');
      if (parts.length > 1) {
        return parts.last; // Return the token part after /invite/
      }
    }

    // If it's already just a token, return as is
    return trimmedInput;
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
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
    _glowRotateAnimation = Tween<double>(begin: 0.0, end: 2 * pi).animate(
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

  // ✅ UPDATED: Use enhanced auth service
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    try {
      // ✅ Use enhanced login with persistent storage
      final result = await AuthService.login(
        _emailController.text.trim(),
        _passwordController.text,
        rememberMe: _rememberMe,
      );

      if (result['success']) {
        if (mounted) {
          final loginData = await AuthService.getLoginData();
          final userType = loginData['user_type'];
          Widget homeScreen;

          switch (userType) {
            case 'athlete':
              homeScreen = const AthleteMainScreen();
              break;
            case 'admin':
              homeScreen = const AdminMainScreen();
              break;
            case 'coach':
            case 'head_coach':
              homeScreen = const CoachHomeScreen();
              break;
            default:
              throw Exception(
                _languageService.getLocalizedText(
                  'Unknown user type: $userType',
                  'نوع مستخدم غير معروف: $userType',
                ),
              );
          }

          HapticFeedback.lightImpact();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => homeScreen),
          );
        }
      } else {
        _showError(
          result['error'] ??
              _languageService.getLocalizedText(
                'Login failed',
                'فشل تسجيل الدخول',
              ),
        );
      }
    } catch (e) {
      _showError(
        _languageService.getLocalizedText('Network error', 'خطأ في الشبكة'),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ✅ UPDATED: Invite link methods with token extraction
  Future<void> _validateInviteToken() async {
    final rawInput = _inviteTokenController.text.trim();
    final token = _extractTokenFromInput(rawInput); // ✅ Extract token from URL

    if (token.isEmpty) {
      _showError(
        _languageService.getLocalizedText(
          'Please enter an invite token',
          'يرجى إدخال رمز الدعوة',
        ),
      );
      return;
    }

    setState(() => _isValidatingInvite = true);

    try {
      final result = await ApiService.validateInviteToken(
        token,
      ); // ✅ Use extracted token

      if (result['success'] && result['valid'] == true) {
        setState(() {
          _validationResult = result;
        });
        _showSuccess(
          _languageService.getLocalizedText(
            'Valid invite link found!',
            'تم العثور على رابط دعوة صالح!',
          ),
        );
      } else {
        setState(() {
          _validationResult = null;
        });
        _showError(
          result['message'] ??
              _languageService.getLocalizedText(
                'Invalid or expired invite link',
                'رابط دعوة غير صالح أو منتهي الصلاحية',
              ),
        );
      }
    } catch (e) {
      setState(() {
        _validationResult = null;
      });
      _showError(
        _languageService.getLocalizedText(
          'Error validating invite link',
          'خطأ في التحقق من رابط الدعوة',
        ),
      );
    } finally {
      setState(() => _isValidatingInvite = false);
    }
  }

  Future<void> _loginWithInvite() async {
    final rawInput = _inviteTokenController.text.trim();
    final token = _extractTokenFromInput(rawInput); // ✅ Extract token from URL

    if (token.isEmpty) {
      _showError(
        _languageService.getLocalizedText(
          'Please enter an invite token',
          'يرجى إدخال رمز الدعوة',
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.loginWithInvite(
        token,
      ); // ✅ Use extracted token

      if (result['success']) {
        final userType = result['data']?['user_type'] ?? 'athlete';

        _showSuccess(
          result['message'] ??
              _languageService.getLocalizedText(
                'Login successful!',
                'تم تسجيل الدخول بنجاح!',
              ),
        );

        // Navigate to appropriate home screen
        if (mounted) {
          Widget homeScreen;
          switch (userType) {
            case 'athlete':
              homeScreen = const AthleteMainScreen();
              break;
            case 'coach':
            case 'head_coach':
              homeScreen = const CoachHomeScreen();
              break;
            case 'admin':
              homeScreen = const AdminMainScreen();
              break;
            default:
              homeScreen = const AthleteMainScreen();
              break;
          }

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => homeScreen),
          );
        }
      } else {
        _showError(
          result['error'] ??
              _languageService.getLocalizedText(
                'Login failed',
                'فشل تسجيل الدخول',
              ),
        );
      }
    } catch (e) {
      _showError(
        _languageService.getLocalizedText(
          'Network error. Please check your connection.',
          'خطأ في الشبكة. يرجى فحص الاتصال.',
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData('text/plain');
    if (clipboardData?.text != null) {
      _inviteTokenController.text = clipboardData!.text!;
      // Auto-validate after pasting
      _validateInviteToken();
    }
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

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _languageService.textDirection,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            _buildBackground(),
            _buildMorphingShapes(),
            _buildFloatingParticles(),
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
                        // Header with language toggle
                        Row(
                          children: [
                            _buildGlassButton(
                              child: Icon(
                                Icons.arrow_back,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                              onTap: () => Navigator.of(context).pop(),
                            ),
                            const Spacer(),
                            // ✅ ADD: Language toggle button
                            _buildGlassButton(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _languageService.isArabic
                                        ? Icons.language
                                        : Icons.translate,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _languageService.isArabic ? 'EN' : 'عر',
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: _toggleLanguage,
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // ✅ ADD: Mode Toggle Buttons
                        Row(
                          children: [
                            Expanded(
                              child: _buildModeToggleButton(
                                title: _languageService.getLocalizedText(
                                  'Regular Login',
                                  'تسجيل دخول عادي',
                                ),
                                isSelected: !_isInviteMode,
                                onTap:
                                    () => setState(() {
                                      _isInviteMode = false;
                                      _validationResult = null;
                                      _inviteTokenController.clear();
                                    }),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildModeToggleButton(
                                title: _languageService.getLocalizedText(
                                  'Invite Link',
                                  'رابط الدعوة',
                                ),
                                isSelected: _isInviteMode,
                                onTap:
                                    () => setState(() {
                                      _isInviteMode = true;
                                      _validationResult = null;
                                    }),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Login Form Card
                        _buildGlassCard(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLogoSection(),
                              const SizedBox(height: 24),
                              Text(
                                _languageService.getLocalizedText(
                                  'HFA Swim',
                                  'سباحة أكاديمية هفا',
                                ),
                                style: const TextStyle(
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
                                _isInviteMode
                                    ? _languageService.getLocalizedText(
                                      'Login with invite link',
                                      'تسجيل الدخول برابط الدعوة',
                                    )
                                    : _languageService.getLocalizedText(
                                      'Sign in to your account',
                                      'سجل الدخول إلى حسابك',
                                    ),
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  color: const Color(
                                    0xFF108FFF,
                                  ).withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 48),

                              // ✅ ADD: Conditional form content
                              if (_isInviteMode) ...[
                                // Invite Link Section
                                _buildInviteLinkSection(),
                              ] else ...[
                                // Regular Login Section
                                _buildRegularLoginSection(),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ ADD: Mode toggle button
  Widget _buildModeToggleButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isSelected
                  ? const Color(0xFF108FFF)
                  : const Color(0xFF108FFF).withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
        boxShadow:
            isSelected
                ? [
                  BoxShadow(
                    color: const Color(0xFF108FFF).withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
                : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color:
                isSelected
                    ? const Color(0xFF108FFF).withOpacity(0.1)
                    : Colors.white.withOpacity(0.1),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(
                      color:
                          isSelected
                              ? const Color(0xFF108FFF)
                              : const Color(0xFF108FFF).withOpacity(0.6),
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 14,
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

  // ✅ ADD: Regular login section
  Widget _buildRegularLoginSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Email Field
        Text(
          _languageService.getLocalizedText('Email', 'البريد الإلكتروني'),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF108FFF),
          ),
        ),
        const SizedBox(height: 10),
        _buildThemedTextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          hintText: _languageService.getLocalizedText(
            'your@email.com',
            'البريد@الإلكتروني.com',
          ),
          icon: Icons.email_outlined,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return _languageService.getLocalizedText(
                'Please enter your email',
                'يرجى إدخال بريدك الإلكتروني',
              );
            }
            if (!value.contains('@')) {
              return _languageService.getLocalizedText(
                'Please enter a valid email',
                'يرجى إدخال بريد إلكتروني صحيح',
              );
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        // Password Field
        Text(
          _languageService.getLocalizedText('Password', 'كلمة المرور'),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF108FFF),
          ),
        ),
        const SizedBox(height: 10),
        _buildThemedTextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          hintText: _languageService.getLocalizedText(
            'Enter your password',
            'أدخل كلمة المرور',
          ),
          icon: Icons.lock_outline,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed:
                () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return _languageService.getLocalizedText(
                'Please enter your password',
                'يرجى إدخال كلمة المرور',
              );
            }
            return null;
          },
        ),

        // ✅ ADD: Remember me checkbox
        const SizedBox(height: 16),
        CheckboxListTile(
          title: Text(
            _languageService.getLocalizedText(
              'Keep me logged in',
              'ابقني مسجلاً',
            ),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF108FFF)),
          ),
          subtitle: Text(
            _languageService.getLocalizedText(
              'Stay logged in on this device',
              'ابق مسجلاً على هذا الجهاز',
            ),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF108FFF).withOpacity(0.7),
            ),
          ),
          value: _rememberMe,
          onChanged: (value) => setState(() => _rememberMe = value ?? true),
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: const Color(0xFF108FFF),
        ),

        // Forgot Password
        Align(
          alignment: Alignment.centerRight,
          child: _buildPlasmaLink(
            title: _languageService.getLocalizedText(
              'Forgot Password?',
              'نسيت كلمة المرور؟',
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ForgotPasswordScreen(),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 24),

        // Login Button
        _buildQuantumButton(
          title:
              _isLoading
                  ? _languageService.getLocalizedText(
                    'Logging In...',
                    'جاري تسجيل الدخول...',
                  )
                  : _languageService.getLocalizedText(
                    'Sign In',
                    'تسجيل الدخول',
                  ),
          onTap: _isLoading ? null : _login,
          isLoading: _isLoading,
        ),
        const SizedBox(height: 16),

        // Register Link
        Center(
          child: _buildPlasmaLink(
            title: _languageService.getLocalizedText(
              'Don\'t have an account? Register',
              'ليس لديك حساب؟ سجل الآن',
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AthleteRegistrationPage(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ✅ ADD: Invite link section
  Widget _buildInviteLinkSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _languageService.getLocalizedText('Invite Token', 'رمز الدعوة'),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF108FFF),
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
                controller: _inviteTokenController,
                textDirection: TextDirection.ltr,
                style: const TextStyle(
                  color: Color(0xFF108FFF),
                  fontFamily: 'monospace',
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: _languageService.getLocalizedText(
                    'Paste full URL or just the token...',
                    'الصق الرابط كاملاً أو الرمز فقط...',
                  ),
                  hintStyle: TextStyle(
                    color: const Color(0xFF108FFF).withOpacity(0.5),
                  ),
                  prefixIcon: Icon(
                    Icons.link,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.8),
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: _pasteFromClipboard,
                        icon: const Icon(Icons.paste),
                        color: Theme.of(context).colorScheme.primary,
                        tooltip: _languageService.getLocalizedText(
                          'Paste from clipboard',
                          'لصق من الحافظة',
                        ),
                      ),
                      if (_inviteTokenController.text.isNotEmpty)
                        IconButton(
                          onPressed:
                              _isValidatingInvite ? null : _validateInviteToken,
                          icon:
                              _isValidatingInvite
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF108FFF),
                                    ),
                                  )
                                  : const Icon(Icons.check_circle_outline),
                          color: Theme.of(context).colorScheme.primary,
                          tooltip: _languageService.getLocalizedText(
                            'Validate token',
                            'التحقق من الرمز',
                          ),
                        ),
                    ],
                  ),
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _validationResult = null;
                  });
                },
              ),
            ),
          ),
        ),

        // Validation Result
        if (_validationResult != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _languageService.getLocalizedText(
                        'Valid Invite Link',
                        'رابط دعوة صالح',
                      ),
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _languageService.getLocalizedText(
                    'User: ${_validationResult!['user_name']} (${_validationResult!['user_role']})',
                    'المستخدم: ${_validationResult!['user_name']} (${_validationResult!['user_role']})',
                  ),
                  style: TextStyle(color: Colors.green[600], fontSize: 12),
                ),
                Text(
                  _languageService.getLocalizedText(
                    'Email: ${_validationResult!['user_email']}',
                    'البريد الإلكتروني: ${_validationResult!['user_email']}',
                  ),
                  style: TextStyle(color: Colors.green[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Login with Invite Button
        _buildQuantumButton(
          title:
              _isLoading
                  ? _languageService.getLocalizedText(
                    'Logging In...',
                    'جاري تسجيل الدخول...',
                  )
                  : _languageService.getLocalizedText(
                    'Login with Invite',
                    'تسجيل الدخول بالدعوة',
                  ),
          onTap: _isLoading ? null : _loginWithInvite,
          isLoading: _isLoading,
        ),

        const SizedBox(height: 16),

        // Info text
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF108FFF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF108FFF).withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: const Color(0xFF108FFF).withOpacity(0.7),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _languageService.getLocalizedText(
                    'Paste the full URL or just the token to login as another user temporarily.',
                    'الصق الرابط كاملاً أو الرمز فقط لتسجيل الدخول كمستخدم آخر مؤقتاً.',
                  ),
                  style: TextStyle(
                    color: const Color(0xFF108FFF).withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
      builder:
          (context, child) => Stack(
            children: [
              Transform(
                transform:
                    Matrix4.identity()
                      ..scale(_morphingShapeAnimation.value * 0.3 + 1.0)
                      ..rotateZ(_morphingShapeAnimation.value * pi),
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
                      ..rotateZ(_morphingShapeAnimation.value * -pi),
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
          ),
    );
  }

  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: Listenable.merge(_particleAnimations),
      builder:
          (context, child) => Stack(
            children: List.generate(8, (index) {
              final anim = _particleAnimations[index];
              return Positioned(
                left: (index * 8 + 5) * MediaQuery.of(context).size.width / 100,
                top:
                    (index * 6 + 15) * MediaQuery.of(context).size.height / 100,
                child: Transform(
                  transform:
                      Matrix4.identity()
                        ..translate(0.0, anim.value * -40)
                        ..scale(anim.value * 0.7 + 0.5)
                        ..rotateZ(anim.value * 2 * pi),
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
          ),
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
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF108FFF).withOpacity(0.06),
                ),
              ),
              Icon(
                _isInviteMode ? Icons.link : Icons.person,
                size: 60,
                color: const Color(0xFF108FFF),
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
                            fontWeight: FontWeight.w800,
                            fontSize: 16.0,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlasmaLink({
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              bottom: 0,
              child: Container(
                width: title.length * 7.5,
                height: 1.8,
                decoration: BoxDecoration(
                  color: const Color(0xFF108FFF).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(0.9),
                ),
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14.5,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
