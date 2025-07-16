import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../services/api_service.dart';

class AthleteMonthlyCalendarScreen extends StatefulWidget {
  final Map<String, dynamic> athlete;

  const AthleteMonthlyCalendarScreen({super.key, required this.athlete});

  @override
  State<AthleteMonthlyCalendarScreen> createState() =>
      _AthleteMonthlyCalendarScreenState();
}

class _AthleteMonthlyCalendarScreenState
    extends State<AthleteMonthlyCalendarScreen> {
  late PageController _pageController;
  late DateTime _currentMonth;
  Map<String, Map<String, dynamic>> _attendanceData = {};
  Map<String, List<String>> _missedGearData = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _pageController = PageController(initialPage: 1000); // infinite scroll
    _loadAttendanceData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadAttendanceData() async {
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.getAthleteMonthlyAttendance(
        widget.athlete['athlete_id'],
        _currentMonth.year,
        _currentMonth.month,
      );
      if (result['success']) {
        setState(() {
          _attendanceData = _parseAttendanceData(result['data']);
          _missedGearData = _parseMissedGearData(result['data']);
        });
      } else {
        debugPrint('❌ Failed to load attendance data: ${result['error']}');
      }
    } catch (e) {
      debugPrint('❌ Error loading attendance: $e');
    } finally {
      setState(() => _isLoading = false);
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
            'gear_missing': false, // Adapt if your API provides this
          };
        }
      }
    }
    return parsed;
  }

  Map<String, List<String>> _parseMissedGearData(dynamic data) {
    Map<String, List<String>> parsed = {};
    if (data is Map && data['attendance'] is List) {
      final attendanceList = data['attendance'] as List;
      for (var record in attendanceList) {
        if (record is Map && record['session_date'] != null) {
          final notes = record['notes']?.toString() ?? '';
          if (notes.isNotEmpty) {
            final gearItems =
                notes
                    .split(RegExp(r'[,\n;]'))
                    .map((item) => item.trim())
                    .where((item) => item.isNotEmpty)
                    .toList();
            if (gearItems.isNotEmpty) {
              parsed[record['session_date']] = gearItems;
            }
          }
        }
      }
    }
    return parsed;
  }

  Color _getDayColor(DateTime day) {
    final dateStr =
        '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    final attendance = _attendanceData[dateStr];

    if (attendance == null) return Colors.grey[300]!;
    final status = attendance['status']?.toString() ?? '';
    final gearMissing = attendance['gear_missing'] == true;

    if (status == 'present' && !gearMissing) {
      return const Color(0xFF007AFF);
    } else if (status == 'present' && gearMissing) {
      return Colors.orange;
    } else if (status == 'absent') {
      return Colors.red;
    }
    return Colors.grey[300]!;
  }

  void _onPageChanged(int index) {
    final monthOffset = index - 1000;
    final newMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + monthOffset,
    );
    if (newMonth.year != _currentMonth.year ||
        newMonth.month != _currentMonth.month) {
      setState(() {
        _currentMonth = newMonth;
      });
      _loadAttendanceData();
    }
  }

  String _getMonthAttendanceRate() {
    if (_attendanceData.isEmpty) return '0%';
    final totalDays = _attendanceData.length;
    final presentDays =
        _attendanceData.values
            .where((data) => data['status'] == 'present')
            .length;
    if (totalDays == 0) return '0%';
    return '${((presentDays / totalDays) * 100).round()}%';
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.athlete['name'] ?? loc.athlete,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            Text(
              loc.monthlyAttendance,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF007AFF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Month Navigation Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF007AFF), Color(0xFF0066CC)],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: const Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                Text(
                  '${_getMonthName(_currentMonth.month, context)} ${_currentMonth.year}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildCalendar(context),
                      const SizedBox(height: 24),
                      _buildMonthlyStats(context),
                      const SizedBox(height: 24),
                      _buildMissedGearWidget(context),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final daysOfWeek = loc.daysOfWeek.split(',');

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildLegendItem(const Color(0xFF007AFF), loc.presentWithGear),
                _buildLegendItem(Colors.orange, loc.presentWithoutGear),
                _buildLegendItem(Colors.red, loc.absent),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children:
                  daysOfWeek
                      .map(
                        (day) => Expanded(
                          child: Center(
                            child: Text(
                              day,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 12),
            _buildCalendarGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
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
    for (int i = 0; i < 42; i++) {
      final date = startDate.add(Duration(days: i));
      final isCurrentMonth = date.month == _currentMonth.month;
      final isToday = _isToday(date);

      dayWidgets.add(
        GestureDetector(
          onTap: isCurrentMonth ? () => _showDayDetails(date, context) : null,
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isCurrentMonth ? _getDayColor(date) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border:
                  isToday
                      ? Border.all(color: const Color(0xFF007AFF), width: 2)
                      : null,
            ),
            child: Center(
              child: Text(
                '${date.day}',
                style: TextStyle(
                  color:
                      isCurrentMonth
                          ? (isToday ? const Color(0xFF007AFF) : Colors.white)
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

  Widget _buildMonthlyStats(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final attendanceRate = _getMonthAttendanceRate();
    final rateColor = _getAttendanceColor(attendanceRate);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: const Color(0xFF007AFF), size: 24),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    loc.monthlyStatistics,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    loc.attendanceRate,
                    attendanceRate,
                    Icons.percent,
                    rateColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    loc.daysPresent,
                    '${_attendanceData.values.where((data) => data['status'] == 'present').length}',
                    Icons.check_circle,
                    const Color(0xFF007AFF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    loc.daysAbsent,
                    '${_attendanceData.values.where((data) => data['status'] == 'absent').length}',
                    Icons.cancel,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    loc.gearIssues,
                    '${_attendanceData.values.where((data) => data['gear_missing'] == true).length}',
                    Icons.warning,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMissedGearWidget(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final missedGearDays =
        _missedGearData.entries
            .where((entry) => entry.value.isNotEmpty)
            .toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange[600], size: 24),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    loc.missedGearDetails,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (missedGearDays.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF007AFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: const Color(0xFF007AFF),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        loc.perfectNoGearMissed,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: missedGearDays.length,
                itemBuilder: (context, index) {
                  final entry = missedGearDays[index];
                  final date = DateTime.tryParse(entry.key) ?? DateTime.now();
                  final missedItems = entry.value;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.calendar_today,
                            color: Colors.orange[600],
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${date.day}/${date.month}/${date.year}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 4,
                                children:
                                    missedItems
                                        .map(
                                          (item) => Chip(
                                            label: Text(
                                              item,
                                              style: const TextStyle(
                                                fontSize: 11,
                                              ),
                                            ),
                                            backgroundColor: Colors.orange[100],
                                            side: BorderSide(
                                              color: Colors.orange[300]!,
                                            ),
                                            padding: EdgeInsets.zero,
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                          ),
                                        )
                                        .toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  String _getMonthName(int month, BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    switch (month) {
      case 1:
        return loc.january;
      case 2:
        return loc.february;
      case 3:
        return loc.march;
      case 4:
        return loc.april;
      case 5:
        return loc.may;
      case 6:
        return loc.june;
      case 7:
        return loc.july;
      case 8:
        return loc.august;
      case 9:
        return loc.september;
      case 10:
        return loc.october;
      case 11:
        return loc.november;
      case 12:
        return loc.december;
      default:
        return '';
    }
  }

  Color _getAttendanceColor(String rate) {
    final percentage = int.tryParse(rate.replaceAll('%', '')) ?? 0;
    if (percentage >= 90) return const Color(0xFF007AFF);
    if (percentage >= 75) return Colors.orange;
    return Colors.red;
  }

  void _showDayDetails(DateTime date, BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final attendance = _attendanceData[dateStr];
    final missedGear = _missedGearData[dateStr] ?? [];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text('${date.day}/${date.month}/${date.year}'),
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
                                ? const Color(0xFF007AFF)
                                : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        attendance['status'] == 'present'
                            ? loc.presentWithGear
                            : loc.absent,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  if (attendance['notes'] != null &&
                      attendance['notes'].toString().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      loc.notes,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(attendance['notes'].toString()),
                  ],
                  if (missedGear.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      "Missed Gear:", // Use the literal string temporarily
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      children:
                          missedGear
                              .map(
                                (item) => Chip(
                                  label: Text(
                                    item,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  backgroundColor: Colors.orange[100],
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ] else ...[
                  Text(loc.noAttendanceDataForDay),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(loc.close),
              ),
            ],
          ),
    );
  }
}
