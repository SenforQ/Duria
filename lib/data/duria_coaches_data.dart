import 'dart:convert';

import 'package:flutter/services.dart';

enum CoachFilterKind {
  all,
  realPerson,
  ai,
  custom,
}

extension CoachFilterKindLabel on CoachFilterKind {
  String get label => switch (this) {
        CoachFilterKind.all => 'All',
        CoachFilterKind.realPerson => 'Real coaches',
        CoachFilterKind.ai => 'AI coaches',
        CoachFilterKind.custom => 'Custom',
      };
}

enum CoachSourceKind {
  bundled,
  custom,
}

class BundledCoachProfile {
  const BundledCoachProfile({
    required this.id,
    required this.category,
    required this.nickname,
    required this.tagline,
    required this.skills,
    required this.avatarAsset,
    required this.galleryAssets,
    required this.videoAsset,
  });

  final String id;
  final CoachFilterKind category;
  final String nickname;
  final String tagline;
  final List<String> skills;
  final String avatarAsset;
  final List<String> galleryAssets;
  final String videoAsset;
}

BundledCoachProfile _coachFromJson(Map<String, dynamic> j) {
  return BundledCoachProfile(
    id: j['id'] as String,
    category: CoachFilterKind.realPerson,
    nickname: j['nickname'] as String,
    tagline: j['tagline'] as String? ?? '',
    skills: List<String>.from(j['skills'] as List<dynamic>? ?? <dynamic>[]),
    avatarAsset: j['avatar'] as String,
    galleryAssets: List<String>.from(j['gallery'] as List<dynamic>? ?? <dynamic>[]),
    videoAsset: j['video'] as String,
  );
}

class DuriaCoachesManifest {
  DuriaCoachesManifest._();

  static const String assetPath = 'assets/Duria_Resource/coaches_manifest.json';

  static List<BundledCoachProfile>? _cache;

  static Future<List<BundledCoachProfile>> loadBundledCoaches() async {
    if (_cache != null) {
      return _cache!;
    }
    final String raw = await rootBundle.loadString(assetPath);
    final Map<String, dynamic> root = jsonDecode(raw) as Map<String, dynamic>;
    final List<dynamic> arr = root['coaches'] as List<dynamic>;
    _cache = arr
        .map((dynamic e) => _coachFromJson(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }

  static void clearCacheForTests() {
    _cache = null;
  }
}
