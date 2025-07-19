import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../services/api_service.dart';

class AthleteHomeScreen extends StatefulWidget {
  const AthleteHomeScreen({super.key});

  @override
  State<AthleteHomeScreen> createState() => _AthleteHomeScreenState();
}

class _AthleteHomeScreenState extends State<AthleteHomeScreen> {
  // User data
  String? userId;
  String? token;
  int? athleteId;

  // Current selected month for calendar
  DateTime _currentMonth = DateTime.now();

  // Attendance data for current month
  Map<String, Map<String, dynamic>> _attendanceData = {};
  bool _isLoadingAttendance = false;

  // Payment data for current month
  String? _paymentStatus;
  bool _isLoadingPayment = false;

  // Overall loading state
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    setState(() => _isInitializing = true);

    await _getUserData();
    await _getAthleteId();
    await _loadCurrentMonthData();

    setState(() => _isInitializing = false);
  }

  Future<void> _getUserData() async {
    userId = await ApiService.getUserId();
    token = await ApiService.storage.read(key: 'auth_token');
    print(
      '✅ User data - ID: $userId, Token: ${token != null ? 'Available' : 'Missing'}',
    );
  }

  Future<void> _getAthleteId() async {
    try {
      final result = await ApiService.getAthleteIdFromUserId();
      if (result['success'] && result['data'] != null) {
        athleteId = result['data']['athlete_id'];
        print('✅ Athlete ID loaded: $athleteId');
      } else {
        print('❌ Failed to get athlete ID: ${result['error']}');
      }
    } catch (e) {
      print('❌ Error getting athlete ID: $e');
    }
  }

  Future<void> _loadCurrentMonthData() async {
    await Future.wait([_loadMonthlyAttendance(), _loadPaymentStatus()]);
  }

  Future<void> _loadMonthlyAttendance() async {
    if (athleteId == null) {
      print('❌ No athlete ID available for attendance');
      return;
    }

    setState(() => _isLoadingAttendance = true);
    try {
      final result = await ApiService.getAthleteMonthlyAttendance(
        athleteId!,
        _currentMonth.year,
        _currentMonth.month,
      );

      if (result['success']) {
        setState(() {
          _attendanceData = _parseAttendanceData(result['data']);
        });
        print('✅ Monthly attendance loaded: ${_attendanceData.length} records');
      } else {
        print('❌ Monthly attendance failed: ${result['error']}');
        setState(() => _attendanceData = {});
      }
    } catch (e) {
      print('❌ Error loading monthly attendance: $e');
      setState(() => _attendanceData = {});
    } finally {
      setState(() => _isLoadingAttendance = false);
    }
  }

  Future<void> _loadPaymentStatus() async {
    if (userId == null) {
      print('❌ No user ID available for payment');
      return;
    }

    setState(() => _isLoadingPayment = true);
    try {
      print('🔄 Loading payment status for user ID: $userId');

      final result = await ApiService.getPayments();
      print('🔄 Payment API result: $result');

      if (result['success']) {
        final payData = result['data'];
        print('🔄 Payment data received: $payData');
        print('🔄 Payment data type: ${payData.runtimeType}');

        if (payData is Map<String, dynamic>) {
          final currentDueKey = _getCurrentDueKey();
          print('🔄 Looking for due key: $currentDueKey');
          print('🔄 Available keys in payment data: ${payData.keys.toList()}');

          final status = payData[currentDueKey];
          print('🔄 Found status for $currentDueKey: $status');

          setState(() {
            _paymentStatus = status?.toString() ?? 'pending';
          });
          print('✅ Payment status set to: $_paymentStatus');
        } else {
          print('❌ Unexpected payment data format: ${payData.runtimeType}');
          setState(() => _paymentStatus = 'pending');
        }
      } else {
        print('❌ Payment API failed: ${result['error']}');
        setState(() => _paymentStatus = 'pending');
      }
    } catch (e) {
      print('❌ Exception loading payment status: $e');
      setState(() => _paymentStatus = 'pending');
    } finally {
      setState(() => _isLoadingPayment = false);
    }
  }

  Map<String, Map<String, dynamic>> _parseAttendanceData(dynamic data) {
    Map<String, Map<String, dynamic>> parsed = {};
    if (data is Map && data['attendance'] is List) {
      final attendanceList = data['attendance'] as List;
      for (var record in attendanceList) {
        if (record is Map && record['session_date'] != null) {
          parsed[record['session_date']] = {
            'status': record['status'],
            'notes': record['notes'],
            'gear_missing': record['notes']?.toString().isNotEmpty ?? false,
          };
        }
      }
    }
    return parsed;
  }

  String _getCurrentDueKey() {
    final now = DateTime.now();
    final dueKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-01';
    print('🔄 Current due key generated: $dueKey');
    return dueKey;
  }

  String _getCurrentMonthName(AppLocalizations l10n) {
    return '${_getMonthName(_currentMonth.month, l10n)} ${_currentMonth.year}';
  }

  String _getMonthName(int month, AppLocalizations l10n) {
    switch (month) {
      case 1:
        return l10n.january;
      case 2:
        return l10n.february;
      case 3:
        return l10n.march;
      case 4:
        return l10n.april;
      case 5:
        return l10n.may;
      case 6:
        return l10n.june;
      case 7:
        return l10n.july;
      case 8:
        return l10n.august;
      case 9:
        return l10n.september;
      case 10:
        return l10n.october;
      case 11:
        return l10n.november;
      case 12:
        return l10n.december;
      default:
        return l10n.unknown;
    }
  }

  Color _getDayColor(DateTime day) {
    final dateStr =
        '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    final attendance = _attendanceData[dateStr];

    if (attendance == null) return Colors.grey[200]!;
    final status = attendance['status']?.toString() ?? '';
    final gearMissing = attendance['gear_missing'] == true;

    if (status == 'present' && !gearMissing) {
      return const Color(0xFF4CAF50); // Green - present with gear
    } else if (status == 'present' && gearMissing) {
      return const Color(0xFFFF9800); // Orange - present without gear
    } else if (status == 'absent') {
      return const Color(0xFFF44336); // Red - absent
    }
    return Colors.grey[200]!;
  }

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  void _changeMonth(int direction) {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + direction,
      );
    });
    _loadMonthlyAttendance();
  }

  String _getPaymentIcon(String? status) {
    switch (status) {
      case 'paid':
        return '✅';
      case 'late':
        return '⚠️';
      case 'pending':
        return '⏳';
      case 'error':
        return '❓';
      default:
        return '❌';
    }
  }

  String _getPaymentLabel(String? status, AppLocalizations l10n) {
    switch (status) {
      case 'paid':
        return l10n.paid;
      case 'late':
        return l10n.latePayment;
      case 'pending':
        return l10n.pending;
      case 'error':
        return l10n.error;
      default:
        return l10n.unknown;
    }
  }

  Color _getPaymentColor(String? status) {
    switch (status) {
      case 'paid':
        return const Color(0xFF4CAF50);
      case 'late':
        return const Color(0xFFFF9800);
      case 'pending':
        return const Color(0xFF2196F3);
      case 'error':
        return const Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isInitializing) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.loadingDashboard,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1976D2),
        title: Text(
          l10n.myDashboard,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadCurrentMonthData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadCurrentMonthData,
        color: const Color(0xFF1976D2),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1976D2).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.welcomeBack,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.todayIs(
                        DateTime.now().day.toString(),
                        _getMonthName(DateTime.now().month, l10n),
                        DateTime.now().year.toString(),
                      ),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Payment Status Widget
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getPaymentColor(
                              _paymentStatus,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.payment,
                            color: _getPaymentColor(_paymentStatus),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.paymentStatus,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getCurrentMonthName(l10n),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF666666),
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (_isLoadingPayment)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            else
                              Row(
                                children: [
                                  Text(
                                    _getPaymentIcon(_paymentStatus),
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _getPaymentLabel(_paymentStatus, l10n),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: _getPaymentColor(_paymentStatus),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        // Debug info (can be removed in production)
                        if (_paymentStatus != null)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${l10n.user}: $userId',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  '${l10n.key}: ${_getCurrentDueKey()}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Monthly Attendance Calendar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Calendar Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1976D2).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.calendar_month,
                            color: Color(0xFF1976D2),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.monthlyAttendance,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const Spacer(),
                        // Attendance debug info
                        if (athleteId != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${l10n.athleteId(athleteId.toString())}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Month Navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => _changeMonth(-1),
                          icon: const Icon(Icons.chevron_left),
                          iconSize: 28,
                          color: const Color(0xFF1976D2),
                        ),
                        Text(
                          _getCurrentMonthName(l10n),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _changeMonth(1),
                          icon: const Icon(Icons.chevron_right),
                          iconSize: 28,
                          color: const Color(0xFF1976D2),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Legend
                    Wrap(
                      alignment: WrapAlignment.spaceEvenly,
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        _buildLegendItem(
                          const Color(0xFF4CAF50),
                          l10n.present,
                          l10n,
                        ),
                        _buildLegendItem(
                          const Color(0xFFFF9800),
                          l10n.noGear,
                          l10n,
                        ),
                        _buildLegendItem(
                          const Color(0xFFF44336),
                          l10n.absent,
                          l10n,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Days of week headers
                    Row(
                      children:
                          l10n.daysOfWeekShort
                              .split(',')
                              .map(
                                (day) => Expanded(
                                  child: Center(
                                    child: Text(
                                      day,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF666666),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),

                    const SizedBox(height: 12),

                    // Calendar grid
                    if (_isLoadingAttendance)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      _buildCalendarGrid(l10n),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, AppLocalizations l10n) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF666666),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid(AppLocalizations l10n) {
    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    );
    final startDate = firstDayOfMonth.subtract(
      Duration(days: firstDayOfMonth.weekday % 7),
    );

    List<Widget> dayWidgets = [];

    // Build 6 weeks (42 days) to ensure we show the full month
    for (int i = 0; i < 42; i++) {
      final date = startDate.add(Duration(days: i));
      final isCurrentMonth = date.month == _currentMonth.month;
      final isToday = _isToday(date);

      dayWidgets.add(
        GestureDetector(
          onTap: isCurrentMonth ? () => _showDayDetails(date, l10n) : null,
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isCurrentMonth ? _getDayColor(date) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border:
                  isToday
                      ? Border.all(color: const Color(0xFF1976D2), width: 2)
                      : null,
            ),
            child: Center(
              child: Text(
                '${date.day}',
                style: TextStyle(
                  color:
                      isCurrentMonth
                          ? (isToday ? const Color(0xFF1976D2) : Colors.white)
                          : Colors.grey[400],
                  fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      children: dayWidgets,
    );
  }

  void _showDayDetails(DateTime date, AppLocalizations l10n) {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final attendance = _attendanceData[dateStr];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              '${date.day} ${_getMonthName(date.month, l10n)} ${date.year}',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (attendance != null) ...[
                  Row(
                    children: [
                      Icon(
                        attendance['status'] == 'present'
                            ? Icons.check_circle
                            : Icons.cancel,
                        color:
                            attendance['status'] == 'present'
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFF44336),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        attendance['status'] == 'present'
                            ? l10n.present
                            : l10n.absent,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  if (attendance['notes'] != null &&
                      attendance['notes'].toString().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      l10n.notes,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(attendance['notes'].toString()),
                  ],
                ] else ...[
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(l10n.noTrainingSession),
                    ],
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.close),
              ),
            ],
          ),
    );
  }
}
