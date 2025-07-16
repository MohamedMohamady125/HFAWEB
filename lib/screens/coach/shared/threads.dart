import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // <-- i18n import

class ThreadsScreen extends StatefulWidget {
  const ThreadsScreen({super.key});

  @override
  State<ThreadsScreen> createState() => _ThreadsScreenState();
}

class _ThreadsScreenState extends State<ThreadsScreen>
    with AutomaticKeepAliveClientMixin {
  Map<String, dynamic>? _user;
  String? _branchName;
  List<Map<String, dynamic>> _messages = [];
  String _messageInput = '';
  bool _isLoading = true;
  int? _threadId;
  String? _error;

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get user profile
      final userResult = await ApiService.getUserProfile();
      if (!userResult['success']) throw Exception('Failed to get user profile');

      final userData = userResult['data'];
      setState(() => _user = userData);

      if (userData['branch_id'] == null) {
        throw Exception('No branch assigned');
      }

      // Get branch details
      final branchResult = await ApiService.getBranchDetails(
        userData['branch_id'],
      );
      if (branchResult['success']) {
        setState(() => _branchName = branchResult['data']['name']);
      }

      // Get threads for branch
      final threadsResult = await ApiService.getThreadsForBranch(
        userData['branch_id'].toString(),
      );
      if (!threadsResult['success'] ||
          (threadsResult['data'] as List).isEmpty) {
        setState(() {
          _threadId = null;
          _messages = [];
        });
        return;
      }

      final threads = threadsResult['data'] as List;
      final currentThreadId = threads[0]['id'];
      setState(() => _threadId = currentThreadId);

      // Get messages for the thread
      final postsResult = await ApiService.getThreadPosts(currentThreadId);
      if (postsResult['success']) {
        final posts = postsResult['data'] as List;
        final sortedPosts = List<Map<String, dynamic>>.from(posts);
        sortedPosts.sort((a, b) {
          final dateA = DateTime.parse(a['created_at']);
          final dateB = DateTime.parse(b['created_at']);
          return dateA.compareTo(dateB);
        });

        setState(() => _messages = sortedPosts);
        _scrollToBottom();
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _messages = [];
        _user = null;
        _branchName = null;
        _threadId = null;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _postMessage() async {
    if (_messageInput.trim().isEmpty || _threadId == null || _user == null)
      return;

    final optimisticMessage = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'user_id': _user!['id'],
      'author': _user!['name'],
      'message': _messageInput,
      'created_at': DateTime.now().toIso8601String(),
      'sent': false,
    };

    setState(() {
      _messages.add(optimisticMessage);
      _messageInput = '';
      _messageController.clear();
    });

    _scrollToBottom();

    try {
      final result = await ApiService.postToThread(
        _threadId!,
        optimisticMessage['message'] as String,
      );

      if (result['success']) {
        setState(() {
          final index = _messages.indexWhere(
            (msg) => msg['id'] == optimisticMessage['id'],
          );
          if (index != -1) {
            _messages[index]['sent'] = true;
          }
        });
        HapticFeedback.lightImpact();
      } else {
        setState(() {
          final index = _messages.indexWhere(
            (msg) => msg['id'] == optimisticMessage['id'],
          );
          if (index != -1) {
            _messages[index]['sent'] = null;
          }
        });
        _showError(AppLocalizations.of(context)!.failedToSendMessage);
      }
    } catch (e) {
      setState(() {
        final index = _messages.indexWhere(
          (msg) => msg['id'] == optimisticMessage['id'],
        );
        if (index != -1) {
          _messages[index]['sent'] = null;
        }
      });
      _showError(AppLocalizations.of(context)!.anErrorOccurred);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Expanded(
                      child:
                          _messages.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                itemCount: _messages.length,
                                itemBuilder: (context, index) {
                                  final message = _messages[index];
                                  final showDateLabel = _shouldShowDateLabel(
                                    index,
                                  );

                                  return Column(
                                    children: [
                                      if (showDateLabel)
                                        _buildDateLabel(message['created_at']),
                                      _buildMessageBubble(message),
                                    ],
                                  );
                                },
                              ),
                    ),
                    _buildInputWidget(),
                  ],
                ),
              ),
            ),
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF007AFF),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.branchGroupTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Color(0xFF3B82F6)),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.loadingMessages,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
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
                      Row(
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
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.error,
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
                      Text(
                        _error ?? AppLocalizations.of(context)!.anErrorOccurred,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF64748B),
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _fetchData,
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        label: Text(
                          AppLocalizations.of(context)!.retry,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
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
                          elevation: 4,
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF007AFF),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Text(
            '💬 ${AppLocalizations.of(context)!.branchGroupTitle}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (_branchName != null) ...[
            const SizedBox(height: 2),
            Text(
              _branchName!,
              style: const TextStyle(
                color: Color(0xFFE5E7EB),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBranchInfo() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
            child: const Icon(Icons.people, color: Color(0xFF3B82F6), size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _branchName ?? AppLocalizations.of(context)!.unknownBranch,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.of(context)!.online,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Color(0xFF9CA3AF),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noMessagesYet,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.startConversation,
            style: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }

  bool _shouldShowDateLabel(int index) {
    if (index == 0) return true;

    final currentDate = DateTime.parse(_messages[index]['created_at']);
    final previousDate = DateTime.parse(_messages[index - 1]['created_at']);

    return !_isSameDay(currentDate, previousDate);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Widget _buildDateLabel(String dateStr) {
    final date = DateTime.parse(dateStr);
    final formattedDate = DateFormat('EEEE, MMM d').format(date);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            formattedDate,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isMine = message['user_id'] == _user?['id'];
    final messageTime = DateTime.parse(message['created_at']);
    final timeStr = DateFormat('h:mm a').format(messageTime);

    String statusIndicator = '';
    if (isMine) {
      final sent = message['sent'];
      statusIndicator =
          sent == true
              ? '✓✓'
              : sent == false
              ? '✓'
              : '!';
    }

    return Container(
      margin: EdgeInsets.only(
        left: isMine ? 64 : 16,
        right: isMine ? 16 : 64,
        top: 4,
        bottom: 4,
      ),
      child: Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isMine ? const Color(0xFF007AFF) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isMine ? 18 : 4),
              bottomRight: Radius.circular(isMine ? 4 : 18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message['message'] ?? '',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.25,
                  color: isMine ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '$timeStr $statusIndicator',
                    style: TextStyle(
                      fontSize: 11,
                      color:
                          isMine
                              ? Colors.white.withOpacity(0.7)
                              : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
              ),
              child: TextField(
                controller: _messageController,
                onChanged: (value) => setState(() => _messageInput = value),
                onSubmitted: (_) => _postMessage(),
                maxLines: null,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.typeAMessage,
                  hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  counterText: '',
                ),
                style: const TextStyle(fontSize: 16, color: Color(0xFF1E293B)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _messageInput.trim().isEmpty ? null : _postMessage,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color:
                    _messageInput.trim().isEmpty
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF007AFF),
                borderRadius: BorderRadius.circular(24),
                boxShadow:
                    _messageInput.trim().isEmpty
                        ? null
                        : [
                          BoxShadow(
                            color: const Color(0xFF007AFF).withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
