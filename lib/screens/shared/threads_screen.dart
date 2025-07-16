import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ThreadsScreen extends StatefulWidget {
  const ThreadsScreen({super.key});
  @override
  State<ThreadsScreen> createState() => _ThreadsScreenState();
}

class _ThreadsScreenState extends State<ThreadsScreen>
    with AutomaticKeepAliveClientMixin {
  bool _isLoading = true;
  List<dynamic> _threads = [];
  List<dynamic> _messages = [];
  String? _userBranchId;
  String? _userType;
  String? _userName;
  int? _selectedThreadId;
  String _selectedThreadTitle = '';
  String? _error;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeAndLoadData();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeAndLoadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _getUserInfo();
      await _loadThreads();
      if (_threads.isNotEmpty) {
        _selectThread(_threads[0]['id'], _threads[0]['title']);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getUserInfo() async {
    try {
      _userType = await ApiService.getUserType();
      final result = await ApiService.getUserProfile();
      if (result['success']) {
        final userData = result['data'];
        _userBranchId = userData['branch_id']?.toString();
        _userName = userData['name'] ?? AppLocalizations.of(context)!.you;
      }
    } catch (e) {
      throw Exception(AppLocalizations.of(context)!.failedToGetUserProfile);
    }
  }

  Future<void> _loadThreads() async {
    try {
      if (_userBranchId != null) {
        final result = await ApiService.getThreadsForBranch(_userBranchId!);
        if (result['success']) {
          setState(() {
            _threads = result['data'] ?? [];
          });
        } else {
          throw Exception(
            result['error'] ??
                AppLocalizations.of(context)!.failedToLoadThreads,
          );
        }
      } else {
        throw Exception(
          AppLocalizations.of(context)!.userBranchInfoNotAvailable,
        );
      }
    } catch (e) {
      throw Exception(AppLocalizations.of(context)!.networkErrorLoadingThreads);
    }
  }

  Future<void> _selectThread(int threadId, String title) async {
    setState(() {
      _selectedThreadId = threadId;
      _selectedThreadTitle = title;
      _messages = [];
    });
    await _loadMessages(threadId);
  }

  Future<void> _loadMessages(int threadId) async {
    try {
      final result = await ApiService.getThreadPosts(threadId);
      if (result['success']) {
        final posts = result['data'] as List;
        final sortedPosts = List<Map<String, dynamic>>.from(posts);
        sortedPosts.sort((a, b) {
          final dateA = DateTime.parse(a['created_at']);
          final dateB = DateTime.parse(b['created_at']);
          return dateA.compareTo(dateB);
        });
        setState(() {
          _messages = sortedPosts;
        });
        _scrollToBottom();
      } else {
        _showError(
          result['error'] ?? AppLocalizations.of(context)!.failedToLoadMessages,
        );
      }
    } catch (e) {
      _showError(AppLocalizations.of(context)!.networkErrorLoadingMessages);
    }
  }

  Future<void> _sendMessage() async {
    if (!_isCoach || _selectedThreadId == null) return;
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final optimisticMessage = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'user_id': _userName,
      'author': _userName,
      'message': message,
      'created_at': DateTime.now().toIso8601String(),
      'sent': false,
    };

    setState(() {
      _messages.add(optimisticMessage);
      _messageController.clear();
      _isSending = true;
    });

    _scrollToBottom();

    try {
      final result = await ApiService.postToThread(_selectedThreadId!, message);
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
    } finally {
      setState(() => _isSending = false);
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
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  bool get _isCoach => _userType == 'coach' || _userType == 'head_coach';

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_isLoading) return _buildLoadingState();
    if (_error != null) return _buildErrorState();
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
                    if (_threads.isEmpty)
                      Expanded(child: _buildEmptyState())
                    else if (_selectedThreadId == null)
                      Expanded(child: _buildSelectThreadPrompt())
                    else ...[
                      Expanded(
                        child:
                            _messages.isEmpty
                                ? _buildNoMessagesState()
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
                                          _buildDateLabel(
                                            message['created_at'],
                                          ),
                                        _buildMessageBubble(message),
                                      ],
                                    );
                                  },
                                ),
                      ),
                      if (_isCoach && _selectedThreadId != null)
                        _buildInputWidget()
                      else if (!_isCoach && _selectedThreadId != null)
                        _buildReadOnlyIndicator(),
                    ],
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
                  '💬 ${AppLocalizations.of(context)!.branchChat}',
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
                      AppLocalizations.of(context)!.loadingThreads,
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
                        onPressed: _initializeAndLoadData,
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
      child: Row(
        children: [
          if (_threads.length > 1)
            GestureDetector(
              onTap: _showThreadSelector,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.swap_horiz, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      AppLocalizations.of(context)!.switchThread,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '💬 ${AppLocalizations.of(context)!.branchChat}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (_selectedThreadTitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    _selectedThreadTitle,
                    style: const TextStyle(
                      color: Color(0xFFE5E7EB),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  HapticFeedback.lightImpact();
                  await _initializeAndLoadData();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              if (_isCoach) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _showCreateThreadDialog,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ],
          ),
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
              _userBranchId != null
                  ? AppLocalizations.of(context)!.branchDiscussion
                  : AppLocalizations.of(context)!.unknownBranch,
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
          const Icon(Icons.forum, size: 64, color: Color(0xFF9CA3AF)),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noChatThreadsYet,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isCoach
                ? AppLocalizations.of(context)!.createFirstDiscussion
                : AppLocalizations.of(context)!.coachHasNotCreatedThreads,
            style: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
            textAlign: TextAlign.center,
          ),
          if (_isCoach) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _showCreateThreadDialog,
              icon: const Icon(Icons.add_comment, color: Colors.white),
              label: Text(
                AppLocalizations.of(context)!.createThread,
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
        ],
      ),
    );
  }

  Widget _buildSelectThreadPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.message, size: 64, color: Color(0xFF9CA3AF)),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.selectAThread,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.tapSwitchToChoose,
            style: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoMessagesState() {
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
            _isCoach
                ? AppLocalizations.of(context)!.startConversation
                : AppLocalizations.of(context)!.waitForCoach,
            style: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
            textAlign: TextAlign.center,
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
    final isMine = message['author'] == _userName;
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isMine ? const Color(0xFF007AFF) : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(16).copyWith(
              bottomLeft:
                  isMine ? const Radius.circular(16) : const Radius.circular(4),
              bottomRight:
                  isMine ? const Radius.circular(4) : const Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMine)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    message['author'] ?? AppLocalizations.of(context)!.unknown,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isMine ? Colors.white70 : const Color(0xFF475569),
                    ),
                  ),
                ),
              Text(
                message['message'] ?? '',
                style: TextStyle(
                  fontSize: 15,
                  color: isMine ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timeStr,
                    style: TextStyle(
                      fontSize: 10,
                      color: isMine ? Colors.white60 : const Color(0xFF64748B),
                    ),
                  ),
                  if (isMine) ...[
                    const SizedBox(width: 4),
                    Text(
                      statusIndicator,
                      style: TextStyle(
                        fontSize: 10,
                        color:
                            message['sent'] == null
                                ? Colors.red.shade200
                                : Colors.white60,
                      ),
                    ),
                  ],
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
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.typeAMessage,
                  hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                style: const TextStyle(fontSize: 16, color: Color(0xFF1E293B)),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                onTap: _scrollToBottom,
              ),
            ),
          ),
          const SizedBox(width: 10),
          _isSending
              ? const CircularProgressIndicator(color: Color(0xFF007AFF))
              : GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF007AFF),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF007AFF),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 24),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFD97706), size: 20),
          const SizedBox(width: 8),
          Text(
            AppLocalizations.of(context)!.readOnlyMode,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFFD97706),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showThreadSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.selectChatThread,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _threads.length,
                  itemBuilder: (context, index) {
                    final thread = _threads[index];
                    final isSelected = _selectedThreadId == thread['id'];
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? const Color(0xFF007AFF).withOpacity(0.1)
                                : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected
                                  ? const Color(0xFF007AFF)
                                  : const Color(0xFFE2E8F0),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? const Color(0xFF007AFF)
                                    : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.chat_bubble_outline,
                            color:
                                isSelected
                                    ? Colors.white
                                    : const Color(0xFF007AFF),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          thread['title'] ??
                              AppLocalizations.of(context)!.untitledThread,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        subtitle: Text(
                          "${AppLocalizations.of(context)!.created}: ${_formatDate(thread['created_at'] ?? '')}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        trailing:
                            isSelected
                                ? const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF007AFF),
                                  size: 20,
                                )
                                : null,
                        onTap: () {
                          Navigator.of(context).pop();
                          _selectThread(thread['id'], thread['title']);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        tileColor:
                            isSelected
                                ? const Color(0xFF007AFF).withOpacity(0.1)
                                : Colors.transparent,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }

  void _showCreateThreadDialog() {
    if (!_isCoach) return;
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              AppLocalizations.of(context)!.createNewThread,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            content: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.threadTitleHint,
                  hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: const TextStyle(fontSize: 16, color: Color(0xFF1E293B)),
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  AppLocalizations.of(context)!.cancel,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final title = titleController.text.trim();
                  if (title.isNotEmpty && _userBranchId != null) {
                    Navigator.of(context).pop();
                    await _createThread(title);
                  } else {
                    _showError(
                      AppLocalizations.of(context)!.threadTitleCannotBeEmpty,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  AppLocalizations.of(context)!.create,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _createThread(String title) async {
    try {
      final result = await ApiService.createThread(_userBranchId!, title);
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.threadCreatedSuccessfully,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(20),
          ),
        );
        await _loadThreads();
        if (_threads.isNotEmpty) {
          _selectThread(_threads.last['id'], _threads.last['title']);
        }
      } else {
        _showError(AppLocalizations.of(context)!.failedToCreateThread);
      }
    } catch (e) {
      _showError(AppLocalizations.of(context)!.anErrorOccurred);
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now().toLocal();
      final difference = now.difference(date);
      if (difference.inDays == 0 && now.day == date.day) {
        return '${AppLocalizations.of(context)!.todayAt} ${_formatMessageTime(dateStr)}';
      } else if (difference.inDays == 1 && now.day - date.day == 1) {
        return '${AppLocalizations.of(context)!.yesterdayAt} ${_formatMessageTime(dateStr)}';
      } else if (difference.inDays < 7) {
        return '${DateFormat('EEE').format(date)}, ${_formatMessageTime(dateStr)}';
      } else {
        return DateFormat('dd/MM/yy').format(date);
      }
    } catch (e) {
      return '';
    }
  }

  String _formatMessageTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return DateFormat('h:mm a').format(date);
    } catch (e) {
      return '';
    }
  }
}
