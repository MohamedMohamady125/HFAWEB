import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../services/api_service.dart';
import '../../auth/login_screen.dart';
import '../shared/registration_requests_screen.dart';
import '../shared/weekly_attendance_screen.dart';
import '../shared/monthly_attendance_screen.dart';
import '../shared/threads.dart';
import '../shared/gear.dart';
import '../coach_profile_screen.dart';

class CoachHomeScreen extends StatefulWidget {
  const CoachHomeScreen({super.key});

  @override
  State<CoachHomeScreen> createState() => _CoachHomeScreenState();
}

class _CoachHomeScreenState extends State<CoachHomeScreen> {
  Map<String, dynamic>? _profile;
  List<dynamic> _assignedBranches = [];
  Map<String, dynamic>? _currentBranch;
  bool _isLoading = true;
  String? _error;
  bool _isLoadingBranches = false;

  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _loadProfile();
    _loadAssignedBranches();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await ApiService.getUserProfile();
      if (result['success']) {
        setState(() {
          _profile = result['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = AppLocalizations.of(context)!.failedToLoadProfile;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = AppLocalizations.of(context)!.failedToLoadProfileData;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAssignedBranches() async {
    setState(() {
      _isLoadingBranches = true;
    });

    try {
      final result = await ApiService.getCoachAssignedBranches();
      if (result['success']) {
        setState(() {
          _assignedBranches = result['data']['assigned_branches'] ?? [];
          _currentBranch = result['data']['current_branch'];
          _isLoadingBranches = false;
        });
      } else {
        setState(() {
          _isLoadingBranches = false;
        });
        print('Failed to load assigned branches: ${result['error']}');
      }
    } catch (e) {
      setState(() {
        _isLoadingBranches = false;
      });
      print('Exception loading assigned branches: $e');
    }
  }

  Future<void> _switchBranch(Map<String, dynamic> branch) async {
    setState(() {
      _isLoadingBranches = true;
    });

    try {
      final result = await ApiService.setCoachActiveBranch(branch['id']);
      if (result['success']) {
        setState(() {
          _currentBranch = branch;
          _isLoadingBranches = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Switched to ${branch['name']} branch'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );

        // Refresh profile to update current branch context
        _loadProfile();
      } else {
        setState(() {
          _isLoadingBranches = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to switch branch: ${result['error']}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoadingBranches = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error switching branch: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _showBranchSwitcher() {
    if (_assignedBranches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No branches assigned to you'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const Icon(Icons.swap_horiz, color: Colors.deepPurple),
                      const SizedBox(width: 12),
                      const Text(
                        'Switch Branch',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (_isLoadingBranches)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                ),

                // Current branch indicator
                if (_currentBranch != null)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.deepPurple.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.deepPurple),
                        const SizedBox(width: 8),
                        Text(
                          'Current: ${_currentBranch!['name']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Branches list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _assignedBranches.length,
                    itemBuilder: (context, index) {
                      final branch = _assignedBranches[index];
                      final isCurrentBranch =
                          _currentBranch != null &&
                          branch['id'] == _currentBranch!['id'];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          tileColor:
                              isCurrentBranch
                                  ? Colors.deepPurple.withOpacity(0.1)
                                  : Colors.grey[50],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color:
                                  isCurrentBranch
                                      ? Colors.deepPurple
                                      : Colors.grey[300]!,
                              width: isCurrentBranch ? 2 : 1,
                            ),
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  isCurrentBranch
                                      ? Colors.deepPurple
                                      : Colors.grey[400],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.business,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            branch['name'] ?? 'Unknown Branch',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color:
                                  isCurrentBranch
                                      ? Colors.deepPurple
                                      : Colors.black87,
                            ),
                          ),
                          subtitle:
                              branch['address'] != null
                                  ? Text(
                                    branch['address'],
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  )
                                  : null,
                          trailing:
                              isCurrentBranch
                                  ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.deepPurple,
                                  )
                                  : const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                          onTap:
                              isCurrentBranch || _isLoadingBranches
                                  ? null
                                  : () {
                                    Navigator.pop(context);
                                    _switchBranch(branch);
                                  },
                        ),
                      );
                    },
                  ),
                ),

                // Footer
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  String get _firstName {
    if (_profile == null || _profile!['name'] == null) return '';
    return _profile!['name'].split(' ')[0];
  }

  String get _currentBranchDisplay {
    if (_currentBranch != null) {
      return _currentBranch!['name'] ?? 'Unknown Branch';
    }
    return _profile?['branch_name'] ?? 'No Branch';
  }

  void _navigateToRegistrationRequests() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RegistrationRequestsScreen(),
      ),
    );
  }

  void _navigateToWeeklyAttendance() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const WeeklyAttendanceScreen()),
    );
  }

  void _navigateToMonthlyAttendance() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const MonthlyAttendanceScreen()),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.comingSoonFeature(feature)),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF0F2F5),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.deepPurple),
              const SizedBox(height: 16),
              Text(l10n.loadingDashboard, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF0F2F5),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(fontSize: 16, color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _loadProfile, child: Text(l10n.retry)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          _buildHomeScreenContent(l10n),
          const ThreadsScreen(),
          const GearScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat),
            label: l10n.threads,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.inventory),
            label: l10n.gear,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_circle),
            label: l10n.profile,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple[700],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 10,
      ),
    );
  }

  Widget _buildHomeScreenContent(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 60),
          Text(
            'Welcome $_firstName',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            l10n.coachDashboard,
            style: const TextStyle(fontSize: 15, color: Color(0xFF666666)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Branch Switcher Card
          _buildBranchSwitcherCard(),

          const SizedBox(height: 25),
          _buildToolsGrid(l10n),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildBranchSwitcherCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.deepPurple, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Current Branch',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (_profile?['role'] == 'head_coach')
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'HEAD COACH',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  _currentBranchDisplay,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              // Only show switch button for regular coaches or head coaches with multiple branches
              if (_profile?['role'] == 'coach' ||
                  (_profile?['role'] == 'head_coach' &&
                      _assignedBranches.length > 1))
                ElevatedButton.icon(
                  onPressed: _isLoadingBranches ? null : _showBranchSwitcher,
                  icon:
                      _isLoadingBranches
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.swap_horiz, size: 16),
                  label: const Text('Switch'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    minimumSize: const Size(0, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
            ],
          ),
          if (_assignedBranches.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'You have access to ${_assignedBranches.length} branches',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildToolsGrid(AppLocalizations l10n) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        _buildToolCard(
          title: l10n.registrationRequests,
          onTap: _navigateToRegistrationRequests,
          color: Colors.green,
          icon: '📝',
        ),
        _buildToolCard(
          title: l10n.weeklyAttendance,
          onTap: _navigateToWeeklyAttendance,
          color: Colors.teal,
          icon: '📊',
        ),
        _buildToolCard(
          title: l10n.monthlyAttendanceCalendar,
          onTap: _navigateToMonthlyAttendance,
          color: Colors.green,
          isAttendanceCalendar: true,
          icon: '📅',
        ),
      ],
    );
  }

  Widget _buildToolCard({
    required String title,
    required VoidCallback onTap,
    required Color color,
    bool isAttendanceCalendar = false,
    String? icon,
  }) {
    Color backgroundColor = Colors.white;
    Color borderColor = Colors.transparent;
    Color textColor = Colors.black;
    double borderWidth = 0;

    if (isAttendanceCalendar) {
      backgroundColor = Colors.white;
      borderColor = const Color(0xFF34C759);
      borderWidth = 2;
      textColor = const Color(0xFF34C759);
    } else {
      backgroundColor = Colors.white;
      borderColor = color.withOpacity(0.5);
      borderWidth = 2;
      textColor = color;
    }

    return SizedBox(
      width: (MediaQuery.of(context).size.width - 48) / 2,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(14),
            border:
                borderWidth > 0
                    ? Border.all(color: borderColor, width: borderWidth)
                    : null,
            boxShadow: [
              BoxShadow(
                color:
                    isAttendanceCalendar
                        ? const Color(0xFF34C759).withOpacity(0.2)
                        : color.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              if (icon != null) ...[
                const SizedBox(height: 4),
                Text(icon, style: const TextStyle(fontSize: 20)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
