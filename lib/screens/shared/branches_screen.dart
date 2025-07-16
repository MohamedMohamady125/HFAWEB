// branches_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback and SystemUiOverlayStyle
import 'package:url_launcher/url_launcher.dart'; // For opening URLs (maps, phone calls)
import 'package:webview_flutter/webview_flutter.dart'; // For embedding YouTube videos
import 'package:webview_flutter_android/webview_flutter_android.dart'; // Android specific
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart'; // iOS specific

// Assuming LanguageService.dart is in ../../services/language_service.dart
// If not, you'll need to create a simple version of it.
import '../../services/language_service.dart';

/// Define the Branch data model
class Branch {
  final int id;
  final String name;
  final String address;
  final String? locationUrl;
  final String phone;
  final String practiceDays;
  final String? practiceTime;
  final String? practiceTimeAr;
  final String? videoUrl;

  Branch({
    required this.id,
    required this.name,
    required this.address,
    this.locationUrl,
    required this.phone,
    required this.practiceDays,
    this.practiceTime,
    this.practiceTimeAr,
    this.videoUrl,
  });
}

// Static list of branches, equivalent to the React Native 'branches' array
final List<Branch> branches = [
  Branch(
    id: 1,
    name: "RPM Gym, Maadi",
    address: "RPM Gym, Maadi",
    locationUrl: "https://maps.app.goo.gl/gdvGS2xxUaM74unT7",
    phone: "02-25267890",
    practiceDays: "Saturday, Tuesday, Thursday",
    practiceTime: "Saturday: 11 AM or 1 PM, Tuesday & Thursday: 3:30 PM",
    practiceTimeAr: "السبت: ١١ صباحًا أو ١ ظهرًا، الثلاثاء والخميس: ٣:٣٠ مساءً",
    videoUrl: "https://www.youtube.com/embed/5t1DHQE8zfg",
  ),
  Branch(
    id: 2,
    name: "Power Gym2, Hadayek Al-Ahram",
    address: "Power Gym2, Hadayek Al-Ahram",
    locationUrl: "https://maps.app.goo.gl/HRfGZXEzwGZqyYar7",
    phone: "02-38247631",
    practiceDays: "Saturday, Tuesday, Thursday",
    practiceTime:
        "Saturday: 8:30 AM, Tuesday: 3:30 PM or 6:30 PM, Thursday: 8:30 PM",
    practiceTimeAr:
        "السبت: ٨:٣٠ صباحًا، الثلاثاء: ٣:٣٠ مساءً أو ٦:٣٠ مساءً، الخميس: ٨:٣٠ مساءً",
    videoUrl: null, // No video URL provided
  ),
  Branch(
    id: 3,
    name: "V Fit Gym, 6th October City",
    address: "V Fit Gym, 6th October City",
    locationUrl: "https://maps.app.goo.gl/aRwbUrf45sezvAAg7",
    phone: "02-38247632",
    practiceDays: "Sunday, Tuesday, Thursday",
    practiceTime: "Sunday: 3:30 PM, Tuesday: 9 PM, Thursday: 3:30 PM",
    practiceTimeAr: "الأحد: ٣:٣٠ مساءً، الثلاثاء: ٩ مساءً، الخميس: ٣:٣٠ مساءً",
    videoUrl: null,
  ),
  Branch(
    id: 4,
    name: "Fitness Zone Gym, Nasr City",
    address: "Fitness Zone Gym, Nasr City",
    locationUrl: "https://maps.app.goo.gl/jwo8J5ZsXEmishXA8",
    phone: "02-24157832",
    practiceDays: "Saturday, Monday, Wednesday",
    practiceTime: "Saturday, Monday, Wednesday: 8:30 PM",
    practiceTimeAr: "السبت، الاثنين، الأربعاء: ٨:٣٠ مساءً",
    videoUrl: null,
  ),
  Branch(
    id: 5,
    name: "Bank Misr Club, New Cairo",
    address: "Bank Misr Club, New Cairo",
    locationUrl: "https://maps.app.goo.gl/GS9Qvww69cqPJ3LW7",
    phone: "02-26183492",
    practiceDays: "Saturday, Monday, Wednesday",
    practiceTime: "Saturday, Monday, Wednesday: 3:45 PM or 5:45 PM",
    practiceTimeAr: "السبت، الاثنين، الأربعاء: ٣:٤٥ مساءً أو ٥:٤٥ مساءً",
    videoUrl: "https://youtube.com/shorts/NUe6lj56ePk?si=8x0Aq0J1I29M76mk",
  ),
];

class BranchesScreen extends StatefulWidget {
  const BranchesScreen({super.key});

  @override
  State<BranchesScreen> createState() => _BranchesScreenState();
}

class _BranchesScreenState extends State<BranchesScreen>
    with TickerProviderStateMixin {
  // Animation controllers for header and cards
  late AnimationController _headerFadeController;
  late Animation<double> _headerFadeAnimation;
  late AnimationController _headerSlideController;
  late Animation<Offset> _headerSlideAnimation;

  // List of animation controllers for each branch card for staggered animation
  final List<AnimationController> _cardAnimationControllers = [];
  final List<Animation<double>> _cardFadeAnimations = [];
  final List<Animation<Offset>> _cardSlideAnimations = [];

  // Language Service instance
  final LanguageService _languageService = LanguageService();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeLanguage();

    // Start header animations
    _headerFadeController.forward();
    _headerSlideController.forward();

    // Start staggered card animations
    _startCardAnimations();

    // Listen to language changes to rebuild UI
    _languageService.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    _headerFadeController.dispose();
    _headerSlideController.dispose();
    for (var controller in _cardAnimationControllers) {
      controller.dispose();
    }
    _languageService.removeListener(_onLanguageChanged);
    super.dispose();
  }

  /// Initializes all animation controllers and their tweens.
  void _initializeAnimations() {
    // Header animations
    _headerFadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerFadeController, curve: Curves.easeOut),
    );

    _headerSlideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.2), // Start slightly above
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _headerSlideController, curve: Curves.easeOut),
    );

    // Card animations
    for (int i = 0; i < branches.length; i++) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      );
      _cardAnimationControllers.add(controller);
      _cardFadeAnimations.add(
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut)),
      );
      _cardSlideAnimations.add(
        Tween<Offset>(
          begin: const Offset(0, 0.1), // Start slightly below
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut)),
      );
    }
  }

  /// Starts the staggered animation for branch cards.
  void _startCardAnimations() async {
    for (int i = 0; i < _cardAnimationControllers.length; i++) {
      await Future.delayed(Duration(milliseconds: i * 100)); // Stagger delay
      _cardAnimationControllers[i].forward();
    }
  }

  /// Initializes the language from storage.
  Future<void> _initializeLanguage() async {
    await _languageService.initializeLanguage();
    if (mounted) setState(() {});
  }

  /// Callback for language changes to trigger UI rebuild.
  void _onLanguageChanged() {
    if (mounted) {
      setState(() {
        // Re-evaluate localized texts and text direction
      });
    }
  }

  /// Opens a URL using url_launcher.
  Future<void> _openUrl(String? url, String errorMessageKey) async {
    if (url == null || url.isEmpty) {
      _showSnackBar(
        _languageService.getLocalizedText(
          "Location URL not available.",
          errorMessageKey,
        ),
      );
      return;
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showSnackBar(
        _languageService.getLocalizedText(
          "Could not launch $url",
          "تعذر فتح $url",
        ),
      );
    }
  }

  /// Displays a SnackBar message.
  void _showSnackBar(String message) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blueAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenHeight = MediaQuery.of(context).size.height;

    return Directionality(
      textDirection: _languageService.textDirection,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark, // For dark status bar icons
          child: Stack(
            children: [
              // Background Gradient Layers
              Positioned.fill(child: Container(color: Colors.white)),
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF108fff).withOpacity(0.03),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    // Header
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _headerFadeAnimation,
                        _headerSlideAnimation,
                      ]),
                      builder: (context, child) {
                        return Opacity(
                          opacity: _headerFadeAnimation.value,
                          child: Transform.translate(
                            offset:
                                _headerSlideAnimation.value *
                                screenHeight *
                                0.1, // Scale slide effect
                            child: _buildHeader(context),
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        itemCount: branches.length,
                        itemBuilder: (context, index) {
                          final branch = branches[index];
                          return AnimatedBuilder(
                            animation: Listenable.merge([
                              _cardFadeAnimations[index],
                              _cardSlideAnimations[index],
                            ]),
                            builder: (context, child) {
                              return Opacity(
                                opacity: _cardFadeAnimations[index].value,
                                child: Transform.translate(
                                  offset:
                                      _cardSlideAnimations[index].value *
                                      30, // Direct pixel offset
                                  child: _buildBranchCard(branch, context),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the main header section of the screen.
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(), // Pop current screen
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: Colors.white,
                border: Border.all(
                  color: const Color(0xFF108fff).withOpacity(0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF108fff).withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Text(
                '←', // Unicode arrow for back
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF108fff),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Header Content
          Expanded(
            child: Column(
              crossAxisAlignment:
                  _languageService.textDirection == TextDirection.rtl
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
              children: [
                Text(
                  _languageService.getLocalizedText("Our Branches", "فروعنا"),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF108fff),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _languageService.getLocalizedText(
                    "Find your nearest training location",
                    "ابحث عن أقرب موقع تدريب لك",
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color(0xFF108fff).withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a single branch information card.
  Widget _buildBranchCard(Branch branch, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF108fff).withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: const Color(0xFF108fff).withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Glow (top border)
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: 3,
              width: double.infinity,
              color: const Color(0xFF108fff).withOpacity(0.7),
              margin: const EdgeInsets.only(bottom: 20),
            ),
          ),
          // Branch Header
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  color: const Color(0xFF108fff).withOpacity(0.1),
                  border: Border.all(
                    color: const Color(0xFF108fff).withOpacity(0.2),
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: const Text('🏋️', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      branch.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF108fff),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF108fff).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF108fff).withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        _languageService.getLocalizedText("Active", "نشط"),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF108fff),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Practice Schedule
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF108fff).withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF108fff).withOpacity(0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('⏰', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(
                      _languageService.getLocalizedText(
                        "Practice Time",
                        "أوقات التدريب",
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF108fff),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _languageService.isArabic
                      ? branch.practiceTimeAr ?? branch.practiceTime ?? "N/A"
                      : branch.practiceTime ?? "N/A",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF108fff),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Action Buttons
          Row(
            children: [
              Expanded(
                // Ensures buttons share space
                child: _buildActionButton(
                  icon: '📍',
                  text: _languageService.getLocalizedText(
                    "View Location",
                    "عرض الموقع",
                  ),
                  backgroundColor: const Color(0xFF108fff),
                  onTap:
                      () => _openUrl(
                        branch.locationUrl,
                        "location_not_available",
                      ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                // Ensures buttons share space
                child: _buildActionButton(
                  icon: '📞',
                  text: _languageService.getLocalizedText(
                    "Call Now",
                    "اتصل الآن",
                  ),
                  backgroundColor: const Color(0xFF25d366), // WhatsApp green
                  onTap:
                      () => _openUrl(
                        'tel:${branch.phone}',
                        "phone_not_available",
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Video Section
          if (branch.videoUrl != null && branch.videoUrl!.isNotEmpty)
            _buildVideoSection(branch.videoUrl!),
          if (branch.videoUrl == null || branch.videoUrl!.isEmpty)
            _buildNoVideoSection(),
        ],
      ),
    );
  }

  /// Helper to build action buttons.
  Widget _buildActionButton({
    required String icon,
    required String text,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            // Fix for RenderFlex overflow: Wrap text in Expanded
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
                textAlign:
                    TextAlign.center, // Center text within expanded space
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the video section with an embedded WebView.
  Widget _buildVideoSection(String videoUrl) {
    // Controller for the WebView
    late final WebViewController controller;
    bool videoLoading = false; // Initial assumption

    // Initialize the WebView controller
    PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      params = AndroidWebViewControllerCreationParams();
      AndroidWebViewController.enableDebugging(true);
    } else if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    controller =
        WebViewController.fromPlatformCreationParams(params)
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000))
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                // Can show progress here, e.g., print('WebView is loading (progress: $progress%)');
              },
              onPageStarted: (String url) {
                if (mounted) {
                  setState(() {
                    videoLoading = true;
                  });
                }
              },
              onPageFinished: (String url) {
                if (mounted) {
                  setState(() {
                    videoLoading = false;
                  });
                }
              },
              onWebResourceError: (WebResourceError error) {
                _showSnackBar(
                  _languageService.getLocalizedText(
                    "Failed to load video: ${error.description}",
                    "فشل تحميل الفيديو: ${error.description}",
                  ),
                );
                if (mounted) {
                  setState(() {
                    videoLoading = false;
                  });
                }
              },
            ),
          )
          ..loadRequest(Uri.parse(videoUrl));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('🎬', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              _languageService.getLocalizedText("Branch Video", "فيديو الفرع"),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF108fff),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.black, // Background for WebView
            border: Border.all(
              color: const Color(0xFF108fff).withOpacity(0.2),
              width: 2,
            ),
          ),
          clipBehavior: Clip.antiAlias, // Clip content to border radius
          child: Stack(
            children: [
              WebViewWidget(controller: controller),
              if (videoLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.1),
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(
                      color: Color(0xFF108fff),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the section indicating no video is available.
  Widget _buildNoVideoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF108fff).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF108fff).withOpacity(0.2),
          width: 2,
          // Fixed: Use BorderStyle.solid for a simple line, or implement custom
          // painting for dashed/dotted lines if needed.
          // For a visual representation like dashed/dotted, you would
          // typically use a CustomPainter, but for simplicity and direct
          // Flutter API, we'll use solid here unless you need exact dashed styling.
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          const Text('🎬', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            _languageService.getLocalizedText(
              "Video coming soon",
              "الفيديو قادم قريباً",
            ),
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF108fff).withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Placeholder for LanguageService.dart (if you don't have it already)
// Place this in '../../services/language_service.dart'
/*
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static final LanguageService _instance = LanguageService._internal();

  factory LanguageService() {
    return _instance;
  }

  LanguageService._internal();

  Locale? _locale;
  bool _isArabic = false;

  Locale get locale => _locale ?? const Locale('en');
  bool get isArabic => _isArabic;
  TextDirection get textDirection => _isArabic ? TextDirection.rtl : TextDirection.ltr;

  Future<void> initializeLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLangCode = prefs.getString('language_code');
    if (savedLangCode != null) {
      _locale = Locale(savedLangCode);
      _isArabic = savedLangCode == 'ar';
    } else {
      _locale = const Locale('en');
      _isArabic = false;
    }
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    _isArabic = !_isArabic;
    _locale = _isArabic ? const Locale('ar') : const Locale('en');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', _locale!.languageCode);
    notifyListeners();
  }

  String getLocalizedText(String englishText, String arabicText) {
    return _isArabic ? arabicText : englishText;
  }
}
*/
