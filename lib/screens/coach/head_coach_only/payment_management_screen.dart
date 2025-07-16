import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // <-- import this
import '../../../services/api_service.dart';

class PaymentManagementScreen extends StatefulWidget {
  const PaymentManagementScreen({super.key});

  @override
  State<PaymentManagementScreen> createState() =>
      _PaymentManagementScreenState();
}

class _PaymentManagementScreenState extends State<PaymentManagementScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _athletes = [];
  Map<int, String> _paymentStatuses = {};
  bool _isLoading = true;
  bool _isUpdating = false;
  String _searchQuery = '';
  String? _error;
  String _selectedMonth = '';

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setCurrentMonth();
    _loadPaymentData();
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

  void _setCurrentMonth() {
    final now = DateTime.now();
    _selectedMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}-01';
  }

  Future<void> _loadPaymentData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final profileResponse = await ApiService.getUserProfile();
      if (!profileResponse['success'] || profileResponse['data'] == null) {
        setState(() {
          _error = 'error';
        });
        return;
      }

      final branchId = profileResponse['data']['branch_id']?.toString();
      if (branchId == null) {
        setState(() {
          _error = 'error';
        });
        return;
      }

      final result = await ApiService.getPaymentSummary(int.parse(branchId));
      if (result['success']) {
        final records = List<Map<String, dynamic>>.from(
          result['data']['records'] ?? [],
        );

        final athletes = <Map<String, dynamic>>[];
        final statuses = <int, String>{};

        for (final record in records) {
          final athleteId = record['athlete_id'] as int;
          final athleteName = record['athlete_name']?.toString() ?? '';
          final statusMap = Map<String, String>.from(record['statuses'] ?? {});
          final currentStatus = statusMap[_selectedMonth] ?? 'pending';
          athletes.add({'id': athleteId, 'name': athleteName, 'email': ''});
          statuses[athleteId] = currentStatus;
        }

        setState(() {
          _athletes = athletes;
          _paymentStatuses = statuses;
        });

        _fadeController.forward();
        _slideController.forward();
      } else {
        setState(() {
          _error = result['error']?.toString() ?? 'error';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'error';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updatePaymentStatus(int athleteId, String status) async {
    if (_isUpdating) return;
    setState(() => _isUpdating = true);

    try {
      final result = await ApiService.markPayment(
        athleteId: athleteId,
        sessionDate: _selectedMonth,
        status: status,
      );
      if (result['success']) {
        setState(() {
          _paymentStatuses[athleteId] = status;
        });
        HapticFeedback.lightImpact();
        _showSuccessSnackBar(
          AppLocalizations.of(context)!.paymentStatusUpdated,
        );
      } else {
        _showErrorSnackBar(
          AppLocalizations.of(
            context,
          )!.failedToUpdatePaymentStatus(result['error']?.toString() ?? ''),
        );
      }
    } catch (e) {
      _showErrorSnackBar(
        AppLocalizations.of(context)!.failedToUpdatePaymentStatus(e.toString()),
      );
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF007AFF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
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
      final query = _searchQuery.toLowerCase();
      return name.contains(query);
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return const Color(0xFF007AFF);
      case 'late':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Icons.check_circle;
      case 'late':
        return Icons.warning;
      case 'pending':
      default:
        return Icons.schedule;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final paidCount = _paymentStatuses.values.where((s) => s == 'paid').length;
    final pendingCount =
        _paymentStatuses.values.where((s) => s == 'pending').length;
    final lateCount = _paymentStatuses.values.where((s) => s == 'late').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text(
          loc.paymentManagement,
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
            onPressed: _isLoading ? null : _loadPaymentData,
            tooltip: loc.refresh,
          ),
        ],
      ),
      body: _buildBody(loc, paidCount, pendingCount, lateCount),
    );
  }

  Widget _buildBody(
    AppLocalizations loc,
    int paidCount,
    int pendingCount,
    int lateCount,
  ) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFF007AFF)),
            const SizedBox(height: 16),
            Text(loc.loadingPaymentData, style: const TextStyle(fontSize: 16)),
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
              child: const Icon(
                Icons.error_outline,
                size: 64,
                color: Color(0xFF007AFF),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              loc.errorLoadingPaymentData,
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
              onPressed: _loadPaymentData,
              icon: const Icon(Icons.refresh),
              label: Text(loc.retry),
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
              child: const Icon(
                Icons.group_outlined,
                size: 64,
                color: Color(0xFF007AFF),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              loc.noAthletesFound,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              loc.noAthletesRegisteredBranch,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final filteredAthletes = _filteredAthletes;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            // Header with stats and search
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF007AFF), Color(0xFF0066CC)],
                ),
              ),
              child: Column(
                children: [
                  // Stats Row
                  Row(
                    children: [
                      const Icon(Icons.payment, color: Colors.white, size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.monthlyPaymentStatus,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${loc.paid}: $paidCount • ${loc.pending}: $pendingCount • ${loc.late}: $lateCount',
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
                      hintText: loc.searchAthletes,
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
            // Athletes List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredAthletes.length,
                itemBuilder: (context, index) {
                  final athlete = filteredAthletes[index];
                  return _buildAthletePaymentCard(athlete, loc);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAthletePaymentCard(
    Map<String, dynamic> athlete,
    AppLocalizations loc,
  ) {
    final athleteId = athlete['id'] ?? 0;
    final athleteName = athlete['name'] ?? loc.unknown;
    final currentStatus = _paymentStatuses[athleteId] ?? 'pending';

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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Athlete Info Row
            Row(
              children: [
                // Profile Avatar
                Container(
                  width: 50,
                  height: 50,
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
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Athlete Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        athleteName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            _getStatusIcon(currentStatus),
                            size: 16,
                            color: _getStatusColor(currentStatus),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${loc.current} ${loc._getStatusText(currentStatus).toUpperCase()}',
                            style: TextStyle(
                              fontSize: 12,
                              color: _getStatusColor(currentStatus),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Payment Status Buttons
            Row(
              children: [
                // Paid Button
                Expanded(
                  child: _buildStatusButton(
                    label: loc.paid,
                    icon: Icons.check_circle,
                    color: const Color(0xFF007AFF),
                    isSelected: currentStatus == 'paid',
                    onTap: () => _updatePaymentStatus(athleteId, 'paid'),
                  ),
                ),
                const SizedBox(width: 8),
                // Pending Button
                Expanded(
                  child: _buildStatusButton(
                    label: loc.pending,
                    icon: Icons.schedule,
                    color: Colors.orange,
                    isSelected: currentStatus == 'pending',
                    onTap: () => _updatePaymentStatus(athleteId, 'pending'),
                  ),
                ),
                const SizedBox(width: 8),
                // Late Button
                Expanded(
                  child: _buildStatusButton(
                    label: loc.late,
                    icon: Icons.warning,
                    color: Colors.red,
                    isSelected: currentStatus == 'late',
                    onTap: () => _updatePaymentStatus(athleteId, 'late'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isUpdating ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? color : Colors.grey[600],
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? color : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper extension for localization of status text
extension on AppLocalizations {
  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return paid;
      case 'pending':
        return pending;
      case 'late':
        return late;
      default:
        return status;
    }
  }
}
