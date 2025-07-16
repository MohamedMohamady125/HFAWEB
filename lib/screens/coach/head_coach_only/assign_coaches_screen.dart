import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../services/api_service.dart';
import 'coach_assignment_details.dart';

class AssignCoachesScreen extends StatefulWidget {
  const AssignCoachesScreen({super.key});

  @override
  State<AssignCoachesScreen> createState() => _AssignCoachesScreenState();
}

class _AssignCoachesScreenState extends State<AssignCoachesScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _coaches = [];
  bool _isLoading = true;
  String _searchQuery = '';
  Map<String, dynamic> _assignmentStats = {};

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadAllData();
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

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);

    try {
      final coachesResult = await ApiService.getAllCoaches();
      final statsResult = await ApiService.getCoachAssignmentStats();

      if (coachesResult['success']) {
        setState(() {
          _coaches = List<Map<String, dynamic>>.from(
            coachesResult['data'] ?? [],
          );
        });
      } else {
        _showError(
          AppLocalizations.of(
            context,
          )!.failedToLoadCoaches(coachesResult['error']),
        );
      }

      if (statsResult['success']) {
        setState(() {
          _assignmentStats = Map<String, dynamic>.from(
            statsResult['data'] ?? {},
          );
        });
      } else {
        _showError(
          AppLocalizations.of(context)!.failedToLoadStats(statsResult['error']),
        );
      }

      _fadeController.forward();
      _slideController.forward();
    } catch (e) {
      print('❌ Error loading data: $e');
      _showError(AppLocalizations.of(context)!.failedToLoadData);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToCoachAssignment(Map<String, dynamic> coach) {
    HapticFeedback.lightImpact();
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => CoachAssignmentDetailScreen(coach: coach),
          ),
        )
        .then((_) => _loadAllData());
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

  List<Map<String, dynamic>> get _filteredCoaches {
    if (_searchQuery.isEmpty) return _coaches;

    return _coaches.where((coach) {
      final name = coach['name']?.toString().toLowerCase() ?? '';
      final email = coach['email']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  String _getAssignmentStatus(Map<String, dynamic> coach) {
    final assignments = coach['assignments'] as List<dynamic>? ?? [];
    final l10n = AppLocalizations.of(context)!;
    if (assignments.isEmpty) return l10n.unassignedStat;
    if (assignments.length == 1) return '1 ${l10n.assignedStat}';
    return '${assignments.length} ${l10n.multiBranchStat}';
  }

  Color _getStatusColor(Map<String, dynamic> coach) {
    final assignments = coach['assignments'] as List<dynamic>? ?? [];
    if (assignments.isEmpty) return Colors.orange;
    if (assignments.length == 1) return Colors.green;
    return Colors
        .blue; // Keeping this blue as it already fits "aqua blue light"
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text(
          l10n.assignCoachesTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.blue[600], // Changed from purple
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadAllData,
            tooltip: l10n.refreshTooltip,
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.blue[400],
                    ), // Changed from purple
                    const SizedBox(height: 16),
                    Text(
                      l10n.loadingCoaches,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              )
              : FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildContent(),
                ),
              ),
    );
  }

  Widget _buildContent() {
    final l10n = AppLocalizations.of(context)!;
    if (_coaches.isEmpty && _searchQuery.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue[50], // Changed from purple
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.assignment_ind_outlined,
                size: 64,
                color: Colors.blue[300], // Changed from purple
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noCoachesFound,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noCoachesAvailable,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final filteredCoaches = _filteredCoaches;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue[600]!,
                Colors.blue[400]!,
              ], // Changed from purple
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.assignment_ind,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.coachAssignmentsTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          l10n.coachesInSystem(
                            _assignmentStats['total_coaches'] ?? 0,
                          ),
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
                  hintText: l10n.searchCoachesHint,
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
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildQuickStat(
                  l10n.assignedStat,
                  _assignmentStats['assigned_coaches'] ?? 0,
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildQuickStat(
                  l10n.unassignedStat,
                  _assignmentStats['unassigned_coaches'] ?? 0,
                  Colors.orange,
                ),
              ),
              Expanded(
                child: _buildQuickStat(
                  l10n.multiBranchStat,
                  _assignmentStats['multi_branch_coaches'] ?? 0,
                  Colors.blue,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child:
              filteredCoaches.isEmpty && _searchQuery.isNotEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_off_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noCoachesForQuery(_searchQuery),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredCoaches.length,
                    itemBuilder: (context, index) {
                      final coach = filteredCoaches[index];
                      return _buildCoachCard(coach, index);
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildQuickStat(String title, int count, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoachCard(Map<String, dynamic> coach, int index) {
    final assignmentStatus = _getAssignmentStatus(coach);
    final statusColor = _getStatusColor(coach);
    final assignments = coach['assignments'] as List<dynamic>? ?? [];

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
          onTap: () => _navigateToCoachAssignment(coach),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue[400]!,
                        Colors.blue[600]!,
                      ], // Changed from purple
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      (coach['name'] ?? 'C')[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coach['name'] ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        coach['email'] ?? 'No email',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.assignment_ind,
                                  size: 14,
                                  color: statusColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  assignmentStatus,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (assignments.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'ID: ${coach['id']}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (assignments.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 4,
                          children:
                              assignments
                                  .take(3)
                                  .map<Widget>(
                                    (assignment) => Chip(
                                      label: Text(
                                        assignment['branch_name'] ?? 'Branch',
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                      backgroundColor:
                                          Colors
                                              .blue[50], // Changed from purple
                                      side: BorderSide(
                                        color: Colors.blue[200]!,
                                      ), // Changed from purple
                                      padding: EdgeInsets.zero,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  )
                                  .toList()
                                ..addAll(
                                  assignments.length > 3
                                      ? [
                                        Chip(
                                          label: Text(
                                            '+${assignments.length - 3}',
                                            style: const TextStyle(
                                              fontSize: 10,
                                            ),
                                          ),
                                          backgroundColor: Colors.grey[100],
                                          padding: EdgeInsets.zero,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ]
                                      : [],
                                ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50], // Changed from purple
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.assignment_ind,
                    color: Colors.blue[600], // Changed from purple
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
}
