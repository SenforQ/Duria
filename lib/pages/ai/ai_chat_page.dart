import 'package:flutter/material.dart';

import '../../services/wallet_service.dart';
import '../../services/zhipu_ai_service.dart';
import '../../wallet_insufficient_helper.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({
    super.key,
    this.coachName,
    this.coachAvatarUrl,
    this.presetQuestions,
  });

  final String? coachName;
  final String? coachAvatarUrl;
  final List<String>? presetQuestions;

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ZhipuAiService _service = ZhipuAiService();
  final List<_ChatMessage> _messages = <_ChatMessage>[
    const _ChatMessage(
      role: _MessageRole.assistant,
      text: 'Hi! I am your AI fitness assistant. How can I help you today?',
    ),
  ];
  bool _sending = false;
  static const List<String> _defaultPresetQuestions = <String>[
    'Can you make me a 7-day beginner workout plan?',
    'What should I eat after strength training?',
    'How can I reduce belly fat safely?',
    'How many rest days do I need each week?',
    'Can you suggest a 20-minute home workout?',
  ];

  List<String> get _presetQuestions =>
      widget.presetQuestions == null || widget.presetQuestions!.isEmpty
      ? _defaultPresetQuestions
      : widget.presetQuestions!;

  void _clearMessages() {
    setState(() {
      _messages
        ..clear()
        ..add(
          const _ChatMessage(
            role: _MessageRole.assistant,
            text:
                'Hi! I am your AI fitness assistant. How can I help you today?',
          ),
        );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    final bool paid = await WalletService.instance.trySpendCoins(
      WalletService.aiChatMessageCost,
    );
    if (!paid) {
      if (mounted) {
        showInsufficientCoinsSnackBar(context);
      }
      return;
    }

    setState(() {
      _messages.add(_ChatMessage(role: _MessageRole.user, text: text));
      _sending = true;
      _controller.clear();
    });
    _scrollToBottom();

    try {
      final List<Map<String, String>> conversation =
          _messages.map((m) => m.toApiMessage()).toList();
      final reply = await _service.sendConversation(conversation);
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(
            role: _MessageRole.assistant,
            text: reply,
          ),
        );
      });
    } catch (_) {
      await WalletService.instance.addCoins(WalletService.aiChatMessageCost);
      if (!mounted) return;
      setState(() {
        _messages.add(
          const _ChatMessage(
            role: _MessageRole.assistant,
            text:
                'Sorry, I cannot reply right now. Please check your network or API configuration.',
          ),
        );
      });
    } finally {
      if (mounted) {
        setState(() => _sending = false);
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.coachName == null ? 'AI Chat' : '${widget.coachName} Chat',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _sending ? null : _clearMessages,
            child: const Text('Clear'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message.role == _MessageRole.user;
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isUser)
                          CircleAvatar(
                            radius: 16,
                            backgroundImage: widget.coachAvatarUrl == null
                                ? const AssetImage('assets/user_default.png')
                                    as ImageProvider
                                : NetworkImage(widget.coachAvatarUrl!),
                            backgroundColor: colorScheme.surfaceContainerHighest,
                          ),
                        if (!isUser) const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          constraints: const BoxConstraints(maxWidth: 260),
                          decoration: BoxDecoration(
                            color: isUser
                                ? colorScheme.primary
                                : colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            message.text,
                            style: TextStyle(
                              color:
                                  isUser ? colorScheme.onPrimary : Colors.black87,
                              fontSize: 14,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presetQuestions.map((question) {
                return ActionChip(
                  label: Text(question),
                  onPressed: _sending
                      ? null
                      : () {
                          _controller.text = question;
                          _send();
                        },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 4),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText: widget.coachName == null
                            ? 'Ask your fitness question...'
                            : 'Ask ${widget.coachName}...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _sending ? null : _send,
                    style: FilledButton.styleFrom(
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    child: _sending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Send'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _MessageRole {
  user,
  assistant,
}

class _ChatMessage {
  const _ChatMessage({
    required this.role,
    required this.text,
  });

  final _MessageRole role;
  final String text;

  Map<String, String> toApiMessage() {
    return <String, String>{
      'role': role == _MessageRole.user ? 'user' : 'assistant',
      'content': text,
    };
  }
}
