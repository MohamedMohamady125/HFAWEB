// Create this file: lib/services/branch_notifier.dart

import 'package:flutter/foundation.dart';

class BranchNotifier extends ChangeNotifier {
  static final BranchNotifier _instance = BranchNotifier._internal();
  factory BranchNotifier() => _instance;
  BranchNotifier._internal();

  int? _currentBranchId;
  String? _currentBranchName;

  int? get currentBranchId => _currentBranchId;
  String? get currentBranchName => _currentBranchName;

  void updateBranch(int branchId, String branchName) {
    if (_currentBranchId != branchId) {
      _currentBranchId = branchId;
      _currentBranchName = branchName;
      print('🔄 Branch changed to: $branchName (ID: $branchId)');
      notifyListeners(); // This will trigger updates in listening widgets
    }
  }

  void clearBranch() {
    _currentBranchId = null;
    _currentBranchName = null;
    notifyListeners();
  }
}
