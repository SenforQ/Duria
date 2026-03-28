import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoachModerationService extends ChangeNotifier {
  CoachModerationService._();
  static final CoachModerationService instance = CoachModerationService._();

  static const String _keyBlacklist = 'duria_coach_ids_blacklist_v1';
  static const String _keyBlocked = 'duria_coach_ids_blocked_v1';

  final Set<String> _blacklisted = <String>{};
  final Set<String> _blocked = <String>{};

  /// Called after block/blacklist (e.g. pop to root tab).
  VoidCallback? onAfterBlockOrBlacklist;

  Set<String> _decodeSet(String? raw) {
    if (raw == null || raw.isEmpty) return <String>{};
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => e as String).toSet();
    } catch (_) {
      return <String>{};
    }
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _blacklisted
      ..clear()
      ..addAll(_decodeSet(prefs.getString(_keyBlacklist)));
    _blocked
      ..clear()
      ..addAll(_decodeSet(prefs.getString(_keyBlocked)));
  }

  Future<void> _persistBlacklist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBlacklist, jsonEncode(_blacklisted.toList()..sort()));
  }

  Future<void> _persistBlocked() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBlocked, jsonEncode(_blocked.toList()..sort()));
  }

  bool isHidden(String coachId) =>
      _blacklisted.contains(coachId) || _blocked.contains(coachId);

  Future<void> blacklistCoach(String coachId) async {
    _blacklisted.add(coachId);
    await _persistBlacklist();
    notifyListeners();
    onAfterBlockOrBlacklist?.call();
  }

  Future<void> blockCoach(String coachId) async {
    _blocked.add(coachId);
    await _persistBlocked();
    notifyListeners();
    onAfterBlockOrBlacklist?.call();
  }
}
