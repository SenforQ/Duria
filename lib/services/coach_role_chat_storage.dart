import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CoachRoleChatStorage {
  CoachRoleChatStorage._();
  static final CoachRoleChatStorage instance = CoachRoleChatStorage._();

  static const String _keyPrefix = 'duria_coach_role_chat_v1_';

  String _key(String coachId) => '$_keyPrefix$coachId';

  Future<String?> loadUserMessage(String coachId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(coachId));
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final text = map['userMessage'] as String?;
      if (text == null || text.isEmpty) return null;
      return text;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUserMessage(String coachId, String message) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key(coachId),
      jsonEncode(<String, dynamic>{'userMessage': message}),
    );
  }
}
