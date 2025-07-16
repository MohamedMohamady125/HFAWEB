import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../services/api_service.dart';

class RegistrationRequestsScreen extends StatefulWidget {
  const RegistrationRequestsScreen({super.key});

  @override
  State<RegistrationRequestsScreen> createState() =>
      _RegistrationRequestsScreenState();
}

class _RegistrationRequestsScreenState extends State<RegistrationRequestsScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;
  bool _isProcessing = false;

  // ✅ NEW: Add user profile and branch context
  Map<String, dynamic>? _userProfile;
  String? _currentBranchName;
  String? _userRole;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserProfileAndRequests(); // ✅ NEW: Load user profile first
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

  // ✅ NEW: Load user profile first to get branch context
  Future<void> _loadUserProfileAndRequests() async {
    setState(() => _isLoading = true);

    try {
      print('🔄 Loading user profile to get branch context...');
      final profileResult = await ApiService.getUserProfile();

      if (profileResult['success']) {
        _userProfile = profileResult['data'];
        _currentBranchName = _userProfile?['branch_name'];
        _userRole = _userProfile?['role'];

        print('✅ User Profile Loaded:');
        print('   - Role: $_userRole');
        print('   - Branch: $_currentBranchName');
        print('   - Branch ID: ${_userProfile?['branch_id']}');

        // Now load the registration requests
        await _loadRequests();
      } else {
        _showError('Failed to load user profile: ${profileResult['error']}');
      }
    } catch (e) {
      print('❌ Error loading user profile: $e');
      _showError('Failed to load user information: $e');
    }
  }

  Future<void> _loadRequests() async {
    try {
      print('🔄 Loading registration requests for branch: $_currentBranchName');
      final result = await ApiService.getRegistrationRequests();

      print('🔄 Registration requests result: $result');

      if (result['success']) {
        final requestsList = List<Map<String, dynamic>>.from(
          result['data'] ?? [],
        );

        // ✅ DEBUG: Print each request to verify branch filtering
        print(
          '🔍 DEBUG - Found ${requestsList.length} requests for $_currentBranchName:',
        );
        for (int i = 0; i < requestsList.length; i++) {
          final request = requestsList[i];
          print('   Request ${i + 1}:');
          print('     - ID: ${request['id']}');
          print('     - Name: ${request['athlete_name']}');
          print('     - Email: ${request['email']}');
          print('     - Branch: ${request['branch_name']}');
          print('     - Submitted: ${request['submitted_at']}');

          // ✅ VALIDATION: Check if request branch matches user branch
          final requestBranch = request['branch_name'];
          if (requestBranch != _currentBranchName) {
            print(
              '   ⚠️ WARNING: Request for different branch! Expected: $_currentBranchName, Got: $requestBranch',
            );
          } else {
            print(
              '   ✅ Request correctly matches user branch: $_currentBranchName',
            );
          }
        }

        // ✅ ADDITIONAL CLIENT-SIDE FILTERING (just in case)
        // Filter requests to only show ones for the current user's branch
        final filteredRequests =
            requestsList.where((request) {
              final requestBranch = request['branch_name'];
              return requestBranch == _currentBranchName;
            }).toList();

        if (filteredRequests.length != requestsList.length) {
          print(
            '⚠️ CLIENT-SIDE FILTER: Removed ${requestsList.length - filteredRequests.length} requests not for $_currentBranchName branch',
          );
        }

        setState(() {
          _requests = filteredRequests;
        });

        _fadeController.forward();
        _slideController.forward();
      } else {
        _showError(
          'Failed to load requests: ${result['error'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      print('❌ Error loading requests: $e');
      _showError('Failed to load registration requests: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _approveRequest(
    int requestId,
    String athleteName,
    String branchName,
  ) async {
    // ✅ VALIDATION: Ensure request is for current branch
    if (branchName != _currentBranchName) {
      _showError('Cannot approve request for different branch: $branchName');
      return;
    }

    final confirmed = await _showConfirmDialog(
      'Approve Registration',
      'Are you sure you want to approve the registration for $athleteName for $_currentBranchName branch?',
      confirmText: 'Approve',
      confirmColor: const Color(0xFF007AFF),
    );
    if (!confirmed) return;

    setState(() => _isProcessing = true);

    try {
      print(
        '🔄 Approving request ID: $requestId for $athleteName (Branch: $branchName)',
      );
      final result = await ApiService.approveRegistrationRequest(requestId);

      if (result['success']) {
        _showSuccess(
          'Registration approved successfully for $_currentBranchName branch!',
        );
        HapticFeedback.lightImpact();
        setState(() {
          _requests.removeWhere((request) => request['id'] == requestId);
        });
      } else {
        _showError(
          'Failed to approve registration: ${result['error'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      print('❌ Error approving request: $e');
      _showError('Failed to approve registration: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _rejectRequest(
    int requestId,
    String athleteName,
    String branchName,
  ) async {
    // ✅ VALIDATION: Ensure request is for current branch
    if (branchName != _currentBranchName) {
      _showError('Cannot reject request for different branch: $branchName');
      return;
    }

    final confirmed = await _showConfirmDialog(
      'Reject Registration',
      'Are you sure you want to reject the registration for $athleteName for $_currentBranchName branch? This action cannot be undone.',
      confirmText: 'Reject',
      confirmColor: Colors.red,
    );
    if (!confirmed) return;

    setState(() => _isProcessing = true);

    try {
      print(
        '🔄 Rejecting request ID: $requestId for $athleteName (Branch: $branchName)',
      );
      final result = await ApiService.rejectRegistrationRequest(requestId);

      if (result['success']) {
        _showSuccess('Registration rejected.');
        HapticFeedback.lightImpact();
        setState(() {
          _requests.removeWhere((request) => request['id'] == requestId);
        });
      } else {
        _showError(
          'Failed to reject registration: ${result['error'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      print('❌ Error rejecting request: $e');
      _showError('Failed to reject registration: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
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

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF007AFF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<bool> _showConfirmDialog(
    String title,
    String content, {
    required String confirmText,
    required Color confirmColor,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(title),
                content: Text(content),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      confirmText,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
        ) ??
        false;
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid Date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Registration Requests',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            // ✅ NEW: Show current branch in subtitle
            if (_currentBranchName != null)
              Text(
                _currentBranchName!,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        backgroundColor: const Color(0xFF007AFF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadUserProfileAndRequests,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Color(0xFF007AFF)),
                    const SizedBox(height: 16),
                    Text(
                      _userProfile == null
                          ? 'Loading user profile...'
                          : 'Loading requests for $_currentBranchName...',
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
    if (_requests.isEmpty) {
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
                Icons.check_circle_outline,
                size: 64,
                color: Color(0xFF007AFF),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Pending Requests',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentBranchName != null
                  ? 'No registration requests for $_currentBranchName branch.'
                  : 'All registration requests have been processed.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // ✅ ENHANCED: Branch context header
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF007AFF), Color(0xFF0066CC)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.pending_actions, color: Colors.white, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentBranchName != null
                          ? '$_currentBranchName Branch'
                          : 'Pending Requests',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${_requests.length} athletes waiting for approval',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // ✅ NEW: Role indicator
              if (_userRole != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _userRole!.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _requests.length,
            itemBuilder: (context, index) {
              final request = _requests[index];
              return _buildRequestCard(request, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request, int index) {
    final requestBranch = request['branch_name'] ?? 'Unknown Branch';
    final athleteName = request['athlete_name'] ?? 'Unknown';
    final isCorrectBranch = requestBranch == _currentBranchName;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            !isCorrectBranch
                ? Border.all(
                  color: Colors.orange,
                  width: 2,
                ) // ✅ Warning border for wrong branch
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ WARNING: Show warning if wrong branch
            if (!isCorrectBranch)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange[700], size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'WARNING: This request is for $requestBranch, not $_currentBranchName',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Header with athlete info
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: Color(0xFF007AFF),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        athleteName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Submitted ${_formatDate(request['submitted_at'])}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'PENDING',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ✅ ENHANCED: Branch Information Display with validation
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    isCorrectBranch
                        ? const Color(0xFF007AFF).withOpacity(0.05)
                        : Colors.orange.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      isCorrectBranch
                          ? const Color(0xFF007AFF).withOpacity(0.2)
                          : Colors.orange.withOpacity(0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 18,
                    color:
                        isCorrectBranch
                            ? const Color(0xFF007AFF)
                            : Colors.orange[700],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Branch: ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  Expanded(
                    child: Text(
                      requestBranch,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color:
                            isCorrectBranch
                                ? const Color(0xFF007AFF)
                                : Colors.orange[700],
                      ),
                    ),
                  ),
                  if (isCorrectBranch)
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: const Color(0xFF007AFF),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Contact Information
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          request['email'] ?? 'No Email',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          request['phone'] ?? 'No Phone',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Action Buttons - Only enabled for correct branch
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        (_isProcessing || !isCorrectBranch)
                            ? null
                            : () => _rejectRequest(
                              request['id'],
                              athleteName,
                              requestBranch,
                            ),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          !isCorrectBranch ? Colors.grey : Colors.red[600],
                      side: BorderSide(
                        color:
                            !isCorrectBranch ? Colors.grey : Colors.red[600]!,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed:
                        (_isProcessing || !isCorrectBranch)
                            ? null
                            : () => _approveRequest(
                              request['id'],
                              athleteName,
                              requestBranch,
                            ),
                    icon:
                        _isProcessing
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Icon(Icons.check, size: 18),
                    label: Text(
                      _isProcessing
                          ? 'Processing...'
                          : !isCorrectBranch
                          ? 'Wrong Branch'
                          : 'Approve',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          !isCorrectBranch
                              ? Colors.grey
                              : const Color(0xFF007AFF),
                      foregroundColor: Colors.white,
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
}
