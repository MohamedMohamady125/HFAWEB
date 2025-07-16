import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_screen.dart';
import 'coach_login_screen.dart';
import 'head_coach_login_screen.dart';
import 'register_screen.dart';
import '../shared/branches_screen.dart';
import 'dart:math';
import 'dart:ui'; // Added for ImageFilter

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _masterFadeController;
  late AnimationController _logoBreathController;
  late AnimationController _titleWaveController;
  late AnimationController _cardFloatController;
  late AnimationController _buttonPulseController;
  late AnimationController _glowRotateController;
  late AnimationController _textShimmerController;
  late AnimationController _morphingShapeController;
  late AnimationController _topButtonsController;
  late AnimationController _logoEntranceController;
  late AnimationController _titleEntranceController;
  late AnimationController _cardEntranceController;
  late AnimationController _buttonsEntranceController;
  late List<AnimationController> _particleControllers;

  late Animation<double> _masterFadeAnimation;
  late Animation<double> _logoBreathAnimation;
  late Animation<double> _titleWaveAnimation;
  late Animation<double> _cardFloatAnimation;
  late Animation<double> _buttonPulseAnimation;
  late Animation<double> _glowRotateAnimation;
  late Animation<double> _textShimmerAnimation;
  late Animation<double> _morphingShapeAnimation;
  late Animation<double> _topButtonsAnimation;
  late Animation<double> _logoEntranceAnimation;
  late Animation<double> _titleEntranceAnimation;
  late Animation<double> _cardEntranceAnimation;
  late Animation<double> _buttonsEntranceAnimation;
  late List<Animation<double>> _particleAnimations;

  bool _isArabic = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Master fade
    _masterFadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _masterFadeAnimation = Tween<double>(begin: 0.0, end: 0.4).animate(
      CurvedAnimation(
        parent: _masterFadeController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Logo breathing
    _logoBreathController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _logoBreathAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _logoBreathController,
        curve: Curves.easeInOutSine,
      ),
    );

    // Title wave
    _titleWaveController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    _titleWaveAnimation = Tween<double>(begin: 0.0, end: -3.0).animate(
      CurvedAnimation(
        parent: _titleWaveController,
        curve: Curves.easeInOutSine,
      ),
    );

    // Card floating
    _cardFloatController = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );
    _cardFloatAnimation = Tween<double>(begin: 0.0, end: -6.0).animate(
      CurvedAnimation(
        parent: _cardFloatController,
        curve: Curves.easeInOutSine,
      ),
    );

    // Button pulse
    _buttonPulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _buttonPulseAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(
        parent: _buttonPulseController,
        curve: Curves.easeInOutQuad,
      ),
    );

    // Glow rotation
    _glowRotateController = AnimationController(
      duration: const Duration(milliseconds: 15000),
      vsync: this,
    );
    _glowRotateAnimation = Tween<double>(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(parent: _glowRotateController, curve: Curves.linear),
    );

    // Text shimmer
    _textShimmerController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    _textShimmerAnimation = Tween<double>(begin: -200.0, end: 200.0).animate(
      CurvedAnimation(parent: _textShimmerController, curve: Curves.linear),
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

    // Entrance animations
    _topButtonsController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _topButtonsAnimation = Tween<double>(begin: -100.0, end: 0.0).animate(
      CurvedAnimation(parent: _topButtonsController, curve: Curves.easeOut),
    );

    _logoEntranceController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _logoEntranceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoEntranceController, curve: Curves.bounceOut),
    );

    _titleEntranceController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _titleEntranceAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _titleEntranceController, curve: Curves.easeOut),
    );

    _cardEntranceController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _cardEntranceAnimation = Tween<double>(begin: 100.0, end: 0.0).animate(
      CurvedAnimation(parent: _cardEntranceController, curve: Curves.easeOut),
    );

    _buttonsEntranceController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _buttonsEntranceAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _buttonsEntranceController,
        curve: Curves.easeOut,
      ),
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
    // Start entrance animations
    _masterFadeController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      _topButtonsController.forward();
      Future.delayed(const Duration(milliseconds: 100), () {
        _logoEntranceController.forward();
        Future.delayed(const Duration(milliseconds: 100), () {
          _titleEntranceController.forward();
          Future.delayed(const Duration(milliseconds: 100), () {
            _cardEntranceController.forward();
            Future.delayed(const Duration(milliseconds: 100), () {
              _buttonsEntranceController.forward();
            });
          });
        });
      });
    });

    // Start continuous animations
    Future.delayed(const Duration(milliseconds: 300), () {
      _logoBreathController.repeat(reverse: true);
      _titleWaveController.repeat(reverse: true);
      _cardFloatController.repeat(reverse: true);
      _buttonPulseController.repeat(reverse: true);
      _glowRotateController.repeat();
      _textShimmerController.repeat();
      _morphingShapeController.repeat(reverse: true);
      for (var controller in _particleControllers) {
        controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _masterFadeController.dispose();
    _logoBreathController.dispose();
    _titleWaveController.dispose();
    _cardFloatController.dispose();
    _buttonPulseController.dispose();
    _glowRotateController.dispose();
    _textShimmerController.dispose();
    _morphingShapeController.dispose();
    _topButtonsController.dispose();
    _logoEntranceController.dispose();
    _titleEntranceController.dispose();
    _cardEntranceController.dispose();
    _buttonsEntranceController.dispose();
    for (var controller in _particleControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _navigateWithHaptic(Widget destination) {
    HapticFeedback.lightImpact();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => destination));
  }

  void _toggleLanguage() {
    setState(() {
      _isArabic = !_isArabic;
    });
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isArabic ? 'Switched to Arabic' : 'Switched to English'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFF108FFF).withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _viewServices() {
    HapticFeedback.lightImpact();
    _navigateWithHaptic(const BranchesScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          _buildBackground(),
          // Morphing Shapes
          _buildMorphingShapes(),
          // Floating Particles
          _buildFloatingParticles(),
          // Grid Pattern (Subtle)
          AnimatedBuilder(
            animation: _masterFadeAnimation,
            builder:
                (context, child) => Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    image: DecorationImage(
                      image: MemoryImage(
                        Uint8List.fromList(List.filled(16 * 16 * 4, 0)),
                      ),
                      repeat: ImageRepeat.repeat,
                      opacity: _masterFadeAnimation.value * 0.5,
                    ),
                  ),
                ),
          ),
          // Main Content
          SafeArea(
            child: AnimatedBuilder(
              animation: _masterFadeAnimation,
              builder:
                  (context, child) => Opacity(
                    opacity: _masterFadeAnimation.value / 0.4,
                    child: Column(
                      children: [
                        // Top Action Bar
                        _buildTopActionBar(),
                        // Main Content
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Logo
                                _buildLogoSection(),
                                const SizedBox(height: 32),
                                // Title
                                _buildTitleSection(),
                                const SizedBox(height: 28),
                                // Action Card
                                _buildActionCard(),
                              ],
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildTopActionBar() {
    return AnimatedBuilder(
      animation: _topButtonsAnimation,
      builder:
          (context, child) => Transform.translate(
            offset: Offset(0, _topButtonsAnimation.value),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Language Switch
                  _buildGlassButton(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.language,
                          color: Color(0xFF108FFF),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isArabic ? 'EN' : 'AR',
                          style: const TextStyle(
                            color: Color(0xFF108FFF),
                            fontWeight: FontWeight.w700,
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                    onTap: _toggleLanguage,
                  ),
                  // Coach Logins
                  Row(
                    children: [
                      _buildNeuralButton(
                        child: const Text(
                          '🅷',
                          style: TextStyle(
                            fontSize: 20,
                            color: Color(0xFF108FFF),
                          ),
                        ),
                        onTap:
                            () => _navigateWithHaptic(
                              const HeadCoachLoginScreen(),
                            ),
                      ),
                      Container(
                        width: 20,
                        height: 2.0,
                        decoration: BoxDecoration(
                          color: const Color(0xFF108FFF).withOpacity(0.4),
                          borderRadius: BorderRadius.circular(1.0),
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      _buildNeuralButton(
                        child: const Text(
                          '🅲',
                          style: TextStyle(
                            fontSize: 20,
                            color: Color(0xFF108FFF),
                          ),
                        ),
                        onTap:
                            () => _navigateWithHaptic(const CoachLoginScreen()),
                      ),
                    ],
                  ),
                ],
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
                  horizontal: 18,
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

  Widget _buildNeuralButton({
    required Widget child,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF108FFF).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF108FFF).withOpacity(0.1),
            blurRadius: 24,
            spreadRadius: -2.0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Material(
            color: Colors.white.withOpacity(0.25),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
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
      animation: Listenable.merge([
        _logoBreathAnimation,
        _logoEntranceAnimation,
        _glowRotateAnimation,
      ]),
      builder:
          (context, child) => Transform.scale(
            scale: _logoEntranceAnimation.value * _logoBreathAnimation.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glow Ring
                Transform.rotate(
                  angle: _glowRotateAnimation.value,
                  child: Container(
                    width: 136,
                    height: 136,
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
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF108FFF).withOpacity(0.06),
                  ),
                ),
                // Logo
                Image.asset(
                  'assets/images/hfalogos.png',
                  width: 112,
                  height: 112,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    print('Error loading logo: $error');
                    return const Icon(
                      Icons.error,
                      size: 112,
                      color: Colors.grey,
                    );
                  },
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildTitleSection() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _titleEntranceAnimation,
        _titleWaveAnimation,
        _textShimmerAnimation,
      ]),
      builder:
          (context, child) => Transform.translate(
            offset: Offset(
              0,
              _titleEntranceAnimation.value + _titleWaveAnimation.value,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Title
                Text(
                  _isArabic ? 'نادي السباحة' : 'HFA',
                  style: const TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF108FFF),
                    letterSpacing: -1.0,
                    shadows: [
                      Shadow(
                        color: Color.fromRGBO(16, 143, 255, 0.2),
                        offset: Offset(0, 2.0),
                        blurRadius: 4.0,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                // Shimmer
                Positioned(
                  top: 0,
                  bottom: 0,
                  child: Transform.translate(
                    offset: Offset(_textShimmerAnimation.value, 0),
                    child: Container(
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
                // Underline
                Positioned(
                  bottom: -10.0,
                  child: Container(
                    width: 70,
                    height: 3.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFF108FFF),
                      borderRadius: BorderRadius.circular(2.0),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF108FFF).withOpacity(0.4),
                          blurRadius: 8.0,
                          offset: const Offset(0, 2.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildActionCard() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _cardEntranceAnimation,
        _cardFloatAnimation,
      ]),
      builder:
          (context, child) => Transform.translate(
            offset: Offset(
              0,
              _cardEntranceAnimation.value + _cardFloatAnimation.value,
            ),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 320),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28.0),
                border: Border.all(
                  color: const Color(0xFF108FFF).withOpacity(0.1),
                ),
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
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                    ),
                    padding: const EdgeInsets.all(28.0),
                    child: AnimatedBuilder(
                      animation: _buttonsEntranceAnimation,
                      builder:
                          (context, child) => Transform.translate(
                            offset: Offset(0, _buttonsEntranceAnimation.value),
                            child: Column(
                              children: [
                                // Login Button
                                _buildQuantumButton(
                                  title:
                                      _isArabic
                                          ? 'تسجيل دخول لاعب'
                                          : 'Athlete Login',
                                  onTap:
                                      () => _navigateWithHaptic(
                                        const LoginScreen(),
                                      ),
                                ),
                                const SizedBox(height: 18),
                                // Register Button
                                _buildHoloButton(
                                  title: _isArabic ? 'تسجيل جديد' : 'Register',
                                  onTap:
                                      () => _navigateWithHaptic(
                                        const AthleteRegistrationPage(),
                                      ),
                                ),
                                const SizedBox(height: 18),
                                // View Services
                                _buildPlasmaLink(
                                  title:
                                      _isArabic
                                          ? 'عرض خدماتنا'
                                          : 'View Our Services',
                                  onTap: _viewServices,
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

  Widget _buildQuantumButton({
    required String title,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: _buttonPulseAnimation,
      builder:
          (context, child) => Transform.scale(
            scale: _buttonPulseAnimation.value,
            child: Container(
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
              child: Stack(
                children: [
                  // Energy Wave
                  Positioned.fill(
                    child: Transform.scale(
                      scale: (_buttonPulseAnimation.value - 1) * 10 + 1,
                      child: Opacity(
                        opacity: (1 - (_buttonPulseAnimation.value - 1) / 0.02)
                            .clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22.0),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1.8,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Button Core
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onTap,
                        borderRadius: BorderRadius.circular(18),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 16,
                            ),
                            child: Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 15.0,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
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

  Widget _buildHoloButton({
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF108FFF).withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF108FFF).withOpacity(0.15),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Material(
            color: Colors.white.withOpacity(0.15),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(18),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 16,
                  ),
                  child: Text(
                    title,
                    style: TextStyle(
                      color: const Color(0xFF108FFF).withOpacity(0.9),
                      fontWeight: FontWeight.w700,
                      fontSize: 15.0,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
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
            // Underline effect
            Positioned(
              bottom: 0,
              child: Container(
                width: title.length * 7.0,
                height: 1.5,
                decoration: BoxDecoration(
                  color: const Color(0xFF108FFF).withOpacity(0.7),
                  borderRadius: BorderRadius.circular(0.75),
                ),
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: const Color(0xFF108FFF).withOpacity(0.9),
                fontWeight: FontWeight.w600,
                fontSize: 14.0,
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
