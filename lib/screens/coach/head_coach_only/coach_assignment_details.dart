import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../services/api_service.dart';

class CoachAssignmentDetailScreen extends StatefulWidget {
  final Map<String, dynamic> coach;

  const CoachAssignmentDetailScreen({Key? key, required this.coach})
    : super(key: key);

  @override
  State<CoachAssignmentDetailScreen> createState() =>
      _CoachAssignmentDetailScreenState();
}

class _CoachAssignmentDetailScreenState
    extends State<CoachAssignmentDetailScreen> {
  List<Map<String, dynamic>> _allBranches = [];
  Set<int> _assignedBranchIds = {};
  bool _isLoading = true;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final allBranchesResult = await ApiService.getAllBranches();
      final assignmentsResult = await ApiService.getCoachAssignments(
        widget.coach['id'],
      );

      if (allBranchesResult['success'] && assignmentsResult['success']) {
        setState(() {
          _allBranches = List<Map<String, dynamic>>.from(
            allBranchesResult['data'] ?? [],
          );
          _assignedBranchIds = Set<int>.from(
            (assignmentsResult['data'] ?? []).map((b) => b['id']),
          );
        });
      } else {
        _showError(AppLocalizations.of(context)!.failedToLoadBranches);
      }
    } catch (e) {
      _showError(AppLocalizations.of(context)!.errorLoadingBranches);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _assignOrUnassignBranch(int branchId, bool assigned) async {
    if (_isUpdating) return;
    setState(() => _isUpdating = true);

    try {
      if (assigned) {
        final result = await ApiService.unassignCoachFromBranch(
          widget.coach['id'],
          branchId,
        );
        if (result['success']) {
          setState(() => _assignedBranchIds.remove(branchId));
          _showSuccess(AppLocalizations.of(context)!.branchUnassigned);
        } else {
          _showError(AppLocalizations.of(context)!.failedToUnassign);
        }
      } else {
        final result = await ApiService.assignCoachToBranch(
          widget.coach['id'],
          branchId,
        );
        if (result['success']) {
          setState(() => _assignedBranchIds.add(branchId));
          _showSuccess(AppLocalizations.of(context)!.branchAssigned);
        } else {
          _showError(AppLocalizations.of(context)!.failedToAssign);
        }
      }
      HapticFeedback.lightImpact();
    } catch (e) {
      _showError(AppLocalizations.of(context)!.failedToAssign);
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.coach['name'] ?? l10n.coachAssignmentsTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue[600], // Changed from purple
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFFF0F2F5),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(color: Colors.blue[400]),
              ) // Changed from purple
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      l10n.branchesAssignedTo(widget.coach['name'] ?? ''),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child:
                        _allBranches.isEmpty
                            ? Center(
                              child: Text(
                                l10n.noBranchesFound,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                            : ListView.builder(
                              itemCount: _allBranches.length,
                              itemBuilder: (context, index) {
                                final branch = _allBranches[index];
                                final assigned = _assignedBranchIds.contains(
                                  branch['id'],
                                );
                                return ListTile(
                                  title: Text(
                                    branch['name'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  trailing: ElevatedButton(
                                    onPressed:
                                        _isUpdating
                                            ? null
                                            : () => _assignOrUnassignBranch(
                                              branch['id'],
                                              assigned,
                                            ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          assigned
                                              ? Colors.red
                                              : Colors
                                                  .blue, // 'Colors.blue' for aqua theme
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      minimumSize: const Size(80, 36),
                                    ),
                                    child:
                                        _isUpdating
                                            ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                            : Text(
                                              assigned
                                                  ? l10n.unassignButton
                                                  : l10n.assignButton,
                                            ),
                                  ),
                                );
                              },
                            ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20, top: 8),
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                      label: Text(l10n.backButton),
                    ),
                  ),
                ],
              ),
    );
  }
}
