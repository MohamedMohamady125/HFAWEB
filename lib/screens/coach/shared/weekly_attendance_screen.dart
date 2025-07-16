import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../services/api_service.dart';

class WeeklyAttendanceScreen extends StatefulWidget {
  const WeeklyAttendanceScreen({super.key});

  @override
  State<WeeklyAttendanceScreen> createState() => _WeeklyAttendanceScreenState();
}

class _WeeklyAttendanceScreenState extends State<WeeklyAttendanceScreen>
    with TickerProviderStateMixin {
  int _selectedDay = 0;
  List<Map<String, dynamic>> _attendance = [];
  List<String> _sessionDates = [];
  int? _branchId;
  bool _isLoading = true;
  String? _error;

  bool _isGearModalVisible = false;
  int? _currentAthleteId;
  String? _missedGearAnswer;
  String _missedGearNotes = '';
  final TextEditingController _gearNotesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfileAndSessionDates();
  }

  @override
  void dispose() {
    _gearNotesController.dispose();
    super.dispose();
  }

  List<String> get _days {
    final l10n = AppLocalizations.of(context)!;
    return [l10n.day1, l10n.day2, l10n.day3];
  }

  Future<void> _loadUserProfileAndSessionDates() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final profileResult = await ApiService.getUserProfile();
      if (!profileResult['success']) {
        _showError(
          AppLocalizations.of(
            context,
          )!.failedToGetUserProfile(profileResult['error'] ?? ''),
        );
        return;
      }

      final branchId = profileResult['data']['branch_id'];
      if (branchId == null) {
        _showError(AppLocalizations.of(context)!.branchIdNotFound);
        return;
      }

      setState(() {
        _branchId = branchId;
      });

      await _loadSessionDates();
    } catch (e) {
      _showError(AppLocalizations.of(context)!.failedToLoadUserProfile);
    }
  }

  Future<void> _loadSessionDates() async {
    if (_branchId == null) return;
    final l10n = AppLocalizations.of(context)!;

    try {
      final result = await ApiService.getBranchSessionDates(_branchId!);

      if (result['success']) {
        setState(() {
          _sessionDates = List<String>.from(result['data'] ?? []);
        });

        if (_sessionDates.isNotEmpty) {
          _loadAttendance();
        } else {
          setState(() {
            _isLoading = false;
            _error = l10n.noSessionDatesConfigured;
          });
        }
      } else {
        _showError(l10n.failedToLoadSessionDates(result['error'] ?? ''));
      }
    } catch (e) {
      _showError(AppLocalizations.of(context)!.failedToLoadSessionDatesGeneral);
    }
  }

  String _getDateForSelectedDay() {
    if (_selectedDay < _sessionDates.length) {
      return _sessionDates[_selectedDay];
    }
    return '';
  }

  Future<void> _loadAttendance() async {
    if (_branchId == null) return;
    final l10n = AppLocalizations.of(context)!;

    setState(() => _isLoading = true);

    try {
      final date = _getDateForSelectedDay();
      if (date.isEmpty) {
        _showError(l10n.sessionDateNotAvailable);
        return;
      }

      final result = await ApiService.getBranchDayAttendance(_branchId!, date);

      if (result['success']) {
        setState(() {
          _attendance = List<Map<String, dynamic>>.from(result['data'] ?? []);
          _error = null;
        });
      } else {
        _showError(l10n.failedToLoadAttendance(result['error'] ?? ''));
      }
    } catch (e) {
      _showError(l10n.failedToLoadAttendanceGeneral);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    setState(() {
      _error = message;
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _onPressPresent(int athleteId) {
    setState(() {
      _currentAthleteId = athleteId;
      _missedGearAnswer = null;
      _missedGearNotes = '';
      _gearNotesController.clear();
      _isGearModalVisible = true;
    });
  }

  // ✅ FIXED: Updated _markAttendance method to properly pass notes
  Future<void> _markAttendance(
    int athleteId,
    String status, {
    String? notes,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final date = _getDateForSelectedDay();
      if (date.isEmpty) {
        _showError(l10n.sessionDateNotAvailable);
        return;
      }

      print('🔄 Marking attendance:');
      print('   - Athlete ID: $athleteId');
      print('   - Status: $status');
      print('   - Date: $date');
      print('   - Notes: $notes'); // Debug: Check if notes are being passed

      final result = await ApiService.markWeeklyAttendance(
        athleteId: athleteId,
        sessionDate: date,
        status: status,
        notes: notes, // ✅ FIXED: Pass notes parameter to API
      );

      if (result['success']) {
        await _loadAttendance();
        HapticFeedback.lightImpact();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.attendanceMarked(status)),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      } else {
        _showError(l10n.failedToUpdateAttendance(result['error'] ?? ''));
      }
    } catch (e) {
      _showError(l10n.failedToUpdateAttendanceGeneral);
    }
  }

  void _handleGearModalYes() {
    setState(() {
      _missedGearAnswer = 'yes';
    });
  }

  void _handleGearModalNo() {
    if (_currentAthleteId != null) {
      _markAttendance(_currentAthleteId!, 'present');
      _closeGearModal();
    }
  }

  void _handleGearModalSubmit() {
    final l10n = AppLocalizations.of(context)!;
    if (_gearNotesController.text.trim().isEmpty) {
      _showError(l10n.enterMissedGearNotes);
      return;
    }

    if (_currentAthleteId != null) {
      _markAttendance(
        _currentAthleteId!,
        'present',
        notes: _gearNotesController.text.trim(),
      );
      _closeGearModal();
    }
  }

  void _closeGearModal() {
    setState(() {
      _isGearModalVisible = false;
      _currentAthleteId = null;
      _missedGearAnswer = null;
      _missedGearNotes = '';
      _gearNotesController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text(
          l10n.weeklyAttendanceTitle,
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
            onPressed: _isLoading ? null : _loadUserProfileAndSessionDates,
            tooltip: l10n.refresh,
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Day Tabs
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF007AFF), Color(0xFF0066CC)],
                  ),
                ),
                child: Row(
                  children:
                      _days.asMap().entries.map((entry) {
                        final index = entry.key;
                        final day = entry.value;
                        final isSelected = _selectedDay == index;
                        final hasDate = index < _sessionDates.length;

                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap:
                                    hasDate
                                        ? () {
                                          setState(() {
                                            _selectedDay = index;
                                          });
                                          _loadAttendance();
                                          HapticFeedback.lightImpact();
                                        }
                                        : null,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        !hasDate
                                            ? Colors.white.withOpacity(0.05)
                                            : isSelected
                                            ? Colors.white.withOpacity(0.2)
                                            : Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        isSelected && hasDate
                                            ? Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            )
                                            : null,
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        day,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color:
                                              hasDate
                                                  ? Colors.white
                                                  : Colors.white.withOpacity(
                                                    0.5,
                                                  ),
                                          fontWeight:
                                              isSelected && hasDate
                                                  ? FontWeight.w600
                                                  : FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                      if (hasDate) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          _sessionDates[index]
                                              .split('-')
                                              .sublist(1)
                                              .join('/'),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.8,
                                            ),
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),

              // Error Message
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(color: Colors.red[600]),
                        ),
                      ),
                    ],
                  ),
                ),

              // Content
              Expanded(
                child:
                    _isLoading
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(
                                color: Color(0xFF007AFF),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.loadingAttendance,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                        : _attendance.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.group_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.noAthletesFound,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _sessionDates.isEmpty
                                    ? l10n.noSessionDatesConfigured
                                    : l10n.noAttendanceDataForDay,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _attendance.length,
                          itemBuilder: (context, index) {
                            final athlete = _attendance[index];
                            return _buildAthleteCard(athlete, l10n);
                          },
                        ),
              ),
            ],
          ),

          if (_isGearModalVisible) _buildGearModal(l10n),
        ],
      ),
    );
  }

  Widget _buildAthleteCard(
    Map<String, dynamic> athlete,
    AppLocalizations l10n,
  ) {
    final status = athlete['status']?.toString() ?? '';
    final notes = athlete['notes']?.toString() ?? '';
    final athleteId = athlete['athlete_id'] as int;
    final athleteName =
        athlete['athlete_name']?.toString() ?? l10n.unknownAthlete;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    athleteName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (notes.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Text(
                        l10n.missedGear(notes),
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                  if (status.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            status == 'present'
                                ? Colors.green.withOpacity(0.1)
                                : status == 'absent'
                                ? Colors.red.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l10n.status(status.toUpperCase()),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color:
                              status == 'present'
                                  ? Colors.green[700]
                                  : status == 'absent'
                                  ? Colors.red[700]
                                  : Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () => _onPressPresent(athleteId),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color:
                          status == 'present'
                              ? Colors.green[500]
                              : Colors.grey[100],
                      shape: BoxShape.circle,
                      border:
                          status == 'present'
                              ? null
                              : Border.all(color: Colors.green[300]!, width: 2),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.check,
                        color:
                            status == 'present'
                                ? Colors.white
                                : Colors.green[600],
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _markAttendance(athleteId, 'absent'),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color:
                          status == 'absent'
                              ? Colors.red[500]
                              : Colors.grey[100],
                      shape: BoxShape.circle,
                      border:
                          status == 'absent'
                              ? null
                              : Border.all(color: Colors.red[300]!, width: 2),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.close,
                        color:
                            status == 'absent' ? Colors.white : Colors.red[600],
                        size: 20,
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

  Widget _buildGearModal(AppLocalizations l10n) {
    if (!_isGearModalVisible) return const SizedBox.shrink();

    return Material(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.didMissGear,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              if (_missedGearAnswer == null) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleGearModalYes,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[600],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          l10n.yes,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleGearModalNo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          l10n.no,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else if (_missedGearAnswer == 'yes') ...[
                TextField(
                  controller: _gearNotesController,
                  maxLines: 3,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: l10n.typeMissedGearHere,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF007AFF)),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleGearModalSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          l10n.submit,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _closeGearModal,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red[600],
                          side: BorderSide(color: Colors.red[600]!),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          l10n.cancel,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
