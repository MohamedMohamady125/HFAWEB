import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';
import '../../services/language_service.dart';
import '../auth/login_screen.dart';
import '../auth/change_password.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../auth/welcome_screen.dart';

class AthleteProfileScreen extends StatefulWidget {
  const AthleteProfileScreen({super.key});

  @override
  State<AthleteProfileScreen> createState() => _AthleteProfileScreenState();
}

class _AthleteProfileScreenState extends State<AthleteProfileScreen>
    with TickerProviderStateMixin {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  // Remove local _isArabic - use global service instead
  final LanguageService _languageService = LanguageService();

  // Measurements
  Map<String, String> _measurements = {
    'height': '',
    'weight': '',
    'arm': '',
    'leg': '',
    'fat': '',
    'muscle': '',
  };
  bool _hasExistingMeasurements = false;

  // Performance Logs
  List<Map<String, dynamic>> _performanceLogs = [];
  bool _hasExistingPerformance = false;

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // ✅ ADD: Invite link properties
  String? _currentInviteLink;
  bool _isGeneratingInvite = false;
  List<Map<String, dynamic>> _myInviteLinks = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeLanguage();
    _loadAllData();

    // Listen to language changes
    _languageService.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _languageService.removeListener(_onLanguageChanged);
    super.dispose();
  }

  // Initialize language from storage
  Future<void> _initializeLanguage() async {
    await _languageService.initializeLanguage();
    if (mounted) setState(() {});
  }

  // Handle language changes
  void _onLanguageChanged() {
    if (mounted) setState(() {});
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
  }

  // Toggle language using global service
  Future<void> _toggleLanguage() async {
    await _languageService.toggleLanguage();
    HapticFeedback.lightImpact();
    _showSuccess(
      _languageService.getLocalizedText(
        'Switched to English',
        'تم التبديل إلى العربية',
      ),
    );
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);

    try {
      await Future.wait([
        _loadProfile(),
        _loadMeasurements(),
        _loadPerformanceLogs(),
        _loadMyInviteLinks(), // ✅ ADD: Load invite links
      ]);

      // Start animations
      _fadeController.forward();
      _slideController.forward();
    } catch (e) {
      print('❌ Error loading profile data: $e');
      _showError(
        _languageService.getLocalizedText(
          'Failed to load profile data',
          'فشل في تحميل بيانات الملف الشخصي',
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadProfile() async {
    final result = await ApiService.getUserProfile();
    if (result['success']) {
      setState(() {
        _profile = result['data'];
      });
    } else {
      throw Exception('Failed to load profile');
    }
  }

  Future<void> _loadMeasurements() async {
    try {
      print('🔄 Loading measurements...');
      final result = await ApiService.getMeasurements();
      print('🔄 Measurements API result: $result');

      if (result['success']) {
        final data = result['data'];
        print('🔄 Measurements data received: $data');

        if (data != null) {
          Map<String, dynamic>? latestMeasurement;

          if (data is List && data.isNotEmpty) {
            latestMeasurement = Map<String, dynamic>.from(data.first);
            print('✅ Using latest measurement from array: $latestMeasurement');
          } else if (data is Map) {
            latestMeasurement = Map<String, dynamic>.from(data);
            print('✅ Using single measurement object: $latestMeasurement');
          }

          if (latestMeasurement != null) {
            setState(() {
              _measurements = {
                'height': _safeToString(latestMeasurement!['height']),
                'weight': _safeToString(latestMeasurement['weight']),
                'arm': _safeToString(latestMeasurement['arm']),
                'leg': _safeToString(latestMeasurement['leg']),
                'fat': _safeToString(latestMeasurement['fat']),
                'muscle': _safeToString(latestMeasurement['muscle']),
              };
              _hasExistingMeasurements = true;
            });
            print('✅ Measurements loaded successfully: $_measurements');
          } else {
            print('ℹ️ No measurement data found in response');
            _resetMeasurements();
          }
        } else {
          print('ℹ️ API returned null data');
          _resetMeasurements();
        }
      } else {
        print('❌ API call failed: ${result['error']}');
        _resetMeasurements();
      }
    } catch (e) {
      print('❌ Exception loading measurements: $e');
      _resetMeasurements();
    }
  }

  String _safeToString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is num) return value.toString();
    return value.toString();
  }

  void _resetMeasurements() {
    setState(() {
      _measurements = {
        'height': '',
        'weight': '',
        'arm': '',
        'leg': '',
        'fat': '',
        'muscle': '',
      };
      _hasExistingMeasurements = false;
    });
    print('🔄 Measurements reset to empty state');
  }

  Future<void> _loadPerformanceLogs() async {
    try {
      final result = await ApiService.getPerformanceLogs();
      print('🔄 Performance logs API result: $result');

      if (result['success'] && result['data'] != null) {
        final List<dynamic> logs = result['data'];

        _performanceLogs.clear();

        if (logs.isNotEmpty) {
          for (final log in logs) {
            _performanceLogs.add({
              'id': log['id'],
              'meet_name': log['meet_name'] ?? '',
              'meet_date': log['meet_date'] ?? '',
              'event_name': log['event_name'] ?? '',
              'result_time': log['result_time'] ?? '',
              'created_at': log['created_at'] ?? '',
            });
          }

          setState(() {
            _hasExistingPerformance = true;
          });

          print(
            '✅ Loaded ${logs.length} existing logs + adding 1 empty slot = ${logs.length + 1} total',
          );
        } else {
          setState(() {
            _hasExistingPerformance = false;
          });
          print('ℹ️ No existing performance logs found');
        }

        _performanceLogs.add(_createEmptyPerformanceLog());
        setState(() {});
      } else {
        print('ℹ️ API returned no performance logs');
        setState(() {
          _hasExistingPerformance = false;
          _performanceLogs = [_createEmptyPerformanceLog()];
        });
      }
    } catch (e) {
      print('⚠️ Error loading performance logs: $e');
      setState(() {
        _hasExistingPerformance = false;
        _performanceLogs = [_createEmptyPerformanceLog()];
      });
    }
  }

  Map<String, dynamic> _createEmptyPerformanceLog() {
    return {
      'id': null,
      'meet_name': '',
      'meet_date': '',
      'event_name': '',
      'result_time': '',
    };
  }

  // ✅ ADD: Invite link methods
  Future<void> _generateInviteLink() async {
    setState(() => _isGeneratingInvite = true);

    try {
      final result = await ApiService.createInviteLink();

      if (result['success']) {
        setState(() {
          _currentInviteLink = result['invite_url'];
        });

        // Copy to clipboard
        await Clipboard.setData(ClipboardData(text: _currentInviteLink!));

        _showSuccess(
          _languageService.getLocalizedText(
            'Invite link generated and copied to clipboard!',
            'تم إنشاء رابط الدعوة ونسخه إلى الحافظة!',
          ),
        );

        HapticFeedback.lightImpact();

        // Refresh invite links list
        await _loadMyInviteLinks();
      } else {
        _showError(
          result['error'] ??
              _languageService.getLocalizedText(
                'Failed to generate invite link',
                'فشل في إنشاء رابط الدعوة',
              ),
        );
      }
    } catch (e) {
      _showError(
        _languageService.getLocalizedText(
          'Error generating invite link',
          'خطأ في إنشاء رابط الدعوة',
        ),
      );
    } finally {
      setState(() => _isGeneratingInvite = false);
    }
  }

  Future<void> _loadMyInviteLinks() async {
    try {
      final result = await ApiService.getMyInviteLinks();

      if (result['success']) {
        setState(() {
          _myInviteLinks = List<Map<String, dynamic>>.from(
            result['invite_links'],
          );
        });
      }
    } catch (e) {
      print('❌ Error loading invite links: $e');
    }
  }

  Future<void> _shareInviteLink() async {
    if (_currentInviteLink != null) {
      // Copy to clipboard
      await Clipboard.setData(ClipboardData(text: _currentInviteLink!));

      _showSuccess(
        _languageService.getLocalizedText(
          'Invite link copied to clipboard!',
          'تم نسخ رابط الدعوة إلى الحافظة!',
        ),
      );

      HapticFeedback.lightImpact();
    }
  }

  void _showInviteLinksDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              _languageService.getLocalizedText(
                'My Invite Links',
                'روابط الدعوة الخاصة بي',
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child:
                  _myInviteLinks.isEmpty
                      ? Center(
                        child: Text(
                          _languageService.getLocalizedText(
                            'No invite links created yet',
                            'لم يتم إنشاء روابط دعوة بعد',
                          ),
                        ),
                      )
                      : ListView.builder(
                        itemCount: _myInviteLinks.length,
                        itemBuilder: (context, index) {
                          final link = _myInviteLinks[index];
                          final isUsed = link['used'] == 1;
                          final isInvalidated = link['invalidated_at'] != null;
                          final expiresAt = DateTime.parse(link['expires_at']);
                          final isExpired = DateTime.now().isAfter(expiresAt);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Icon(
                                isUsed
                                    ? Icons.check_circle
                                    : isInvalidated || isExpired
                                    ? Icons.cancel
                                    : Icons.link,
                                color:
                                    isUsed
                                        ? Colors.green
                                        : isInvalidated || isExpired
                                        ? Colors.red
                                        : Colors.blue,
                              ),
                              title: Text(
                                '${link['token'].substring(0, 8)}...',
                                style: const TextStyle(fontFamily: 'monospace'),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _languageService.getLocalizedText(
                                      'Created: ${link['created_at']?.toString().split('T')[0] ?? 'Unknown'}',
                                      'تم الإنشاء: ${link['created_at']?.toString().split('T')[0] ?? 'غير معروف'}',
                                    ),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    isUsed
                                        ? _languageService.getLocalizedText(
                                          'Used',
                                          'مستخدم',
                                        )
                                        : isInvalidated
                                        ? _languageService.getLocalizedText(
                                          'Invalidated',
                                          'ملغي',
                                        )
                                        : isExpired
                                        ? _languageService.getLocalizedText(
                                          'Expired',
                                          'منتهي الصلاحية',
                                        )
                                        : _languageService.getLocalizedText(
                                          'Active',
                                          'نشط',
                                        ),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          isUsed
                                              ? Colors.green
                                              : isInvalidated || isExpired
                                              ? Colors.red
                                              : Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              trailing:
                                  !isUsed && !isInvalidated && !isExpired
                                      ? IconButton(
                                        icon: const Icon(Icons.copy),
                                        onPressed: () async {
                                          final fullUrl =
                                              'https://ornate-banoffee-460953.netlify.app/invite/${link['token']}';
                                          await Clipboard.setData(
                                            ClipboardData(text: fullUrl),
                                          );
                                          _showSuccess(
                                            _languageService.getLocalizedText(
                                              'Link copied!',
                                              'تم نسخ الرابط!',
                                            ),
                                          );
                                        },
                                      )
                                      : null,
                            ),
                          );
                        },
                      ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  _languageService.getLocalizedText('Close', 'إغلاق'),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _saveMeasurements() async {
    try {
      bool hasValidData = false;
      final cleanMeasurements = <String, double>{};

      for (final entry in _measurements.entries) {
        final value = entry.value.trim();
        if (value.isNotEmpty) {
          final doubleValue = double.tryParse(value);
          if (doubleValue != null && doubleValue > 0) {
            cleanMeasurements[entry.key] = doubleValue;
            hasValidData = true;
          }
        }
      }

      if (!hasValidData) {
        _showError(
          _languageService.getLocalizedText(
            'Please enter at least one valid measurement',
            'يرجى إدخال قياس واحد صحيح على الأقل',
          ),
        );
        return;
      }

      final result = await ApiService.saveMeasurements(cleanMeasurements);
      if (result['success']) {
        setState(() => _hasExistingMeasurements = true);
        _showSuccess(
          _languageService.getLocalizedText(
            _hasExistingMeasurements
                ? 'Measurements updated successfully!'
                : 'Measurements saved successfully!',
            _hasExistingMeasurements
                ? 'تم تحديث القياسات بنجاح!'
                : 'تم حفظ القياسات بنجاح!',
          ),
        );
        HapticFeedback.lightImpact();
      } else {
        _showError(
          result['error'] ??
              _languageService.getLocalizedText(
                'Failed to save measurements',
                'فشل في حفظ القياسات',
              ),
        );
      }
    } catch (e) {
      print('❌ Error saving measurements: $e');
      _showError(
        _languageService.getLocalizedText(
          'Error saving measurements',
          'خطأ في حفظ القياسات',
        ),
      );
    }
  }

  Future<void> _savePerformanceLogs() async {
    try {
      final List<Map<String, String>> validLogs = [];

      for (final log in _performanceLogs) {
        final eventName = log['event_name'].toString().trim();
        final resultTime = log['result_time'].toString().trim();

        if (eventName.isNotEmpty && resultTime.isNotEmpty) {
          validLogs.add({'event_name': eventName, 'result_time': resultTime});
        }
      }

      if (validLogs.isEmpty) {
        _showError(
          _languageService.getLocalizedText(
            'Please fill in at least one event with both Event Name and Result Time.',
            'يرجى ملء حدث واحد على الأقل مع اسم الحدث ووقت النتيجة.',
          ),
        );
        return;
      }

      final result = await ApiService.replaceAllPerformanceLogs(validLogs);

      if (result['success']) {
        final createdCount = result['created_count'] ?? validLogs.length;
        final deletedCount = result['deleted_count'] ?? 0;

        _showSuccess(
          _languageService.getLocalizedText(
            'Success! Saved $createdCount events (replaced $deletedCount old records)',
            'نجح! تم حفظ $createdCount أحداث (استبدال $deletedCount سجلات قديمة)',
          ),
        );
        HapticFeedback.lightImpact();

        await _loadPerformanceLogs();
      } else {
        _showError(
          result['error'] ??
              _languageService.getLocalizedText(
                'Failed to save performance logs',
                'فشل في حفظ سجلات الأداء',
              ),
        );
      }
    } catch (e) {
      print('❌ Error saving performance logs: $e');
      _showError(
        _languageService.getLocalizedText(
          'Error saving performance logs',
          'خطأ في حفظ سجلات الأداء',
        ),
      );
    }
  }

  void _addPerformanceLog() {
    print(
      '➕ Adding new performance log. Current count: ${_performanceLogs.length}',
    );
    setState(() {
      _performanceLogs.add(_createEmptyPerformanceLog());
    });
    print('➕ After adding: ${_performanceLogs.length} logs');
  }

  void _removePerformanceLog(int index) {
    final log = _performanceLogs[index];
    if (log['id'] == null &&
        _performanceLogs.where((l) => l['id'] == null).length > 1) {
      setState(() {
        _performanceLogs.removeAt(index);
      });
    }
  }

  Future<void> _refreshData() async {
    HapticFeedback.lightImpact();

    print('🔍 Before refresh - Current logs count: ${_performanceLogs.length}');
    print('🔍 Existing performance flag: $_hasExistingPerformance');

    await _loadAllData();

    print('🔍 After refresh - New logs count: ${_performanceLogs.length}');
    print('🔍 New existing performance flag: $_hasExistingPerformance');

    _showSuccess(
      _languageService.getLocalizedText(
        'Data refreshed successfully!',
        'تم تحديث البيانات بنجاح!',
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await _showConfirmDialog(
      _languageService.getLocalizedText('Logout', 'تسجيل الخروج'),
      _languageService.getLocalizedText(
        'Are you sure you want to logout?',
        'هل أنت متأكد من أنك تريد تسجيل الخروج؟',
      ),
    );

    if (confirmed) {
      await ApiService.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          (route) => false,
        );
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<bool> _showConfirmDialog(String title, String content) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text(title),
                content: Text(content),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      _languageService.getLocalizedText('Cancel', 'إلغاء'),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text(
                      _languageService.getLocalizedText('Confirm', 'تأكيد'),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF0F2F5),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.blue),
              const SizedBox(height: 16),
              Text(
                _languageService.getLocalizedText(
                  'Loading Profile...',
                  'تحميل الملف الشخصي...',
                ),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Directionality(
      textDirection: _languageService.textDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F2F5),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildProfileCard(),
                      const SizedBox(height: 16),
                      _buildInviteLinkCard(), // ✅ ADD: Invite link card
                      const SizedBox(height: 16),
                      _buildMeasurementsCard(),
                      const SizedBox(height: 16),
                      _buildPerformanceCard(),
                      const SizedBox(height: 16),
                      _buildActionButtons(),
                      const SizedBox(height: 32),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: Colors.blue[600],
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          _languageService.getLocalizedText('Profile', 'الملف الشخصي'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue[700]!, Colors.blue[500]!],
            ),
          ),
        ),
      ),
      actions: [
        // Language Toggle Button
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _languageService.isArabic ? Icons.language : Icons.translate,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  _languageService.isArabic ? 'EN' : 'عر',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            onPressed: _toggleLanguage,
            tooltip: _languageService.getLocalizedText(
              'Switch to Arabic',
              'التبديل إلى الإنجليزية',
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _refreshData,
          tooltip: _languageService.getLocalizedText('Refresh', 'تحديث'),
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: _logout,
          tooltip: _languageService.getLocalizedText('Logout', 'تسجيل الخروج'),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[400]!, Colors.blue[600]!],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              _profile?['name'] ??
                  _languageService.getLocalizedText('Athlete', 'لاعب'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _profile?['email'] ?? '',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _languageService.getLocalizedText('Athlete', 'لاعب'),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ ADD: Invite Link Card
  Widget _buildInviteLinkCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.share, color: Colors.purple[700]),
                ),
                const SizedBox(width: 12),
                Text(
                  _languageService.getLocalizedText(
                    'Invite Link',
                    'رابط الدعوة',
                  ),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _languageService.getLocalizedText(
                'Generate a secure link to let others login as you. Link expires in 24 hours.',
                'إنشاء رابط آمن للسماح للآخرين بتسجيل الدخول كما لو كانوا أنت. ينتهي الرابط خلال 24 ساعة.',
              ),
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _isGeneratingInvite ? null : _generateInviteLink,
                    icon:
                        _isGeneratingInvite
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Icon(
                              Icons.generating_tokens,
                              color: Colors.white,
                            ),
                    label: Text(
                      _languageService.getLocalizedText(
                        'Generate Link',
                        'إنشاء رابط',
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[600],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showInviteLinksDialog,
                    icon: const Icon(Icons.history),
                    label: Text(
                      _languageService.getLocalizedText('History', 'التاريخ'),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.purple[600],
                      side: BorderSide(color: Colors.purple[600]!),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            if (_currentInviteLink != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _languageService.getLocalizedText(
                        'Your Invite Link:',
                        'رابط الدعوة الخاص بك:',
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _currentInviteLink!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 20),
                          onPressed: _shareInviteLink,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.purple[100],
                            foregroundColor: Colors.purple[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementsCard() {
    final measurementLabels = {
      'height': _languageService.getLocalizedText(
        '📏 Height (cm)',
        '📏 الطول (سم)',
      ),
      'weight': _languageService.getLocalizedText(
        '⚖️ Weight (kg)',
        '⚖️ الوزن (كجم)',
      ),
      'arm': _languageService.getLocalizedText(
        '💪 Arm Length (cm)',
        '💪 طول الذراع (سم)',
      ),
      'leg': _languageService.getLocalizedText(
        '🦵 Leg Length (cm)',
        '🦵 طول الساق (سم)',
      ),
      'fat': _languageService.getLocalizedText(
        '📊 Body Fat (%)',
        '📊 دهون الجسم (%)',
      ),
      'muscle': _languageService.getLocalizedText(
        '💪 Muscle Mass (%)',
        '💪 كتلة العضلات (%)',
      ),
    };

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.straighten, color: Colors.orange[700]),
                ),
                const SizedBox(width: 12),
                Text(
                  _languageService.getLocalizedText(
                    'Body Measurements',
                    'قياسات الجسم',
                  ),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...measurementLabels.entries.map(
              (entry) => _buildMeasurementInput(entry.key, entry.value),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveMeasurements,
                icon: const Icon(Icons.save, color: Colors.white),
                label: Text(
                  _languageService.getLocalizedText(
                    _hasExistingMeasurements
                        ? 'Update Measurements'
                        : 'Save Measurements',
                    _hasExistingMeasurements
                        ? 'تحديث القياسات'
                        : 'حفظ القياسات',
                  ),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[600],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementInput(String key, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: _measurements[key],
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textDirection: TextDirection.ltr, // Numbers are always LTR
            decoration: InputDecoration(
              hintText: '0.0',
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.orange[600]!, width: 2),
              ),
            ),
            onChanged: (value) {
              _measurements[key] = value;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.timer, color: Colors.green[700]),
                ),
                const SizedBox(width: 12),
                Text(
                  _languageService.getLocalizedText(
                    'Performance Logs',
                    'سجلات الأداء',
                  ),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_hasExistingPerformance)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _languageService.getLocalizedText(
                    '${_performanceLogs.where((log) => log['id'] != null).length} saved records',
                    '${_performanceLogs.where((log) => log['id'] != null).length} سجلات محفوظة',
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            ..._performanceLogs.asMap().entries.map(
              (entry) => _buildPerformanceLogInput(entry.key, entry.value),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _addPerformanceLog,
                    icon: const Icon(Icons.add),
                    label: Text(
                      _languageService.getLocalizedText(
                        'Add New Event',
                        'إضافة حدث جديد',
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green[600],
                      side: BorderSide(color: Colors.green[600]!),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _savePerformanceLogs,
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: Text(
                      _languageService.getLocalizedText(
                        'Save All Events',
                        'حفظ جميع الأحداث',
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceLogInput(int index, Map<String, dynamic> log) {
    final isExistingRecord = log['id'] != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isExistingRecord ? Colors.blue[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isExistingRecord ? Colors.blue[200]! : Colors.green[200]!,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _languageService.getLocalizedText(
                        isExistingRecord ? 'Event ${index + 1}' : 'New Event',
                        isExistingRecord ? 'حدث ${index + 1}' : 'حدث جديد',
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color:
                            isExistingRecord
                                ? Colors.blue[700]
                                : Colors.green[700],
                      ),
                    ),
                    if (isExistingRecord && log['created_at'] != null)
                      Text(
                        _languageService.getLocalizedText(
                          'Saved: ${log['created_at'].toString().split('T')[0]}',
                          'محفوظ: ${log['created_at'].toString().split('T')[0]}',
                        ),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
              if (isExistingRecord)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _languageService.getLocalizedText('SAVED', 'محفوظ'),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              if (!isExistingRecord &&
                  _performanceLogs.where((log) => log['id'] == null).length > 1)
                IconButton(
                  onPressed: () => _removePerformanceLog(index),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  iconSize: 20,
                  tooltip: _languageService.getLocalizedText(
                    'Remove this empty event',
                    'إزالة هذا الحدث الفارغ',
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: log['event_name'],
            decoration: InputDecoration(
              labelText: _languageService.getLocalizedText(
                'Event Name',
                'اسم الحدث',
              ),
              hintText: _languageService.getLocalizedText(
                'e.g., 100m Freestyle',
                'مثل: سباحة حرة 100م',
              ),
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              _performanceLogs[index]['event_name'] = value;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: log['result_time']?.toString() ?? '',
            textDirection: TextDirection.ltr, // Times are always LTR
            decoration: InputDecoration(
              labelText: _languageService.getLocalizedText(
                'Result Time',
                'وقت النتيجة',
              ),
              hintText: _languageService.getLocalizedText(
                'e.g., 1:23.45 or 83.45',
                'مثل: 1:23.45 أو 83.45',
              ),
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              _performanceLogs[index]['result_time'] = value;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              _showError(
                _languageService.getLocalizedText(
                  'Settings feature coming soon!',
                  'ميزة الإعدادات قريباً!',
                ),
              );
            },
            icon: const Icon(Icons.settings),
            label: Text(
              _languageService.getLocalizedText('Settings', 'الإعدادات'),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordScreen(),
                ),
              );
            },
            icon: const Icon(Icons.lock),
            label: Text(
              _languageService.getLocalizedText(
                'Change Password',
                'تغيير كلمة المرور',
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
