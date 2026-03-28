import 'dart:io';

import 'package:flutter/material.dart';

import '../../services/coach_role_chat_storage.dart';

class CoachRoleChatPage extends StatefulWidget {
  const CoachRoleChatPage({
    super.key,
    required this.coachId,
    required this.coachName,
    this.avatarAsset,
    this.avatarFile,
    this.presetQuestions,
  });

  final String coachId;
  final String coachName;
  final String? avatarAsset;
  final File? avatarFile;
  final List<String>? presetQuestions;

  @override
  State<CoachRoleChatPage> createState() => _CoachRoleChatPageState();
}

class _CoachRoleChatPageState extends State<CoachRoleChatPage> {
  static const List<String> _defaultPresets = <String>[
    'Could you share your schedule and pricing?',
    'What gear should I prepare before training?',
    'My knees are sensitive—can you adjust the plan?',
    'How many strength days do you recommend per week?',
    'Any diet tips while cutting?',
  ];

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_RoleChatLine> _lines = <_RoleChatLine>[];
  bool _hasSentUserMessage = false;

  List<String> get _presets =>
      widget.presetQuestions != null && widget.presetQuestions!.isNotEmpty
          ? widget.presetQuestions!
          : _defaultPresets;

  @override
  void initState() {
    super.initState();
    _lines.add(
      _RoleChatLine(
        fromCoach: true,
        text:
            'Hi, I am ${widget.coachName}. I coach strength and conditioning—glad to meet you. Leave a message anytime.',
      ),
    );
    _restoreSavedMessage();
  }

  Future<void> _restoreSavedMessage() async {
    final saved = await CoachRoleChatStorage.instance.loadUserMessage(widget.coachId);
    if (!mounted) return;
    if (saved != null && saved.isNotEmpty) {
      setState(() {
        _lines.add(_RoleChatLine(fromCoach: false, text: saved));
        _hasSentUserMessage = true;
      });
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
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

  Future<void> _send() async {
    if (_hasSentUserMessage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can send one message until they reply.')),
      );
      return;
    }
    final text = _controller.text.trim();
    if (text.isEmpty) {
      return;
    }

    setState(() {
      _lines.add(_RoleChatLine(fromCoach: false, text: text));
      _hasSentUserMessage = true;
      _controller.clear();
    });
    await CoachRoleChatStorage.instance.saveUserMessage(widget.coachId, text);
    if (!mounted) return;
    _scrollToBottom();
  }

  void _applyPreset(String q) {
    if (_hasSentUserMessage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can send one message until they reply.')),
      );
      return;
    }
    setState(() => _controller.text = q);
  }

  Widget _coachAvatar(ColorScheme colorScheme) {
    const double r = 16;
    if (widget.avatarAsset != null) {
      return CircleAvatar(
        radius: r,
        backgroundImage: AssetImage(widget.avatarAsset!),
        backgroundColor: colorScheme.surfaceContainerHighest,
      );
    }
    final f = widget.avatarFile;
    if (f != null && f.existsSync()) {
      return CircleAvatar(
        radius: r,
        backgroundImage: FileImage(f),
        backgroundColor: colorScheme.surfaceContainerHighest,
      );
    }
    final name = widget.coachName.trim();
    final initial = name.isEmpty
        ? '?'
        : String.fromCharCode(name.runes.first);
    return CircleAvatar(
      radius: r,
      backgroundColor: const Color(0xFF8BC34A).withValues(alpha: 0.35),
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF33691E),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final inputLocked = _hasSentUserMessage;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.coachName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _lines.length,
              itemBuilder: (context, index) {
                final line = _lines[index];
                if (line.fromCoach) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _coachAvatar(colorScheme),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            constraints: const BoxConstraints(maxWidth: 280),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              line.text,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      constraints: const BoxConstraints(maxWidth: 280),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        line.text,
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontSize: 14,
                          height: 1.35,
                        ),
                      ),
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
              children: _presets.map((question) {
                return ActionChip(
                  label: Text(question, maxLines: 2, overflow: TextOverflow.ellipsis),
                  onPressed: inputLocked ? null : () => _applyPreset(question),
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
                      readOnly: inputLocked,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText: inputLocked
                            ? 'Message sent. Waiting for a reply.'
                            : 'Type a message…',
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
                    onPressed: _send,
                    style: FilledButton.styleFrom(
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    child: const Text('Send'),
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

class _RoleChatLine {
  _RoleChatLine({required this.fromCoach, required this.text});

  final bool fromCoach;
  final String text;
}
