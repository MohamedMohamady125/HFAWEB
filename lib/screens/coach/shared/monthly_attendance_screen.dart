import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../services/api_service.dart';
import 'athlete_monthly_calendar_screen.dart';

class MonthlyAttendanceScreen extends StatefulWidget {
  const MonthlyAttendanceScreen({super.key});

  @override
  State<MonthlyAttendanceScreen> createState() =>
      _MonthlyAttendanceScreenState();
}

class _MonthlyAttendanceScreenState extends State<MonthlyAttendanceScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _athletes = [];
  Map<int, Map<String, dynamic>> _attendanceData = {};
  bool _isLoading = true;
  bool _isLoadingAttendance = false;
  String _searchQuery = '';
  String? _error;

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadAthletes();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
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
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
  }

  Future<void> _loadAthletes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await ApiService.getAllAthletes();

      if (result['success']) {
        final athletes = List<Map<String, dynamic>>.from(result['data']);

        // Debug logging
        print('🔍 DEBUG: Loaded ${athletes.length} athletes');
        if (athletes.isNotEmpty) {
          print('🔍 DEBUG: First athlete structure: ${athletes[0]}');
          print('🔍 DEBUG: Available keys: ${athletes[0].keys.toList()}');
        }

        setState(() {
          _athletes = athletes;
          _isLoadingAttendance = true;
        });
        await _loadAttendanceData();
        _fadeController.forward();
        _slideController.forward();
      } else {
        setState(() {
          _error = AppLocalizations.of(
            context,
          )!.failedToLoadAthletes(result['error'] ?? '');
        });
      }
    } catch (e) {
      setState(() {
        _error = AppLocalizations.of(context)!.failedToLoadAthletesGeneral;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAttendanceData() async {
    final currentDate = DateTime.now();
    final currentYear = currentDate.year;
    final currentMonth = currentDate.month;

    for (final athlete in _athletes) {
      // Get all possible ID fields for debugging
      final athleteId = athlete['athlete_id'];
      final userId = athlete['user_id'];
      final id = athlete['id'];

      print('🔍 DEBUG: Processing athlete: ${athlete['name']}');
      print('🔍 DEBUG: athlete_id: $athleteId, user_id: $userId, id: $id');
      print('🔍 DEBUG: Full athlete data: $athlete');

      // Now we have the correct athlete_id from the backend
      final targetId = athleteId; // Use athlete_id directly

      if (targetId != null) {
        try {
          print('🔍 DEBUG: Calling API with ID: $targetId');

          var attendanceResult = await ApiService.getAthleteMonthlyAttendance(
            targetId,
            currentYear,
            currentMonth,
          );

          print(
            '🔍 DEBUG: API call result for athlete $targetId: ${attendanceResult['success']}',
          );
          print('🔍 DEBUG: API response: ${attendanceResult['data']}');

          // If current month has no data and it's not January, try previous month
          if (attendanceResult['success'] &&
              attendanceResult['data'] != null &&
              (attendanceResult['data']['attendance'] as List).isEmpty &&
              currentMonth > 1) {
            print('🔍 DEBUG: No data for current month, trying previous month');
            attendanceResult = await ApiService.getAthleteMonthlyAttendance(
              targetId,
              currentYear,
              currentMonth - 1,
            );
            print(
              '🔍 DEBUG: Previous month result: ${attendanceResult['data']}',
            );
          }

          if (attendanceResult['success'] && attendanceResult['data'] != null) {
            // Use the same ID that was used for the API call
            _attendanceData[targetId] = attendanceResult['data'];
            print('🔍 DEBUG: Successfully stored attendance for ID $targetId');
            print(
              '🔍 DEBUG: Attendance records count: ${(attendanceResult['data']['attendance'] as List).length}',
            );
          } else {
            print(
              '🔍 DEBUG: Failed to load attendance for ID $targetId: ${attendanceResult['error']}',
            );
          }
        } catch (e) {
          print('🔍 DEBUG: Exception for athlete ID $targetId: $e');
          // Don't call _showError here as it causes inherited widget issues
        }
      } else {
        print('🔍 DEBUG: No valid ID found for athlete: ${athlete['name']}');
      }
    }

    if (mounted) {
      setState(() {
        _isLoadingAttendance = false;
      });
    }
  }

  void _navigateToAthleteCalendar(Map<String, dynamic> athlete) {
    HapticFeedback.lightImpact();
    final athleteWithAttendance = Map<String, dynamic>.from(athlete);
    final targetId = athlete['athlete_id']; // Use athlete_id directly

    // Ensure required fields exist
    athleteWithAttendance['id'] = targetId; // Add id field for compatibility

    if (targetId != null && _attendanceData.containsKey(targetId)) {
      athleteWithAttendance['monthlyAttendance'] = _attendanceData[targetId];
    }

    print('🔍 DEBUG: Navigating with athlete data: $athleteWithAttendance');

    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) =>
                AthleteMonthlyCalendarScreen(athlete: athleteWithAttendance),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredAthletes {
    if (_searchQuery.isEmpty) return _athletes;

    return _athletes.where((athlete) {
      final name = athlete['name']?.toString().toLowerCase() ?? '';
      final email = athlete['email']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  String _getAttendanceRate(Map<String, dynamic> athlete) {
    final targetId = athlete['athlete_id']; // Use athlete_id directly
    if (targetId == null || !_attendanceData.containsKey(targetId)) {
      return '0%';
    }

    final attendanceInfo = _attendanceData[targetId]!;
    final attendanceList = List<Map<String, dynamic>>.from(
      attendanceInfo['attendance'] ?? [],
    );

    if (attendanceList.isEmpty) return '0%';

    final totalSessions = attendanceList.length;
    final attendedSessions =
        attendanceList.where((record) => record['status'] == 'present').length;
    final rate = (attendedSessions / totalSessions * 100).round();

    return '$rate%';
  }

  Map<String, int> _getAttendanceStats(Map<String, dynamic> athlete) {
    final targetId = athlete['athlete_id']; // Use athlete_id directly
    if (targetId == null || !_attendanceData.containsKey(targetId)) {
      return {'present': 0, 'absent': 0, 'total': 0};
    }

    final attendanceInfo = _attendanceData[targetId]!;
    final attendanceList = List<Map<String, dynamic>>.from(
      attendanceInfo['attendance'] ?? [],
    );

    final presentCount =
        attendanceList.where((record) => record['status'] == 'present').length;
    final absentCount =
        attendanceList.where((record) => record['status'] == 'absent').length;

    return {
      'present': presentCount,
      'absent': absentCount,
      'total': attendanceList.length,
    };
  }

  Color _getAttendanceColor(String rate) {
    final percentage = int.tryParse(rate.replaceAll('%', '')) ?? 0;
    if (percentage >= 90) return const Color(0xFF007AFF);
    if (percentage >= 75) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text(
          l10n.monthlyAttendance,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF007AFF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadAthletes,
            tooltip: l10n.refresh,
          ),
        ],
      ),
      body: _buildBody(l10n),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFF007AFF)),
            const SizedBox(height: 16),
            Text(l10n.loadingAthletes, style: const TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF007AFF).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: const Color(0xFF007AFF),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.errorLoadingAthletes,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadAthletes,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: _buildContent(l10n),
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n) {
    if (_athletes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF007AFF).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.group_outlined,
                size: 64,
                color: const Color(0xFF007AFF),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noAthletesFound,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noAthletesRegistered,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadAthletes,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.refresh),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final filteredAthletes = _filteredAthletes;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF007AFF), Color(0xFF0066CC)],
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_month,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.monthlyAttendanceOverview,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          l10n.athletesInBranch(filteredAthletes.length),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: l10n.searchAthletes,
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredAthletes.length,
            itemBuilder: (context, index) {
              final athlete = filteredAthletes[index];
              return _buildAthleteCard(athlete, index, l10n);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAthleteCard(
    Map<String, dynamic> athlete,
    int index,
    AppLocalizations l10n,
  ) {
    final attendanceRate = _getAttendanceRate(athlete);
    final attendanceColor = _getAttendanceColor(attendanceRate);
    final attendanceStats = _getAttendanceStats(athlete);
    final targetId = athlete['athlete_id'];
    final athleteName = athlete['name'] ?? l10n.unknown;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToAthleteCalendar(athlete),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar - Fixed size
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF007AFF), Color(0xFF0066CC)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      athleteName.isNotEmpty
                          ? athleteName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Content - Flexible to take remaining space
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name - with overflow handling
                      Text(
                        athleteName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),

                      // Email - with overflow handling
                      Text(
                        athlete['email'] ?? l10n.noEmail,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 8),

                      // Tags - using Constrained Wrap to prevent overflow
                      SizedBox(
                        width: double.infinity,
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: [
                            // Attendance rate tag
                            _buildStatTag(
                              icon: Icons.percent,
                              text: attendanceRate,
                              color: attendanceColor,
                            ),

                            // Present count tag
                            if (attendanceStats['present']! > 0)
                              _buildStatTag(
                                icon: Icons.check,
                                text: '${attendanceStats['present']}',
                                color: const Color(0xFF007AFF),
                              ),

                            // Absent count tag
                            if (attendanceStats['absent']! > 0)
                              _buildStatTag(
                                icon: Icons.close,
                                text: '${attendanceStats['absent']}',
                                color: Colors.red,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Calendar icon - Fixed size
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.calendar_view_month,
                    color: const Color(0xFF007AFF),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build stat tags consistently
  Widget _buildStatTag({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
