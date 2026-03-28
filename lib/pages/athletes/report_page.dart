import 'package:flutter/material.dart';

import '../../models/report.dart';
import '../../services/community_service.dart';

String _reportTypeLabel(ReportType t) {
  return switch (t) {
    ReportType.spam => 'Spam',
    ReportType.inappropriate => 'Inappropriate',
    ReportType.harassment => 'Harassment',
    ReportType.misinformation => 'Misinformation',
    ReportType.violence => 'Violence',
    ReportType.other => 'Other',
  };
}

class CoachReportPage extends StatefulWidget {
  const CoachReportPage({
    super.key,
    required this.coachId,
    required this.coachNickname,
  });

  final String coachId;
  final String coachNickname;

  @override
  State<CoachReportPage> createState() => _CoachReportPageState();
}

class _CoachReportPageState extends State<CoachReportPage> {
  ReportType _type = ReportType.other;
  final TextEditingController _description = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _description.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe the issue')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await CommunityService().reportContent(
        targetType: 'coach',
        targetId: widget.coachId,
        type: _type,
        description: text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report submitted. We will review it soon.')),
      );
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report coach'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            widget.coachNickname,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pick a reason and add details so we can review.',
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
          ),
          const SizedBox(height: 24),
          Text(
            'Category',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          ...ReportType.values.map((t) {
            return RadioListTile<ReportType>(
              title: Text(_reportTypeLabel(t)),
              value: t,
              groupValue: _type,
              onChanged: _submitting
                  ? null
                  : (v) {
                      if (v != null) setState(() => _type = v);
                    },
              contentPadding: EdgeInsets.zero,
            );
          }),
          const SizedBox(height: 16),
          Text(
            'Details',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _description,
            maxLines: 6,
            minLines: 4,
            enabled: !_submitting,
            decoration: InputDecoration(
              hintText: 'Describe what happened…',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _submitting
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Submit report'),
          ),
        ],
      ),
    );
  }
}
