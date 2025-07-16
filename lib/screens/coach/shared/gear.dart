import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/api_service.dart';
import '../../../services/branch_notifier.dart'; // ✅ CORRECT IMPORT
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GearScreen extends StatefulWidget {
  const GearScreen({super.key});

  @override
  State<GearScreen> createState() => _GearScreenState();
}

class _GearScreenState extends State<GearScreen>
    with AutomaticKeepAliveClientMixin {
  Map<String, dynamic>? _branch;
  Map<String, dynamic>? _selectedBranch; // For head coaches to select branch
  List<Map<String, dynamic>> _availableBranches = []; // For head coaches
  String _gearText = '';
  bool _isLoading = true;
  bool _isUpdating = false;
  bool _canEdit = false;
  bool _isHeadCoach = false;
  String? _error;

  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeData();

    // ✅ FIXED: Use singleton instance directly
    BranchNotifier().addListener(_onBranchChanged);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();

    // ✅ FIXED: Remove listener properly
    BranchNotifier().removeListener(_onBranchChanged);
    super.dispose();
  }

  // ✅ Handle branch changes
  void _onBranchChanged() {
    print('🔄 Gear screen detected branch change');
    if (mounted) {
      // Reload data for new branch
      _initializeData();
    }
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final profileResult = await ApiService.getUserProfile();
      if (!profileResult['success']) {
        throw Exception('Failed to load user profile');
      }

      final userData = profileResult['data'];
      final userRole = userData['role'];

      // ✅ Use branch from notifier if available (for switched branches)
      int? branchId = BranchNotifier().currentBranchId ?? userData['branch_id'];
      String? branchName =
          BranchNotifier().currentBranchName ?? userData['branch_name'];

      _canEdit = userRole == 'head_coach' || userRole == 'coach';
      _isHeadCoach = userRole == 'head_coach';

      if (_isHeadCoach) {
        // Head coaches can select any branch
        await _loadAllBranches();

        // Set default branch to current branch (switched or assigned)
        if (branchId != null) {
          _branch = {
            'id': branchId,
            'name': branchName ?? AppLocalizations.of(context)!.unknownBranch,
          };
          _selectedBranch = _branch;
        } else if (_availableBranches.isNotEmpty) {
          // If no assigned branch, default to first available branch
          _selectedBranch = _availableBranches.first;
          _branch = _selectedBranch;
        }
      } else {
        // Regular coaches and athletes use their assigned/current branch
        if (branchId == null) {
          throw Exception('No branch assigned to account');
        }

        _branch = {
          'id': branchId,
          'name': branchName ?? AppLocalizations.of(context)!.unknownBranch,
        };
        _selectedBranch = _branch;
      }

      if (_selectedBranch != null) {
        await _loadGearForBranch(_selectedBranch!['id']);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAllBranches() async {
    try {
      final result = await ApiService.getAllBranchesForGear();
      if (result['success']) {
        setState(() {
          _availableBranches = List<Map<String, dynamic>>.from(
            result['branches'] ?? [],
          );
        });
      }
    } catch (e) {
      print('Error loading branches: $e');
    }
  }

  Future<void> _loadGearForBranch(int branchId) async {
    try {
      final gearResult = await ApiService.getGearForBranch(branchId.toString());
      if (gearResult['success']) {
        final gearData = gearResult['data'];
        final content = gearData['message'] ?? '';

        setState(() {
          _gearText = content;
          _textController.text = content;
          _isLoading = false;
        });
      } else {
        setState(() {
          _gearText = '';
          _textController.text = '';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _onBranchChangedManually(Map<String, dynamic> branch) async {
    setState(() {
      _selectedBranch = branch;
      _isLoading = true;
    });

    await _loadGearForBranch(branch['id']);
  }

  Future<void> _updateGear() async {
    if (!_canEdit || _selectedBranch == null || _gearText.trim().isEmpty)
      return;

    setState(() => _isUpdating = true);

    try {
      final result = await ApiService.postGear(
        _selectedBranch!['id'].toString(),
        _gearText.trim(),
      );

      if (result['success']) {
        HapticFeedback.lightImpact();
        _showSuccess(AppLocalizations.of(context)!.gearUpdateSuccess);
      } else {
        _showError(
          '${AppLocalizations.of(context)!.gearUpdateFailed}: ${result['error']}',
        );
      }
    } catch (e) {
      _showError('${AppLocalizations.of(context)!.gearUpdateFailed}: $e');
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  void _onTextChanged(String text) {
    setState(() {
      _gearText = text;
    });
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildBranchInfo(),
            Expanded(child: _buildGearEditor()),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(showLoading: true),
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF007AFF)),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Text(
                AppLocalizations.of(context)!.loadingGearInformation,
                style: const TextStyle(fontSize: 16, color: Color(0xFF64748B)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.warning,
                          color: Color(0xFFEF4444),
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.error,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error ??
                            AppLocalizations.of(context)!.unknownErrorOccurred,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF64748B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _initializeData,
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        label: Text(
                          AppLocalizations.of(context)!.retry,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007AFF),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader({bool showLoading = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF007AFF), Color(0xFF0056CC)],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '🎒 ${AppLocalizations.of(context)!.gearInformationTitle}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildBranchInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Current Branch Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Color(0xFF3B82F6),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedBranch?['name'] ??
                        AppLocalizations.of(context)!.unknownBranch,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                // Branch selector for head coaches
                if (_isHeadCoach && _availableBranches.isNotEmpty)
                  PopupMenuButton<Map<String, dynamic>>(
                    icon: const Icon(
                      Icons.swap_horiz,
                      color: Color(0xFF3B82F6),
                    ),
                    onSelected: _onBranchChangedManually,
                    itemBuilder:
                        (context) =>
                            _availableBranches.map((branch) {
                              return PopupMenuItem<Map<String, dynamic>>(
                                value: branch,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color:
                                          _selectedBranch?['id'] == branch['id']
                                              ? const Color(0xFF007AFF)
                                              : Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        branch['name'] ?? 'Unknown Branch',
                                        style: TextStyle(
                                          fontWeight:
                                              _selectedBranch?['id'] ==
                                                      branch['id']
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                          color:
                                              _selectedBranch?['id'] ==
                                                      branch['id']
                                                  ? const Color(0xFF007AFF)
                                                  : Colors.black87,
                                        ),
                                      ),
                                    ),
                                    if (_selectedBranch?['id'] == branch['id'])
                                      const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Color(0xFF007AFF),
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                  ),
              ],
            ),
          ),

          // Head Coach indicator
          if (_isHeadCoach) const SizedBox(height: 8),
          if (_isHeadCoach)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF007AFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.admin_panel_settings,
                    size: 14,
                    color: Color(0xFF007AFF),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Head Coach - Can post to any branch',
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF007AFF),
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

  Widget _buildGearEditor() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Color(0xFF3B82F6),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.editGearTitle,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  AppLocalizations.of(context)!.gearDescription,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 20),

                // Text Input
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 2,
                    ),
                    color:
                        _canEdit
                            ? const Color(0xFFFAFAFA)
                            : const Color(0xFFF1F5F9),
                  ),
                  child: Column(
                    children: [
                      Container(
                        constraints: const BoxConstraints(
                          minHeight: 150,
                          maxHeight: 300,
                        ),
                        child: TextField(
                          controller: _textController,
                          onChanged: _onTextChanged,
                          enabled: _canEdit,
                          maxLines: null,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1E293B),
                            height: 1.5,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                AppLocalizations.of(context)!.gearHintText,
                            hintStyle: const TextStyle(
                              color: Color(0xFF9CA3AF),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(14),
                            bottomRight: Radius.circular(14),
                          ),
                          border: Border(
                            top: BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${_gearText.length}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Update Button or Read-only Message
                if (_canEdit)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          (_isUpdating || _gearText.trim().isEmpty)
                              ? null
                              : _updateGear,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            (_isUpdating || _gearText.trim().isEmpty)
                                ? const Color(0xFF9CA3AF)
                                : const Color(0xFF007AFF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation:
                            (_isUpdating || _gearText.trim().isEmpty) ? 0 : 4,
                        shadowColor: const Color(0xFF007AFF).withOpacity(0.25),
                      ),
                      child:
                          _isUpdating
                              ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    AppLocalizations.of(context)!.updating,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                              : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.updateGearButton,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBBF24),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.visibility,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.readOnlyMessage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
