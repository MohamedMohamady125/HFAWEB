import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// ✅ FIXED: Use correct relative imports instead of package imports
import 'screens/coach/coach_only/coach_home_screen.dart';
import 'services/api_service.dart';
import 'services/auth_services.dart'; // ✅ ADD: Enhanced auth service
import 'services/language_service.dart'; // ✅ ADD: Language service
import 'screens/auth/welcome_screen.dart';
import 'screens/athlete/athlete_main_screen.dart';
import 'screens/admin/admin_main_screen.dart';
import 'screens/auth/coach_login_screen.dart';
import 'screens/coach/head_coach_only/head_coach_home_screen.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize services
  await LanguageService().initializeLanguage();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final LanguageService _languageService = LanguageService();
  Timer? _keepAliveTimer;

  @override
  void initState() {
    super.initState();
    _languageService.addListener(_onLanguageChanged);
    WidgetsBinding.instance.addObserver(this);

    // ✅ Start keep-alive timer for PWA persistent login
    _startKeepAliveTimer();
  }

  @override
  void dispose() {
    _languageService.removeListener(_onLanguageChanged);
    WidgetsBinding.instance.removeObserver(this);
    _keepAliveTimer?.cancel();
    super.dispose();
  }

  // ✅ Keep session alive for PWA
  void _startKeepAliveTimer() {
    _keepAliveTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      AuthService.refreshTokenSilently();
    });
  }

  // ✅ Handle app lifecycle changes for PWA
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        AuthService.refreshTokenSilently();
        break;
      case AppLifecycleState.paused:
        AuthService.refreshTokenSilently();
        break;
      default:
        break;
    }
  }

  void _onLanguageChanged() {
    setState(() {});
  }

  void setLocale(Locale locale) {
    if (locale.languageCode == 'ar') {
      if (!_languageService.isArabic) {
        _languageService.toggleLanguage();
      }
    } else {
      if (_languageService.isArabic) {
        _languageService.toggleLanguage();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HFA Flutter App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true),
        fontFamily: _languageService.isArabic ? 'Cairo' : 'Roboto',
      ),
      locale:
          _languageService.isArabic ? const Locale('ar') : const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      builder: (context, child) {
        return Directionality(
          textDirection: _languageService.textDirection,
          child: child!,
        );
      },

      localeResolutionCallback: (locale, supportedLocales) {
        if (_languageService.isArabic) return const Locale('ar');

        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return const Locale('en');
      },
      home: const EnhancedSplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ✅ Enhanced Splash Screen with Persistent Login
class EnhancedSplashScreen extends StatefulWidget {
  const EnhancedSplashScreen({super.key});

  @override
  State<EnhancedSplashScreen> createState() => _EnhancedSplashScreenState();
}

class _EnhancedSplashScreenState extends State<EnhancedSplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatusEnhanced();
  }

  Future<void> _checkAuthStatusEnhanced() async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      // ✅ Check if user should auto-login
      final shouldAutoLogin = await AuthService.shouldAutoLogin();

      if (!shouldAutoLogin) {
        print('🔄 Auto-login disabled, going to welcome screen');
        _navigateToWelcome();
        return;
      }

      // ✅ Check if user is logged in with enhanced method
      final isLoggedIn = await AuthService.isLoggedIn();

      if (mounted) {
        if (isLoggedIn) {
          final loginData = await AuthService.getLoginData();
          final userType = loginData['user_type'];

          print('✅ User is logged in as: $userType');

          Widget homeScreen;
          switch (userType) {
            case 'athlete':
              homeScreen = const AthleteMainScreen();
              break;
            case 'coach':
              homeScreen = const CoachHomeScreen();
              break;
            case 'head_coach':
              homeScreen = const RegularCoachHomeScreen();
              break;
            case 'admin':
              homeScreen = const AdminMainScreen();
              break;
            default:
              print('⚠️ Unknown user type: $userType, going to welcome');
              _navigateToWelcome();
              return;
          }

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => homeScreen),
          );
        } else {
          print('❌ User not logged in, going to welcome screen');
          _navigateToWelcome();
        }
      }
    } catch (e) {
      print('❌ Error checking auth status: $e');
      if (mounted) _navigateToWelcome();
    }
  }

  void _navigateToWelcome() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pool, size: 100, color: Colors.white),
            const SizedBox(height: 24),
            Text(
              l10n?.appTitle ?? 'HFA Swim',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 16),
            Text(
              l10n?.loadingDashboard ?? 'Checking login status...',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ Enhanced Bottom Navigation Bar for iPhone PWA
class LocalizedBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const LocalizedBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Get safe area padding for iPhone home indicator
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      // Add extra height for iPhone PWA and home indicator
      height: 70 + bottomPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          onTap: onTap,
          selectedItemColor: const Color(0xFF1976D2),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.transparent,
          elevation: 0,
          // Increase icon size for better PWA experience
          iconSize: 26,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          // Add more padding between icon and label
          landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
          items: [
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: const Icon(Icons.home),
              ),
              activeIcon: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: const Icon(Icons.home, size: 28),
              ),
              label: l10n.home,
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: const Icon(Icons.chat),
              ),
              activeIcon: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: const Icon(Icons.chat, size: 28),
              ),
              label: l10n.threads,
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: const Icon(Icons.sports),
              ),
              activeIcon: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: const Icon(Icons.sports, size: 28),
              ),
              label: l10n.gear,
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: const Icon(Icons.person),
              ),
              activeIcon: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: const Icon(Icons.person, size: 28),
              ),
              label: l10n.profile,
            ),
          ],
        ),
      ),
    );
  }
}
